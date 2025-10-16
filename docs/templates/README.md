# Templates Overview

This directory hosts reusable Markdown templates that keep each target analysis consistent and reproducible.

## Core Analysis Documents

These three files form the foundation of every target analysis:

- **`README.md`** — High-level overview, findings summary, verification checklist, references
- **`fingerprints.md`** — Bytecode signatures for method matching across obfuscation (FP-001, FP-002, etc.)
- **`patch-plan.md`** — Implementation strategy, injection points, testing checklist, risks

*(Note: Previous `journal.md` and `tooling.md` templates have been deprecated. Use app-specific `tooling.md` for command documentation.)*

## Helper Scripts

Optional utilities in `scripts/`:
- `decompile-pipeline.sh` — Automated apktool + jadx + metrics pipeline
- `detect-obfuscation.py` — Analyze decompiled bytecode for obfuscation patterns
- `enumerate-entry-points.py` — Extract entry points from manifest

## Bootstrap a New Target

```bash
# 1. Create directory structure
mkdir -p apps/<package>/<version>/{apk,decode/{apktool,jadx,dex2jar,cfr},notes,artifacts,tmp}

# 2. Copy templates to notes/
cp docs/templates/{README,fingerprints,patch-plan}.md apps/<package>/<version>/notes/

# 3. (Optional) Create app-specific tooling.md to log commands
cat > apps/<package>/<version>/notes/tooling.md << 'EOF'
# Tooling & Reproducibility

**App**: <package>
**Version**: <version>
**APK SHA-256**: [hash]
**Date**: YYYY-MM-DD

## Tools & Versions
- Java: ...
- apktool: ...
- jadx: ...
- CFR: ...

## Commands Run
### apktool
\`\`\`bash
apktool -JXmx4g d ...
\`\`\`

### jadx
\`\`\`bash
./scripts/run-jadx.sh ...
\`\`\`

### dex2jar
\`\`\`bash
for dex in classes*.dex; do d2j-dex2jar "$dex"; done
\`\`\`

### CFR (per-DEX analysis)
\`\`\`bash
cfr decode/dex2jar/classes8.jar --outputdir decode/cfr/classes8
\`\`\`

## Performance Metrics
- apktool: Xs, XXX GB output
- jadx: Xs, XXX GB output, XXX errors (Y%)
- CFR: Xs per jar
EOF
```

## Real Example: TikTok 36.5.4

See `apps/tiktok/36.5.4/notes/`:
- **README.md** — Tracking mechanism explanation, findings summary
- **fingerprints.md** — FP-001 (CopyLinkChannel.LJI), FP-002 (C98444aOV.LIZIZ), FP-003, FP-004
- **patch-plan.md** — Share link sanitization strategy with 3 implementation options
- **cfr-comparison.md** — CFR vs JADX analysis for key methods
- **tooling.md** — Exact commands, heap settings, runtime metrics

## Workflow

1. **Setup**: Create target structure + copy templates
2. **Decompile**: Run jadx (+ optional dex2jar + CFR)
3. **Analyze**: Update README, fingerprints, patch-plan with findings
4. **Document**: Log all commands in tooling.md for reproducibility
5. **Validate**: Cross-reference fingerprints ↔ patch-plan ↔ comparison docs

Update templates in-place as you investigate. This repo's templates stay generic; each target evolves its own docs.
