# Sources

This document records the upstream repositories tracked by this repository and how they relate to the generated local packs.

The repository uses a two-layer model:

- `upstreams/`: git-tracked source repositories kept locally for updates and provenance
- `skills/`: generated local pack layer synced by `skillshare`

The current repository strategy assumes most imported skills stay unmodified. Because of that, pack membership is managed through `config/pack-manifest.json`, and selected skill directories are copied from `upstreams/` into `skills/`.

## Standalone Management Skills

### qiushi-skill-installer

- Local path: `skills/qiushi-skill-installer`
- Canonical external repository: <https://github.com/HughYau/qiushi-skill>
- Role: discover the official repository and follow its latest host-specific installation, validation, update, or uninstall instructions
- Exception: this is a locally maintained routing skill, not an imported qiushi method skill and not a generated pack member

### friday-agent-bridge

- Local path: `skills/friday-agent-bridge`
- Canonical source: `Tencent-LightHouse:/home/ubuntu/friday-data/agent-bridge/codex-skill/friday-agent-bridge`
- Role: exchange structured tasks and execution reports with Friday through the SSH-based Agent Bridge
- Exception: this is a server-maintained custom skill, not a tracked public upstream and not a generated pack member
- Update procedure: refresh the local copy from the canonical server path, review the diff, then run `skillshare sync --force`

## Rules

- Upstream repositories are discovery and update sources, not the direct sync layer.
- Upstream clones stay in `upstreams/`.
- Generated pack contents stay in `skills/`.
- `config/pack-manifest.json` is the source of truth for pack membership.
- Do not sync `upstreams/` directly with `skillshare`.
- If a skill becomes heavily customized later, document that exception explicitly.

## Update Workflow

Refresh tracked upstream repositories:

```powershell
.\scripts\update-upstreams.ps1
```

Rebuild local packs from the manifest:

```powershell
.\scripts\sync-packs-from-upstreams.ps1
```

Sync generated packs to configured AI tool targets:

```powershell
skillshare sync --force
```

## Current Tracked Upstreams

### sickn33/antigravity-awesome-skills

- Local path: `upstreams/antigravity-awesome-skills`
- URL: <https://github.com/sickn33/antigravity-awesome-skills>
- Role:
  - large discovery source
  - historical parent of the user's older mixed skill collection
- Notes:
  - used for many practical general-purpose skills in the current packs
  - too large to mirror wholesale into the sync layer

### anthropics/skills

- Local path: `upstreams/anthropic-skills`
- URL: <https://github.com/anthropics/skills>
- Role:
  - official baseline skill source
  - preferred source when an official skill exists and local customization is not needed
- Notes:
  - currently used for `skill-creator`

### obra/superpowers

- Local path: `upstreams/superpowers`
- URL: <https://github.com/obra/superpowers>
- Role:
  - workflow and engineering-process skills
- Notes:
  - preferred source for planning, debugging, TDD, and worktree workflow skills
  - currently used for the core workflow pack items

### wshobson/agents

- Local path: `upstreams/wshobson-agents`
- URL: <https://github.com/wshobson/agents>
- Role:
  - engineering and architecture discovery source
- Notes:
  - useful for backend, architecture, and frontend/mobile support skills
  - currently used for `tailwind-design-system`

### coreyhaines31/marketingskills

- Local path: `upstreams/marketingskills`
- URL: <https://github.com/coreyhaines31/marketingskills>
- Role:
  - marketing and growth discovery source
- Notes:
  - tracked for future optional packs
  - not currently used in the first active generated packs

## Current Pack Provenance Summary

This is the current high-level mapping from upstreams into local packs.

### workflow-core

- `brainstorming` -> `superpowers`
- `writing-plans` -> `superpowers`
- `systematic-debugging` -> `superpowers`
- `test-driven-development` -> `superpowers`
- `using-git-worktrees` -> `superpowers`

### quality-review

- `code-reviewer` -> `antigravity-awesome-skills`

### docs-writing

- `readme` -> `antigravity-awesome-skills`

### frontend-web

- `frontend-developer` -> `antigravity-awesome-skills`
- `react-best-practices` -> `antigravity-awesome-skills`
- `tailwind-design-system` -> `wshobson-agents`
- `typescript-expert` -> `antigravity-awesome-skills`

### python-backend

- `python-pro` -> `antigravity-awesome-skills`

### devops-platform

- `docker-expert` -> `antigravity-awesome-skills`

### database-api

- `database-design` -> `antigravity-awesome-skills`
- `api-patterns` -> `antigravity-awesome-skills`

### flutter-mobile

- `flutter-expert` -> `antigravity-awesome-skills`
- `mobile-developer` -> `antigravity-awesome-skills`
- `mobile-design` -> `antigravity-awesome-skills`

### agent-systems

- `agent-memory-systems` -> `antigravity-awesome-skills`
- `agent-orchestration-multi-agent-optimize` -> `antigravity-awesome-skills`

### sales-marketing

- `customer-research` -> `marketingskills`
- `pricing-strategy` -> `marketingskills`
- `sales-enablement` -> `marketingskills`
- `community-marketing` -> `marketingskills`

### toc-validation

- `customer-research` -> `marketingskills`
- `pricing-strategy` -> `marketingskills`
- `launch-strategy` -> `marketingskills`
- `social-content` -> `marketingskills`

### social-video-growth

- `product-marketing-context` -> `marketingskills`
- `customer-research` -> `marketingskills`
- `content-strategy` -> `marketingskills`
- `social-content` -> `marketingskills`
- `copywriting` -> `marketingskills`
- `paid-ads` -> `marketingskills`
- `launch-strategy` -> `marketingskills`

### meta-tools

- `file-organizer` -> `antigravity-awesome-skills`
- `skill-creator` -> `anthropic-skills`

### archive

- `debugging-strategies` -> `antigravity-awesome-skills`

## When To Update This File

Update this file when:

- a new upstream repository is added
- an existing upstream changes role significantly
- the pack strategy changes
- heavily customized local skills are introduced and no longer fit the generated-copy model
