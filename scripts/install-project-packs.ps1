param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [Parameter(Mandatory = $true)]
    [string[]]$Packs,

    [string[]]$Targets = @("codex"),

    [switch]$Remove
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillsRoot = Join-Path $repoRoot "skills"
$projectFullPath = (Resolve-Path -LiteralPath $ProjectPath).Path
$projectSkillshareConfig = Join-Path $projectFullPath ".skillshare\config.yaml"
$projectSkillsRoot = Join-Path $projectFullPath ".skillshare\skills"
$projectPackManifestPath = Join-Path $projectFullPath ".skillshare\skillpacks.json"
$targetCsv = ($Targets -join ",")

function Get-PackSkillNames {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackPath
    )

    $skillDirs = Get-ChildItem -LiteralPath $PackPath -Directory -Force |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") }

    return @($skillDirs | Select-Object -ExpandProperty Name)
}

function Read-ProjectPackManifest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return @{
            version = 1
            packs = @{}
        }
    }

    $raw = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable

    if (-not $raw.ContainsKey("packs") -or $null -eq $raw.packs) {
        $raw.packs = @{}
    }

    return $raw
}

function Write-ProjectPackManifest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [hashtable]$Manifest
    )

    $parent = Split-Path -Parent $Path
    New-Item -ItemType Directory -Force -Path $parent | Out-Null

    $json = $Manifest | ConvertTo-Json -Depth 8
    Set-Content -LiteralPath $Path -Value $json
}

if (-not (Test-Path -LiteralPath $skillsRoot)) {
    throw "Missing skills root: $skillsRoot"
}

if (-not (Test-Path -LiteralPath $projectFullPath)) {
    throw "Missing project path: $projectFullPath"
}

$previousLocation = Get-Location

try {
    Set-Location -LiteralPath $projectFullPath

    if (-not (Test-Path -LiteralPath $projectSkillshareConfig) -and -not $Remove) {
        Write-Host "Initializing project skillshare config in $projectFullPath"
        skillshare init -p --targets $targetCsv
    }

    if (-not (Test-Path -LiteralPath $projectSkillshareConfig) -and $Remove) {
        throw "Project is not initialized for skillshare: $projectFullPath"
    }

    $manifestBefore = Read-ProjectPackManifest -Path $projectPackManifestPath
    $previousManagedSkills = @()
    foreach ($packEntry in $manifestBefore.packs.GetEnumerator()) {
        $previousManagedSkills += @($packEntry.Value)
    }
    $previousManagedSkills = @($previousManagedSkills | Sort-Object -Unique)

    $manifestAfter = @{
        version = 1
        packs = @{}
    }

    foreach ($entry in $manifestBefore.packs.GetEnumerator()) {
        $manifestAfter.packs[$entry.Key] = @($entry.Value)
    }

    foreach ($pack in $Packs) {
        $packPath = Join-Path $skillsRoot $pack

        if (-not (Test-Path -LiteralPath $packPath)) {
            throw "Unknown pack: $pack"
        }

        if ($Remove) {
            if ($manifestAfter.packs.ContainsKey($pack)) {
                Write-Host "Removing pack registration: $pack"
                $manifestAfter.packs.Remove($pack)
            } else {
                Write-Host "Pack not currently registered in project manifest: $pack"
            }
            continue
        }

        $skillNames = Get-PackSkillNames -PackPath $packPath

        if (-not $skillNames -or $skillNames.Count -eq 0) {
            Write-Host "Skipping empty pack: $pack"
            continue
        }

        Write-Host "Registering pack: $pack"
        $manifestAfter.packs[$pack] = @($skillNames)
    }

    $desiredSkillNames = @()
    foreach ($packEntry in $manifestAfter.packs.GetEnumerator()) {
        $desiredSkillNames += @($packEntry.Value)
    }
    $desiredSkillNames = @($desiredSkillNames | Sort-Object -Unique)

    $skillsToRemove = @($previousManagedSkills | Where-Object { $desiredSkillNames -notcontains $_ })
    foreach ($skillName in $skillsToRemove) {
        $destDir = Join-Path $projectSkillsRoot $skillName
        if (Test-Path -LiteralPath $destDir) {
            Write-Host "Removing $skillName from $projectSkillsRoot"
            Remove-Item -LiteralPath $destDir -Recurse -Force
        }
    }

    $skillSourceMap = @{}
    foreach ($packEntry in $manifestAfter.packs.GetEnumerator()) {
        $packName = $packEntry.Key
        $packPath = Join-Path $skillsRoot $packName

        foreach ($skillName in @($packEntry.Value)) {
            if (-not $skillSourceMap.ContainsKey($skillName)) {
                $skillSourceMap[$skillName] = Join-Path $packPath $skillName
            }
        }
    }

    foreach ($skillName in $desiredSkillNames) {
        $sourceDir = $skillSourceMap[$skillName]
        if (-not (Test-Path -LiteralPath $sourceDir)) {
            throw "Missing skill source for ${skillName}: $sourceDir"
        }

        $destDir = Join-Path $projectSkillsRoot $skillName
        Write-Host "Copying $skillName into $projectSkillsRoot"

        if (Test-Path -LiteralPath $destDir) {
            Remove-Item -LiteralPath $destDir -Recurse -Force
        }

        Copy-Item -LiteralPath $sourceDir -Destination $destDir -Recurse -Force
    }

    Write-ProjectPackManifest -Path $projectPackManifestPath -Manifest $manifestAfter

    Write-Host "Syncing project targets in $projectFullPath"
    skillshare sync
}
finally {
    Set-Location -LiteralPath $previousLocation
}
