# TikTok 36.5.4 - Obfuscated Class Mapping

> **Status**: Phase 6 complete - URL parameter sanitizer implemented and tested. Phase 7 ReVanced port validated.

## Share-Related Classes

| Obfuscated Class | Purpose | Key Methods | Location | Status |
|------------------|---------|------------|----------|--------|
| `p003X.UEU` | **PRIMARY: URL transformer/sanitizer** | `LIZLLL(int, String, String, String)` | classes15.dex | [PASS] **Patched** |
| `p003X.UEa` | URL builder returning canonical+tracking | `LIZ()` | classes15.dex | [PASS] Found |
| `p003X.C54243JOk` | Gateway - builds AwemeSharePackage from Aweme | `LIZ(Aweme, Context, ...)` | classes9.dex | [PASS] Found |
| `com.appsflyer.share.ShareInviteHelper` | AppsFlyerLib share helper | `generateInviteUrl()` | classes20.dex | [PASS] Found |
| `com.bytedance.android.livesdkapi.depend.model.live.Room` | Live room with share_url field | `shareUrl` (field) | - | [PASS] Found |

**REMOVED**: `com.p124ss.ugc.aweme.creation.base.ShareModel` - Only defines Open Platform metadata, no share URL logic

## Tracking Parameters

**Target for Removal**:
- `utm_*` - Marketing tracking (utm_source, utm_campaign, utm_medium)
- `share_*` - Share analytics (share_iid, share_link_id, share_app_id, share_item_id)
- `_d`, `_r`, `u_code` - TikTok internal tracking
- `timestamp`, `social_share_type` - Behavioral analytics
- `ugbiz_name`, `ug_btm` - Business unit tracking
- JSON blobs (e.g., `link_reflow_popup_iteration_sharer`)

## Phase 1: Discovery Path (2025-10-19)

### Key Findings

**URL Construction Flow**:
1. `Aweme.getShareUrl()` → Returns canonical URL
2. `C54243JOk.LIZ()` → Builds AwemeSharePackage from Aweme
3. `BaseSharePackage` → Stores URL (passes through unchanged)
4. `AwemeSharePackage.LJIJJLI()` → Entry point with canonical URL
5. `UEU.LIZLLL()` → URL processing orchestrator **[INJECTION POINT]**
6. `UEa.LIZ()` → Returns canonical URL with massive tracking blob
7. Distribution → URL flows to Intent (WhatsApp/Twitter/SMS) or Clipboard

**Critical Discovery**: URL arrives canonical at `LJIJJLI()`, gets tracking parameters added by `UEa.LIZ()`, needs sanitization before distribution.

### Verification Results

- [PASS] JVM descriptors verified (byte-for-byte match)
- [PASS] Smali shard paths confirmed consistent
- [PASS] Share plumbing verified (ACTION_SEND, EXTRA_TEXT, ClipboardManager)
- [PASS] Complete URL construction path verified end-to-end
- [PASS] No lambdas - straightforward patching

**Patch Target Identified**: `UEU.LIZLLL()` in `smali_classes15/X/UEU.smali` line 3866

---

## Phase 6: URL Parameter Sanitizer (Production Implementation)

**Date**: 2025-10-20
**Status**: [PASS] COMPLETE - Production-ready
**Build**: `phase6-sanitizer-fixed-aligned.apk`

### Discovery

Testing revealed `UEa.LIZ()` returns canonical URLs with **massive tracking blob** (18 parameters, 505 bytes):
```
https://www.tiktok.com/@user/video/ID?_r=1&u_code=0&...utm_source=copy&...share_link_id=...
```

**Strategy Pivot**: Strip all tracking parameters from canonical URLs (whitelist approach).

### Patch Details

**Location**: `smali_classes15/X/UEU.smali:3866-3883`
**Method**: `UEU.LIZLLL(int, String, String, String)LX/Wu4;`
**Approach**: Remove everything after '?' character

**Register Allocation**:
- `.registers 8` (upgraded from 6)
- v0: int (indexOf result)
- v1: String (URL - modified in-place)
- v2: String (const-string temporaries)
- v3: String (reserved/unused)

