param(
    [string[]]$OnlyPacks
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $repoRoot "config\\pack-manifest.json"
$upstreamsRoot = Join-Path $repoRoot "upstreams"
$skillsRoot = Join-Path $repoRoot "skills"

if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Missing pack manifest: $manifestPath"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$packs = @($manifest.packs)

if ($OnlyPacks -and $OnlyPacks.Count -gt 0) {
    $wanted = $OnlyPacks | ForEach-Object { $_.ToLowerInvariant() }
    $packs = $packs | Where-Object { $wanted -contains $_.name.ToLowerInvariant() }
}

foreach ($pack in $packs) {
    $packPath = Join-Path $skillsRoot $pack.name
    New-Item -ItemType Directory -Force -Path $packPath | Out-Null

    Get-ChildItem -LiteralPath $packPath -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne 'skillshare' } |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force }

    foreach ($skill in @($pack.skills)) {
        $sourceDir = Join-Path (Join-Path $upstreamsRoot $skill.sourceRepo) $skill.sourcePath
        $destDir = Join-Path $packPath $skill.name

        if (-not (Test-Path -LiteralPath $sourceDir)) {
            throw "Missing source path for $($skill.name): $sourceDir"
        }

        Copy-Item -LiteralPath $sourceDir -Destination $destDir -Recurse -Force
    }
}
