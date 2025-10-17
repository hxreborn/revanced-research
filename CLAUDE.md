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
├── AGENTS.md              # Machine-facing guide (Conventional Commits, RE workflow)
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

## Extended Thinking for Complex Analysis

Use Claude's extended thinking when analysis requires deep evaluation:

**Levels:**
- `"think"` — Fingerprint validation across 3+ versions, opcode pattern disambiguation
- `"think hard"` — Data flow analysis spanning 5+ call stacks, patch strategy comparison
- `"think harder"` — Alternative implementation tradeoffs with security/compatibility analysis
- `"ultrathink"` — Complete bytecode reconstruction from obfuscated patterns

**Example scenarios:**
- Resolving ambiguous enum values from decompiled code
- Comparing dex2jar + CFR output against JADX for method signature validation
- Designing injection strategy with minimal register pressure
- Mapping class hierarchy through multiple inheritance levels

## Session Management

**Context boundaries:**
- Use `/clear` between distinct targets (e.g., after completing tiktok analysis, clear before instagram)
- Start fresh session per app version to prevent token bloat
- Each major phase transition (decode → analysis → bytecode verification) = new session scope

**When to persist context:**
- Keep same session for related fingerprint refinements (FP-001 → FP-002)
- Maintain context during single-app data flow analysis
- Preserve during iterative patch plan revisions

**Recovery patterns:**
- If context becomes stale, summarize findings in phase-handoff.md, then `/clear`
- For long-running investigations, checkpoint progress in notes/ before clearing

## Dynamic Analysis & Runtime Validation

After static fingerprinting, validate findings with Frida:

**Workflow:**
1. **Hook target methods** to confirm argument types, return values, call ordering
2. **Log runtime behavior** for fields/enums that decompilation couldn't resolve
3. **Document mismatches** (e.g., "decompiled enum shows 0x01, runtime uses 0x02")

**AI-Assisted Hook Generation:**
```javascript
// Prompt: "Generate Frida hook for method Lcom/ss/android/ugc/aweme/share/C98549aQC;->LJFF(...)V
// to log all arguments and return value"
Java.perform(function() {
  var targetClass = Java.use("com.ss.android.ugc.aweme.share.C98549aQC");
  targetClass.LJFF.implementation = function() {
    console.log("[+] LJFF called with args:", arguments);
    var result = this.LJFF.apply(this, arguments);
    console.log("[+] LJFF returned:", result);
    return result;
  };
});
```

**Integration with fingerprints:**
- Update `fingerprints.md` with runtime-confirmed signatures
- Note discrepancies in `*-phase-handoff.md` as critical unknowns

## Package Name Reference

**TikTok 36.5.4:** `com.zhiliaoapp.musically` (not `com.ss.android.ugc.tiktok`)

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

## AI-Assisted Analysis Patterns

Modern workflows combine static analysis + LLM capabilities:

**Code Interpretation:**
- Prompt: "Explain this smali bytecode pattern" for opcode sequences
- Use for obfuscated control flow reconstruction
- Document interpretation in data-flow-analysis.md

**Script Generation:**
- "Generate Frida hook for method X to log args/return"
- "Create ripgrep pattern to find all usages of field Y"
- "Write bash one-liner to extract class names matching pattern Z"

**Cross-Reference Automation:**
- "Find all invocations of IShortenUrlApi across decompiled sources"
- "Map class hierarchy for C98549aQC and identify injection-safe parent methods"
- "Compare method signatures between JADX and CFR outputs for classesX.jar"

**Validation:**
- Always verify AI-generated patterns against actual bytecode
- Test generated Frida scripts in controlled environment before production
- Document successful prompts in tooling.md for reuse across versions

## Integration with revanced-patches

When analysis is complete:
1. Extract **method descriptors** (e.g., `Lcom/example/Share;->buildLink(Ljava/lang/String;)Ljava/lang/String;`)
2. Extract **smali offsets** or **bytecode patterns** for stable matching
3. Document **dependencies** (e.g., "runs after UI patch")
4. Push findings to `revanced-patches/` as a patch outline, not raw decompiled code

**Do NOT commit** full sources, APKs, or decode outputs to this repo.

## Claude Session Checklist

When starting new target analysis:

1. **Session Scope:** Start fresh (`/clear` if continuing from prior app)
2. **Load Context:** Review `apps/<package>/<version>/notes/README.md` for status
3. **Tool Validation:** Confirm decode outputs exist, check tooling.md for versions
4. **Analysis Mode:** Choose approach:
   - Quick fingerprint → standard analysis
   - Complex bytecode → `think hard` or `ultrathink`
   - Runtime validation → Frida hook generation + testing
5. **Documentation:** Update fingerprints.md, patch-plan.md as findings emerge
6. **Phase Transition:** Create `*-phase-handoff.md` before moving to smali implementation
7. **Completion:** Summarize in README.md, `/clear` before next target

**Escalation patterns:**
- If decompilation ambiguous → try dex2jar + CFR alternative
- If fingerprint matching fails → request runtime validation with Frida
- If GC crashes → consult docs/jvm_gc_troubleshooting.md

## Reference

- **AGENTS.md** — Universal machine guide (setup, workflow, commit style, maintenance cadence)
- **README.md** — Human-facing project overview
- **docs/jvm_gc_troubleshooting.md** — GC crash diagnosis & recovery

**Maintenance:**
- Review this file quarterly alongside AGENTS.md updates
- Align with new Claude Code features as released
- Document new AI-assisted patterns as they prove valuable in practice
