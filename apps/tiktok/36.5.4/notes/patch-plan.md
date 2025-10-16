# Patch Implementation Plan

**App:** TikTok
**Version:** 36.5.4
**Patch Name:** Share Link Sanitizer
**Priority:** HIGH
**Status:** DESIGN → IMPLEMENTATION-READY
**Author:** ReVanced Research
**Last Updated:** 2025-10-16

> **📋 DESIGN REFERENCE**: See `implementation-strategy.md` for detailed bytecode-level planning, register allocation, fingerprint anchors, and implementation checklist. This document provides the high-level context.

---

## Executive Summary

**Objective:** Prevent TikTok from generating tracking-enabled short URLs by intercepting the shortening process and substituting canonical URLs instead.

**User Impact:** Users' clipboard and all share destinations receive canonical URLs (`https://www.tiktok.com/@user/video/{id}`) with **zero tracking metadata**, eliminating the ability for TikTok to correlate shares across platforms.

**Risk Level:** LOW  
**Complexity:** SIMPLE (single injection point, no query param parsing needed)

---

## Problem Statement

### Current Behavior

TikTok intercepts share requests before users see the URL and generates tracking-enabled short URLs:

1. **Share Triggered**: User taps Copy Link, More options, or channel chip
2. **Shortening Request**: TikTok sends full URL to `IShortenUrlApi.getShareLinkShortenUel()`
3. **Short URL Generated**: API returns short code (e.g., `vm.tiktok.com/ZNd7AJCU5/`)
   - Short code encodes metadata: who shared, when, from which surface, user context
4. **Clipboard Write**: Short URL copied to clipboard
5. **Server Logging**: When shared URL is clicked elsewhere, TikTok decodes short code → correlates user behavior

**Evidence**: Examples from user research:
- Input: `https://www.tiktok.com/@champimuros/video/7561790867955076374` (canonical, clean)
- Clipboard receives: `https://vm.tiktok.com/ZNd7AJCU5/` (short code with embedded metadata)

### Desired Behavior

Users' clipboard and all share destinations receive canonical URLs with zero tracking identifiers.

**Success Criteria:**
- [ ] Shared links are canonical form: `https://www.tiktok.com/@{user}/video/{id}`
- [ ] No short URLs generated (bypass shortening entirely)
- [ ] Works across ALL share surfaces (Copy, More options, channel chips)
- [ ] Link functionality preserved (video still loads)
- [ ] Analytics/logging still fires (no broken observables)
- [ ] No app crashes

---

## Technical Analysis

### Target Components

**Primary Class:** `Lcom/p124ss/android/ugc/aweme/share/C98549aQC;`  
**Primary Method:** `LJFF(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)L...;`  
**Location:** `classes18.dex`, line 183  
**Interception Point:** Pre-shortening (before IShortenUrlApi.getShareLinkShortenUel invocation)

### Call Graph

```
User Share Action (Copy Link, More Options, Channel Chip)
  ↓
ShareService.triggerShare(Aweme, channel)
  ↓
CopyLinkWorker.doWork() / Channel Handler
  ↓
[PATCH TARGET] C98549aQC.LJFF(itemType, url1, url2, url3)
  ├─ Access Aweme context (userId, videoId)
  ├─ Derive canonical URL: https://www.tiktok.com/@{userId}/video/{videoId}
  └─ Return: AbstractC98976aX5.m14172LJ(canonicalUrl)
      └─ [Skip IShortenUrlApi.getShareLinkShortenUel()]
  ↓
C50550Hrl.LIZIZ()  [Observer chain]
  ↓
Result: Observable<String> → Clipboard / Share destination
```

### Dependencies

- **Aweme context access**: Must resolve Aweme fields from LJFF scope
- **Helper function**: `ShareUrlUtils.buildCanonicalUrl(int, String, long, String)`
- **Observable wrapper**: `AbstractC98976aX5.m14172LJ(String)` must return compatible type

