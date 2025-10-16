# Templates Overview

This directory hosts reusable Markdown templates that keep each target consistent.

- `journal.md` — session log with timing/metrics sections.
- `tooling.md` — captures inputs, tool versions, commands, and metrics.
- `fingerprints.md` — tracks candidate bytecode fingerprints and validation status.
- `patch-plan.md` — summarises the intended patch, risks, and validation steps.

To bootstrap a new target:
```bash
mkdir -p targets/<package>/<version>/{apk,decode/{apktool,jadx},notes,artifacts,tmp}
cp docs/templates/*.md targets/<package>/<version>/notes/
```
Update the copies in-place as you investigate; the templates here stay generic.
