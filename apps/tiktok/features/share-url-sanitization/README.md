# Share URL Sanitization - TikTok

## Summary

**Problem**: TikTok share URLs contain 18+ tracking parameters (utm_*, share_*, _d, _r, timestamps, JSON blobs) totaling 505 bytes. These expose user sharing behavior to analytics platforms.

**Solution**: Whitelist sanitization - strip everything after `?` character, preserving only the canonical URL base (`https://www.tiktok.com/@user/video/ID`).

**Status**: Passed - Both Smali (Phase 6) and ReVanced (Phase 7) implementations validated

**Patch**: `feat/tiktok-sanitize-share-urls` in `revanced-src/revanced-patches`

---

## Version Map

| Version | Status | Smali Tests | Logs | Base APK |
|---------|--------|-------------|------|----------|
| 36.5.4 | Passed | [36.5.4/smali-tests](36.5.4/smali-tests) | [36.5.4/logs](36.5.4/logs) | [apks/36.5.4/base.apk.info](../../apks/36.5.4/base.apk.info) |
| 36.6.0 | Pending | - | - | - |

---

## Technical Reference

### Obfuscation Map

| Obfuscated Class | Purpose | Key Methods | Status |
|------------------|---------|-------------|--------|
| `p003X.UEU` | **URL transformer/sanitizer** | `LIZLLL(int, String, String, String)` | Patched |
| `p003X.UEa` | URL builder (adds tracking) | `LIZ()` | Found |
| `p003X.C54243JOk` | Share package builder | `LIZ(Aweme, Context, ...)` | Found |

**URL Flow**:
```
Aweme.getShareUrl() → Canonical URL
  ↓
C54243JOk.LIZ() → Build AwemeSharePackage
  ↓
AwemeSharePackage.LJIJJLI() → Entry point
  ↓
UEU.LIZLLL() ← INJECTION POINT
  ↓
UEa.LIZ() → Adds 18 tracking parameters
  ↓
Distribution (Intent/Clipboard)
```

**Tracking Parameters** (18 total, 505 bytes):
- Marketing: `utm_source`, `utm_campaign`, `utm_medium` (3)
- Analytics: `share_iid`, `share_link_id`, `share_app_id`, `share_item_id` (4)
- Internal: `_d`, `_r`, `u_code` (3)
- Behavioral: `timestamp`, `social_share_type` (2)
- Business: `ugbiz_name`, `ug_btm` (2)
- Dynamic: `link_reflow_popup_iteration_sharer` JSON blob (1)

### Injection Points

**Location**: `smali_classes15/X/UEU.smali:3866`

**Method**: `LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)LX/Wu4;`

**Register Allocation**:
| Register | Type | Purpose |
|----------|------|---------|
| v0 | int | indexOf result (position of '?') |
| v1 | String | URL (modified in-place) |
| v2 | String | const-string temporaries |

**Implementation**:
```smali
move-result-object v1              # v1 = URL from UEa.LIZ()

if-eqz v1, :keep_shortened_c       # Null safety
goto :start_sanitize

:start_sanitize
const-string v2, "?"
invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v0

if-lez v0, :check_shortened        # Skip if no '?' or '?' at position 0

const/4 v2, 0x0
invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1              # v1 now contains clean URL

:check_shortened
# Continue to rest of method

:keep_shortened_c
# Fall through (null case)
```

**Edge Cases**:
- Null URL: Skip sanitization via `if-eqz`
- No query string: `indexOf("?")` returns -1, skip via `if-lez`
- Malformed ('?' at position 0): Skip via `if-lez`

### Fingerprints

**Fingerprint for ReVanced**:
```kotlin
internal val urlShorteningFingerprint = fingerprint {
    returnType = "LX/Wu4;"
    parameters = listOf("I", "Ljava/lang/String;", "Ljava/lang/String;", "Ljava/lang/String;")
    strings = listOf("share_url")
}
```

