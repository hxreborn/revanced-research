# TikTok 36.5.4 - Project Overview

## Objective

Remove tracking parameters from TikTok share URLs to protect user privacy. Target parameters:
- `utm_*` - Marketing tracking (utm_source, utm_campaign, utm_medium)
- `share_*` - Share analytics (share_iid, share_link_id, share_app_id, share_item_id)
- `_d`, `_r`, `u_code` - TikTok internal tracking
- `timestamp`, `social_share_type` - Behavioral analytics
- `ugbiz_name`, `ug_btm` - Business unit tracking
- JSON blobs (e.g., `link_reflow_popup_iteration_sharer`)

## APK Metadata

| Property | Value |
|----------|-------|
| **Package** | `com.zhiliaoapp.musically` (TikTok China fork) |
| **Version** | 36.5.4 |
| **Architecture** | arm64-v8a, armeabi-v7a |
| **Min SDK** | 24 (Android 7.0) |
| **Target SDK** | 35 (Android 15) |
| **API Level** | 35 |

### Original APK Hash (SHA256)
```
[See apps/tiktok/36.5.4/apk-metadata.txt]
```

## Research Workspace

| Path | Contents |
|------|----------|
| `apps/tiktok/36.5.4/decompiled-jadx/` | JADX decompilation with Java sources + deobfuscation |
| `apps/tiktok/36.5.4/decompiled-smali/` | Smali bytecode (47 DEX shards, 50 classes folders) |
| `apps/tiktok/36.5.4/smali-tests/` | Iterative test builds (01-canonical-url through 05-option-c-bypass) |
| `apps/tiktok/36.5.4/patches/` | Final patch files (`.smali.patch` format) |
| `apps/tiktok/36.5.4/logs/` | Test execution logs and evidence |
| `apps/tiktok/36.5.4/verification/` | Analysis notes and obfuscation mappings |

## Notes

### 1. Whitelist Over Blacklist
Future-proof approach: Strip everything after `?` character (all tracking lives in query string). Prevents breakage when TikTok adds new tracking parameters.

### 2. URL Flow Analysis
- Canonical URLs arrive at **AwemeSharePackage.LJIJJLI()** (line 2795) with zero tracking parameters
- Tracking blob is **added** by UEa.LIZ() (18 parameters, 505 bytes)
- No shortening orchestrator needs to be bypassed; parameters can be removed cleanly

### 3. Register Type Safety
- Smali verifier enforces strict typing: v0 must always be `int`, v1/v2 must always be `String`
- Mixing types (e.g., storing int result in String register) causes DEX verification failures
- Solution: Allocate registers by type, never repurpose them

### 4. Label Hygiene
- Suffix labels with `_c` or unique identifier to prevent collisions
- Pattern: `:keep_shortened_c`, `:check_shortened` (prevents collision with other patches)
- Improves debuggability and reduces merge conflicts

### 5. Smali-First Validation
- Prove concept in raw Smali **before** porting to ReVanced framework
- Test in emulator/device with logging before removing debug output
- Catch DEX verification errors early; prevents broken ReVanced builds

### 6. ReVanced Dynamic Register Extraction
- Modern ReVanced extracts target register from actual instruction: `OneRegisterInstruction.registerA`
- Safer than hardcoding register numbers (v0, v1, etc.)
- Fingerprints use bytecode matching, not line numbers (version-resistant)

## Build Commands

### Smali Testing (Phase 6)
```bash
# Extract target DEX
cd apps/tiktok/36.5.4/smali-tests/05-option-c-bypass
unzip -j ../../../apps/tiktok/36.5.4/base.apk classes15.dex

# Decompile
baksmali d classes15.dex -o smali-classes15/

# Edit and recompile
vim smali_classes15/X/UEU.smali  # Apply sanitizer patch
smali a smali_classes15/ -o classes15-patched.dex --api 35

# Inject and sign
zip -j patched.apk classes15-patched.dex
zipalign -v 4 patched.apk patched-aligned.apk
apksigner sign --ks ~/.android/debug.keystore --ks-pass pass:android patched-aligned.apk

# Test
adb install -r patched-aligned.apk
# Observe: Copy share link, verify no tracking params
```

### ReVanced Build (Phase 7)
```bash
cd revanced-src/revanced-patches

# Compile patch
./gradlew build

# Apply to APK
java -jar revanced-src/revanced-cli.jar \
  -a base.apk \
  --patch "Sanitize share URLs" \
  --out patched.apk

# Verify
apksigner verify patched.apk
sha256sum patched.apk
```

## Validation Evidence

| Test | Result | Log |
|------|--------|-----|
| Smali DEX compilation | [PASS] | No errors, valid bytecode |
| APK installation | [PASS] | No verification errors |
| Runtime behavior | [PASS] | URL sanitized on share |
| Parameter removal | [PASS] | 18 params → 0 params |
| Size reduction | [PASS] | 568 chars → 63 chars (89%) |
| App stability | [PASS] | No crashes, normal operation |
| ReVanced build | [PASS] | Gradle success, CLI success |
| ReVanced runtime | [PASS] | Share tested, no errors |

See `apps/tiktok/36.5.4/logs/` for detailed evidence.

## Timeline

- **2025-10-19**: Phases 1-3 (reconnaissance, analysis) - identified AwemeSharePackage as share entry point
- **2025-10-19**: Phase 4 (discovery) - discovered canonical URL at LJIJJLI() line 2795, URL tracking at UEa.LIZ()
- **2025-10-20**: Phase 5 (explored) - bypass shortening orchestrator (superseded by Phase 6 discovery)
- **2025-10-20**: Phase 6 (success) - URL parameter sanitizer implemented and validated in Smali
- **2025-10-21**: Phase 7 (success) - ReVanced port completed, tested, ready for upstream PR

## Status

**[COMPLETE]** - Both Smali patch and ReVanced port validated successfully. Ready for upstream submission.

---

See [index.md](index.md) for navigation and phase details.
