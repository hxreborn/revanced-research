# TikTok 36.5.4 - Share URL Sanitization Attempt History

## Phase 5: Option C Bypass - Register-Safe Canonical URL Swap (COMPLETE ✅)

**Date Completed**: 2025-10-20
**Status**: ✅ PASS - Patch compiles, DEX verifies, app launches without crashes
**Approach**: Post-result interception with proper register allocation

### Summary

Implemented Option C bypass strategy in `UEU.LIZLLL()` method. Detects when the URL shortener returns a shortened vm./vt.tiktok.com URL and replaces it with the canonical URL before downstream processing.

### Key Findings

**Register Mapping Critical** ⚠️
- Method signature: `LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)LX/Wu4;`
- Directive: `.registers 6` (total 6 registers)
- **Correct allocation**: v0-v1 = local variables, v2-v5 = parameter registers p0-p3
- **Initial error**: Used v2/v4 assuming they were local, but they map to p0/p2 parameters
- **Solution**: Use only v0-v1 for temporary storage to avoid parameter register conflicts

**DEX Verifier Type Conflicts**
First attempt failed with:
```
java.lang.VerifyError: Verifier rejected class X.UEU
[0x46] register v2 has type Conflict but expected Integer
```

Root cause: Trying to use a parameter register (v2=String) to store a boolean result caused type mismatch. Fixed by using v0 (true local register) for all temporary operations.

### Patch Details

**Location**: `smali_classes15/X/UEU.smali:3864-3886`
**Method**: `UEU.LIZLLL()` - URL shortener orchestrator

**Before**:
```
move-result-object v1  # v1 = shortened URL result from UEa.LIZ()
# ... continues to isEmpty check
```

**After** (FINAL WORKING VERSION):
```
move-result-object v1  # v1 = shortened URL result

# PHASE 5 PATCH: Option C Bypass
if-eqz v1, :keep_shortened_c          # null-safe guard

const-string v0, "https://vm.tiktok.com"
invoke-virtual {v1, v0}, Ljava/lang/String;->startsWith(...)Z
move-result v0                        # v0 = boolean (is vm.tiktok.com?)
if-nez v0, :swap_canonical_c          # if NOT vm, check vt

const-string v0, "https://vt.tiktok.com"
invoke-virtual {v1, v0}, Ljava/lang/String;->startsWith(...)Z
move-result v0                        # v0 = boolean (is vt.tiktok.com?)
if-eqz v0, :keep_shortened_c          # if NOT vt, skip swap

:swap_canonical_c
const-string v0, "TikTokCanonicalSwap"
invoke-static {v0, p1}, Landroid/util/Log;->d(...)  # Debug log
move-object v1, p1                    # v1 = p1 (canonical URL)

:keep_shortened_c
# ... continue to isEmpty check
```

### Build Artifacts

| Artifact | Status | Notes |
|----------|--------|-------|
| `smali_classes15_fresh/` | ✅ | Fresh decompile from base APK |
| `classes15-final.dex` | ✅ | Patched DEX (103MB) - passes verifier |
| `phase5-final-aligned.apk` | ✅ | Signed, aligned, ready for testing (323MB) |

### Test Results

| Test | Result | Evidence |
|------|--------|----------|
| APK Compilation | ✅ PASS | No smali compiler errors |
| DEX Verification | ✅ PASS | Android runtime accepts DEX |
| App Launch | ✅ PASS | App runs without VerifyError crash |
| Process Stability | ✅ PASS | No AndroidRuntime FATAL exceptions |

### Key Insights for Future Phases

1. **Register Pressure**: With `.registers N` and M parameters, only first (N-M) registers are truly local temporaries
2. **Type Safety**: Smali compiler strictly enforces type consistency - parameter registers cannot change types
3. **Label Hygiene**: Suffixed labels (`:swap_canonical_c`, `:keep_shortened_c`) prevent collisions with existing control flow
4. **Null Safety First**: Check for null before calling string methods to prevent NPE

### Testing Results

**Functional Test (2025-10-20 17:35 UTC)**:
- ✅ Clicked share button in app
- ⚠️ Shortened URL received (not canonical)
- ⚠️ No "TikTokCanonicalSwap" log detected

**Analysis**:
- Patch code IS in the installed APK
- App IS stable (no crashes)
- Share functionality IS working (user got URL)
- BUT: Patch not activating during share

**Root Cause Hypothesis**:
The share flow may use a different code path than `UEU.LIZLLL()`:
- `AwemeSharePackage.LJIJJLI()` - Main entry point, gets URL from BaseSharePackage
- `WebSharePackage` - Uses LIZLLL for web shares
- Wrap channels (WhatsApp, Twitter) - May bypass LIZLLL, go directly to Intent
- CopyLink channel - Uses different URL extraction

**CRITICAL FINDING - Phase 6 Discovery**:

Runtime Execution shows:
```
W/droid.ugc.trill: Method X.TdI X.JV8.LIZLLL() failed lock verification
```

**Problem**: We patched `UEU.LIZLLL()` but runtime uses `JV8.LIZLLL()`!
- `JV8.smali` doesn't exist in decompilation
- Likely Kotlin synthetic/generated class at runtime
- Different method returns different type (X.TdI vs X.Wu4)
- Our patch location is WRONG

**Next Phase (Phase 6)**:
1. ✅ CONFIRMED: LIZLLL IS being called, but wrong method patched
2. Investigate: Is JV8 a Kotlin synthetic? Runtime-generated?
3. Find proper injection point: trace actual call stack
4. Alternative approach: Intercept at AwemeSharePackage.LJIJJLI() instead
5. Consider patching URL at source (before any shortening call)

### Issues Encountered & Resolutions

| Issue | Error | Resolution |
|-------|-------|-----------|
| Register type conflict | `register v2 has type Conflict` | Changed patch to use v0 only (true local reg) |
| Parameter register reuse | Smali allocated p0, p2 to temp vars | Explicitly use v0-v1 range only |
| Verifier rejection | DEX verification failed | Ensure temporaries don't shadow parameters |

### References

- **Patch target**: `X/UEU.LIZLLL()` in `classes15.dex`
- **URL shortener method**: `LX/UEa;->LIZ()` (called at line 3859)
- **Related methods**: `UEU.LIZLLL()` (primary), `AwemeSharePackage.LJIJJLI()` (calling context)
- **Test directory**: `/apps/tiktok/36.5.4/smali-tests/05-option-c-bypass/`

---

**Status**: Ready for Phase 6 (Share action testing and log verification)
