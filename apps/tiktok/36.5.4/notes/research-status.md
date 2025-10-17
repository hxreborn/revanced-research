# TikTok 36.5.4 Share Link Sanitizer

**Status**: Analysis complete
**Date**: 2025-10-16

---

## Current State

All analysis documents are locked and cross-linked. See `bytecode-phase-handoff.md` for critical unknowns blocking implementation.

### Core Documentation (Production-Ready)

| Document | Purpose | Status |
|----------|---------|--------|
| `fingerprints.md` | FP-NEW + archived FP-001 with rationale | [PASS] Final |
| `patch-plan.md` | High-level strategy, 6 test cases | [PASS] Final |
| `implementation-strategy.md` | Bytecode-level design, helper signatures | [PASS] Final |
| `ljff-data-flow-analysis.md` | Call path, register planning, verification checklist | [PASS] Final |
| `tooling.md` | Reproducible commands, tool versions, metrics | [PASS] Final |
| `README.md` | Overview, findings, evidence validation | [PASS] Final |

### Supplementary

| Document | Purpose | Status |
|----------|---------|--------|
| `bytecode-phase-handoff.md` | Transition checklist, unknowns, resolution steps | [PASS] Active |

---

## Key Decisions (Locked)

### FP-NEW: C98549aQC.LJFF() (Pre-Shortening)

**Why This Over CopyLinkChannel.LJI()?**

| Aspect | CopyLinkChannel.LJI | C98549aQC.LJFF | Winner |
|--------|-------------------|-----------------|--------|
| Timing | After shortening | **Before shortening** | [PASS] LJFF |
| Coverage | Copy link only | **All surfaces** | [PASS] LJFF |
| Analytics | Breaks | **Preserved** | [PASS] LJFF |
| Network Calls | None eliminated | **IShortenUrlApi bypassed** | [PASS] LJFF |

FP-001 archived as historical reference (see `fingerprints.md`).

### Helper Function Strategy

```java
// Pseudocode
Observable<String> buildCanonicalUrl(
    int itemType,        // Share type (Copy, More, Channel)
    String url1,         // Parameter 1 (see bytecode-phase-handoff)
    String url2,         // Parameter 2
    String url3          // Parameter 3 (fallback)
) {
    if (isLinkShareType(itemType)) {
        String canonicalUrl = deriveCanonicalUrl(url1, url2, url3);
        return AbstractC98976aX5.m14172LJ(canonicalUrl);
    }
    // Non-link shares: pass through unchanged
    return IShortenUrlApi.getShareLinkShortenUel(...);
}
```

### Injection Strategy

Replace `IShortenUrlApi.getShareLinkShortenUel()` invocation:

```
BEFORE: invoke-interface {...}, LIShortenUrlApi;->getShareLinkShortenUel(...)
AFTER:  invoke-static {...}, LLhelperClass;->buildCanonicalUrl(...)
```

---

## Unknowns (Blocking Bytecode Phase)

See `bytecode-phase-handoff.md` for resolution commands and status.

### 🔍 Unknown #1: Aweme Field Access

**Question**: How to get `userId` and `videoId` in LJFF context?

**Options**:
- [ ] Aweme passed as parameter
- [ ] Cached in static/instance field
- [ ] Already extracted in string params (p2-p4)

**Resolution**: See [patch-plan.md](./patch-plan.md)

### Unknown #2: itemType Enum Mapping

**Question**: Which int value = "link share"?

**Options**:
- [ ] Find enum constant definition
- [ ] Trace LJFF callers for itemType values
- [ ] Use fallback (apply to all itemType values)

**Resolution**: See [patch-plan.md](./patch-plan.md)

### Unknown #3: Observable Type Compatibility

**Question**: Does `AbstractC98976aX5.m14172LJ(String)` return same type as `IShortenUrlApi.getShareLinkShortenUel()`?

**Resolution**: See [patch-plan.md](./patch-plan.md)

---

## Navigation

**Understanding the Approach:**
→ Start: `patch-plan.md` (high-level)
→ Details: `implementation-strategy.md` (bytecode spec)

**Validation:**
→ Fingerprints: `fingerprints.md`
→ Reproducibility: `tooling.md`

**Implementation Phase:**
→ Unknowns: `bytecode-phase-handoff.md`
→ Verification: `ljff-data-flow-analysis.md`

---

## 2025-10-17 Diagnostic Logging Run

- **Build:** `artifacts/tiktok-logged-install-final.apk` (signed, installed on Pixel 9 Pro)  
- **Docs:** `notes/diagnostic-logging.md`
- **Logs:** `artifacts/logcat_RV-Sanitizer.log` for baseline comparisons  

**Highlights**
- `LX/aQC;->LJFF` confirmed as universal entry point for all share paths.
- Clipboard writes consistently flow through `LX/aTc;->LIZLLL`.
- URL shortening shrinks payloads from ~400+ chars to 23 chars (≈94% reduction).
- Channel tracking values logged; enables targeting specific share channels later.

**Usage**
```bash
adb logcat -s RV-Sanitizer:D -v time
```
Monitor while performing share actions to verify canonical URL patches once implemented.

---


