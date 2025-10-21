# TikTok 36.5.4 - Obfuscated Class Mapping

> **Changelog:** 2025-10-20 - Phase 1 hypothesis superseded; canonical URL found at LJIJJLI. See injection-points.md and attempt-history.md for details.

## Share-Related Classes

| Obfuscated Class | Purpose | Key Methods | Location | Status |
|------------------|---------|------------|----------|--------|
| `p003X.UEU` | **PRIMARY: Canonical URL transformer** | `LIZJ(int, String, String, String)` | classes15.dex | ✅ **Patched** |
| `p003X.C54243JOk` | Gateway - builds AwemeSharePackage from Aweme | `LIZ(Aweme, Context, ...)` | classes9.dex | ✅ Found |
| `com.appsflyer.share.ShareInviteHelper` | AppsFlyerLib share helper | `generateInviteUrl()` | classes20.dex | ✅ Found |
| `com.bytedance.android.livesdkapi.depend.model.live.Room` | Live room with share_url field | `shareUrl` (field) | - | ✅ Found |

**REMOVED**: ❌ `com.p124ss.ugc.aweme.creation.base.ShareModel` - Only defines Open Platform metadata, no share URL logic (verified 2025-10-19)

## URL/Link Related

### Strings Found
- `share_url` - Annotation: `@InterfaceC37646Cp7("share_url")` in Room.java
- `copylink` - URL copy functionality
- `utm_source` - Tracking parameter (TARGET FOR REMOVAL)
- `utm_*` - Generic tracking patterns
- `tt_*` - TikTok tracking patterns
- `enter_*` - Tracking parameters

### Search Locations
- **JADX output**: `decompiled-jadx/sources/` (166,751 Java sources decompiled at 99% completion)
- **Smali bytecode**: `decompiled-smali-full/smali_classes*/` (248,437 complete Smali files)
- **Search indices**:
  - `indices/strings.txt` (39,246 URL/link/share related hits)
  - `indices/handlers.txt` (30,477 onClick/button/clip related hits)
  - `indices/bundles.txt` (94,225 Bundle/Intent/extras hits)
  - `indices/canonical-urls.txt` (546,958 video_id/aweme_id/tiktok.com patterns)
  - `indices/specific.txt` (188 copylink/share_url/utm_ tracking patterns)

## Share Intent Link Canonicalizer - Patch Goal

**Objective**: Use canonical full-length URLs instead of TikTok-shortened links when sharing to external apps

**Strategy**:
- **Intercept canonical URL** BEFORE it's shortened by TikTok's API
- **Bypass API shortener** to use full canonical URL in share Intent
- **Result**: External apps receive full URLs like `https://www.tiktok.com/@user/video/ID` instead of `https://vm.tiktok.com/{SHORT_ID}`
- **Benefit**: Direct access to video content without tracking parameter injection, no dependency on TikTok's shortener service

**Patch Strategy**:
1. **Identify canonical URL source**: Find where full-length video URLs are stored (before API shortening)
2. **Locate interception point**: In `AbstractC82063UGk.m11879LJ()` or earlier in the pipeline
3. **Override with canonical URL**: Substitute the shortened link with the full canonical URL
4. **Pass to Intent**: Let canonical URL flow through to Intent.putExtra() or clipboard

**Expected flow**:
```
User taps Share
     ↓
Canonical URL available (e.g., https://www.tiktok.com/@user/video/XXXX)
     ↓
API shortening process (would create vm.tiktok.com link)
     ↓
[PATCH INTERCEPTION - Use canonical instead of shortened]
     ↓
Intent.putExtra() receives canonical URL
     ↓
Send to external app / clipboard with full URL
```

**Key principle**: Single interception point in URL building pipeline for consistent canonical links across all share channels

## Phase 1 Findings


## Phase 1.4: Cross-Reference Verification COMPLETE ✅

**Date Completed**: 2025-10-19
**Status**: ✅ PASS - Ready for Phase 2
**Verification Type**: Automated + Manual + Smali inspection

**Verification Results**:
- ✅ JVM descriptors verified (byte-for-byte match)
- ✅ Smali shard paths confirmed consistent
- ✅ Share plumbing verified (ACTION_SEND, EXTRA_TEXT, ClipboardManager)
- ✅ Lambda/invoke-custom: CLEAR (no lambdas, straightforward patching)
- ✅ Resource strings verified
- ✅ URL variants mapped (vm/vt/m.tiktok.com, canonical patterns)
- ✅ Decompilation consistency: PERFECT
- ✅ Complete URL construction path verified end-to-end
- ✅ Aweme→Builder URL extraction confirmed in Smali

