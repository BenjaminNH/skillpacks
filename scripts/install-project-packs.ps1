param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [Parameter(Mandatory = $true)]
    [string[]]$Packs,

    [string[]]$Targets = @("codex")
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillsRoot = Join-Path $repoRoot "skills"
$projectFullPath = (Resolve-Path -LiteralPath $ProjectPath).Path
$projectSkillshareConfig = Join-Path $projectFullPath ".skillshare\config.yaml"
$projectSkillsRoot = Join-Path $projectFullPath ".skillshare\skills"
$targetCsv = ($Targets -join ",")

if (-not (Test-Path -LiteralPath $skillsRoot)) {
    throw "Missing skills root: $skillsRoot"
}

if (-not (Test-Path -LiteralPath $projectFullPath)) {
    throw "Missing project path: $projectFullPath"
}

$previousLocation = Get-Location

try {
    Set-Location -LiteralPath $projectFullPath

    if (-not (Test-Path -LiteralPath $projectSkillshareConfig)) {
        Write-Host "Initializing project skillshare config in $projectFullPath"
        skillshare init -p --targets $targetCsv
    }

    foreach ($pack in $Packs) {
        $packPath = Join-Path $skillsRoot $pack

        if (-not (Test-Path -LiteralPath $packPath)) {
            throw "Unknown pack: $pack"
        }

        $skillDirs = Get-ChildItem -LiteralPath $packPath -Directory -Force |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") }

        if (-not $skillDirs -or $skillDirs.Count -eq 0) {
            Write-Host "Skipping empty pack: $pack"
            continue
        }

        foreach ($skillDir in $skillDirs) {
            $destDir = Join-Path $projectSkillsRoot $skillDir.Name
            Write-Host "Copying $($skillDir.Name) from pack $pack into $projectSkillsRoot"

            if (Test-Path -LiteralPath $destDir) {
                Remove-Item -LiteralPath $destDir -Recurse -Force
            }

            Copy-Item -LiteralPath $skillDir.FullName -Destination $destDir -Recurse -Force
        }
    }

    Write-Host "Syncing project targets in $projectFullPath"
    skillshare sync
}
finally {
    Set-Location -LiteralPath $previousLocation
}
