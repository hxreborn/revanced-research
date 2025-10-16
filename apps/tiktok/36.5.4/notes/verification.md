# Verification & Validation

This document validates the tracking mechanism claims in `fingerprints.md` against public evidence and identifies what requires APK-level verification.

## Public Evidence (Independently Verified)

### ✅ Verified: Short Link Redirect Behavior

**Claim:** TikTok uses `vm.tiktok.com/[SHORT_CODE]/` redirectors that resolve to canonical `www.tiktok.com/...` URLs

**Evidence:**
- Public community tools (yt-dlp, toklinkfixer.com) routinely expand these
- Hacker News discussions confirm redirect chain behavior
- Expansion works offline: `curl -I -L "https://vm.tiktok.com/XYZ/"` → canonical URL

**Verification command:**
```bash
curl -s -I -L "https://vm.tiktok.com/ZNd7ARdUF/" -o /dev/null -w "%{url_effective}\n"
```

### ✅ Verified: Query Parameter Patterns

**Claim:** TikTok URLs contain tracking parameters like `share_link_id`, `is_from_webapp`, `sender_device`, `web_id`, `_d`

**Evidence:**
- yt-dlp GitHub issues #9997 and related threads document these parameters
- Community link-cleaning tools (toklinkfixer.com) strip these params
- Public scraping tools handle them routinely

**Known params in the wild:**
```
- is_from_webapp=1
- sender_device=pc/mobile
- web_id=[tracking_uuid]
- _d=[signature]
- share_link_id=[uuid]
- social_share_type=[int]
- invitation_scene=[string]
```

**Verification command:**
```bash
python3 -c "
from urllib.parse import urlparse, parse_qs
url = 'https://www.tiktok.com/@user/video/123?is_from_webapp=1&share_link_id=abc'
params = parse_qs(urlparse(url).query)
print('Tracking params:', params)
"
```

### ✅ Verified: Link Cleaning Approaches

**Claim:** Community tools expand short URLs and strip query params

**Evidence:**
- toklinkfixer.com implements exactly this: expand → strip params → canonicalize
- Multiple Reddit threads discuss this technique
- Discord bots use this pattern

**Two common strategies:**
1. **Strip params offline** (fast, doesn't need network):
   ```python
   url = "https://www.tiktok.com/@user/video/123?share_link_id=X&_d=Y"
   from urllib.parse import urlparse
   clean = f"{urlparse(url).scheme}://{urlparse(url).netloc}{urlparse(url).path}"
   # Result: https://www.tiktok.com/@user/video/123
   ```

2. **Expand short URL** (requires network):
   ```bash
   curl -s -L "https://vm.tiktok.com/XYZ/" | grep -oP '(?<=og:url" content=")[^"]+' || \
   curl -s -I -L "https://vm.tiktok.com/XYZ/" | grep -i ^location | tail -1
   ```

---

## Requires APK-Level Verification

### ❌ Cannot Verify (No APK access yet): Private Symbols & API Paths

**Claim:** Tracking happens in `C98444aOV.java` at lines 137-146 via endpoint `/tiktok/share/link/shorten/multi/v1/`

**Status:** Decompiled class names and private API paths cannot be independently verified without:
1. Decompiled APK binary inspection, OR
2. Network packet capture (mitmproxy/tcpdump with HTTPS interception)

**Verification checklist:**
- [ ] `jadx -d out app.apk && rg "C98444aOV|share/link/shorten" out/` confirms class/endpoint
- [ ] `adb logcat | grep -i "shorten\|share_link_id"` shows method calls during share
- [ ] `mitmproxy` captures POST to `/tiktok/share/link/shorten/multi/v1/` with `MultiShortenShareRequest` payload
- [ ] Request body confirms `share_link_id`, `social_share_type`, `share_item_id` fields
- [ ] Response contains `MultiShortenModel` with short URL

### ❌ Cannot Verify (No APK access yet): Internal Class Structure

**Claims:**
- `MultiShortenShareRequest` with fields `scene`, `share_urls`
- `ShareURLInfo` with fields `platformId`, `shareUrl`
- `C98761aTc.LIZLLL()` handles final clipboard write
- `CopyLinkChannel.LJI()` is the interception point

**Status:** Require APK decompilation to confirm bytecode/structure

**How to verify:**
```bash
# Extract class bytecode
jadx -d out app.apk

# Grep for class definitions
rg "class.*MultiShortenShareRequest|class.*ShareURLInfo|class.*CopyLinkChannel" out/

# Inspect method signatures
rg "fun LJI|method LJI" out/ -A 5
```

---

## Summary Table

| Claim | Evidence | Verification Status | How to Verify |
|-------|----------|---------------------|---------------|
| Short URLs redirect to canonical | Community tools, public discussions | ✅ Publicly confirmed | `curl -I -L vm.tiktok.com/X` |
| Query params present in URLs | yt-dlp, scraper tools, link cleaners | ✅ Publicly confirmed | Strip & inspect params from live URL |
| Link cleaning via param stripping | toklinkfixer.com, Reddit threads | ✅ Publicly confirmed | Use live link cleaning tools |
| API endpoint `/tiktok/share/link/shorten/multi/v1/` | Private/decompiled | ❌ Needs APK verification | mitmproxy capture or jadx grep |
| Class `C98444aOV` handles tracking params | Decompiled source | ❌ Needs APK verification | `jadx -d out app.apk && rg C98444aOV` |
| `MultiShortenShareRequest` structure | Decompiled source | ❌ Needs APK verification | `jadx -d out app.apk && rg MultiShortenShareRequest -A 10` |
| `CopyLinkChannel.LJI()` is clipboard intercept | Decompiled source | ❌ Needs APK verification | Smali analysis or hook test |

---

## Next Steps

### Priority 1: Confirm Private Claims (APK-level)

```bash
# 1. Decompile and search for critical classes
jadx -d /tmp/tiktok_out apps/tiktok/36.5.4/apk/tiktok-36.5.4.apk
rg "class C98444aOV|class CopyLinkChannel|class MultiShortenShareRequest" /tmp/tiktok_out -A 5

# 2. Search for API endpoint path
rg "share/link/shorten|tiktok/share/link" /tmp/tiktok_out/

# 3. Search for tracking param names
rg "share_link_id|invitation_scene|social_share_type" /tmp/tiktok_out/ -B 2 -A 2
```

### Priority 2: Network Verification (Device-level)

```bash
# On Android device/emulator with mitmproxy:
adb shell settings put global http_proxy 192.168.1.X:8080
# Use app → trigger share → inspect POST in mitmproxy
# Verify payload matches MultiShortenShareRequest structure
```

### Priority 3: Runtime Hook Test

```bash
# Frida hook to confirm LJI() receives content.LIZLLL with tracking params
frida -U -f com.tiktok.android -l hook.js

# hook.js: intercept CopyLinkChannel.LJI() and log content.LIZLLL
```

---

## Conclusion

The **three-phase tracking model** (URL building → shortening API → server redirect) is **supported by public community evidence**. The **specific internal implementation** (exact class names, API paths, field structures) **requires APK-level verification** but is consistent with observed behavior.

All patch strategies in `fingerprints.md` remain valid regardless of exact implementation details, as they target the observable clipboard write point.
