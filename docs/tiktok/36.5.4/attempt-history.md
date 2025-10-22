# TikTok 36.5.4 - Share URL Sanitization Attempt History

## Phase 6: URL Parameter Sanitizer - Production Implementation

**Date Completed**: 2025-10-20
**Status**: [WORKING] - 89% size reduction, validated
**Approach**: Whitelist sanitization - strip all query parameters from canonical URLs

### Summary

Discovered that `UEa.LIZ()` returns canonical URLs with massive tracking blobs (18 parameters, 505 bytes). Implemented URL parameter sanitizer using whitelist approach: strip everything after '?' character.

**Result**: Clean, tracking-free URLs (`https://www.tiktok.com/@user/video/ID`) delivered to all share channels.

### Technical Details

**Location**: `smali_classes15/X/UEU.smali:3866-3883`
**Method**: `UEU.LIZLLL()` - URL shortener orchestrator
**Register Changes**: `.registers 8` for safety

**Implementation**:
- **Whitelist approach**: Remove everything after '?'
- **Single operation**: `indexOf("?")` + `substring(0, index)`
- **Edge case safe**: Handles null, no '?', '?' at position 0
- **Register allocation**: v0=int (indexOf result), v1=String (URL), v2=String (const-string temps)

**Production Patch Code**:
```smali
move-result-object v1  # v1 = canonical URL from UEa.LIZ()

if-eqz v1, :keep_shortened_c  # Null check

const-string v2, "?"
invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v0

if-lez v0, :check_shortened  # Skip if no '?' or '?' at position 0

const/4 v2, 0x0
invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1  # v1 now contains clean URL

:check_shortened
# Continue to isEmpty check and rest of method
```

### Test Results

**Test 1: Copy Link (Clipboard)** - [PASS]

| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| URL Length | 568 chars | 63 chars | **89%** |
| Parameters | 18 tracking params | 0 params | **100%** |

**Before**: `https://www.tiktok.com/@pure.8k/video/7558444171787373846?_r=1&u_code=0&...utm_source=copy&...share_link_id=...` (505 bytes of tracking)

**After**: `https://www.tiktok.com/@pure.8k/video/7558444171787373846`

**Tracking Removed**: utm_* (marketing), share_* (analytics), _d/_r (internal), timestamps, JSON blobs

**Stability**: [PASS] No DEX verification errors, no crashes, app runs normally

### Build Artifacts

- `classes15-sanitizer-fixed.dex` - Production DEX (103MB)
- `phase6-sanitizer-fixed-aligned.apk` - Signed, aligned (323MB)
- `patches/phase6-url-sanitizer.smali.patch` - Clean patch file
- `logs/phase6-test-clipboard.log` - Test evidence

### Notes

1. **Whitelist Over Blacklist**: Future-proof against new tracking parameters
2. **Single-Purpose Registers**: v0=int, v2=String consistently throughout patch
3. **Branch Logic**: `if-lez v0` means "jump if v0 <= 0" (counterintuitive but correct)
4. **Edge Case Coverage**: Null check, no '?', '?' at position 0 all handled safely

### References

- **Patch file**: `patches/phase6-url-sanitizer.smali.patch` - Complete implementation
- **Test results**: `test-results.md` - Validation evidence
- **Logs**: `logs/phase6-test-clipboard.log` - Test evidence
- **Injection details**: `injection-points.md` - Phase 6 injection point
- **Status**: `obfuscation-map.md` - Phase 6 results

---

## Phase 7: ReVanced Port

**Date**: 2025-10-21
**Branch**: feat/tiktok-sanitize-share-urls
**Status**: [WORKING]

### Implementation

Ported Phase 6 Smali patch to ReVanced framework with annotation-based metadata:

**Architecture**:
- **Extension**: `ShareUrlSanitizer.clean()` (Java) - indexOf + substring logic
- **Patch**: `sanitizeShareUrlsPatch` (Kotlin BytecodePatch)
- **Location**: `misc/share/` category under TikTok patches
- **Strategy**: Always-on (no settings toggle) - privacy-first default
- **Register handling**: Dynamic extraction via `OneRegisterInstruction.registerA`

