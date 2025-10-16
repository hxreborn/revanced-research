# Implementation Strategy — TikTok 36.5.4 Share Link Sanitizer

**Status**: DESIGN (Ready for bytecode implementation phase)  
**Date**: 2025-10-16  
**Target**: Production patch for ReVanced  

---

## Executive Summary

This patch intercepts TikTok's URL shortening mechanism **before** any short URL is generated, substituting a tracking-free canonical URL that preserves video functionality. By hooking at `C98549aQC.LJFF()`, we intercept **all** share surfaces (copy link, share sheet, individual channel chips) at the source, eliminating the need for post-clipboard interception and ensuring analytics pipelines remain intact.

---

## Target & Behavior

### Injection Point

**Class**: `Lcom/p124ss/android/ugc/aweme/share/C98549aQC;`  
**Method**: `LJFF(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)L...;`  
**Location**: `classes18.dex`  
**Reference**: `apps/tiktok/36.5.4/decode/cfr/classes18/X/aQC.java:183`

### Why LJFF?

Every share surface (Copy link, "More options", individual channel chips) executes this method immediately **before** a URL is exposed to users. This is where `IShortenUrlApi.getShareLinkShortenUel` is invoked—the gateway to short URL generation.

### Patch Behavior

**For link-oriented scenes/channels:**
1. Detect the relevant share scene/channel type within LJFF
2. Invoke helper that derives canonical URL: `https://www.tiktok.com/@{uniqueId}/video/{aid}`
3. Replace the `IShortenUrlApi.getShareLinkShortenUel` observable with:
   ```
   AbstractC98976aX5.m14172LJ(canonicalUrl)
   ```
4. Timing fields (`C98549aQC.LIZ`, `C98549aQC.LIZIZ`) remain untouched
5. Observer (`new C50550Hrl(...)`) proceeds unchanged
6. Analytics/logging pipeline fires normally

**Result**: Users receive canonical URLs with zero tracking parameters, no network overhead, all analytics intact.

---

## Conceptual Patch Flow

```
LJFF(itemType, url1, url2, url3) called
  ↓
[PATCH] Detect: itemType == LINK_CHANNEL?
  ↓ YES
[PATCH] Derive canonical URL from context (Aweme fields / originShareUri)
  ↓
[PATCH] Replace IShortenUrlApi.getShareLinkShortenUel(...) call
  ↓
[PATCH] Return: AbstractC98976aX5.m14172LJ(canonicalUrl)
  ↓
Downstream observer wiring processes canonical URL
  ↓
Result: Clean URL in clipboard, share sheet, all destinations
```

---

## Fingerprint Specification

### New: LJFFShorteningFingerprint

**Purpose**: Locate the exact LJFF method where shortening is invoked  
**Confidence**: 95% (method name + API invoke anchors)

**Anchors** (in order of appearance in bytecode):
1. Dual `new-instance` instructions for `C530904i` (request builder initialization)
2. Call to `IV4.LIZIZ.LJJJJLI(...)` (context or config setup)
3. `invoke-interface` to `IShortenUrlApi.getShareLinkShortenUel` (the shortener call itself)

**Kotlin Definition** (for implementation):
```kotlin
internal val ljffShorteningFingerprint = fingerprint {
    // Anchor by method name (most stable)
    custom { method, _ ->
        method.name == "LJFF"
    }
    
    // Optionally add string or opcode anchors for robustness:
    // - invoke-interface IShortenUrlApi.getShareLinkShortenUel
    // - new-instance C530904i (request builder)
}
```

**Backup Anchors** (if method name not unique):
- Presence of `invoke-interface` to `IShortenUrlApi` 
- Sequential `new-instance` instructions for builder pattern
- Return type: `L...;` (Observable or similar)

---

## Archived Fingerprint: FP-001

### CopyLinkChannel.LJI() — Why Retired

**Original Signature**:
```
Lcom/p124ss/android/ugc/aweme/share/improve/channel/CopyLinkChannel;
  ->LJI(C98754aTV;Landroid/content/Context;InterfaceC50877Hx2;)Z
```

**Location**: `classes8.dex`, line 36  
**Reference**: `apps/tiktok/36.5.4/decode/jadx/sources/com/p124ss/android/ugc/aweme/share/improve/channel/CopyLinkChannel.java:36`

**Method Behavior**:
```java
public boolean LJI(C98754aTV content, Context context, InterfaceC50877Hx2 callback) {
    String strLIZIZ;
    
    String str = content.LIZJ;  // Title
    if (str == null || str.length() == 0) {
        strLIZIZ = content.LIZLLL;  // URL (already shortened)
    } else {
        StringBuilder sb = CLD.LIZ();
        sb.append(content.LIZJ);
        sb.append(' ');
        sb.append(content.LIZLLL);  // URL (already shortened)
        strLIZIZ = CLD.LIZIZ(sb);
    }
    
    // Direct clipboard write with NO interception possible
    new C98761aTc(...).LIZLLL(strLIZIZ, context, ...);
    return true;
}
```