---

## Implementation Strategy

### Method: Pre-Shortening Interception

Hook `C98549aQC.LJFF()` **before** URL shortening occurs, replacing the shortener API call with a canonical URL reconstruction.

### Fingerprint

**Target:** FP-NEW (`C98549aQC.LJFF()`) — **NOT FP-001**  
**Confidence:** 95%  
**Location:** `classes18.dex`, line 183 (CFR reference)

**Why LJFF over CopyLinkChannel.LJI():**

| Criterion | LJI (Archived) | LJFF (New) | Winner |
|-----------|----------------|-----------|--------|
| **Timing** | Post-shortening (too late) | Pre-shortening (optimal) | ✅ LJFF |
| **Coverage** | Copy only | All surfaces (copy, more, chips) | ✅ LJFF |
| **Data Access** | Short URL only | Full Aweme context | ✅ LJFF |
| **Analytics** | Breaks logging | Preserved | ✅ LJFF |
| **Network Calls** | None eliminated | IShortenUrlApi bypassed | ✅ LJFF |
| **Future-Proof** | Fragile | Robust | ✅ LJFF |

---

### Solution: Canonical URL Reconstruction

**Strategy**: Intercept LJFF, derive canonical URL from Aweme context, skip shortener

**Pseudo-code:**
```java
// Inside C98549aQC.LJFF()
if (isLinkShareType(itemType)) {
    String userId = getSharedAwemeContext().getUser().getUniqueId();
    long videoId = getSharedAwemeContext().getAid();
    String canonicalUrl = "https://www.tiktok.com/@" + userId + "/video/" + videoId;
    
    // Instead of: IShortenUrlApi.getShareLinkShortenUel(request)
    // Return: AbstractC98976aX5.m14172LJ(canonicalUrl)
}
```

**Pros:**
- ✅ Intercepts ALL share surfaces (not just copy)
- ✅ Eliminates network shortening call
- ✅ Analytics/logging preserved
- ✅ Future-proof (if channels added, still works)
- ✅ No query params (metadata in short URL is replaced with canonical)

**Cons:**
- Requires Aweme field access from share context/caches
- Must identify itemType values for link-oriented shares

---

## Helper Function Requirement

**Location**: `extensions/tiktok/misc/privacy/ShareUrlUtils.java`

**Function Signature**:
```java
public static String buildCanonicalUrl(
    int itemType,           // Detect link-oriented shares
    String userId,          // From Aweme.User.getUniqueId()
    long videoId,           // From Aweme.getAid()
    String fallbackUrl      // Original URL if derivation fails
) {
    if (isLinkShareType(itemType)) {
        try {
            return "https://www.tiktok.com/@" + userId + "/video/" + videoId;
        } catch (Exception e) {
            Logger.printException(() -> "canonical build failed", e);
        }
    }
    return fallbackUrl;
}
```

**Critical Unknowns to Resolve**:
- [ ] Aweme/field availability in LJFF: Are userId/videoId accessible, or must cached from context?
- [ ] itemType semantics: Which int values correspond to link-oriented shares?
- [ ] Observable wrapping: Confirm AbstractC98976aX5.m14172LJ returns compatible type

## Injection Details

### Location: C98549aQC.LJFF() [classes18.dex:183]

**Before:** `invoke-interface {...}, IShortenUrlApi;->getShareLinkShortenUel(...)`  
**After:** Replaced with direct canonical URL return

**Injection Concept:**
```smali
# Original (to be replaced):
invoke-interface {v_api}, LIShortenUrlApi;->getShareLinkShortenUel(...)
move-result-object v_result

# Patched (conceptual):
invoke-static {p1, v_userId, v_videoId, v_fallback}, 
    Lcom/revanced/tiktok/extensions/ShareUrlUtils;->buildCanonicalUrl(...)Z
move-result-object v_canonical

invoke-static {v_canonical}, 
    LAbstractC98976aX5;->m14172LJ(Ljava/lang/String;)L...;
move-result-object v_result
```