**Production Code**:
```smali
move-result-object v1  # v1 = canonical URL with tracking blob

if-eqz v1, :keep_shortened_c  # Null check

const-string v2, "?"
invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v0

if-lez v0, :check_shortened  # Skip if no '?' or '?' at position 0

const/4 v2, 0x0
invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1  # v1 now contains clean URL

:check_shortened
# Continue to isEmpty check...
```

### Test Results

**Test 1: Copy Link (Clipboard)** - [PASS]

| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| URL Length | 568 chars | 63 chars | **89%** |
| Parameters | 18 tracking params | 0 params | **100%** |

**Before**: `https://www.tiktok.com/@pure.8k/video/7558444171787373846?_r=1&u_code=0&...` (505 bytes tracking)

**After**: `https://www.tiktok.com/@pure.8k/video/7558444171787373846`

### Edge Cases Validated

- [PASS] URL with 18 parameters - all removed successfully
- [PASS] Nested JSON in query string - handled correctly
- [PASS] Special characters (&, =, %7B, etc.) - no crashes
- [PASS] URL without '?' - indexOf returns -1, if-lez jumps safely
- [PASS] Null URL - handled by if-eqz guard

### Build Results

- [PASS] DEX compiles cleanly (103MB)
- [PASS] Android runtime verification passed
- [PASS] App runs stable, no crashes
- [PASS] Clean URLs delivered to all share channels
- [PASS] Production-ready (debug logs removed)

### Documentation

- **Patch file**: `patches/phase6-url-sanitizer.smali.patch`
- **Test results**: `PHASE6-TEST-RESULTS.md`
- **Test logs**: `logs/phase6-test-clipboard.log`, `logs/phase6-revanced-*.log`
- **Injection details**: `injection-points.md` - Phase 6 section
- **ReVanced port**: `attempt-history.md` - Phase 7 section

### Why Whitelist Over Blacklist?

- Future-proof against new tracking parameters
- Simpler logic (one indexOf + substring)
- Clean URLs are predictable: `@user/video/ID`
- No parameter enumeration needed

---

## Search Indices

**JADX output**: `decompiled-jadx/sources/` (166,751 Java sources, 99% decompiled)
**Smali bytecode**: `decompiled-smali-full/smali_classes*/` (248,437 complete files)

**Search indices**:
- `indices/strings.txt` - 39,246 URL/link/share patterns
- `indices/handlers.txt` - 30,477 onClick/button/clip patterns
- `indices/bundles.txt` - 94,225 Bundle/Intent/extras patterns
- `indices/canonical-urls.txt` - 546,958 video_id/aweme_id/tiktok.com patterns
- `indices/specific.txt` - 188 copylink/share_url/utm_ patterns

---

## Archive: Superseded Approaches

### Phase 1 Hypothesis (Disproven)

Initial analysis identified `UEU.LIZJ()` as primary interception point. **Disproven by Test 1** - method never called during share. Actual entry point is `AwemeSharePackage.LJIJJLI()`. See `injection-points.md` Phase 2 for test results.

### Phase 5: Option C Bypass - Canonical URL Swap (Superseded)

**Date**: 2025-10-20
**Status**: [SUPERSEDED] by Phase 6
**Why Superseded**: Testing revealed `UEa.LIZ()` returns canonical URLs with tracking parameters, NOT shortened vm./vt. URLs. The vm./vt. detection logic was based on incorrect assumption.

**Patch Strategy**: Detect shortened URLs (vm.tiktok.com, vt.tiktok.com) after `UEa.LIZ()` call and swap to canonical URL (p1 parameter).

**Register Allocation Issue**:
- `.registers 6` means 2 local (v0-v1), 4 parameter (v2-v5)
- Using v2/v4 caused DEX verifier type conflicts (parameter registers cannot change types)
- Fix: Use v0 only for all temporaries

**Result**: [PASS] Patch compiled and installed successfully, but functional premise was wrong - no shortened URLs to detect at this layer. Phase 6 sanitizer approach replaced this.

**Build Artifacts**: `smali-tests/05-option-c-bypass/phase5-final-aligned.apk`, `classes15-final.dex`

---

## Resources

- **Decompiled JADX**: `decompiled-jadx/` (Java sources)
- **Smali output**: `decompiled-smali-full/` (All bytecode)
- **Search index**: `indices/` (searchable patterns)
- **APK metadata**: `apk-metadata.txt` (SHA256: 0552a22f...)
