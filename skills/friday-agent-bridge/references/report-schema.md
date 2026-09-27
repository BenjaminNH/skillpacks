# Friday Agent Bridge Report Schema

Use this structure for reports uploaded to `reports/unread/`.

```markdown
---
task_id: PB-YYYYMMDD-NNN
status: completed
created_at: YYYY-MM-DDTHH:MM:SS+08:00
completed_at: YYYY-MM-DDTHH:MM:SS+08:00
initiated_by: friday | computer_agent
universe_path: D:\\Document\\Universe\\Sale\\PersonalBrand\\projects\\2026\\...
---

# Task result

## Completed

- ...

## Files changed

- `relative/path/to/file`

## Verification

- Command or check:
- Real result:

## User review required

- None, or list the exact decisions needed.

## Candidate context updates

Only list durable decisions, preferences, project state changes, or reusable lessons that Friday may consider recording. Do not modify Friday memory directly.

## Next step

- ...
```

## Status values

- `completed`
- `needs_review`
- `blocked`
- `failed`

## Rules

- Keep the report concise and factual.
- For a task-linked report, preserve the exact `task_id` from the task file.
- For a computer-agent-initiated report, use a unique project report ID such as `ATOUR-YYYYMMDD-NNN`, set `initiated_by: computer_agent`, and do not imply that a task file exists.
- Do not include passwords, tokens, cookies, private keys, authorization codes, or connection strings.
- Use `[REDACTED]` for any secret that appears in command output or logs.
- Include real verification results, not intended or hypothetical results.
