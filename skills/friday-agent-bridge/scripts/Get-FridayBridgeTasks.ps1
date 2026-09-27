[CmdletBinding()]
param(
    [ValidateSet('Tencent-LightHouse')]
    [string]$SshAlias = 'Tencent-LightHouse'
)

$ErrorActionPreference = 'Stop'
$remote = '/home/ubuntu/friday-data/agent-bridge/tasks/pending'

& ssh $SshAlias "find '$remote' -maxdepth 1 -type f -name '*.md' -printf '%f\n' | sort"
if ($LASTEXITCODE -ne 0) {
    throw "Unable to list Friday Agent Bridge tasks."
}
