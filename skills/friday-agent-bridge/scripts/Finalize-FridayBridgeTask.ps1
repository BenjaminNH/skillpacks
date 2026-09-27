[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z][A-Z0-9-]*-[0-9]{8}-[0-9]{3}$')]
    [string]$TaskId,
    [ValidateSet('completed', 'failed')]
    [string]$FinalState = 'completed',
    [ValidateSet('Tencent-LightHouse')]
    [string]$SshAlias = 'Tencent-LightHouse'
)

$ErrorActionPreference = 'Stop'
$root = '/home/ubuntu/friday-data/agent-bridge/tasks'
$source = "$root/processing/$TaskId.md"
$destination = "$root/$FinalState/$TaskId.md"
$unreadReport = "/home/ubuntu/friday-data/agent-bridge/reports/unread/$TaskId.md"
$processedReport = "/home/ubuntu/friday-data/agent-bridge/reports/processed/$TaskId.md"

& ssh $SshAlias "(test -s '$unreadReport' || test -s '$processedReport') && ln -T -- '$source' '$destination' && rm -- '$source'"
if ($LASTEXITCODE -ne 0) {
    throw "Unable to finalize task '$TaskId': a report is missing, or the task is unavailable or already finalized."
}

Write-Output "Task '$TaskId' moved to $FinalState."
