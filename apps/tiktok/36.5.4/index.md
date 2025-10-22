# TikTok 36.5.4 - Share URL Sanitization Patch

**Status**: [COMPLETE] Phase 7 - ReVanced port validated

**Target**: Remove tracking parameters from share URLs

**Result**: 89% size reduction (568 → 63 chars), 100% tracking parameter removal

---

## Quick Links

| Item | Location |
|------|----------|
| **Live Patch (Java)** | `revanced-src/revanced-patches/extensions/tiktok/src/main/java/app/revanced/extension/tiktok/share/ShareUrlSanitizer.java` |
| **Live Patch (Kotlin)** | `revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/SanitizeShareUrlsPatch.kt` |
| **Smali Reference** | `apps/tiktok/36.5.4/patches/phase6-url-sanitizer.smali.patch` |
| **Validation Evidence** | `apps/tiktok/36.5.4/logs/phase6-test-clipboard.log` |

---

## Phase Timeline

| Phase | Date | Focus | Status |
|-------|------|-------|--------|
| **Phase 4** | 2025-10-19 | Discovery & verification | [PASS] |
| **Phase 5** | 2025-10-20 | Bypass shortening orchestrator | [DISPROVEN] |
| **Phase 6** | 2025-10-20 | URL parameter sanitizer (Smali) | [VALIDATED] |
| **Phase 7** | 2025-10-21 | ReVanced port | [VALIDATED] |

**See [phases.md](phases.md) for complete development narratives.**

---

## Documentation Index

- **[overview.md](overview.md)** - APK metadata, objectives, notes
- **[phases.md](phases.md)** - Phase 4-7 development narratives (discovery through validation)
- **[injection-points.md](injection-points.md)** - Technical reference for injection location
- **[obfuscation-map.md](obfuscation-map.md)** - Class/method mappings and tracking parameters
- **[validation-log.md](validation-log.md)** - Test scenarios and results summary
- **[attempt-history.md](attempt-history.md)** - Complete attempt timeline and learnings

---

## Key Findings

### URL Processing Flow
1. **AwemeSharePackage.LJIJJLI()** (line 2795) - Entry point with canonical URL
2. **UEU.LIZLLL()** (line 3866) - Orchestrator that calls UEa.LIZ()
3. **UEa.LIZ()** - Returns canonical URL **with massive tracking blob** (18 params, 505 bytes)
4. **Distribution** - URL goes to Intent (WhatsApp/Twitter/SMS) or Clipboard

### Injection Strategy
- **Location**: `smali_classes15/X/UEU.smali:3866` (after `move-result-object` from `UEa.LIZ()`)
- **Approach**: Whitelist sanitization - strip everything after `?` character
- **Register Safe**: v0=int, v1/v2=String (no DEX verification conflicts)
- **Edge Cases**: Null check, no `?`, `?` at position 0 - all handled

### Results
- **Before**: `https://www.tiktok.com/@user/video/ID?_r=1&u_code=0&utm_source=copy&...` (568 chars)
- **After**: `https://www.tiktok.com/@user/video/ID` (63 chars)
- **Removed**: 18 tracking parameters (utm_*, share_*, _d, _r, timestamps, JSON blobs)

---

## Build Information

**APK Metadata**:
- Package: `com.zhiliaoapp.musically` (TikTok China fork, matches 36.5.4 global version)
- Version: 36.5.4
- Original APK: `base.apk` (decompiled, patched, rebuilt)

**ReVanced Build** (Phase 7):
- APK SHA256: `e8febd0c08b2f5fcbc51cffe0e417ca5a8cd54e90aa2b584e1e5d451eb0a164d`
- Branch: `feat/tiktok-sanitize-share-urls`
- Status: Validated against TikTok 36.5.4, ready for upstream PR

---

## References

All detailed technical documentation is organized in:
- **Research workspace**: `apps/tiktok/36.5.4/` (raw decompilation, test builds, patches)
- **Documentation**: `docs/tiktok/36.5.4/` (narratives, reference specs, validation evidence)
- **Live patch code**: `revanced-src/revanced-patches/` (upstream repository)