**Register Mapping** (To be finalized in bytecode phase):
- `p1`: itemType parameter
- `v_userId`: From Aweme.User.getUniqueId()
- `v_videoId`: From Aweme.getAid()
- `v_result`: Observable returned to observer chain

---

## Testing Plan

### Test Environment Matrix

| Scenario | Environment | Verification Method |
|----------|-------------|---------------------|
| Copy Link | Emulator (API 33) | Clipboard inspection |
| Share Sheet | Emulator + proxy | Network/intent data |
| Analytics | Emulator | Logcat: C50550Hrl |
| Link Functionality | Emulator + Browser | Video load test |
| Edge Cases | Emulator | Special chars, profiles, etc. |

### Test Cases (All Passing Required)

#### TC-001: Copy Link (Primary)
**Precondition**: Patched TikTok installed  
**Steps**:
1. Launch TikTok → Navigate to any video
2. Tap Share → Copy Link
3. Paste in Notes app, inspect clipboard

**Expected**: `https://www.tiktok.com/@{username}/video/{id}` (NO `vm.tiktok.com`, NO params)  
**Verification**: URL matches pattern; opens correctly in browser  
**Status**: `[PASS|FAIL|BLOCKED]`

#### TC-002: Share → More Options
**Precondition**: Patched TikTok installed  
**Steps**:
1. Tap Share → "More" / "More options"
2. Select destination (Notes, Email, WhatsApp)
3. Verify URL in destination

**Expected**: Canonical URL sent  
**Verification**: Same format as TC-001  
**Status**: `[PASS|FAIL|BLOCKED]`

#### TC-003: Share Channel Chips
**Precondition**: TikTok UI shows direct channel chips (WhatsApp, Messenger, etc.)  
**Steps**:
1. Tap channel chip (if available)
2. Monitor clipboard or share intent data

**Expected**: Canonical URL  
**Verification**: No short codes, no tracking params  
**Status**: `[PASS|FAIL|BLOCKED]`

#### TC-004: Analytics Intact
**Precondition**: Logcat enabled, filter: `logcat | grep -i "Hrl"`  
**Steps**:
1. Perform shares (TC-001, TC-002, TC-003)
2. Monitor logcat output

**Expected**: Logging fires normally, no exceptions  
**Verification**: C50550Hrl observer chain completes without errors  
**Status**: `[PASS|FAIL|BLOCKED]`

#### TC-005: Video Functionality
**Precondition**: Patched TikTok on emulator  
**Steps**:
1. Copy canonical URL via TC-001
2. Open in browser or share to recipient
3. Verify video plays

**Expected**: Full video functionality  
**Verification**: No 404, no redirect loops, metadata displays  
**Status**: `[PASS|FAIL|BLOCKED]`

#### TC-006: Edge Cases
**Precondition**: Various video scenarios  
**Steps**:
1. Share video with special characters/emoji in username
2. Share from user profile (not feed)
3. Share live/story if available

**Expected**: All produce canonical URL consistently  
**Verification**: Same format across edge cases  
**Status**: `[PASS|FAIL|BLOCKED]`

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Fingerprint fails | LOW | HIGH | Test across versions |
| URL parsing fails | VERY LOW | MEDIUM | Fallback to original URL |
| Share breaks | VERY LOW | CRITICAL | Test all share paths |
| App detects patch | LOW | MEDIUM | No prevention possible |

---

## Implementation Checklist

- [ ] ReVanced patch JSON configured
- [ ] Helper class bytecode prepared
- [ ] Smali injection tested
- [ ] TC-001 through TC-004 pass
- [ ] Code review complete
- [ ] PR created

---

## Notes

- Patch prevents users from sharing tracking URLs in chat messages
- Server-side tracking (Phase 1/2) occurs before patch point; cannot be prevented client-side
- Future: Network interception could prevent Phase 2 API call (out of scope)
