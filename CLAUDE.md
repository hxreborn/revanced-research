# CLAUDE.md

**Purpose:** Instructions for Claude Code when working in this repository. Keeps edits reproducible, focused, and reviewable.

**Changelog:** 2025-10-26 - Updated to reflect app family structure. Feature READMEs are the single source of truth.

---

## Repository Mission

Research and develop ReVanced patches through **Smali-first validation**. Every bytecode change must work in raw Smali before porting to ReVanced.

**Current Work**: See feature READMEs in `apps/<app-family>/<feature>/README.md` for status and findings.

---

## Core Principles

1. **Validate in Smali first** - Never modify `revanced-src/revanced-patches/` until proven in `smali-tests/`
2. **No APK artifacts in git** - Record hashes in `apk-metadata.txt`, never commit binaries
3. **Surgical edits** - Prefer targeted DEX injection (baksmali → smali) over full apktool rebuilds
4. **Document everything** - Update obfuscation maps, injection points, and attempt history as you learn

---

## Workspace Boundaries

Structure: `apps/<app-family>/<variant|feature>/`

| Directory | Your Access | Purpose |
|-----------|-------------|---------|
| `apps/<app-family>/<variant>/apks/<version>/` | **Read/Write** | APK artifacts, decompilation outputs (jadx/, apktool/) |
| `apps/<app-family>/<feature>/<version>/` | **Read/Write** | Version-specific smali tests, logs, patches |
| `apps/<app-family>/<feature>/README.md` | **Read/Write** | Single source of truth: status, findings, technical details |
| `revanced-src/revanced-patches/` | **Read-only** | Upstream port (only after Smali validation) |

Example: `apps/tiktok/` contains variants (trill, musically) and shared features (share-url-sanitization)

---

## Task Management

**Use TodoWrite proactively** for:
- Multi-step Smali validation workflows
- Complex ReVanced patch porting
- Any task with 3+ distinct steps

**Use Task tool (subagent_type=Explore)** when:
- Exploring the codebase for patterns (e.g., "find all share URL handlers")
- Searching across decompiled sources without a specific file target
- Answering "how does X work" questions

**Ask questions** when:
- Multiple approaches are valid and user preference matters
- Requirements are ambiguous
- You need clarification on obfuscation mappings

---

## Development Workflow

### Discovery (Read-only)
```bash
# Search JADX decompilation for patterns
rg "<pattern>" apps/tiktok/trill/apks/36.5.4/jadx/

# Verify in Smali
rg "<pattern>" apps/tiktok/<feature>/36.5.4/trill/smali-tests/*/smali-classes*/
```

### Smali Testing (Your primary workflow)
Detailed commands in `WORKFLOW.md` Phase 2. Essential pipeline:
1. Extract target DEX: `unzip -j base.apk classes15.dex`
2. Decompile: `baksmali d classes15.dex -o smali-classes15/`
3. Edit smali, add verification logs
4. Recompile: `smali a smali-classes15/ -o classes15-patched.dex --api 35`
5. Inject: `zip -j patched.apk classes15-patched.dex`
6. Sign: `zipalign` → `apksigner`

### Documentation (Required after validation)
- Feature `README.md` - Update status, technical details, validation results
- `logs/` - Save test logs with timestamps
- Inline Smali comments - Document register usage, injection points, edge cases

---

## Environment Notes

**Paths in $PATH:**
- `/usr/share/java/smali/` (baksmali/smali)
- `~/Android/Sdk/build-tools/36.1.0/` (zipalign, apksigner)

**Memory limits:** For large DEX assembly, set `SMALI_THREADS=1` and `java -Xmx16G`

**Git commit style:** Conventional commits (`type(scope): summary`)
- `test(tiktok): verify canonical URL patch in UEU.smali:150`
- `docs(smali): update injection points for LJIJJ method`

---

## Safety Guardrails

- **No network requests** unless explicitly asked
- **No background jobs** without notification
- **Report OOM errors** with stderr snippet and suggest alternatives (reduce threads, Java 11)
- **Only stage intentional changes** - use `git add -p` when committing

---

## Quick Reference

**Single Source of Truth**: `apps/<app-family>/<feature>/README.md`
- Status, findings, technical details, validation results, test matrices all live here
- This is your primary reference for any feature work

**Supporting references**:
- **Version-specific details:** `apps/<app-family>/<feature>/<version>/` (smali-tests, logs, patches)
- **App variants:** `apps/<app-family>/<variant>/apks/` (APK artifacts)
- **Project overview:** `README.md` (repo structure, high-level goals only)