**Technical**:
- **Fingerprint**: Targets `p003X.UEU.LIZLLL(ILjava/lang/String;...)LX/Wu4;`
- **Injection point**: After `move-result-object` from `UEa.LIZ()` call (dynamic line detection)
- **Method call**: `ShareUrlSanitizer.clean(String)` returning sanitized String
- **Register safety**: Extracts destination register from instruction instead of hardcoding

### Validation

- **Gradle builds**: [PASS] - :patches:compileKotlin, :patches:jar, :extensions:tiktok:assembleRelease
- **CLI build**: [PASS] - Generated patches-5.43.1.rvp bundle (see `logs/phase6-revanced-build.log`)
- **Runtime test**: [PASS] - Clipboard overlay triggered, no crashes (see `logs/phase6-revanced-test.log`)
- **Behavior**: Identical to Phase 6 Smali patch (89% reduction expected)
- **APK hash**: `e8febd0c08b2f5fcbc51cffe0e417ca5a8cd54e90aa2b584e1e5d451eb0a164d`

### Files Created

**ReVanced Patches Repository** (feat/tiktok-sanitize-share-urls):
- `extensions/tiktok/src/main/java/app/revanced/extension/tiktok/share/ShareUrlSanitizer.java`
- `patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/Fingerprints.kt`
- `patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/SanitizeShareUrlsPatch.kt`

**Research Repository**:
- `apps/tiktok/36.5.4/revanced-builds/phase6-revanced-aligned.apk`
- `apps/tiktok/36.5.4/revanced-builds/phase6-revanced-aligned.apk.sha256`
- `apps/tiktok/36.5.4/logs/phase6-revanced-build.log`
- `apps/tiktok/36.5.4/logs/phase6-revanced-test.log`

### Notes

1. **Modern ReVanced**: Uses annotation-based metadata (no separate JSON files)
2. **Dynamic register extraction**: Safer than hardcoding - extracts from actual instruction
3. **Gradle API checking**: `:patches:apiDump` required before successful build
4. **CLI syntax**: `-p` for patches bundle, `-e` for enable patch by name
5. **Android SDK**: Requires `local.properties` with `sdk.dir` for extension builds

---

**Status**: [COMPLETE] - ReVanced patch validated against TikTok 36.5.4. Ready for upstream PR consideration.

---

## Archive: Superseded Approaches

### Phase 5: Option C Bypass - Register-Safe Canonical URL Swap

**Date**: 2025-10-20
**Status**: [DISPROVEN] by Phase 6
**Why Superseded**: Discovered that `UEa.LIZ()` returns canonical URLs with tracking blobs, not shortened URLs. Approach of detecting/swapping shortened URLs was based on incorrect assumption about what LIZLLL returns.

**Summary**: Attempted to detect shortened vm./vt.tiktok.com URLs and replace with canonical URLs. Patch compiled and DEX verified successfully, but testing revealed the premise was wrong - no shortened URLs appear at this layer. Instead, canonical URLs arrive with massive tracking parameters that need removal (89% of URL size). This discovery led directly to Phase 6's parameter sanitization approach.

**Key Technical Achievements** (carried forward to Phase 6):
- Proper register allocation: `.registers 6` with v0-v1 local, v2-v5 parameters
- DEX verifier type safety: Must use true local registers for temporary operations
- Label hygiene: Suffixed labels prevent collisions (`:swap_canonical_c`, `:keep_shortened_c`)
- Null safety patterns: Always check null before calling string methods

**Test Results**: [PASS] Compilation and installation, [BROKEN] Functional goal (no shortened URLs to detect)

**Build Artifacts**: `smali-tests/05-option-c-bypass/phase5-final-aligned.apk`, `classes15-final.dex`

**References**: See `injection-points.md` Phase 5 section for complete implementation details.
