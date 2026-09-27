[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z][A-Z0-9-]*-[0-9]{8}-[0-9]{3}$')]
    [string]$TaskId,
    [ValidateSet('Tencent-LightHouse')]
    [string]$SshAlias = 'Tencent-LightHouse'
)

$ErrorActionPreference = 'Stop'
$root = '/home/ubuntu/friday-data/agent-bridge/tasks'
$pending = "$root/pending/$TaskId.md"
$processing = "$root/processing/$TaskId.md"

& ssh $SshAlias "ln -T -- '$pending' '$processing' && rm -- '$pending'"
if ($LASTEXITCODE -ne 0) {
    throw "Task '$TaskId' is unavailable or was already claimed."
}

Write-Output "Claimed task: $TaskId"
