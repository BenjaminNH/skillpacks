param(
    [string[]]$Only,
    [switch]$Reclone
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $repoRoot "upstreams\\manifest.json"

if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Missing manifest: $manifestPath"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json

if (-not $manifest.repos) {
    throw "No repos found in manifest."
}

$repos = @($manifest.repos)

if ($Only -and $Only.Count -gt 0) {
    $wanted = $Only | ForEach-Object { $_.ToLowerInvariant() }
    $repos = $repos | Where-Object {
        $wanted -contains $_.name.ToLowerInvariant() -or $wanted -contains $_.repo.ToLowerInvariant()
    }
}

foreach ($repo in $repos) {
    $targetPath = Join-Path $repoRoot $repo.path
    $parent = Split-Path -Parent $targetPath

    New-Item -ItemType Directory -Force -Path $parent | Out-Null

    if ($Reclone -and (Test-Path -LiteralPath $targetPath)) {
        Remove-Item -LiteralPath $targetPath -Recurse -Force
    }

    if (-not (Test-Path -LiteralPath $targetPath)) {
        Write-Host "Cloning $($repo.repo) -> $targetPath"
        git clone --depth 1 --filter=blob:none $repo.url $targetPath
        continue
    }

    Write-Host "Updating $($repo.repo) -> $targetPath"
    $branch = (git -C $targetPath rev-parse --abbrev-ref HEAD).Trim()
    git -C $targetPath fetch --depth 1 origin
    git -C $targetPath pull --ff-only --depth 1 origin $branch
}
