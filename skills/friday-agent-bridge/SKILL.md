---
name: friday-agent-bridge
description: Use when receiving, claiming, executing, or reporting tasks through Friday's SSH-based Agent Bridge at Tencent-LightHouse. Keeps Friday as the long-term context owner and Codex as the computer-side executor.
---

# Friday Agent Bridge

## Purpose

Use this skill to exchange structured tasks and execution reports with Friday through the user's SSH alias:

```text
Tencent-LightHouse
```

The bridge root on the server is:

```text
/home/ubuntu/friday-data/agent-bridge
```

Friday remains the owner of long-term context. Codex is the execution agent. Do not assume that this bridge grants access to unrelated Friday data.

## Scope

Use the bridge when:

- Friday has asked the computer-side agent to read or execute a task;
- a completed task, failure, or blocked state must be reported back to Friday;
- the user asks to synchronize execution status with Friday;
- the computer-side agent has completed useful work, discovered a project state change, or has a report that Friday should review, even when no Friday-created task exists.

Do not use the bridge for ordinary local coding work without a reason to synchronize with Friday. A Friday task, an explicit user request, or a meaningful completed-work/project-state report is sufficient reason.

## Remote paths

```text
TASK_ROOT=/home/ubuntu/friday-data/agent-bridge/tasks
REPORT_ROOT=/home/ubuntu/friday-data/agent-bridge/reports
```

Task directories:

```text
$TASK_ROOT/pending
$TASK_ROOT/processing
$TASK_ROOT/completed
$TASK_ROOT/failed
```

Report directories:

```text
$REPORT_ROOT/unread
$REPORT_ROOT/processed
$REPORT_ROOT/failed
```

## Required safety rules

1. Use only the SSH host alias `Tencent-LightHouse`; do not invent or expose credentials.
2. Validate every `task_id` before using it in a shell command. Expected format: `PB-YYYYMMDD-NNN` or another explicit uppercase project prefix followed by date and sequence.
3. Do not read unrelated paths under `/home/ubuntu/friday-data/`.
4. Do not write passwords, tokens, cookies, private keys, authorization codes, connection strings, or other credentials to tasks or reports. Replace them with `[REDACTED]`.
5. Do not modify Friday's long-term memory files directly. Report possible durable facts or decisions under `## Candidate context updates`.
6. Do not publish content, delete files, send messages, make payments, change accounts, or perform other high-impact external actions unless the user explicitly confirms that action.
7. If required information is missing, report `blocked`; do not guess.
8. Never overwrite an existing task or report with the same `task_id` without explicit user instruction.
9. Prefer temporary local/remote filenames followed by an atomic rename so Friday never reads a partial report.

## Read and claim a task

Use the bundled scripts for bridge mechanics. They reduce token use and make task claiming/status changes more reliable, especially when using a lightweight model. The scripts do not constrain creative or analytical work.

From the Skill directory, list pending tasks:

```powershell
.\\scripts\\Get-FridayBridgeTasks.ps1
```

Read a candidate task through SSH:

```powershell
ssh Tencent-LightHouse "sed -n '1,240p' /home/ubuntu/friday-data/agent-bridge/tasks/pending/TASK_ID.md"
```

After validating the task ID and deciding to execute it, claim it with:

```powershell
.\\scripts\\Claim-FridayBridgeTask.ps1 -TaskId TASK_ID
```

The claim script creates the `processing` entry exclusively, then removes the `pending` entry. It refuses unavailable or already-claimed tasks without overwriting an existing claim. Do not recreate, duplicate, or manually overwrite a task when claiming fails.

After claiming, inspect the task's requested scope, target paths, approval requirements, and expected deliverables before editing anything.

## Execute the task

- Work only within the paths authorized by the task.
- Preserve literal identifiers, paths, URLs, and user-provided values.
- For content work, keep the formal project正文 in the specified Universe path; the bridge is only for task and report exchange.
- Run the relevant checks before reporting completion.
- If the result needs human review, use `needs_review` rather than `completed`.

## Report a result

The bridge is bidirectional. A report may be linked to a claimed task, or it may be a computer-agent-initiated report with no corresponding task file.

For a task-linked report, preserve the task's `task_id` and follow the normal claim/finalize flow. For an agent-initiated report, choose a unique project report ID (for example `ATOUR-YYYYMMDD-NNN`), set `initiated_by: computer_agent` in front matter, and upload the report directly. Do not create or fabricate a task record just to satisfy the report flow, and do not run `Finalize-FridayBridgeTask.ps1` for an agent-initiated report.

Create a local Markdown report named:

```text
TASK_ID.md
```

Use the schema in `references/report-schema.md`. At minimum include:

- `task_id`;
- status;
- completion time;
- files changed;
- verification performed and real results;
- pending user decisions;
- candidate context updates.

Do not claim completion unless the requested work was actually performed and verified. For an agent-initiated report, describe the completed work or discovered state directly; do not describe it as a claimed task.

Upload safely from Windows PowerShell using the bundled report script:

```powershell
.\\scripts\\Send-FridayBridgeReport.ps1 -TaskId TASK_ID -ReportPath .\\TASK_ID.md
```

The script validates the task ID and report status in the report's YAML front matter, refuses to overwrite an existing report, uploads through a temporary filename, publishes it exclusively in `reports/unread/`, and verifies that the remote file is nonempty.

After a task-linked report is verified, finalize the task with:

```powershell
.\\scripts\\Finalize-FridayBridgeTask.ps1 -TaskId TASK_ID -FinalState completed
```

For an attempted task that failed, use `-FinalState failed`. For `needs_review` or `blocked`, upload the report first and leave the task in `processing` until Friday or the user provides the next decision.

For an agent-initiated report, stop after the remote report is verified. Do not run the finalize script because no task record exists.

## Status selection

- `completed`: requested work finished and verified;
- `needs_review`: work finished sufficiently for user review, but a decision remains;
- `blocked`: cannot proceed without missing information, permission, or external access;
- `failed`: execution was attempted but did not complete successfully.

A report must be sent for every claimed task, including failures and blocks.

## Completion response

After the remote report is verified, summarize locally:

```text
Friday task TASK_ID reported as STATUS.
Report: /home/ubuntu/friday-data/agent-bridge/reports/unread/TASK_ID.md
```

Do not paste secrets or the entire report into chat unless the user asks.
