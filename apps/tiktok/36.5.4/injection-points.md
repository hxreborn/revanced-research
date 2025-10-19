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

## ✅ Plan V2 - Canonical URL Injection (In Progress)

### Approach
Instead of trying to intercept shortened URLs, build canonical URLs directly from Aweme object.

**Injection Point**: `AwemeSharePackage.LJIJJ()` method at line 2423-2432
- Get Aweme via `p0.LJJ()` (method exists at line 3012)
- Extract `aid` (video ID) and `uniqueId` (creator username)
- Build canonical URL: `https://www.tiktok.com/@{uniqueId}/video/{aid}`
- Replace v4 (shortened URL) with canonical before `putString("share_url", v4)`

**Test Location**: `apps/tiktok/36.5.4/smali-tests/02-plan-v2/smali_classes15/`

**Patch Status**:
- ✅ Smali injection applied
- ✅ Logging added ("PLAN_V2_CANONICAL" tag)
- ⏳ Awaiting: DEX compilation and device testing

### Why This Works
1. Bypasses the entire API shortening flow (`/tiktok/share/link/shorten/multi/v1/`)
2. Canonical URL stored in extras bundle before any downstream processing
3. All channels (WhatsApp, SMS, clipboard) receive canonical URL automatically
4. No tracking parameters get baked into backend-shortened URLs

### Documentation
- See `PLAN-V2-NOTES.md` for complete technical details
- Expected logs: `adb logcat | grep "PLAN_V2_CANONICAL"`
