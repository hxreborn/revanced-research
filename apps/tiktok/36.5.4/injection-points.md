# Verified Injection Points - TikTok 36.5.4

## Phase 2 Test Results - 2025-10-19

### ❌ Test 1: FAILED - UEU.LIZJ() Patch
- **Target**: `p003X.UEU.LIZJ()` method in classes15.dex
- **File**: `smali-classes15/X/UEU.smali` line 150
- **Attempted Patch**: `const/4 v0, 0x0` to force canonical URL path
- **Result**: ❌ **URL not affected - method never called during share**
- **Reason**: UEU.LIZJ() is not invoked during the share flow
- **Log**: N/A
- **Status**: Wrong interception point - method not in call stack

### ❌ Test 2: FAILED - UGk.LJ() Patch
- **Target**: `p003X.AbstractC82063UGk.m11879LJ()` method in classes15.dex
- **File**: `smali-classes15/X/UGk.smali` line 3142
- **Attempted Patch**: Hardcoded canonical test URL
- **Result**: ❌ **Patch compiled but method never executed**
- **Reason**: Method is in bytecode but not called during share action
- **Log**: N/A
- **Status**: Wrong call path - method not in call stack

### ❌ Test 3: FAILED - AwemeSharePackage.LJIJJ() Patch
- **Target**: `AwemeSharePackage.LJIJJ()` method
- **File**: `smali-classes15/com/ss/android/ugc/aweme/share/improve/pkg/AwemeSharePackage.smali`
- **Method**: `LJIJJ(Ljava/util/List;LX/UIg;Ljava/lang/String;ILkotlin/jvm/functions/Function2;)V` at line 21638
- **Attempted Patch**: Hardcoded test URL after line 21729
  ```smali
  const-string v4, "https://www.tiktok.com/@PATCHTEST/video/9999999999999999999"
  ```
- **Result**: ❌ **URL still came out shortened** (vm.tiktok.com)
- **Critical Finding**: The shortened URL is already present in the List at line 21682 BEFORE method receives it
- **Log**: `logcat-patchtest-1760896728.log`
- **Conclusion**: **Shortening happens EARLIER in the pipeline - LJIJJ is too late**

### Key Observation from Test 3
```smali
# Line 21682: URL comes from List<String> - ALREADY SHORTENED
invoke-static {p1, p4}...ListProtector;->get(Ljava/util/List;I)Ljava/lang/Object;
move-result-object v2
check-cast v2, Ljava/lang/String;

# Line 21724: URL passed to UEU.LIZ() (adds query params, but shortening already done)
invoke-static {v1, v2}, LX/UEU;->LIZ(Landroid/os/Bundle;Ljava/lang/String;)Ljava/lang/String;
```

## Critical Finding
**The shortened URL was created BEFORE being added to the List** - AwemeSharePackage.LJIJJ receives already-shortened URLs.

## 🎉 BREAKTHROUGH: Found Canonical URL Source!

**Date**: 2025-10-19 20:47
**Discovery**: URL IS CANONICAL at entry point to `AwemeSharePackage.LJIJJLI()`

**Evidence**:
```
W CANONICAL_URL: https://www.tiktok.com/@placeplate/video/7550224638861692168?_r=1&u_code=0...
```

**Method**: `AwemeSharePackage.LJIJJLI()` at line 2795
```smali
iget-object v4, p0, Lcom/ss/android/ugc/aweme/share/base/model/BaseSharePackage;->url:Ljava/lang/String;
```

**Key Finding**: URL arrives as FULL CANONICAL - something AFTER LJIJJLI shortens it to vt.tiktok.com

**Next Step**: Find where LJIJJLI calls the shortening method and replace with canonical

---

## Plan V2 Post-Mortem (Superseded 2025-10-19)

**Approach:** Build canonical URLs from Aweme object in LJIJJ method
**Outcome:** ❌ Failed - LJIJJ not called during share flow
**Test Reference:** Test 3 (attempt-history.md:9)
**Lesson:** Injection point was too late in the pipeline; shortened URL already materialized in List before LJIJJ received it

