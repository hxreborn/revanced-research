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

## Next Investigation (Phase 2 Continued)
Need to trace backwards to find WHERE the URL is shortened/selected:
- **Aweme object**: Check shareUrl field - canonical or pre-shortened?
- **C54243JOk.LIZ()**: Gateway that builds AwemeSharePackage from Aweme
  - Find where List[urls] is populated with shortened links
- **URL shortening method**: Search for methods that generate vm.tiktok.com/vt.tiktok.com
- **API calls**: May receive shortened URL from backend

## Search Pattern for Next Phase
```bash
# Find where List[urls] is populated with shortened URLs
rg "vm\.tiktok\.com|vt\.tiktok\.com" decompiled-jadx/ -B5 -A5

# Find URL shortening API calls
rg "shorten.*url|getShareLinkShortenUrl" decompiled-jadx/ -B3 -A3

# Trace List creation in C54243JOk
rg "new ArrayList|\.add\(.*url" decompiled-jadx/sources/X/JOk.java -B2 -A2
```
