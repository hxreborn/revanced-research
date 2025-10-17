# Bytecode Fingerprints

**App:** TikTok
**Version:** 36.5.4
**Patch Target:** Share Link Sanitizer
**Obfuscation Level:** HIGH (R8/ProGuard)

---

## Overview

Fingerprints for identifying and patching TikTok's share link handling pipeline. 

**PRIMARY TARGET (ACTIVE):** `C98549aQC.LJFF()` — Pre-shortening interception (classes18.dex)  
**SECONDARY TOUCHPOINT:** `LY/ACallableS112S0200000_17;->call$0()` — Pre-call canonicalisation support  
**ARCHIVED REFERENCE:** `CopyLinkChannel.LJI()` — Legacy clipboard hook (kept for historical context)

---

## FP-NEW: C98549aQC.LJFF() — Pre-Shortening URL Interception

**Priority:** CRITICAL  
**Status:** IMPLEMENTATION (canonical bypass validated via logging build)  
**Confidence:** 98%  
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
4. Downstream observer chain (`LX/Hrl`, `C50550Hrl`) processes canonical URL unchanged

### Bytecode Anchors (For Fingerprinting)

**Primary Anchor Sequence (Confirmed 2025-10-17):**
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
**Fallback 1:** Method signature (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)L...;  
**Fallback 2:** `new-instance LC530904i;` followed by shortener call  
**Fallback 3:** Presence of analytics timing block (`LX/Hrl`) immediately after invoke

### Observable Wrapper Compatibility

**Canonical Replacement:** `Lapp/revanced/tiktok/share/CanonicalShortenModelFactory;->create(Ljava/lang/String;)Lcom/ss/android/ugc/aweme/share/model/ShortenModel;`  
**Observable Wrapper:** `new-instance LX/JSy` (Single) wrapping canonical model  
**Status:** ✅ Confirmed via diagnostic logging APK (`artifacts/tiktok-logged-install-final.apk`)

### Version Compatibility

| Version | Status | Notes |
|---------|--------|-------|
| 36.5.4 | ✅ MATCH | Current target; instrumentation verified |
| 36.6.x | ⚠️ ASSUME | Reconfirm anchor sequence before release |
| 37.x.x | ⚠️ REVIEW | Expect obfuscation churn; redo fingerprint

---


---

## FP-SUP: LY/ACallableS112S0200000_17;->call$0() — Canonical URL Preparation

**Role:** Pre-shortening canonicalisation hook (invoked before `aQC.LJFF`)  
**DEX Location:** `classes18.dex`  
**Verification:** Logging build shows `RV-Sanitizer:call0` executing for every copy-link action.

**Anchor Pattern:**
```smali
iget-object v?, p0, LY/ACallable...;->l1:Ljava/lang/Object;
check-cast v?, LX/aTa;
iget-object v?, v? , LX/aTa;->LJJLJLI:Lcom/ss/android/ugc/aweme/feed/model/Aweme;
invoke-static {vAweme, vShareUrl},
    Lapp/revanced/tiktok/share/CanonicalUrlBuilder;->buildFromAweme(...)
```

**Notes:**
- UTM injection block (`LX/DWq;->LIZLLL`) must be skipped when canonical URL contains no query parameters.
- Use this method to source `Aweme` data required by the helper.

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
- jadx (deobf) + instrumentation run: authoritative source  
- CFR: not required; helper smali derived from compiled Kotlin/Java helpers

All fingerprints validated against the 2025-10-17 diagnostic build.
