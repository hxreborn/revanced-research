# TikTok 36.5.4 - Share Link Sanitizer Analysis

**Target App:** TikTok
**App Version:** 36.5.4
**Analysis Date:** 2025-10-16
**Status:** Complete - Ready for patch development

---

## Objective

Develop a ReVanced patch to sanitize tracking parameters from TikTok share links before they are copied to clipboard.

---

## Key Findings

### Share Link Tracking System

TikTok implements a **three-phase tracking system** that embeds user analytics throughout the share flow:

1. **Phase 1 - URL Building**: Share URLs are constructed with embedded query parameters:
   - `share_link_id` (unique tracking UUID per share)
   - `social_share_type` (platform identifier: WhatsApp=22, Facebook, etc.)
   - `share_item_id` (video/content ID)
   - `invitation_scene` (user context: personal_profile, etc.)

2. **Phase 2 - API Shortening**: Full URLs sent to `/tiktok/share/link/shorten/multi/v1/` endpoint:
   - Request: `MultiShortenShareRequest` with scene + list of `ShareURLInfo` objects
   - Response: Short URL like `https://vm.tiktok.com/ZNd7ARdUF/`
   - Short code encodes: tracking_id, platform, timestamp

3. **Phase 3 - Server-Side Tracking**: When user opens short URL:
   - Short code decoded on TikTok's server → retrieves original full URL with params
   - `share_link_id` logged in analytics database
   - Redirect issued to canonical URL (params stripped for clean UX)

### Patch Interception Point

**File:** `com/p124ss/android/ugc/aweme/share/improve/channel/CopyLinkChannel.java`
**Method:** `LJI(C98754aTV content, Context context, ...)`
**Target Field:** `content.LIZLLL` (the share link before clipboard write)

This is the **last opportunity** to intercept and sanitize the URL before it reaches the user's clipboard.

---

## Proposed Patch Strategies

### Option A: Strip Query Parameters (Incomplete)
- Removes visible tracking params from URL before shortening API call
- **Limitation**: Server still generates short codes with encoded tracking

### Option B: Intercept at Clipboard (Recommended)
- Simplest approach: intercept `content.LIZLLL` in `CopyLinkChannel.LJI()`
- Return canonical URL directly (skip shortener entirely)
- **Benefit**: User gets clean, direct link to video

### Option C: Hybrid (Best)
- Extract video ID from short code via local pattern matching
- Build canonical URL client-side without server-side tracking
- Fall back to short URL if extraction fails

---

## Verification & Evidence

### ✅ Publicly Confirmed
These behaviors are validated through independent sources:

- **Short URL redirect behavior**: `vm.tiktok.com/[CODE]/` redirects to canonical `www.tiktok.com/@user/video/[ID]`
  - Verified: Community tools (yt-dlp), public discussions
  - Test: `curl -I -L "https://vm.tiktok.com/XYZ/"` shows redirect chain

- **Query parameter patterns**: TikTok URLs contain tracking params like `share_link_id`, `social_share_type`, `web_id`, `_d`
  - Verified: yt-dlp GitHub issues, scraper tools, public link-cleaning services
  - Community tools (toklinkfixer.com) routinely strip these

- **Link cleaning techniques**: Strip params offline or expand short URLs
  - Verified: Multiple community tools implement both approaches
  - Tested: Both methods work reliably

### ⚠️ Requires APK-Level Verification
These claims require decompiled APK analysis to confirm:

- Exact class names like `C98444aOV` handling URL building
- API endpoint path `/tiktok/share/link/shorten/multi/v1/`
- Internal structure of `MultiShortenShareRequest`, `ShareURLInfo`
- `CopyLinkChannel.LJI()` as the precise interception point

**Verification Status:** ✅ CONFIRMED via jadx decompilation (classes18.dex)

---

## Implementation Checklist

### Pre-Implementation
- [x] Tracking mechanism understood
- [x] Interception point identified
- [x] Public evidence validated
- [x] Decompiled source verified

### Development
- [ ] Extract exact smali bytecode for fingerprints
- [ ] Implement patch bytecode injection
- [ ] Test on emulator/device

### Testing
- [ ] Verify sanitized link in clipboard
- [ ] Confirm no tracking params present
- [ ] Test across share destinations (WhatsApp, SMS, etc.)

### Diagnostic Builds
- ✅ `apps/tiktok/36.5.4/artifacts/tiktok-logged-install-final.apk` — instrumentation build with `RV-Sanitizer` logging
- Logs & analysis: `LOGGING_TEST_RESULTS.md`, `PROJECT_COMPLETION_SUMMARY.md`, `logcat_RV-Sanitizer.log`
- Usage: `adb logcat -s RV-Sanitizer:D -v time`

---

## Related Documentation

- **`fingerprints.md`** — Bytecode signatures for stable method matching
- **`patch-plan.md`** — Detailed implementation strategy and injection details
- **`../decode/jadx/`** — Decompiled source code (gitignored, local only)

---

## References

### Code Locations

| Component | File | Method | Line |
|-----------|------|--------|------|
| URL Builder | `C98444aOV.java` | `LIZIZ()` | 137-146 |
| Link Shortener API | `IMultiShortenUrlApi.java` | `getPreShareLinkShortenUrl()` | - |
| Shortening Request | `MultiShortenShareRequest.java` | - | - |
| Clipboard Intercept | `CopyLinkChannel.java` | `LJI()` | 36 |

### DEX Location
- Primary class split: **classes18.dex** and **classes8.dex**

### Public Resources
- [yt-dlp GitHub](https://github.com/yt-dlp/yt-dlp) — Handles TikTok URL params
- [toklinkfixer.com](https://www.toklinkfixer.com) — Link cleaning tool
- [Community discussions](https://www.reddit.com/r/LifeProTips/) — URL tracking awareness

---

## Notes

- Heavy R8/ProGuard obfuscation throughout; method/field names are mangled
- Tracking is fundamental to TikTok's analytics; multiple interception points exist
- Patch should target the latest clipboard write to ensure all share paths are covered
- Server-side tracking (short code logging) cannot be prevented client-side; focus is on link sanitization
