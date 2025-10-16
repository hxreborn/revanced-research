# revanced-research

Reverse engineering workspace for ReVanced patches.

## Overview
This repository houses the operational playbook and working tree used to investigate Android APKs before patch implementations land in [`revanced-patches`](https://github.com/ReVanced/revanced-patches). It keeps tooling expectations, workspace templates, and per-app research notes in one place so collaborators can ramp quickly and share findings without polluting the main patch repo.

## Structure
- `AGENTS.md` – operations manual describing best practices, tooling, and app-specific focus areas.
- `templates/` – reusable note templates (journal, fingerprints, patch plan, tooling checklist).
- `apps/<app>/<version>/` – per-target sandboxes containing APK copies, decode outputs, notes, scripts, and artifacts.

## Getting Started
1. Clone the repository and review `AGENTS.md`.
2. Create a new workspace:
   ```bash
   mkdir -p apps/<app-id>/<version>/{apk,decode/{apktool,jadx},notes,artifacts,scripts,tmp}
   cp templates/* apps/<app-id>/<version>/notes/
   ```
3. Drop the pristine APK into `apps/<app>/<version>/apk/`, record its hash in `notes/tooling.md`, and follow the workflow in `AGENTS.md` to decode, decompile, and document findings.

## Contribution Guidelines
- Keep binary artifacts, decoded resources, and temporary data out of version control (see `.gitignore`).
- Sync major discoveries back to `AGENTS.md` or the relevant `notes/` file so the knowledge base stays current.
- Use clear commit messages (Conventional Commit style encouraged) to document adjustments to the workflow.

## License
No license has been selected yet. If you plan to publish or reuse content from this repository, add an appropriate license file.
