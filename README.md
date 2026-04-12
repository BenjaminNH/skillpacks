# skillpacks

Curated AI skill packs for project-based use with `skillshare`.

This repository is intentionally split into two layers:

- `upstreams/`: tracked source repositories kept for updates and provenance
- `skills/`: local generated packs that are actually synced to AI tools

Most imported skills are expected to stay unmodified. Because of that, the normal workflow is to map selected upstream skills into local packs and regenerate the pack layer when needed.

## Goals

- Keep skill usage small and focused.
- Prefer project-ready packs over large unfiltered collections.
- Organize skills by actual usage, especially language and workflow.
- Make the collection easy to sync across Codex, Claude, Cursor, OpenCode, and other tools via `skillshare`.

## Design

The intended model is:

- `workflow-core`: planning, debugging, git/workflow fundamentals
- `quality-review`: review and architecture-oriented skills
- `docs-writing`: documentation and writing support
- `frontend-web`: web/frontend work
- `python-backend`: Python service work
- `database-api`: database and API skills
- `flutter-mobile`: Flutter and mobile work
- `agent-systems`: advanced multi-agent or memory/orchestration skills
- `archive`: retired or superseded skills kept temporarily for reference

Typical target size per project:

- `3-5` common skills
- `3-6` language/framework skills
- `0-2` project-specific skills

That keeps most projects near the desired `8-13` total skills.

## Repository Layout

```text
skillpacks/
├── AGENTS.md
├── README.md
├── upstreams/
│   ├── README.md
│   └── manifest.json
├── config/
│   └── pack-manifest.json
├── docs/
│   └── sources.md
├── scripts/
│   ├── sync-packs-from-upstreams.ps1
│   └── update-upstreams.ps1
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

## How It Is Used

This repository is intended to be the canonical `skillshare` source.

Current source path:

```text
D:\Document\Universe\Build\Tools\skillpacks\skills
```

Typical management flow:

1. Refresh `upstreams/` with `scripts/update-upstreams.ps1`.
2. Maintain pack mappings in `config/pack-manifest.json`.
3. Regenerate curated packs with `scripts/sync-packs-from-upstreams.ps1`.
4. Sync curated packs to local AI tool targets with `skillshare sync`.
5. Use project-level `.skillshare/` setups when a project needs only a small subset.

## Source Of Truth

- `config/pack-manifest.json` controls pack membership
- `upstreams/manifest.json` controls tracked upstream repositories
- `AGENTS.md` documents the operational rules for future agent sessions

## Usage Commands

Refresh all tracked upstreams:

```powershell
.\scripts\update-upstreams.ps1
```

Rebuild all generated packs:

```powershell
.\scripts\sync-packs-from-upstreams.ps1
```

Sync generated packs to local AI tools:

```powershell
skillshare sync --force
```

## Operational Rules

- Do not sync `upstreams/` directly.
- Do not hand-edit generated pack skills unless the user explicitly asks for local customization.
- Add or remove skills by updating `config/pack-manifest.json`, then rebuilding packs.
- Keep packs organized by usage, not by original repository.
- Preserve provenance through upstream mappings and `docs/sources.md`.

## Upstream Sources

This repository may draw from public repositories such as:

- `sickn33/antigravity-awesome-skills`
- `anthropics/skills`
- `obra/superpowers`
- `wshobson/agents`
- `coreyhaines31/marketingskills`

Detailed provenance should be tracked in [docs/sources.md](D:/Document/Universe/Build/Tools/skillpacks/docs/sources.md).

## Notes

- `tmp/pack-todo.md` is the staging file for future curation decisions.
- `AGENTS.md` is the main operations document for future agent-managed sessions.
