# Obfuscated Class Mapping - TikTok 36.5.4

**Status**: Phase 6 complete - URL parameter sanitizer implemented and tested. Phase 7 ReVanced port validated.

---

## Share-Related Classes (Reference)

| Obfuscated Class | Purpose | Key Methods | Location | Status |
|------------------|---------|------------|----------|--------|
| `p003X.UEU` | **PRIMARY: URL transformer/sanitizer** | `LIZLLL(int, String, String, String)` | classes15.dex | [PASS] **Patched** |
| `p003X.UEa` | URL builder returning canonical+tracking | `LIZ()` | classes15.dex | [PASS] Found |
| `p003X.C54243JOk` | Gateway - builds AwemeSharePackage from Aweme | `LIZ(Aweme, Context, ...)` | classes9.dex | [PASS] Found |
| `com.appsflyer.share.ShareInviteHelper` | AppsFlyerLib share helper | `generateInviteUrl()` | classes20.dex | [PASS] Found |
| `com.bytedance.android.livesdkapi.depend.model.live.Room` | Live room with share_url field | `shareUrl` (field) | - | [PASS] Found |

**Note**: `com.p124ss.ugc.aweme.creation.base.ShareModel` was analyzed but found to only define Open Platform metadata, no share URL logic relevant to this patch.

---

## URL Construction Flow

```
Aweme.getShareUrl()
  ↓ Returns canonical URL

C54243JOk.LIZ()
  ↓ Builds AwemeSharePackage from Aweme

BaseSharePackage
  ↓ Stores URL (passes through unchanged)

AwemeSharePackage.LJIJJLI()
  ↓ Entry point with canonical URL

UEU.LIZLLL()
  ↓ URL processing orchestrator [INJECTION POINT]

UEa.LIZ()
  ↓ Returns canonical URL with massive tracking blob

Distribution
  ↓ URL flows to Intent (WhatsApp/Twitter/SMS) or Clipboard
```

**Critical Discovery**: URL arrives canonical at `LJIJJLI()`, gets tracking parameters **added** by `UEa.LIZ()`, needs sanitization before distribution.

---

## Tracking Parameters (Target for Removal)

| Category | Parameters | Purpose |
|----------|------------|---------|
| Marketing | `utm_source`, `utm_campaign`, `utm_medium` | Campaign tracking (Google Analytics) |
| Analytics | `share_iid`, `share_link_id`, `share_app_id`, `share_item_id` | Share activity tracking |
| Internal | `_d`, `_r`, `u_code` | TikTok-internal tracking codes |
| Behavioral | `timestamp`, `social_share_type` | Temporal and interaction analytics |
| Business | `ugbiz_name`, `ug_btm` | Business unit identification |
| Dynamic | `link_reflow_popup_iteration_sharer` | JSON blob with dynamic tracking |

**Total**: 18 parameters, 505 bytes

**Whitelist Removal Strategy**: Remove everything after `?` character (future-proof against new parameters)

---

## Implementation Details

### Phase 6: URL Parameter Sanitizer

**Date**: 2025-10-20
**Status**: [PASS] COMPLETE - Production-ready

**Location**: `smali_classes15/X/UEU.smali:3866`
**Method**: `UEU.LIZLLL(int, String, String, String)LX/Wu4;`
**Approach**: Whitelist sanitization - remove everything after `?` character

**Register Allocation**:
- `.registers 8` (upgraded from 6)
- v0: int (indexOf result)
- v1: String (URL - modified in-place)
- v2: String (const-string temporaries)
- v3: String (reserved/unused)

**Implementation** (see [injection-points.md](injection-points.md) for complete code):
- Null safety check via `if-eqz`
- Find `?` position via `indexOf()`
- Extract base URL via `substring(0, index)`
- Edge case handling for -1 (no query string) and 0 (malformed URL)

### Test Results

| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| URL Length | 568 chars | 63 chars | **89%** |
| Parameters | 18 tracking params | 0 params | **100%** |

**Example Transformation**:
- Before: `https://www.tiktok.com/@pure.8k/video/7558444171787373846?_r=1&u_code=0&...` (568 chars)
- After: `https://www.tiktok.com/@pure.8k/video/7558444171787373846` (63 chars)

**Validation**: [PASS] DEX compilation, APK installation, runtime execution, parameter removal, edge cases

### Why Whitelist Over Blacklist?

1. **Future-proof**: New tracking parameters don't break the patch (they get removed anyway)
2. **Simpler logic**: One `indexOf` + one `substring` operation
3. **Predictable output**: Clean URLs always follow pattern `@user/video/ID`
4. **No enumeration needed**: Don't maintain a list of known parameters

---

## Superseded Approaches

### Phase 5: Canonical URL Swap (SUPERSEDED)

**Date**: 2025-10-20
**Status**: [DISPROVEN] by Phase 6
**Why**: Premise disproven - testing revealed URLs at `UEa.LIZ()` are not shortened (vm./vt. format), they're canonical with tracking blob

**Approach Attempted**: Detect shortened vm.tiktok.com/vt.tiktok.com URLs and replace with canonical form

**Technical Achievement**: Established register allocation patterns (`v0` for int, `v1` for String) that Phase 6 reused

**Build Artifacts**: `smali-tests/05-option-c-bypass/phase5-final-aligned.apk`

Superseded by Phase 6 (see [phases.md](phases.md) for full timeline).

---

## Build Artifacts

| Artifact | Location | Purpose |
|----------|----------|---------|
| Smali patch | `apps/tiktok/36.5.4/patches/phase6-url-sanitizer.smali.patch` | Manual patch file reference |
| DEX file | `apps/tiktok/36.5.4/smali-tests/05-option-c-bypass/classes15-sanitizer-fixed.dex` | Compiled bytecode |
| APK | `apps/tiktok/36.5.4/smali-tests/05-option-c-bypass/phase6-sanitizer-fixed-aligned.apk` | Test APK |
| Logs | `apps/tiktok/36.5.4/logs/phase6-test-clipboard.log` | Logcat evidence |

---

## Search Resources

**JADX decompilation**: `apps/tiktok/36.5.4/decompiled-jadx/sources/` (166,751 Java sources, 99% deobfuscated)

**Smali bytecode**: `apps/tiktok/36.5.4/decompiled-smali-full/smali_classes*/` (248,437 complete files)

**Search indices** (built during Phase 1-2):
- `indices/strings.txt` - 39,246 URL/link/share patterns
- `indices/handlers.txt` - 30,477 onClick/button/clip patterns
- `indices/bundles.txt` - 94,225 Bundle/Intent/extras patterns
- `indices/canonical-urls.txt` - 546,958 video_id/aweme_id/tiktok.com patterns
- `indices/specific.txt` - 188 copylink/share_url/utm_ patterns

---

## Related Documentation

- **Injection point details**: [injection-points.md](injection-points.md)
- **Phase narratives**: [phases.md](phases.md)
- **Validation evidence**: [validation-log.md](validation-log.md)
- **Phase 6 walkthrough**: [phases.md#phase-6-smali-implementation](phases.md)
- **Phase 7 ReVanced**: [phases.md#phase-7-revanced-port](phases.md)

---

**Status**: [COMPLETE] - Production Smali implementation validated and ported to ReVanced framework.