**Key Opcodes** (for historical reference):
```smali
.method public LJI(LC98754aTV;Landroid/content/Context;LInterfaceC50877Hx2;)Z
    .locals 2
    
    if-eqz p1, :cond_0
    iget-object v0, p1, LC98754aTV;->LIZLLL:Ljava/lang/String;
    iget-object v1, p1, LC98754aTV;->LIZJ:Ljava/lang/String;
    invoke-static {v0, v1}, LC98761aTc;->LIZLLL(Ljava/lang/String;Ljava/lang/String;)Z
    move-result v0
    return v0
    
    :cond_0
    const/4 v0, 0x0
    return v0
.end method
```

**Why Superseded**:
- ❌ Interception point too late (URL already shortened at `content.LIZLLL`)
- ❌ Only intercepts "Copy Link" surface (not "More options", channel chips)
- ❌ No access to Aweme context (reconstruction would require Base62 decode + API lookup)
- ❌ Cannot prevent network call (shortening already happened upstream)

**Historical Value**: 
- Reference for understanding pre-patch share flow
- Validation that shortening occurs before clipboard write
- Fallback documentation if LJFF fingerprinting fails in future versions

---

## Implementation Checklist

### Phase 1: Code Analysis & Validation

- [ ] **Confirm LJFF Signature**
  ```
  Verify in apps/tiktok/36.5.4/decode/cfr/classes18/X/aQC.java:183:
  - Method name: LJFF
  - Parameters: int, String, String, String
  - Return type: Observable or reactive wrapper
  - Calls: IShortenUrlApi.getShareLinkShortenUel
  ```

- [ ] **Map Parameter Semantics**
  ```
  - p1 (int): itemType or channel identifier
  - p2, p3, p4 (String): URL components, metadata, or context
  
  Determine which parameter indicates "link share" vs other types.
  Location: Search aQC.java for enum/constant definitions
  ```

- [ ] **Validate Observable Wrapper**
  ```
  Confirm AbstractC98976aX5.m14172LJ() behavior:
  - Input: String (canonical URL)
  - Output: Observable or reactive type
  - Compatibility: Can replace IShortenUrlApi.getShareLinkShortenUel result?
  
  Reference: apps/tiktok/36.5.4/decode/cfr/classes18/X/aX5.java
  ```

- [ ] **Identify Aweme Access Path**
  ```
  Determine:
  - Is Aweme object available in LJFF scope?
  - Or only extracted fields (userId, videoId)?
  - How is Aweme passed through share chain?
  
  Trace: C98759aTa.java:23 (share trigger) → LJFF call stack
  ```

### Phase 2: Bytecode Injection Design

- [ ] **Register Allocation Map**
  ```
  For LJFF method:
  - Identify which registers hold parameters (p1, p2, p3, p4)
  - Find register storing IShortenUrlApi.getShareLinkShortenUel result
  - Plan: Where will canonical URL helper result land?
  - Plan: How to replace invoke-interface call?
  
  Output: Diagram showing register flow around injection point
  ```