**Classes/Methods**:
- Extension: `app.revanced.extension.tiktok.share.ShareUrlSanitizer.clean(String)`
- Patch: `app.revanced.patches.tiktok.misc.share.sanitizeShareUrlsPatch`

### Patch References

**ReVanced Implementation**:
- Extension (Java): `revanced-src/revanced-patches/extensions/tiktok/src/main/java/app/revanced/extension/tiktok/share/ShareUrlSanitizer.java`
- Fingerprint (Kotlin): `revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/Fingerprints.kt`
- Patch (Kotlin): `revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/SanitizeShareUrlsPatch.kt`

**Branch**: `feat/tiktok-sanitize-share-urls`

---

## Validation

### Test Matrix

| Scenario | Test | Result | Evidence |
|----------|------|--------|----------|
| Copy link | Clipboard share | Passed | [phase6-test-clipboard.log](36.5.4/logs/phase6-test-clipboard.log) |
| URL format | Canonical structure | Passed | Clean: `https://www.tiktok.com/@pure.8k/video/7558444171787373846` |
| Parameter removal | All 18 params stripped | Passed | 568 chars → 63 chars (89% reduction) |
| Stability | App crashes/hangs | None | Full test run, no exceptions |
| DEX compilation | Bytecode verification | Passed | 103MB DEX, no VerifyError |
| ReVanced build | Gradle + CLI | Passed | Fingerprint matched, injection applied |

### Size Reduction

| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| URL Length | 568 chars | 63 chars | **89%** |
| Parameter Count | 18 | 0 | **100%** |

**Example**:
```
Before: https://www.tiktok.com/@pure.8k/video/7558444171787373846?_r=1&u_code=0&...utm_source=copy&...share_link_id=...

After:  https://www.tiktok.com/@pure.8k/video/7558444171787373846
```

### Test Logs

- Phase 6 (Smali): [36.5.4/logs/phase6-test-clipboard.log](36.5.4/logs/phase6-test-clipboard.log)
- Phase 7 (ReVanced build): [36.5.4/logs/phase6-revanced-build.log](36.5.4/logs/phase6-revanced-build.log)
- Phase 7 (ReVanced runtime): [36.5.4/logs/phase6-revanced-test.log](36.5.4/logs/phase6-revanced-test.log)

---

## Timeline & Decisions

- **2025-10-19**: Phases 1-3 - Identified AwemeSharePackage as share entry point via JADX analysis
- **2025-10-19**: Phase 4 - Discovered canonical URL at `LJIJJLI()` line 2795, tracking blob added by `UEa.LIZ()`
- **2025-10-20**: Phase 5 (Superseded) - Attempted to detect and swap shortened URLs (vm./vt. format), but discovered URLs are already canonical with tracking blob, not shortened. Approach abandoned.
- **2025-10-20**: Phase 6 - Implemented whitelist URL sanitizer: strip everything after `?` character. Validated in Smali with 89% size reduction, all 18 parameters removed.
- **2025-10-21**: Phase 7 - Ported Phase 6 to ReVanced BytecodePatch framework. Build succeeded (Gradle + CLI), runtime behavior matches Smali implementation.

**Why Whitelist Over Blacklist**:
1. Future-proof - new tracking parameters automatically removed
2. Simpler logic - one `indexOf` + one `substring` operation
3. Predictable output - canonical URLs always follow `@user/video/ID` pattern
4. No enumeration needed - don't maintain list of known parameters

---

## References

- WORKFLOW.md Phase 2: [../../../../WORKFLOW.md#phase-2-smali-testing](../../../../WORKFLOW.md#phase-2-smali-testing)
- WORKFLOW.md Phase 3: [../../../../WORKFLOW.md#phase-3-revanced-patch-porting](../../../../WORKFLOW.md#phase-3-revanced-patch-porting)
- APK info: [../../apks/36.5.4/base.apk.info](../../apks/36.5.4/base.apk.info)

---

**Last Updated**: 2025-10-21
**Status**: Passed
