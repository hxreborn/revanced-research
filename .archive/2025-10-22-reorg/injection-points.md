# Verified Injection Points - TikTok 36.5.4

## Discovery Path (Phase 2-4) - 2025-10-19 to 2025-10-20

### Failed Attempts

Systematic testing of potential injection points to locate where URLs are processed:

| Attempt | Target Method | Location | Result | Reason |
|---------|--------------|----------|--------|--------|
| Test 1 | `UEU.LIZJ()` | `X/UEU.smali:150` | [FAIL] | Method never called during share flow |
| Test 2 | `UGk.LJ()` | `X/UGk.smali:3142` | [FAIL] | Method exists in bytecode but not executed |
| Test 3 | `AwemeSharePackage.LJIJJ()` | `AwemeSharePackage.smali:21638` | [FAIL] | Shortened URL already in List - too late in pipeline |

### Breakthrough Discovery

**Critical Finding**: URL arrives as **CANONICAL** at `AwemeSharePackage.LJIJJLI()` line 2795:
```smali
iget-object v4, p0, Lcom/ss/android/ugc/aweme/share/base/model/BaseSharePackage;->url:Ljava/lang/String;
# v4 = "https://www.tiktok.com/@user/video/ID?params..."
```

**URL Processing Flow**:
1. `LJIJJLI()` receives canonical URL from BaseSharePackage
2. `ULX.LIZ(v4, p0)` formats URL (still canonical)
3. `UEU.LIZLLL(v3, v2, v1, v0)` at line 2932 - shortening orchestrator
4. Inside LIZLLL: `UEa.LIZ()` returns URL with massive tracking blob (18 params, 505 bytes)

**Strategic Pivot**: Instead of preventing shortening, discovered URLs already have tracking parameters. Need to sanitize parameters, not detect shortened URLs.

### Verification (Phase 4)

**Test Environment**: Fresh decompilation with minimal logging patch
**Result**: [PASS] Injection point at line 3866 in `X/UEU.smali` verified safe
- Compilation: No errors (103MB DEX)
- Installation: No VerifyError or crashes
- DEX verification: Passed without issues

---

## Phase 6: URL Parameter Sanitizer (PRODUCTION IMPLEMENTATION)

**Date**: 2025-10-20
**Status**: [PASS] Complete and tested
**Strategy**: Whitelist approach - strip all query parameters

### Injection Location

**File**: `smali_classes15/X/UEU.smali`
**Method**: `LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)LX/Wu4;`
**Line**: 3866 (after `move-result-object v1` from `UEa.LIZ()` call)
**Directive**: `.registers 6` → `.registers 8` (added v2-v3 for temporaries)

### Register Allocation

- **v0**: int (indexOf result)
- **v1**: String (URL - modified in-place, initially contains result from UEa.LIZ())
- **v2**: String (const-string temporaries)
- **v3**: String (reserved/unused in production)
- **v4-v5**: Method parameters (p0-p3 mapped to v2-v5 originally)

### Implementation Code

```smali
move-result-object v1  # v1 = canonical URL from UEa.LIZ()

# Null check
if-eqz v1, :keep_shortened_c

# Find '?' character
const-string v2, "?"
invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v0

# Skip if no '?' or '?' at position 0
if-lez v0, :check_shortened

# Extract base URL (remove query string)
const/4 v2, 0x0
invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1

:check_shortened
# Continue to isEmpty check...

:keep_shortened_c
# Fall through to rest of method
```

### Edge Cases Handled

1. **Null URL** (`v1 == null`): Skip sanitization via `if-eqz` guard
2. **No query string** (`indexOf` returns -1): Skip sanitization via `if-lez`
3. **Query string at position 0** (`indexOf` returns 0): Skip sanitization via `if-lez`
4. **Valid query string** (position > 0): Execute `substring(0, index)` to remove parameters

**Branch Logic**: `if-lez v0` means "jump to label if v0 <= 0", so sanitization only occurs when v0 > 0 (valid '?' position).

### Test Results

**Build**: `phase6-sanitizer-fixed-aligned.apk`
**Test**: Copy Link to clipboard

| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| URL Length | 568 chars | 63 chars | **89%** |
| Parameters | 18 tracking params | 0 params | **100%** |

**Parameters Removed**: utm_* (marketing), share_* (analytics), _d/_r (internal), timestamps, JSON blobs

**Stability**: [PASS] - No DEX verification errors, no crashes, normal app operation

### Build Artifacts

- **Patch file**: `patches/phase6-url-sanitizer.smali.patch` - Complete implementation
- **Test results**: `test-results.md` - Validation evidence
- **Test logs**: `logs/phase6-test-clipboard.log` - Logcat capture with URL_BEFORE_CLEAN/URL_AFTER_CLEAN tags
- **APK**: `smali-tests/05-option-c-bypass/phase6-sanitizer-fixed-aligned.apk`

### Key Technical Insights

1. **Whitelist Approach**: Future-proof against new tracking parameters TikTok may add
2. **Register Type Safety**: v0 exclusively int, v1/v2 exclusively String - prevents DEX verification conflicts
3. **Label Hygiene**: Suffix `:_c` on labels (`:keep_shortened_c`, `:check_shortened`) prevents collisions
4. **Single Operation**: One `indexOf` + one `substring` - minimal performance impact
5. **Production Ready**: Debug logs removed, core logic validated
6. **Always-On Behavior**: Uses shared patch name ("Sanitize sharing links") but is **always enabled by default** with no settings toggle (unlike Spotify/Instagram implementations). This is a privacy-first approach for TikTok.

### References

- **Complete patch**: `patches/phase6-url-sanitizer.smali.patch`
- **Test matrix**: `test-results.md`
- **Attempt log**: `attempt-history.md` - Phase 6 section
- **Obfuscation map**: `obfuscation-map.md` - UEU/UEa method details
- **ReVanced port**: Phase 7 implementation in `attempt-history.md`

---

**Status**: [COMPLETE] - Production Smali patch validated. ReVanced port completed in Phase 7.
