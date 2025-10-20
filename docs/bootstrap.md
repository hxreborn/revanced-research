# Bootstrap Archive - Initial Repository Setup

**Note:** This document covers Phase 0 (one-time setup). The repository is already initialized. This is archived for reference only.

---

## **Phase 0: Repository Setup** (One-time)

### Initialize Structure
```bash
# Create main research repository (its revanced-research, this one)
mkdir rv-research && cd rv-research
git init

# Add ReVanced as submodules
git submodule add https://github.com/hxreborn/revanced-patches revanced-src/revanced-patches

# Download CLI
wget https://github.com/ReVanced/revanced-cli/releases/latest/download/revanced-cli.jar -O revanced-src/revanced-cli.jar

# Create documentation
cat > README.md << 'EOF'
# ReVanced Research Repository

## Purpose
Systematic approach to developing ReVanced patches with full documentation and testing.

## Structure
- `apps/`: Version-specific research and testing
- `revanced-src/`: ReVanced source code (submodules)
- `attempt-history.md`: Global tracking to avoid circles
EOF

cat > attempt-history.md << 'EOF'
# Global Attempt Tracker

| Date | App | Version | Target | Method | Result | Next |
|------|-----|---------|--------|--------|--------|------|
EOF

# Study successful patches for reference
cd revanced-src/revanced-patches
grep -r "BytecodePatch" src/ --include="*.kt" | head -20
cat src/main/kotlin/app/revanced/patches/youtube/misc/links/OpenLinksDirectlyPatch.kt
cat src/main/kotlin/app/revanced/patches/youtube/layout/hide/watermark/HideWatermarkPatch.kt
cd ../..

git add .
git commit -m "Initial rv-research structure"
```

---

## Current Structure (Already Initialized)

The repository now contains:

```bash
revanced-research/
├── README.md                    # Main documentation
├── WORKFLOW.md                  # Phase-by-phase runbook
├── CLAUDE.md                    # LLM agent instructions
├── AGENTS.md                    # Contributor guidelines
├── attempt-history.md           # Global attempt tracker
├── docs/
│   └── status.md               # Current state dashboard
├── apps/
│   └── tiktok/36.5.4/
│       ├── base.apk            # Original APK
│       ├── obfuscation-map.md   # Obfuscated class mappings
│       ├── injection-points.md  # Verified injection points
│       ├── decompiled-jadx/     # JADX output
│       ├── decompiled-smali/    # Smali output
│       ├── smali-tests/         # Experimental patches
│       └── verification/        # Evidence logs
└── revanced-src/
    ├── revanced-patches/        # Submodule (forked)
    └── revanced-cli.jar         # CLI tool
```

To get started on Phase 1 or Phase 2, see `WORKFLOW.md`.
