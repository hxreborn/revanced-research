# Patch Implementation Plan

**App:** TikTok
**Version:** 36.5.4
**Patch Name:** Share Link Sanitizer
**Priority:** HIGH
**Status:** DESIGN
**Author:** ReVanced Research
**Last Updated:** 2025-10-16

---

## Executive Summary

**Objective:** Remove tracking parameters from TikTok share links before they are copied to the user's clipboard.

**User Impact:** Users can share TikTok videos without exposing tracking identifiers (`share_link_id`, `social_share_type`, `invitation_scene`, etc.) embedded in the URLs.

**Risk Level:** LOW
**Complexity:** SIMPLE

---

## Problem Statement

### Current Behavior

TikTok embeds user tracking identifiers in every share link:

1. **URL Building**: Query parameters encode user context and platform
2. **URL Shortening**: Full URLs sent to `/tiktok/share/link/shorten/multi/v1/` API
3. **Server Logging**: Short codes decoded and tracking IDs logged

### Desired Behavior

Users' clipboard receives clean links without tracking parameters.

**Success Criteria:**
- [ ] Shared links contain no query parameters
- [ ] Link functionality preserved
- [ ] Works across all share destinations (WhatsApp, SMS, Email, etc.)
- [ ] No app crashes
- [ ] Consistent across multiple shares

---

## Technical Analysis

### Target Components

**Primary Class:** `CopyLinkChannel`
**Primary Method:** `LJI()` (line 36)
**Interception Point:** Before clipboard write

### Call Graph

```
ShareServiceImpl.LIZIZ()
  └─> CopyLinkChannel(false)
      └─> CopyLinkChannel.LJI()  ← PATCH TARGET
          ├─ input: content.LIZLLL (URL with tracking)
          ├─ [SANITIZATION HAPPENS HERE]
          └─> C98761aTc.LIZLLL()  (clipboard write)
```

### Dependencies

- None (Android Uri.parse is sufficient)

---

## Implementation Strategy

### Method: Bytecode Injection

Inject URL sanitization logic inside `CopyLinkChannel.LJI()` after field extraction, before clipboard delegation.

### Fingerprint

**Target:** FP-001 (`CopyLinkChannel.LJI()`)
**Confidence:** 95%

---

## Solution: Strip Query Parameters (Recommended)

**Strategy:** Parse URL and remove all query parameters

**Pseudo-code:**
```java
String shareUrl = content.LIZLLL;  // Full URL with tracking params
Uri uri = Uri.parse(shareUrl);
String cleanUrl = uri.getScheme() + "://" + 
                  uri.getAuthority() + 
                  uri.getPath();
// cleanUrl = "https://www.tiktok.com/@user/video/12345" (no params)
```

**Pros:**
- Simple
- Preserves direct video link
- Works for all shares

**Cons:**
- Server-side tracking still occurs in Phase 1/2 (before patch point)

---

## Injection Details

### Location: CopyLinkChannel.LJI()

**After:** `iget-object` field extraction of `content.LIZLLL`
**Before:** `invoke-static` to `C98761aTc.LIZLLL()` (clipboard)

**Injected Bytecode:**
```smali
invoke-static {v0}, Lcom/revanced/tiktok/extensions/ShareLinkUtils;->sanitizeShareUrl(Ljava/lang/String;)Ljava/lang/String;
move-result-object v0
```

**Helper Class:**
```java
public class ShareLinkUtils {
    public static String sanitizeShareUrl(String url) {
        try {
            Uri uri = Uri.parse(url);
            return uri.getScheme() + "://" + uri.getAuthority() + uri.getPath();
        } catch (Exception e) {
            return url;  // Fallback on error
        }
    }
}
```

---

## Testing Plan

### Test Cases

#### TC-001: WhatsApp Share
1. Open TikTok video
2. Share to WhatsApp
3. Verify URL has no query params

**Expected:** `https://www.tiktok.com/@user/video/123`

#### TC-002: Clipboard
1. Copy link to clipboard
2. Paste in Notes
3. Inspect URL

**Expected:** Clean URL, no tracking params

#### TC-003: Multiple Shares
1. Share 3 times
2. Compare clipboard contents

**Expected:** Identical URLs (no randomization)

#### TC-004: Link Functionality
1. Share and copy link
2. Open link in browser

**Expected:** Video loads; no errors

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Fingerprint fails | LOW | HIGH | Test across versions |
| URL parsing fails | VERY LOW | MEDIUM | Fallback to original URL |
| Share breaks | VERY LOW | CRITICAL | Test all share paths |
| App detects patch | LOW | MEDIUM | No prevention possible |

---

## Implementation Checklist

- [ ] ReVanced patch JSON configured
- [ ] Helper class bytecode prepared
- [ ] Smali injection tested
- [ ] TC-001 through TC-004 pass
- [ ] Code review complete
- [ ] PR created

---

## Notes

- Patch prevents users from sharing tracking URLs in chat messages
- Server-side tracking (Phase 1/2) occurs before patch point; cannot be prevented client-side
- Future: Network interception could prevent Phase 2 API call (out of scope)
