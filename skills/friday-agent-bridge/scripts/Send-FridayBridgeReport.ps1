[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z][A-Z0-9-]*-[0-9]{8}-[0-9]{3}$')]
    [string]$TaskId,
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ReportPath,
    [ValidateSet('Tencent-LightHouse')]
    [string]$SshAlias = 'Tencent-LightHouse'
)

$ErrorActionPreference = 'Stop'
$remoteRoot = '/home/ubuntu/friday-data/agent-bridge/reports/unread'
$remoteFinal = "$remoteRoot/$TaskId.md"
$remoteTemp = "$remoteRoot/.$TaskId.$([guid]::NewGuid().ToString('N')).tmp.md"

$content = Get-Content -LiteralPath $ReportPath -Raw
$frontMatch = [regex]::Match($content, '\A\uFEFF?---\r?\n(?<front>.*?)\r?\n---(?:\r?\n|\z)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
if (-not $frontMatch.Success) {
    throw 'Report must begin with YAML front matter.'
}
$frontMatter = $frontMatch.Groups['front'].Value
$taskIdFields = [regex]::Matches($frontMatter, '(?m)^task_id:[ \t]*([^\r\n]+?)[ \t]*\r?$')
if ($taskIdFields.Count -ne 1 -or $taskIdFields[0].Groups[1].Value -cne $TaskId) {
    throw "Report task_id does not match '$TaskId'."
}
$statusFields = [regex]::Matches($frontMatter, '(?m)^status:[ \t]*([^\r\n]+?)[ \t]*\r?$')
if ($statusFields.Count -ne 1 -or $statusFields[0].Groups[1].Value -cnotmatch '^(completed|needs_review|blocked|failed)$') {
    throw "Report must contain a valid status."
}

& ssh $SshAlias "test ! -e '$remoteFinal'"
if ($LASTEXITCODE -ne 0) {
    throw "A report for '$TaskId' already exists; refusing to overwrite it."
}

& scp -- (Resolve-Path -LiteralPath $ReportPath).Path "${SshAlias}:$remoteTemp"
if ($LASTEXITCODE -ne 0) {
    & ssh $SshAlias "rm -f -- '$remoteTemp'" | Out-Null
    throw "Unable to upload the temporary report."
}

& ssh $SshAlias "if ln -T -- '$remoteTemp' '$remoteFinal'; then rm -- '$remoteTemp' && test -s '$remoteFinal'; else rm -f -- '$remoteTemp'; exit 1; fi"
if ($LASTEXITCODE -ne 0) {
    throw "Unable to finalize or verify the remote report."
}

Write-Output "Uploaded and verified report: $TaskId"
