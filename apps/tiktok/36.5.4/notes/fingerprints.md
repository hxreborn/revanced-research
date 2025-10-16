# Fingerprint Candidates

## Primary Share Flow

### 1. CopyLinkChannel (Confirmed - Primary Target)
| Status | Component | File Path | Method | Signals |
|--------|-----------|-----------|--------|---------|
| **CONFIRMED** | Link Copy Handler | `com/p124ss/android/ugc/aweme/share/improve/channel/CopyLinkChannel.java` | `LJI()` (line 36) | Handles final link copy before clipboard |

**Key findings:**
- `LJI(C98754aTV content, Context context, ...)` receives pre-built share link in `content.LIZLLL`
- Combines title (`content.LIZJ`) + link (`content.LIZLLL`)
- Delegates to `C98761aTc` for clipboard copy (line 51)
- **Patch point:** Intercept `content.LIZLLL` before copy

### 2. AwemeSharePackage (Confirmed - Link Builder)
| Status | Component | File Path | Method | Signals |
|--------|-----------|-----------|--------|---------|
| **CONFIRMED** | Share Package | `com/p124ss/android/ugc/aweme/share/improve/pkg/AwemeSharePackage.java` | `LIZLLL()` | Builds share content, dispatches channels |

**Key findings:**
- Handles multiple share channels (WhatsApp, Facebook, Instagram, SMS, etc.)
- Channel dispatch via handler classes: `C98480aP5`, `C98472aOx`, etc.
- URL building happens in channel-specific handlers
- **Patch point:** Intercept URL before channel assignment

### 3. ShareServiceImpl (Confirmed - Entry Point)
| Status | Component | File Path | Method | Signals |
|--------|-----------|-----------|--------|---------|
| **CONFIRMED** | Service | `com/p124ss/android/ugc/aweme/share/ShareServiceImpl.java` | Multiple LIZIZ() calls | Instantiates `CopyLinkChannel(false)` at lines 978, 1091, 1397, etc. |

**Invocation pattern:**
```java
c98409aNw.LIZIZ(new CopyLinkChannel(false));  // Line 978
```

### 4. ShareService Interface (Confirmed - API)
| Status | Component | File Path | Methods | Notes |
|--------|-----------|-----------|---------|-------|
| **CONFIRMED** | Interface | `com/p124ss/android/ugc/aweme/share/ShareService.java` | ~40 obfuscated methods | One unobfuscated: `shareSubscribeLink()` (line 177) |

---

## Link Building Chain

```
ShareServiceImpl.LIZIZ()
    ↓ (instantiates)
CopyLinkChannel(false)
    ↓ (receives)
C98754aTV content (title + LIZLLL)
    ↓ (calls)
CopyLinkChannel.LJI()
    ↓ (extracts)
content.LIZLLL (the share link - FINAL TARGET)
    ↓ (delegates to)
C98761aTc.LIZLLL() → Clipboard
```

---

## Tracking Parameters Found

From search results in `ApS49S0210000_6.java`:
```
- share_source (from utm_source)
- share_link_id (hardcoded or generated)
- utm_campaign
```

---

## TikTok URL Tracking Mechanism (CRITICAL)

### How Tracking Works (Server-Side + Client-Side)

TikTok implements a **multi-layer tracking system** that is NOT visible in the final short URL:

#### Phase 1: URL Building with Tracking Parameters

**File:** `C98444aOV.java` (classes18.dex), lines 137-146

TikTok builds URLs with **embedded query parameters** before shortening:
```java
UriProtector.getQueryParameter(uri, "invitation_scene")  // User context
UriProtector.getQueryParameter(uri, "share_link_id")      // Tracking ID (CRITICAL)
UriProtector.getQueryParameter(uri, "share_item_id")      // Content ID
UriProtector.getQueryParameter(uri, "social_share_type")  // Platform type (WhatsApp, etc.)
```

**Example full URL (before shortening):**
```
https://www.tiktok.com/@ruii19/video/7561803883618602262?
  share_link_id=TRACKING_UUID&
  social_share_type=22&
  share_item_id=7561803883618602262&
  invitation_scene=personal_profile
```

#### Phase 2: URL Shortening via API

**File:** `IMultiShortenUrlApi.java`