**Correct Entry Point Found:** `AwemeSharePackage.LJIJJLI()` line 2795
- URL arrives canonical: `https://www.tiktok.com/@user/video/ID?params...`
- Shortened by: `UEU.LIZLLL()` at line 2889
- All 5 registers in use, no temp space available
- Next phase: Find bypass for shortening orchestrator or earlier interception

---

## Phase 3 Analysis - 2025-10-20

### Architectural Findings

**Method Entry Point**: `AwemeSharePackage.LJIJJLI(UIg;String;Function2;)V` at line 2795
- **v4 (canonical URL)**: `iget-object` from `BaseSharePackage.url` - **CANONICAL at entry**
- **v2 (formatted URL)**: Result of `ULX.LIZ(v4, p0)` at line 2912 - **still canonical after formatting**
- **v2 (Wu4 async wrapper)**: Result of `UEU.LIZLLL(v3, v2, v1, v0)` at line 2932 - **shortening orchestrator**
- **Registers available**: v0-v4 (method has `.locals 5`)

### Bypass Strategy

**Objective**: Skip the `UEU.LIZLLL()` call and prevent URL shortening

**Option A** (Preferred - Simpler):
- Before LIZLLL call: Save the formatted canonical URL (v2)
- Skip LIZLLL entirely
- Create pass-through Wu4 async wrapper
- Result: All downstream chains receive canonical URL

**Option B** (Complex - Safer):
- Keep LIZLLL call
- Override callback chain to intercept and replace shortened result
- More changes, higher risk of breaking other flows

**Option C** (Minimal - Risky):
- Add fallback: if result starts with `vm.tiktok.com` or `vt.tiktok.com`, use canonical v4 instead
- Least code changes but depends on URL format detection

### Challenges Identified

1. **DEX Verification**: Adding logging statements broke bytecode verification
   - Error: `register v3 has type Reference: java.lang.String but expected Reference: X.04i`
   - Issue: Register type conflicts when inserting new bytecode
   - Solution: Must carefully manage register allocation and type constraints

2. **Wu4 Construction**: Need to understand Wu4 async pattern
   - Wu4 appears to be a reactive/Observable wrapper
   - Callbacks are chained: `.LJIIJ()`, `.LJIJ()`, `.LJIIL()`, `.LJIILJJIL()`
   - Unknown: Can Wu4 be created without LIZLLL invocation?

3. **Register Pressure**: Method only has 5 registers (v0-v4)
   - All currently in use
   - Cannot add temporary variables without careful refactoring

### Next Steps

1. **Study Wu4 pattern**: Find other LIZLLL usages to understand return type
2. **Find safe injection point**: Identify location that won't trigger verification errors
3. **Test incrementally**: Small changes with verification between each step
4. **Fallback approach**: If bypass too complex, consider parameter-passing method interception

---

## Phase 4 Verification - 2025-10-20

### ✅ Injection Point Verified

**Test Environment**: `04-verify-patch` with fresh decompilation

**Patch Created**: Minimal logging statement before LIZLLL call
```smali
const-string v5, "PHASE3_TEST_URL_TO_SHORTEN"
invoke-static {v5, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
```

**Compilation**: ✅ SUCCESS (No errors)
- Command: `java -jar /usr/share/java/smali/smali.jar a smali_classes15 -o classes15-patched.dex --api 35`
- Result: 103MB DEX file created, clean compilation

**APK Build & Install**: ✅ SUCCESS (No verification errors)
- DEX injected into APK
- Aligned with zipalign
- Signed with debug keystore
- Installed on device without VerifyError or crashes
- **Critically**: No DEX verification errors - injection point is safe!

**Key Finding**: Bytecode can be inserted at line 23229 without breaking DEX verification. The minimal approach works.

### Ready for Implementation

**Next Action**: Replace logging with actual bypass logic:
1. Option A: Skip LIZLLL call entirely, create direct Wu4 wrapper with canonical URL
2. Option B: Intercept LIZLLL result and replace shortened URLs
3. Option C: Add fallback detection after LIZLLL

