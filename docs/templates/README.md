# Templates Overview

This directory hosts reusable Markdown templates that keep each target analysis consistent and reproducible.

## Core Analysis Documents

These three files form the foundation of every target analysis:

- **`README.md`** — High-level overview, findings summary, verification checklist, references
- **`fingerprints.md`** — Bytecode signatures for method matching across obfuscation
- **`patch-plan.md`** — Implementation strategy, injection points, testing checklist, risks

*(Note: Create app-specific `tooling.md` for command documentation and reproducibility.)*

## Helper Scripts

Optional utilities in `scripts/`:
- `decompile-pipeline.sh` — Automated apktool + jadx + metrics pipeline
- `detect-obfuscation.py` — Analyze decompiled bytecode for obfuscation patterns
- `enumerate-entry-points.py` — Extract entry points from manifest

## Bootstrap a New Target

```bash
# Create workspace and copy templates
mkdir -p apps/<package>/<version>/{apk,decode/{apktool,jadx},notes,artifacts,tmp}
cp docs/templates/{README,fingerprints,patch-plan}.md apps/<package>/<version>/notes/
```

**Optional**: Add `dex2jar/cfr` subdirectories under `decode/` if you plan to use dex2jar for JAR conversion and CFR for bytecode validation/comparison.

```bash
mkdir -p apps/<package>/<version>/decode/{dex2jar,cfr}
```

## Example: TikTok 36.5.4

See `apps/tiktok/36.5.4/notes/`:
- **README.md** — Tracking mechanism explanation, findings summary
- **fingerprints.md** — FP-NEW (C98549aQC.LJFF) fingerprint for method matching
- **patch-plan.md** — Share link sanitization strategy with 3 implementation options
- **cfr-comparison.md** — CFR vs JADX analysis for key methods
- **tooling.md** — Exact commands, heap settings, runtime metrics

## Workflow

1. **Setup**: Create target structure + copy templates
2. **Decompile**: Run tools per main README guide
3. **Analyze**: Update README, fingerprints, patch-plan with findings
4. **Document**: Log commands in app-specific tooling.md

Update templates in-place as you investigate.
