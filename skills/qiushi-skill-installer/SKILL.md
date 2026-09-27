---
name: qiushi-skill-installer
description: Find and install, update, validate, or uninstall HughYau/qiushi-skill from its official GitHub repository. Use whenever the user mentions qiushi-skill, 求是 Skill, asks where it comes from, or asks an agent to install or manage it for Codex, Claude Code, Cursor, OpenCode, OpenClaw, Hermes, or nanobot.
---

# Qiushi Skill Installer

Use the official repository as the source of truth:

- Repository: `https://github.com/HughYau/qiushi-skill`
- General instructions: `README.md`
- Codex instructions: `.codex/INSTALL.md`
- Other host instructions: the matching `INSTALL.md` or platform document in the repository

## Workflow

1. Identify the current AI host and whether the user wants user-level or project-level installation. Ask before proceeding only when the scope is genuinely ambiguous and would change the destination materially.
2. Retrieve the latest repository instructions before installing. Read `README.md` and the host-specific installation document. Do not rely solely on commands remembered from an earlier version.
3. Check prerequisites and inspect the requested destination. Preserve unrelated existing skills and configuration.
4. Prefer the repository's current non-interactive installer for the detected host and requested scope. For Codex, the documented command at the time this skill was created was:

   ```text
   npx qiushi-skill install --target codex --scope user
   ```

   Use `--scope project` for an explicitly requested project installation. Verify these arguments against the latest upstream documentation before execution.
5. Do not add qiushi-skill to this skillpacks repository's pack manifest or copy its component skills into an existing pack unless the user separately requests curation work.
6. Run the upstream validation command after installation. Prefer `npx qiushi-skill validate`; when Node.js is unavailable and a source checkout exists, use the repository's platform-specific validation script.
7. Report the detected host, selected scope, installation destination, command used, and validation result. If installation changed files outside the current project, say so explicitly.

## Safety

- Treat installation, update, and uninstall as state-changing operations within the scope the user named.
- Never guess a different host or broaden a project installation into a user-level installation.
- For uninstall requests, use the upstream uninstall mechanism so its installation manifest controls what is removed.
- If the repository instructions conflict with this guide, follow the latest upstream instructions and mention the difference.
