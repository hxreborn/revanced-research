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

## plan v2 approach - abandoned

attempted to build canonical URLs from Aweme object in LJIJJ method. approach failed - LJIJJ is not called during share flow. see test 3 failure for context. superseded by LJIJJLI discovery below.

### technical implementation details

**file**: `apps/tiktok/36.5.4/smali-tests/03-minimal/smali_classes15/com/ss/android/ugc/aweme/share/improve/pkg/AwemeSharePackage.smali`

**actual injection point**: LJIJJLI() line 2795 (not LJIJJ or LJII)
- Gets URL: `iget-object v4, p0, Lcom/ss/android/ugc/aweme/share/base/model/BaseSharePackage;->url:Ljava/lang/String;`
- URL is CANONICAL at entry: `https://www.tiktok.com/@user/video/ID?params...`
- Gets shortened by: `UEU.LIZLLL()` at line 2889

**registers available** (within .locals 5):
- v0-v3: used by existing logic
- v4: URL (what we intercept)
- temporary registers can be reused safely

**safety checks**:
- No try-catch violations
- No lambda/invoke-custom
- Single-entry method
- Fallback to original if any field null

**expected outcome**:
- All channels (WhatsApp, SMS, clipboard) get canonical URL
- API shortening still called but with canonical URL
- No tracking params baked into shortened URLs

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
