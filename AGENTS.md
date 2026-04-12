# Skillpacks Agent Guide

This repository is managed as a curated, project-oriented skill library for `skillshare`.

The repository is designed so future agents can maintain it without guessing the workflow.

## What This Repo Is

This repo has two layers:

- `upstreams/`: tracked source repositories, kept as git clones for updates and provenance
- `skills/`: generated local packs that `skillshare` actually syncs to AI tools

Important:

- `skills/` is the sync layer
- `upstreams/` is the update layer
- `config/pack-manifest.json` is the pack source of truth

## Current Skillshare Integration

Global `skillshare` source is expected to point to:

```text
D:\Document\Universe\Build\Tools\skillpacks\skills
```

This means:

- anything under `skills/` may be synced to Codex, Cursor, OpenCode, Antigravity, and other configured targets
- nothing under `upstreams/` should be synced directly

## Repository Structure

```text
skillpacks/
├── AGENTS.md
├── README.md
├── .gitignore
├── config/
│   └── pack-manifest.json
├── docs/
│   └── sources.md
├── scripts/
│   ├── update-upstreams.ps1
│   └── sync-packs-from-upstreams.ps1
├── tmp/
│   └── pack-todo.md
├── upstreams/
│   ├── README.md
│   ├── manifest.json
│   ├── anthropic-skills/
│   ├── antigravity-awesome-skills/
│   ├── superpowers/
│   ├── wshobson-agents/
│   └── marketingskills/
└── skills/
    ├── workflow-core/
    ├── quality-review/
    ├── docs-writing/
    ├── frontend-web/
    ├── python-backend/
    ├── database-api/
    ├── flutter-mobile/
    ├── agent-systems/
    ├── archive/
    └── skillshare/
```

## Source Of Truth Files

Future agents should treat these files as authoritative:

- `config/pack-manifest.json`
  Defines which skills belong to which local pack and where each one comes from upstream.

- `upstreams/manifest.json`
  Defines which upstream repositories are tracked locally.

- `tmp/pack-todo.md`
  Working selection sheet for deciding which skills should be promoted into packs.

`skills/` itself is mostly generated output and should not be the first place to make structural decisions.

## Current Management Model

Most curated skills are expected to remain unmodified copies from upstream sources.

That means the normal workflow is:

1. update upstream clones
2. edit `config/pack-manifest.json`
3. regenerate local packs
4. sync with `skillshare`

Do not assume the repository is meant for heavy local editing of imported skills unless the user explicitly asks for that.

## Rules For Future Agents

### Default Rule

Assume imported skills are generated pack members, not hand-maintained local forks.

### Do

- update upstream repositories through the provided script
- add or remove skills by editing `config/pack-manifest.json`
- regenerate `skills/` through the provided script
- keep pack names stable and practical
- keep `README.md` and this file aligned with the actual workflow
- preserve provenance through upstream mappings

### Do Not

- hand-edit generated skills in `skills/<pack>/` unless the user explicitly wants local customization
- edit upstream clones to represent curated local changes
- sync `upstreams/` directly
- invent new management conventions without updating this file

## Standard Operations

### 1. Refresh Upstreams

Run from repo root:

```powershell
.\scripts\update-upstreams.ps1
```

Refresh one source only:

```powershell
.\scripts\update-upstreams.ps1 -Only anthropic-skills
```

Use this when:

- the user wants latest upstream content
- a skill path needs verification
- a new pack is being assembled from tracked sources

### 2. Rebuild Packs From Upstreams

Run from repo root:

```powershell
.\scripts\sync-packs-from-upstreams.ps1
```

This script:

- reads `config/pack-manifest.json`
- clears generated pack directories
- copies selected upstream skill directories into the right local packs

Use this after:

- changing `config/pack-manifest.json`
- updating upstream repositories

### 3. Sync To Skillshare Targets

After rebuilding packs:

```powershell
skillshare sync --force
```

Use `skillshare status` first if needed:

```powershell
skillshare status
```

### 3a. Install Packs Into A Project

When the user wants pack-based skills added to a specific project, do not change the global target sync rules.

Use project mode instead.

Preferred command:

```powershell
.\scripts\install-project-packs.ps1 -ProjectPath "<project-path>" -Packs workflow-core,python-backend
```

Defaults:

- if the project does not already have `.skillshare/config.yaml`, initialize it in project mode
- default project targets are `codex,cursor`
- copy each skill in the selected pack into the project's `.skillshare/skills/`
- run project-level `skillshare sync` after installation
- when checking project status manually, prefer `skillshare status -p` to avoid relying on auto-detection

