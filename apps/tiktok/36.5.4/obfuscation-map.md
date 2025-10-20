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
