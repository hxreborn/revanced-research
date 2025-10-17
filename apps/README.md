# Applications

Reverse-engineering analysis for specific app versions.

## Structure

Each `apps/<app>/<version>/` contains:
- `apk/` - Original APKs
- `decode/` - Decompilation outputs (apktool, jadx)
- `notes/` - Research findings (fingerprints, patch plans)
- `artifacts/` - Screenshots & evidence

## Active Investigations

- **tiktok/36.5.4** — Share link sanitizer research
  - Status: ✅ Analysis complete (fingerprints, patch plan, bytecode verification ready)
  - See `tiktok/36.5.4/notes/` for research findings

## New Application Setup

```bash
APP=<app-name> VER=<version>
mkdir -p apps/$APP/$VER/{apk,decode/{apktool,jadx},notes,artifacts,tmp}
# Create core notes: README.md, fingerprints.md, patch-plan.md, tooling.md
```