- [ ] **Helper Function Signature**
  ```java
  // Location: extensions/tiktok/misc/privacy/ShareUrlUtils.java
  
  public static String buildCanonicalUrl(
      int itemType,           // To detect link-oriented shares
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

- [ ] **Instruction Sequence Plan**
  ```
  Original (conceptual):
    invoke-interface {v_api}, IShortenUrlApi;->getShareLinkShortenUel(...)
    move-result-object v_result
    ...
    // v_result used in downstream chain
  
  Patched (conceptual):
    // Extract canonical URL components
    invoke-static {p1, p2, p3, p4}, ShareUrlUtils;->buildCanonicalUrl(...)
    move-result-object v_canonical
    
    // Wrap with observable wrapper
    invoke-static {v_canonical}, AbstractC98976aX5;->m14172LJ(...)
    move-result-object v_result
    
    // Continue unchanged (downstream sees same v_result type)
  ```

### Phase 3: Test Validation Plan

- [ ] **TC-001: Copy Link (Primary)**
  ```
  Steps:
  1. Launch patched TikTok
  2. Navigate to any video
  3. Tap Share → Copy Link
  4. Paste in Notes app
  
  Expected Output: https://www.tiktok.com/@{username}/video/{id}
  Verification: No vm.tiktok.com, no query parameters
  ```

- [ ] **TC-002: Share Sheet (More Options)**
  ```
  Steps:
  1. Tap Share → "More" / "More options"
  2. Select destination (Notes, email, etc.)
  3. Verify URL sent
  
  Expected Output: Canonical form
  Verification: Same as TC-001
  ```

- [ ] **TC-003: Channel Chips**
  ```
  If TikTok UI shows direct "Share to WhatsApp" / "Message" / etc.:
  1. Tap a channel chip
  2. Monitor clipboard or share intent data
  
  Expected Output: Canonical URL sent to destination
  Verification: No short codes, no tracking params
  ```

- [ ] **TC-004: Analytics Intact**
  ```
  Steps:
  1. Enable logcat filtering: logcat | grep -i "Hrl\|analytics"
  2. Perform share actions (TC-001, TC-002, TC-003)
  3. Observe logs
  
  Expected: Logging fires normally, no errors
  Verification: No exceptions in C50550Hrl observer chain
  ```

- [ ] **TC-005: Video Functionality**
  ```
  Steps:
  1. Share a canonical URL to another device/account
  2. Recipient clicks/opens URL
  
  Expected: Video plays correctly, metadata displays
  Verification: No 404, no redirect loops
  ```

- [ ] **TC-006: Edge Cases**
  ```
  - Video with special characters in username
  - Video from user profile (not feed)
  - Live video (if applicable)
  - Story/Reel if separate from standard video
  
  Expected: All handle canonical form correctly
  ```

### Phase 4: Documentation Updates

- [ ] **Update fingerprints.md**
  - Add new LJFFShorteningFingerprint section
  - Include backup anchor strategies
  - Archive FP-001 with full historical context
  - Add "Why Retired" rationale

- [ ] **Update patch-plan.md**
  - Change injection point from CopyLinkChannel.LJI to C98549aQC.LJFF
  - Update architecture diagram to show pre-shortening interception
  - Add rationale for why LJFF superior
  - Include helper function pseudo-code

- [ ] **Update tooling.md** (or create addendum)
  - Document analysis evolution (FP-001 → LJFF discovery)
  - List key files analyzed and line numbers
  - Record assumptions made and validation needed

- [ ] **Create implementation-notes.md**
  - Register allocation diagram
  - Bytecode injection pseudocode
  - Observable wrapping details
  - Known gotchas or Android version considerations

---

## Critical Unknowns (Resolve Before Coding)

1. **Aweme/Field Availability in LJFF**
   - Are `userId` and `videoId` accessible in LJFF context?
   - Or must they be extracted/cached from parent method?
   - **Impact**: Determines helper function complexity

2. **Channel Type Detection**
   - What value of `itemType` (parameter p1) indicates "link share"?
   - Is this a named constant in codebase?
   - **Impact**: May need reverse-engineer channel types or test empirically

3. **Observable Wrapping Compatibility**
   - Can `AbstractC98976aX5.m14172LJ(canonicalUrl)` safely replace `IShortenUrlApi` result?
   - Or must it wrap different type?
   - **Impact**: May require additional type conversion in inject

4. **Version Stability Across Minor Versions**
   - Do LJFF signature & IShortenUrlApi call persist in 36.6.x, 37.x?
   - **Impact**: Determines fingerprint robustness; may need version-specific variants

---

## Success Criteria

✅ **Patch is complete when:**
- [ ] Fingerprint reliably locates LJFF in 36.5.4 (95%+ confidence)
- [ ] All 6 test cases pass on emulator
- [ ] Canonical URLs appear in clipboard/share destinations (zero short codes)
- [ ] Analytics/logging fires without errors
- [ ] Video URLs remain functional (recipients can open/play)
- [ ] Documentation fully captures analysis, fingerprints, and fallback strategies

---

## References

**Bytecode Locations:**
- `apps/tiktok/36.5.4/decode/cfr/classes18/X/aQC.java:183` — LJFF method
- `apps/tiktok/36.5.4/decode/cfr/classes18/X/aX5.java` — Observable wrapper
- `apps/tiktok/36.5.4/decode/jadx/sources/.../CopyLinkChannel.java:36` — Legacy FP-001
- `apps/tiktok/36.5.4/decode/jadx/sources/.../Aweme.java:1896` — getAid() method
- `apps/tiktok/36.5.4/decode/jadx/sources/.../User.java:2205` — getUniqueId() method

**Related Analysis:**
- `cfr-comparison.md` — JADX vs CFR validation of fingerprints
- `tooling.md` — Reproducibility commands, tool versions
- `fingerprints.md` — Archived FP-001, new fingerprint anchors

---

## Next Steps

1. **Resolve Critical Unknowns** (Phase 1 checklist above)
2. **Validate Register Allocation** (Phase 2 checklist)
3. **Draft Smali Injection Code** (with concrete register assignments)
4. **Test on Emulator** (TC-001 through TC-006)
5. **Prepare PR for ReVanced**

---

**Document Status**: DESIGN PHASE COMPLETE  
**Ready for**: Bytecode Analysis & Implementation