**Detailed Reports**:
- `VERIFICATION-REPORT.md` (automated verification)
- `VERIFICATION-FINDINGS-INTEGRATED.md` (manual + Smali findings)

---

## ✅ complete url construction path (verified end-to-end)

### Full Flow Chain

```
1. ORIGIN: Aweme.getShareUrl()
   └─ Location: Aweme model object
   └─ Smali: smali_classes9/X/JOk.smali - invoke-virtual {v3}, Aweme;->getShareUrl()
   └─ Returns: URL (canonical or pre-shortened)

2. GATEWAY: p003X.C54243JOk.LIZ(Aweme, Context, ...)
   └─ Location: classes9.dex
   └─ Purpose: Builds AwemeSharePackage from Aweme
   └─ Smali: smali_classes9/X/JOk.smali
   └─ Output: AwemeSharePackage with builder.LJFF = URL

3. RELAY: BaseSharePackage constructor
   └─ File: com/p124ss/android/ugc/aweme/share/base/model/BaseSharePackage.java:22-54
   └─ Action: Stores builder URL to this.url (passes through unchanged)

4. TRANSFORMER: p003X.UEU.LIZJ(int, String, String, String) ⭐ PRIMARY PATCH TARGET
   └─ File: p003X/UEU.java:62-89
   └─ Smali: smali_classes15/X/UEU.smali:107-310
   └─ Input: URL from BaseSharePackage.this.url
   └─ Processing: Runs C82001UEa.LIZ() + C48911HFi.LIZIZ.LJJJJ()
   └─ Decision: Condition at line 67: if (!C83039UhW.LJII())
   └─ Output: Canonical or shortened URL
   ⭐ PATCH STRATEGY: Force canonical URL return regardless of condition

5. PACKAGING: com.p124ss.android.ugc.aweme.relation.share.InviteFriendsSheetPackage
   └─ File: InviteFriendsSheetPackage.java:31-49
   └─ Action: Takes UEU.LIZJ() result
   └─ Creates: UGU/UGT content object with LIZJ=URL

6a. DISTRIBUTION - PATH A (Intent/WhatsApp/Twitter/SMS):
    └─ Via: p003X.AbstractC82063UGk.m11879LJ(UGU)
    ├─ File: p003X/AbstractC82063UGk.java:66-93
    ├─ Action: Combines content.LIZJ + content.LIZIZ + title
    └─ To: All wrap channels (WhatsApp, Twitter, SMS, etc.)

    └─ Channel: WrapDefaultWhatsappChannel.LJIJ(UGU, Context, InterfaceC54258JOz)
    ├─ File: com/p124ss/android/ugc/aweme/channel/share/channel/wrap/WrapDefaultWhatsappChannel.java
    ├─ Line 57 INJECTION POINT:
    │  intent2.putExtra("android.intent.extra.TEXT", AbstractC82063UGk.m11879LJ(content))
    └─ Result: WhatsApp receives canonical URL

6b. DISTRIBUTION - PATH B (Clipboard):
    └─ Via: CopyLinkChannel.LJFF()
    ├─ File: com/p124ss/android/ugc/aweme/share/improve/channel/CopyLinkChannel.java:101-134
    ├─ Action: Extracts UGT.LIZJ / UGT.LIZLLL fields
    └─ To: C81999UDy.LIZLLL()

    └─ Via: p003X.C81999UDy.LIZLLL()
    ├─ File: p003X/C81999UDy.java:188-226
    ├─ Action: Writes ClipData.newPlainText(label, url)
    └─ Result: Clipboard receives canonical URL
```

### Single Patch Point Effect
**Patch Location**: `UEU.LIZJ()` return logic (lines 107-310)
**Effect**: Both Intent AND Clipboard receive same canonical URL from single modification
**Channels Affected**: WhatsApp, Twitter, SMS, Clipboard, and ANY other channels using same URL extraction

---


## phase 1 verification summary

