# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

`revanced-research` is a **reverse-engineering workspace** for analyzing Android APKs to support ReVanced patch development. It maintains a clean, reproducible environment isolated from the main `revanced-patches/` repository. Output includes decompiled sources, decoded resources, and detailed analysis notes—no patched APKs are generated here.

**Key principle:** All findings are documented for traceability (APK hashes, tool versions, commands) so analyses can be reproduced and compared across runs.

## Architecture & Workflow

### High-Level Flow

1. **APK Acquisition** → `apps/<package>/<version>/apk/` (hash verified)
2. **Resource Decode** → `apktool -JXmx4g d` → `apps/<package>/<version>/decode/apktool/`
3. **Bytecode Decompile** → `jadx --threads-count 4 --deobf` → `apps/<package>/<version>/decode/jadx/`
4. **Optional: Alternative Decompilation** → `dex2jar + cfr` for validation
5. **Analysis & Documentation** → Notes in `apps/<package>/<version>/notes/` (fingerprints, patch plans, data flow)
6. **Bytecode Verification** → Resolve unknowns, extract smali, validate injection points
7. **Distilled Output** → Push only fingerprints/offsets back to `revanced-patches/`

### Phase Transitions

**Documentation → Bytecode Phase**

Before proceeding to smali implementation, create a `*-phase-handoff.md` to document:
- What's locked and ready (patch plan, fingerprints, data flow analysis)
- Critical unknowns blocking implementation (e.g., Aweme field access, itemType enum, Observable type compatibility)
- Verification commands to resolve each unknown
- Smali phase readiness checklist (register allocation, injection point location, test environment)

See `apps/tiktok/36.5.4/notes/bytecode-phase-handoff.md` for complete example.

### Directory Structure

```
revanced-research/
├── AGENTS.md              # Reverse-engineering playbook (Conventional Commits, RE workflow)
├── README.md              # Project overview
├── CONTRIBUTING.md        # Contribution guidelines
├── docs/
│   ├── templates/         # Markdown templates (README.md, fingerprints.md, patch-plan.md)
│   └── jvm_gc_troubleshooting.md
├── scripts/
│   ├── check-tools.sh     # Validates Java, apktool, jadx, Android tools, Frida, ripgrep, disk/memory
│   ├── run-jadx.sh        # JADX decompilation with auto-tuned GC (ParallelGC, 80% RAM, all cores)
│   └── cleanup.sh         # Removes decode/, artifacts/, tmp/ safely
├── apps/
│   └── <package>/<version>/
│       ├── apk/           # Pristine APKs (MUST NOT commit .apk files)
│       ├── decode/
│       │   ├── apktool/   # Resources, smali, manifest (gitignored)
│       │   └── jadx/      # Java sources, resources (gitignored)
│       ├── notes/         # fingerprints.md, patch-plan.md, README.md, tooling.md, etc.
│       ├── artifacts/     # Dumps, screenshots, payloads (gitignored)
│       └── tmp/           # Scratch space (gitignored)
```

## Commands & Tools

**Full workflow and commands → AGENTS.md**

**Tool versions and detailed setup → AGENTS.md**

**GC crash guidance → docs/jvm_gc_troubleshooting.md**

## Per-Target Documentation

Each target needs three core notes (templates in `docs/templates/`):

1. **`README.md`** — High-level overview, findings summary, verification checklist, references
2. **`fingerprints.md`** — Bytecode fingerprints for method matching across obfuscation
3. **`patch-plan.md`** — Injection strategy, dependencies, side effects, testing checklist

Supplementary (create as needed):
4. **`tooling.md`** — APK hash, tool versions, CLI flags, performance metrics (create app-specific, not from template)
5. **`*-data-flow-analysis.md`** — Call path diagrams, register allocation, bytecode verification
6. **`implementation-strategy.md`** — Bytecode-level design, helper class signatures
7. **`*-phase-handoff.md`** — Transition checkpoint between analysis phases (unknowns, blockers, verification steps)

Update these as you analyze so future runs (or other agents) can quickly understand the landscape.

## Fingerprinting Methodology

Fingerprints identify injection points across obfuscated code. Each fingerprint (FP-XXX) includes:

### Required Components

1. **Method Signature** — Full smali descriptor with parameters and return type
2. **Location Context** — Class name, package pattern, DEX file, superclass/interfaces
3. **Bytecode Anchors** — Unique opcode sequences for stable matching (e.g., `invoke-interface` to specific APIs)
4. **Matching Strategy** — Primary match + 3 fallback patterns (method name → signature → opcodes → package)
5. **Version Compatibility** — Tested versions with match status (✅/⚠️/❌)

### Fingerprint States

- **FP-NEW** — Current primary target (ready for implementation)
- **FP-001, FP-002, etc.** — Active alternatives or secondary targets
- **ARCHIVED** — Historical reference (explain why archived, e.g., "post-shortening interception inferior to pre-shortening")

### Evolution Pattern

Start with broad surface-level targets (e.g., clipboard write), then refine through bytecode tracing to find optimal injection points (e.g., pre-shortening URL handler). Archive inferior fingerprints with clear rationale for future reference.

### Example: TikTok 36.5.4 Share Link Sanitizer

**FP-NEW: C98549aQC.LJFF()** — Pre-shortening interception
- **Why**: Intercepts before network call, covers all share surfaces
- **Anchors**: `invoke-interface IShortenUrlApi->getShareLinkShortenUel()`, method name "LJFF"
- **Status**: DESIGN (ready for bytecode implementation)

**ARCHIVED: FP-001 CopyLinkChannel.LJI()** — Post-clipboard
- **Why Archived**: Short URL already generated, limited to copy-link surface only
- **Retained For**: Historical context, fallback reference, validation

See `apps/tiktok/36.5.4/notes/fingerprints.md` for complete example.

## Integration with revanced-patches

When analysis is complete:
1. Extract **method descriptors** (e.g., `Lcom/example/Share;->buildLink(Ljava/lang/String;)Ljava/lang/String;`)
2. Extract **smali offsets** or **bytecode patterns** for stable matching
3. Document **dependencies** (e.g., "runs after UI patch")
4. Push findings to `revanced-patches/` as a patch outline, not raw decompiled code

**Do NOT commit** full sources, APKs, or decode outputs to this repo.

## Reference

- **AGENTS.md** — Full reverse-engineering playbook with workflow details
- **README.md** — Project overview and setup
- **docs/jvm_gc_troubleshooting.md** — GC crash diagnosis & recovery