Interpretation rule for future sessions:

- if the user says "add `python-backend` and `frontend-web` skills to project X"
- interpret that as "copy all current skills from those packs into project X's `.skillshare/skills/`, then sync using project-mode skillshare"
- do not globally sync those packs to all tools

### 4. Add A Skill To A Pack

Preferred process:

1. find the skill in `upstreams/`
2. choose the target pack
3. add an entry to `config/pack-manifest.json`
4. run `.\scripts\sync-packs-from-upstreams.ps1`
5. run `skillshare sync --force`

Do not manually copy a skill into `skills/` as the primary method unless you are also updating the manifest.

### 5. Remove A Skill From A Pack

Preferred process:

1. remove the entry from `config/pack-manifest.json`
2. run `.\scripts\sync-packs-from-upstreams.ps1`
3. run `skillshare sync --force`

### 6. Move A Skill Between Packs

Preferred process:

1. move the skill entry to the new pack in `config/pack-manifest.json`
2. rebuild packs
3. sync targets

### 7. Add Packs To A Project From Natural Language

If the user gives a request like:

- "in `<path>` add `python-backend` skills"
- "for this repo install `workflow-core` and `frontend-web`"
- "sync the Flutter pack into this project"

future agents should:

1. resolve the project path
2. verify the pack names exist under `skills/`
3. use `scripts/install-project-packs.ps1`
4. report which skills were copied into the project and synced

If the user does not specify targets and the project is not initialized yet, use the script defaults: `codex,cursor`.

## When Local Customization Is Allowed

Only locally customize imported skills if the user explicitly asks for one of these:

- rename or rewrite a skill substantially
- merge multiple upstream skills into one local skill
- add local project-specific instructions
- keep a permanently customized skill that should no longer be treated as generated

If that happens:

- document the decision in `README.md` or `docs/sources.md`
- avoid silently overwriting that customized skill on the next generated rebuild
- if needed, move it out of the generated model and note the exception clearly

## Current Pack Inventory

At the moment the generated packs are intended to look like this:

- `workflow-core`
  - `brainstorming`
  - `writing-plans`
  - `systematic-debugging`
  - `test-driven-development`
  - `using-git-worktrees`
  - `file-organizer`
  - `skill-creator`

- `quality-review`
  - `code-reviewer`

- `docs-writing`
  - `readme`

- `frontend-web`
  - `frontend-developer`
  - `react-best-practices`
  - `tailwind-design-system`
  - `typescript-expert`

- `python-backend`
  - `python-pro`
  - `docker-expert`
  - `debugging-strategies`

- `database-api`
  - `database-design`
  - `api-patterns`

- `flutter-mobile`
  - `flutter-expert`
  - `mobile-developer`
  - `mobile-design`

- `agent-systems`
  - `agent-memory-systems`
  - `agent-orchestration-multi-agent-optimize`

These may change, but if they do, keep `config/pack-manifest.json` as the source of truth.

## Pack Design Intent

The repo is intentionally organized by usage rather than by upstream source.

Main pack families:

- `workflow-core`
- `quality-review`
- `docs-writing`
- `frontend-web`
- `python-backend`
- `database-api`
- `flutter-mobile`
- `agent-systems`
- `archive`

The user prefers small practical pack combinations rather than giant universal libraries.

Typical target per project:

- `2-4` workflow/common skills
- `3-6` language/framework skills
- `0-2` project-specific skills

This is meant to keep most projects around `8-13` total skills.

## Relationship To tmp/pack-todo.md

`tmp/pack-todo.md` is the staging document for future curation decisions.

Use it to:

- record the user's checkmarks and uncertainty
- decide which skills should enter real packs next
- avoid guessing user intent from memory

When the user confirms new skills:

1. update `config/pack-manifest.json`
2. rebuild packs
3. sync targets

## Validation Checklist

After any meaningful pack change, future agents should usually do this:

1. verify upstream path exists
2. update `config/pack-manifest.json`
3. run `.\scripts\sync-packs-from-upstreams.ps1`
4. inspect `skills/` layout
5. run `skillshare sync --force`
6. report which packs and skills changed

## Editing Notes

- Keep documentation short and operational.
- Prefer ASCII unless the file already uses Unicode.
- Do not create parallel undocumented workflows.
- If the repository strategy changes, update this file first or in the same change.
