# Bytecode Fingerprints

**App:** TikTok
**Version:** 36.5.4
**Patch Target:** Share Link Sanitizer
**Obfuscation Level:** HIGH (R8/ProGuard)

---

## Overview

Fingerprints for identifying and patching TikTok's share link handling pipeline. 

**PRIMARY TARGET** (NEW): `C98549aQC.LJFF()` — Pre-shortening interception (classes18.dex)  
**ARCHIVED REFERENCE**: `CopyLinkChannel.LJI()` — Post-clipboard (see below for historical context)

---

## FP-NEW: C98549aQC.LJFF() — Pre-Shortening URL Interception

**Priority:** CRITICAL
**Status:** DESIGN (ready for implementation)
**Confidence:** 95%
**DEX Location:** `classes18.dex`

### Target

**Feature:** Share link sanitization before shortening
**Patch Name:** SanitizeSharingLinksPatch

### Method Signature

```smali
# Decompiled Java (CFR output)
public Object LJFF(
    int itemType,
    String url1,
    String url2,
    String url3
)
```

**Return Type:** `L...;` (Observable or reactive wrapper)
**Parameters:** `(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)L...;`
**Access Flags:** `public`
**Visibility:** Instance method

### Location

**Class:** `Lcom/p124ss/android/ugc/aweme/share/C98549aQC;`
**Package Pattern:** `com/p124ss/android/ugc/aweme/share/*`
**Superclass:** `Ljava/lang/Object;`
**References:** `apps/tiktok/36.5.4/decode/cfr/classes18/X/aQC.java:183`

### Why This Injection Point

1. **All Share Surfaces Converge Here**: Copy Link, "More options", channel chips all route through LJFF
2. **Pre-Shortening**: Intercepts BEFORE `IShortenUrlApi.getShareLinkShortenUel` is invoked
3. **Full Context Available**: Aweme data accessible via share extras/caches
4. **Analytics Preserved**: `C50550Hrl` observer chain continues unchanged
5. **Network Elimination**: Shortening API call can be bypassed entirely

### Key Operations

1. Detects `itemType` to identify link-oriented shares
2. Derives canonical URL from Aweme context (userId, videoId)
3. Replaces `IShortenUrlApi.getShareLinkShortenUel()` observable with:
   ```
   AbstractC98976aX5.m14172LJ(canonicalUrl)
   ```
4. Downstream observer processes canonical URL unchanged

### Bytecode Anchors (For Fingerprinting)

**Primary Anchor Sequence:**
```smali
new-instance v?, LC530904i;           # Request builder instantiation
...
invoke-interface {...}, LIShortenUrlApi;->getShareLinkShortenUel(...)
                                        # Shortening API call to replace
```

**Backup Anchors:**
- Dual `new-instance` instructions for request builder (C530904i)
- Call to `IV4.LIZIZ.LJJJJLI(...)` (context/config setup)
- Method name: "LJFF"

### Matching Strategy

**Primary Match:** Method name "LJFF" + invoke-interface to `IShortenUrlApi`
**Fallback 1:** Method signature (ILjava/lang/String;...) + return type Observable
**Fallback 2:** New-instance C530904i + invoke-interface pattern
**Fallback 3:** Class pattern + method exists in share package

### Observable Wrapper Compatibility

**Target:** `AbstractC98976aX5.m14172LJ(String canonicalUrl)` → `Observable<String>`
**Validation:** `C50550Hrl` observer only expects Observable<String> with timing data
**Status:** ✅ Type compatible (confirmed in implementation-strategy.md)

### Version Compatibility

| Version | Status | Notes |
|---------|--------|-------|
| 36.5.4 | ✅ MATCH | Discovery target |
| 36.6.x | ⚠️ ASSUME | Likely preserved (minor version) |
| 37.x.x | ⚠️ FLAG | Review before 37.x targeting |

---


---

## String Literals for Verification

Search these strings to confirm class locations:

| String | Expected Class | Purpose |
|--------|----------------|---------|
| `"invitation_scene"` | C98444aOV | URL param extraction |
| `"share_link_id"` | C98444aOV | Tracking ID param |
| `"social_share_type"` | C98444aOV | Platform param |
| `"/tiktok/share/link/shorten/multi/v1"` | IMultiShortenUrlApi | API endpoint |
| `"CopyLinkChannel"` | ShareServiceImpl | Entry point |

---

## Verification Steps

- [x] Confirm classes exist in classes18.dex and classes8.dex
- [x] Verify method signatures match decompiled output
- [x] Locate tracking parameters in source
- [x] Identify clipboard delegation point
- [ ] Extract exact smali bytecode for injection verification
- [ ] Test fingerprints on emulator with hook

---

## Cross-Decompiler Notes

**jadx vs CFR:**
- jadx: Accurate decompilation of obfuscated code; heavy use of renamed types
- CFR: Better type inference for generics; not tested on this APK (CFR incompatible with large APKs)

All findings based on **jadx** decompilation with `--deobf` flag.