**Confidence Level**: HIGH - Injection point is proven to work at bytecode level

---

## Phase 6: URL Parameter Sanitizer - 2025-10-20

### ✅ IMPLEMENTATION COMPLETE

**Approach**: Modified Option C - URL parameter sanitization instead of shortened URL detection
**Discovery**: UEa.LIZ() returns canonical URLs with massive tracking blob, NOT shortened URLs

### Injection Location

**File**: `smali_classes15/X/UEU.smali`
**Method**: `LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)LX/Wu4;`
**Line**: After 3882 (LIZLLL_RESULT log, before :check_shortened)
**Directive Change**: `.registers 6` → `.registers 8` (added v2-v3 local registers)

### Implementation Strategy

**Strip ALL query parameters** (whitelist approach):
```smali
# Find '?' character
const-string v2, "?"
invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v0

# Only clean if '?' at position > 0
if-lez v0, :url_already_clean

# Substring from 0 to '?'
const/4 v2, 0x0
invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1
```

**Register Allocation**:
- v0: int (indexOf result)
- v1: String (URL - modified in-place)
- v2: String (const-string temps)
- v3: String (log messages)

**Label Safety**: New label `:url_already_clean` does not conflict with existing control flow

### Test Results

**Build**: phase6-sanitizer-fixed-aligned.apk (103MB DEX)
**Test Date**: 2025-10-20
**Status**: ✅ PASS

**Test 1: Copy Link (Clipboard)**
- Channel: `aweme`
- Before: 568 chars (massive tracking blob with 18 parameters)
- After: 63 chars (clean canonical URL)
- Size reduction: **89%** (505 bytes removed)
- Logcat: URL_BEFORE_CLEAN → SANITIZER → URL_AFTER_CLEAN confirmed

**Parameters Removed**:
- `utm_*` (utm_source, utm_campaign, utm_medium)
- `share_*` (share_iid, share_link_id, share_app_id, share_item_id)
- TikTok tracking: `_d`, `_r`, `u_code`, `timestamp`, `social_share_type`
- Business tracking: `ugbiz_name`, `ug_btm`
- JSON blob: `link_reflow_popup_iteration_sharer`

**Evidence**: `logs/phase6-test-clipboard.log`

### Key Findings

1. **No Shortened URLs**: UEa.LIZ() returns canonical URLs, shortening doesn't happen at this layer
2. **Massive Tracking Blob**: Every URL has 18+ tracking parameters appended
3. **Whitelist Safer**: Stripping everything after `?` is future-proof against new tracking params
4. **Register Discipline**: Type-safe register allocation prevents DEX verification errors
5. **Branch Logic**: `if-lez` correctly handles no-`?` (-1), `?`-at-start (0), and valid-`?` (>0) cases

### Documentation

- **Patch File**: `patches/phase6-url-sanitizer.smali.patch` (complete implementation)
- **Planning**: `PHASE6-SANITIZER-PLAN.md` (pre-implementation analysis)
- **Test Results**: `PHASE6-TEST-RESULTS.md` (validation evidence)
- **Test Logs**: `logs/phase6-test-clipboard.log` (logcat capture)

### Production Readiness

**Debug Logging**:
- LIZLLL_ENTRY, SHARE_CHANNEL, CANONICAL_INPUT, LIZLLL_RESULT (Phase 5)
- URL_BEFORE_CLEAN, SANITIZER, URL_AFTER_CLEAN (Phase 6)
- **Decision**: Keep sanitizer logs for validation, gate behind build type for production

**Stability**: ✅ No crashes, no DEX verification errors, app functions normally

**Next Steps**:
1. Complete test matrix (WhatsApp, Twitter, Discord, Email, SMS, null handling)
2. Remove or gate debug logs for production build
3. Port to ReVanced patch format

---

**Phase 6 Status**: ✅ **COMPLETE - Ready for ReVanced Porting**