**Endpoint:** `POST /tiktok/share/link/shorten/multi/v1/`

**Request payload** (`MultiShortenShareRequest`):
- `scene`: Share scene type (int)
- `share_urls`: List of `ShareURLInfo` objects
  - `platformId`: Platform identifier (e.g., "whatsapp", "facebook", "sms")
  - `shareUrl`: Full URL with tracking params (above)

**Response** (`MultiShortenModel`):
- Short URL: `https://vm.tiktok.com/ZNd7ARdUF/`
- Short code `ZNd7ARdUF` encodes: `share_link_id`, `social_share_type`, platform, timestamp

#### Phase 3: Server-Side Tracking (vm.tiktok.com)

When user opens short URL:
1. **Short code decoded** on TikTok's server → retrieves original full URL + all query params
2. **Tracking logged**: `share_link_id` recorded in analytics database
3. **Redirect issued** to canonical URL (stripping visible tracking params)
   - From: `https://vm.tiktok.com/ZNd7ARdUF/`
   - To: `https://www.tiktok.com/@ruii19/video/7561803883618602262` (no params visible)

### Query Parameter Status in User-Visible URLs

**No.** The short URLs and final redirect URLs do **NOT** contain visible query parameters because:

1. **Short URL** (`vm.tiktok.com/ZNd7ARdUF/`): Tracking encoded in the short code itself
2. **Canonical URL** (`www.tiktok.com/@...`): Server-side analytics used the original params; redirect removes them for clean UX

### Sanitization Strategy for Patch

**Challenge:** Tracking happens both in the initial long URL AND in the short code generation.

**Solution Options:**

**Option A: Strip query params from long URL** (Incomplete)
```javascript
// Intercept before shortening API call
const url = new URL(content.LIZLLL);
url.searchParams.delete('share_link_id');
url.searchParams.delete('social_share_type');
url.searchParams.delete('share_item_id');
url.searchParams.delete('invitation_scene');
// Problem: Short code will still be generated differently, server may not match
```

**Option B: Intercept at clipboard** (Recommended - Simpler)
```java
// In CopyLinkChannel.LJI()
// Extract short URL and expand to canonical form
String shortUrl = content.LIZLLL;  // e.g., https://vm.tiktok.com/ZNd7ARdUF/
// Option 1: Return canonical URL directly (skip shortener)
String canonicalUrl = "https://www.tiktok.com/@[user]/video/[id]";
clipboard.setText(canonicalUrl);

// Option 2: Return short URL as-is (server-side tracking still happens)
// but at least user doesn't expose tracking params in chats
clipboard.setText(shortUrl);
```

**Option C: Hybrid** (Best UX + Privacy)
```
1. Try to extract video ID from short code via local caching/pattern matching
2. Build canonical URL client-side without server-side tracking
3. Fall back to short URL if extraction fails
```

### Key Code Locations for Patch

| Location | Purpose | File |
|----------|---------|------|
| URL building with params | Extract `share_link_id`, etc. | `C98444aOV.java:137-146` |
| Shortening API call | Intercept request before send | `C98444aOV.java:194-195` |
| Final clipboard write | Last chance to sanitize | `CopyLinkChannel.LJI()` (primary patch point) |
| MultiShortenModel response | Short URL returned | `MultiShortenModel.java` |

---

## Heuristics for Matching

- Look for `CopyLinkChannel` instantiation in smali
- Match method signature: `LJI(C98754aTV, Context, InterfaceC50877Hx2)` → `boolean`
- Track field `LIZLLL` (string type, contains full share URL)
- Verify call chain: `LIZLLL()` in CopyLinkChannel invokes clipboard write

## DEX Location

- **Likely class split:** `classes8.dex` (CopyLinkChannel found here)
- Verify in: `smali/com/p124ss/android/ugc/aweme/share/improve/channel/CopyLinkChannel.smali`

## Verification Steps

- [x] Confirm ShareServiceImpl instantiates CopyLinkChannel
- [x] Verify CopyLinkChannel.LJI() is link copy handler
- [x] Locate tracking parameters (share_source, utm_campaign, share_link_id)
- [ ] Extract exact smali bytecode for patch fingerprinting
- [ ] Test on emulator with hook to verify interception point
- [ ] Cross-check app versions (36.5.4 ✓ confirmed)
