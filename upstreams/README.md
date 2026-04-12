# Upstreams

This directory is the upstream tracking layer for the repository.

Purpose:

- keep original source repositories available locally
- preserve update channels
- avoid losing provenance
- separate upstream clones from curated packs in `../skills/`

Rules:

- do not sync anything from `upstreams/` directly with `skillshare`
- do not edit upstream clones as if they were local curated packs
- copy or adapt selected skills into `../skills/` when promoting them into a maintained pack
- use `scripts/update-upstreams.ps1` to clone or refresh these repositories

The canonical list of tracked repositories lives in `manifest.json`.