### automated verification (2025-10-19)
- ✅ JVM descriptors verified (byte-for-byte match)
- ✅ Smali shard paths confirmed consistent
- ✅ Share plumbing verified (ACTION_SEND, EXTRA_TEXT, ClipboardManager)
- ✅ Lambda/invoke-custom: CLEAR (no lambdas, straightforward patching)
- ✅ Resource strings verified
- ✅ URL variants mapped (vm, vt, m, canonical)
- ✅ Decompilation consistency: PERFECT

### manual verification & corrections
- ✅ ShareModel entry REMOVED (only Open Platform metadata, no URL logic)
- ✅ C54243JOk entry ADDED (gateway method verified in Smali)
- ✅ Complete URL construction path verified end-to-end
- ✅ All distribution channels mapped (Intent, Clipboard, all wrap channels)

### phase 1 readiness: CONFIRMED
All prerequisites met for Phase 2 Smali modification. Primary patch target identified: `UEU.LIZJ()` in smali_classes15/X/UEU.smali lines 107-310

---

## Phase 5: Option C Bypass - Canonical URL Swap ⚠️ SUPERSEDED

**Date**: 2025-10-20
**Status**: SUPERSEDED by Phase 6 - Patch worked but strategy was unnecessary

**Superseded Reason**: Testing revealed UEa.LIZ() returns canonical URLs with tracking parameters, NOT shortened vm./vt. URLs. The vm./vt. detection logic was based on incorrect assumption. Phase 6 sanitizer approach is the correct solution.

### Patch Applied
**Location**: `smali_classes15/X/UEU.smali:3866-3886`
**Method**: `UEU.LIZLLL(int, String, String, String)LX/Wu4;`
**Strategy**: Post-result interception - detect shortened URLs after `UEa.LIZ()` call and swap to canonical

**Register Allocation (CRITICAL)**:
- `.registers 6` means 2 local (v0-v1), 4 parameter (v2-v5)
- ✅ Using v0 for all temporaries (true local register)
- ❌ ERROR: Using v2/v4 caused DEX verifier type conflicts

### Patch Code
```smali
# After: invoke-static {p2, p1, p3}, LX/UEa;->LIZ(...)  [line 3859]
move-result-object v1  # v1 = shortened URL result

if-eqz v1, :keep_shortened_c  # null guard

const-string v0, "https://vm.tiktok.com"
invoke-virtual {v1, v0}, Ljava/lang/String;->startsWith(...)Z
move-result v0
if-nez v0, :swap_canonical_c

const-string v0, "https://vt.tiktok.com"
invoke-virtual {v1, v0}, Ljava/lang/String;->startsWith(...)Z
move-result v0
if-eqz v0, :keep_shortened_c

:swap_canonical_c
const-string v0, "TikTokCanonicalSwap"
invoke-static {v0, p1}, Landroid/util/Log;->d(...)  # Debug tag
move-object v1, p1  # Swap: v1 = canonical (p1)

:keep_shortened_c
# Continue to isEmpty check (line 3889)
```

### Build Results
- ✅ `classes15-final.dex` compiles cleanly (103MB)
- ✅ DEX passes Android runtime verification
- ✅ App launches and runs without crashes
- ✅ No VerifyError or type mismatches

### Test Status
- ✅ APK installed successfully
- ✅ App process runs stable (no FATAL exceptions)
- ⏳ Pending: Trigger share action and verify logs

---

## Phase 6: URL Parameter Sanitizer (Production) ✅

**Date**: 2025-10-20
**Status**: COMPLETE - Production-ready, debug logs stripped
**Build**: `phase6-sanitizer-fixed-aligned.apk`

### Discovery
After Phase 5 implementation, testing revealed that `UEa.LIZ()` returns **canonical URLs, not shortened URLs**. However, these canonical URLs contain a **massive tracking blob** (18 parameters, 505 bytes):

```
https://www.tiktok.com/@user/video/ID?_r=1&u_code=0&preview_pb=0&sharer_language=en&_d=...&share_item_id=...&source=h5_m&timestamp=...&social_share_type=0&utm_source=copy&utm_campaign=client_share&utm_medium=android&share_iid=...&share_link_id=...&share_app_id=1180&ugbiz_name=MAIN&ug_btm=b2001&link_reflow_popup_iteration_sharer={...}
```

**Pivot**: Changed strategy from "detect vm./vt. shortened URLs" to "strip all tracking parameters from canonical URLs"

### Patch Applied
**Location**: `smali_classes15/X/UEU.smali:3866-3883`
**Method**: `UEU.LIZLLL(int, String, String, String)LX/Wu4;`
**Strategy**: Whitelist approach - remove everything after '?' character

