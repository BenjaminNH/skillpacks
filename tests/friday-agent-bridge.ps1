$ErrorActionPreference = 'Stop'
$scripts = Join-Path $PSScriptRoot '..\skills\friday-agent-bridge\scripts'
$taskId = 'PB-20260918-001'

function Assert([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

function Assert-Throws([scriptblock]$Action, [string]$Message) {
    try {
        & $Action | Out-Null
    } catch {
        return
    }
    throw $Message
}

$global:SshCalls = @()
$global:ScpCalls = @()
$global:FailPattern = $null

function global:ssh {
    $global:SshCalls += ,@($args)
    $global:LASTEXITCODE = if ($global:FailPattern -and $args[1] -match $global:FailPattern) { 1 } else { 0 }
    if ($global:LASTEXITCODE -eq 0 -and $args[1] -match '^find ') {
        'PB-20260918-001.md'
    }
}

function global:scp {
    $global:ScpCalls += ,@($args)
    $global:LASTEXITCODE = if ($global:FailPattern -eq 'scp') { 1 } else { 0 }
}

function Reset-Mocks {
    $global:SshCalls = @()
    $global:ScpCalls = @()
    $global:FailPattern = $null
}

foreach ($file in Get-ChildItem $scripts -Filter '*.ps1') {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    Assert ($errors.Count -eq 0) "Parse failed: $($file.Name)"
}

$get = Join-Path $scripts 'Get-FridayBridgeTasks.ps1'
$claim = Join-Path $scripts 'Claim-FridayBridgeTask.ps1'
$send = Join-Path $scripts 'Send-FridayBridgeReport.ps1'
$finalize = Join-Path $scripts 'Finalize-FridayBridgeTask.ps1'

Assert ((& $get) -eq "$taskId.md") 'Pending task listing failed.'
Assert-Throws { & $get -SshAlias 'other-host' } 'Other SSH aliases must be refused.'

Reset-Mocks
Assert-Throws { & $claim -TaskId '../invalid' } 'Invalid task ID must be refused.'
Assert ($global:SshCalls.Count -eq 0) 'Invalid task ID reached SSH.'
& $claim -TaskId $taskId | Out-Null
Assert ($global:SshCalls.Count -eq 1) 'Claim should use one remote operation.'
Assert ($global:SshCalls[0][1] -match 'ln -T -- .*processing/' -and $global:SshCalls[0][1] -match '&& rm --') 'Claim lacks exclusive creation and source removal.'

Reset-Mocks
$global:FailPattern = 'ln -T'
Assert-Throws { & $claim -TaskId $taskId } 'Claim conflict must fail.'

$reportPath = [IO.Path]::GetTempFileName()
try {
    [IO.File]::WriteAllText($reportPath, "---`ntask_id: $taskId`nstatus: completed`n---`n# Result`n")
    Reset-Mocks
    & $send -TaskId $taskId -ReportPath $reportPath | Out-Null
    Assert ($global:ScpCalls.Count -eq 1) 'Valid report was not uploaded.'
    Assert ($global:SshCalls.Count -eq 2) 'Valid report should check and publish once.'
    Assert ($global:SshCalls[1][1] -match 'ln -T --') 'Report publication must be exclusive.'

    [IO.File]::WriteAllText($reportPath, "---`ncreated_at: 2026-09-18`n---`ntask_id: $taskId`nstatus: completed`n")
    Reset-Mocks
    Assert-Throws { & $send -TaskId $taskId -ReportPath $reportPath } 'Body fields must not pass front matter validation.'
    Assert ($global:SshCalls.Count -eq 0) 'Invalid report reached SSH.'

    [IO.File]::WriteAllText($reportPath, "---`ntask_id: $taskId`nstatus: completed`n---`n")
    Reset-Mocks
    $global:FailPattern = '^if ln -T'
    Assert-Throws { & $send -TaskId $taskId -ReportPath $reportPath } 'Report publication conflict must fail.'
} finally {
    [IO.File]::Delete($reportPath)
}

Reset-Mocks
& $finalize -TaskId $taskId -FinalState completed | Out-Null
Assert ($global:SshCalls.Count -eq 1) 'Finalize should use one remote operation.'
Assert ($global:SshCalls[0][1] -match 'reports/unread/' -and $global:SshCalls[0][1] -match 'reports/processed/') 'Finalize must require a report.'
Assert ($global:SshCalls[0][1] -match 'ln -T --') 'Finalize must not overwrite an existing task.'

Reset-Mocks
$global:FailPattern = 'reports/unread/'
Assert-Throws { & $finalize -TaskId $taskId } 'Missing report must prevent finalization.'

$global:LASTEXITCODE = 0
Write-Output 'Friday Agent Bridge script checks passed.'