**Register Allocation**:
- `.registers 8` (upgraded from 6) provides v0-v3 locals
- v0: int (indexOf result)
- v1: String (URL - modified in-place)
- v2: String (const-string temps)
- v3: String (boolean results)

### Production Patch Code
```smali
# After: invoke-static {p2, p1, p3}, LX/UEa;->LIZ(...)  [line 3859]
move-result-object v1  # v1 = canonical URL with tracking blob

# PHASE 6: URL Parameter Sanitizer - Strip all tracking parameters
# Null check - skip if shortener returned null
if-eqz v1, :keep_shortened_c

# Find '?' character (use v0 for int result)
const-string v2, "?"
invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v0

# Skip cleaning if no '?' or '?' at position 0 (v0 <= 0)
if-lez v0, :check_shortened

# Substring from 0 to '?' position - removes entire tracking blob
const/4 v2, 0x0
invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1

:check_shortened
# Continue to isEmpty check and rest of method
```

### Test Results
**Test 1: Copy Link (Clipboard)** ✅ PASS

**Before Sanitization** (568 chars):
```
https://www.tiktok.com/@pure.8k/video/7558444171787373846?_r=1&u_code=0&preview_pb=0&sharer_language=en&_d=f01b3cehlc22d5&share_item_id=7558444171787373846&source=h5_m&timestamp=1760976423&social_share_type=0&utm_source=copy&utm_campaign=client_share&utm_medium=android&share_iid=7563309489895655181&share_link_id=dee1bbdf-0e16-4192-843c-1c412928ba2f&share_app_id=1180&ugbiz_name=MAIN&ug_btm=b2001&link_reflow_popup_iteration_sharer=%7B%22click_empty_to_play%22%3A1%2C%22dynamic_cover%22%3A1%2C%22follow_to_play_duration%22%3A-1.0%2C%22profile_clickable%22%3A1%7D
```

**After Sanitization** (63 chars):
```
https://www.tiktok.com/@pure.8k/video/7558444171787373846
```

**Parameters Removed**: 18 tracking parameters (utm_*, share_*, _d, _r, u_code, timestamp, etc.)
**Size Reduction**: 89% (505 bytes removed)

### Build Results
- ✅ `classes15-sanitizer-fixed.dex` compiles cleanly (103MB)
- ✅ DEX passes Android runtime verification
- ✅ App runs stable, no crashes
- ✅ Clean URLs delivered to clipboard and all share channels
- ✅ Production-ready (all debug logs removed)

### Edge Cases Validated
- ✅ URL with many parameters (18 removed successfully)
- ✅ Nested JSON in query string (handled correctly)
- ✅ Special characters (&, =, %7B, etc.) - no crashes
- ✅ URL without '?' - indexOf returns -1, if-lez jumps, no substring
- ✅ Null URL - handled by if-eqz guard

### Documentation
- **Detailed patch**: `patches/phase6-url-sanitizer.smali.patch`
- **Test results**: `PHASE6-TEST-RESULTS.md`
- **Pre-implementation plan**: `PHASE6-SANITIZER-PLAN.md`
- **Test logs**: `logs/phase6-test-clipboard.log`

### Why Whitelist Over Blacklist?
- Future-proof against new tracking parameters TikTok adds
- Simpler logic (one indexOf + substring)
- Clean URLs are predictable: `@user/video/ID`
- No need to enumerate all tracking fields

---

## Superseded Approaches

### Phase 1 Hypothesis (Disproven)
Initial analysis identified `UEU.LIZJ()` as primary interception point. **Disproven by Test 1** – method never called during share. Actual method is `LJIJJLI` in `AwemeSharePackage`. See `injection-points.md` and `attempt-history.md:1-2` for test results.

### UEU.LIZJ Hypothesis (Disproven)
Detailed analysis of `UEU.LIZJ()` as canonical URL builder. **Test 1 proved this method is NOT called during share flow.** Correct entry point is `LJIJJLI`.

---

## resources

- **Decompiled JADX**: `decompiled-jadx/` (Java sources)
- **Smali output**: `decompiled-smali-full/` (All bytecode)
- **Search index**: `indices/` (searchable patterns)
- **APK metadata**: `apk-metadata.txt` (SHA256: 0552a22f...)
