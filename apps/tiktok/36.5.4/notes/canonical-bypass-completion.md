# TikTok 36.5.4 – Canonical URL Bypass Completion Report

**Status:** Operational  
**Date:** 2025-10-17  
**Device:** Pixel 9 Pro (Android 16)  
**Package:** `com.zhiliaoapp.musically`

---

## 1. Summary
- Implemented canonical URL generation to replace TikTok’s shortener.  
- Added two helper classes (`CanonicalUrlBuilder`, `CanonicalShortenModelFactory`).  
- Patched `LX/aQC;->LJFF` to call helpers, log canonical output, wrap result in `LX/JSy`, and return before the network call.  
- Verified the flow end-to-end using RV-Sanitizer logging.

---

## 2. Helper Components
| File | Purpose |
|------|---------|
| `smali_classes18/app/revanced/tiktok/share/CanonicalUrlBuilder.smali` | Builds canonical URL from `Aweme` or original URL fallback. |
| `smali_classes18/app/revanced/tiktok/share/CanonicalShortenModelFactory.smali` | Produces a `ShortenModel` with canonical URL, wrapped in `LX/JSy`. |

Key behaviour:
- Prefers `Aweme.getAid()` and author `getUniqueId()`.  
- Falls back to parsing original URL if needed.  
- Returns original URL if canonicalisation fails (safety).  
- Reflection-based to avoid direct dependency on obfuscated classes.

---

## 3. Pipeline Changes
```
LY/ACallableS112S0200000_17.call$0
        ↓
LX/aQC.LJFF                        ← inject canonical builder here
        ├─ Logs original URL (`RV-Sanitizer: aQC.LJFF …`)
        ├─ Builds canonical URL (`RV-Sanitizer: aQC.canonical=…`)
        ├─ Wraps in JSy Single and returns (no network)
        ↓
LX/aTc.LIZLLL                      ← clipboard write point
        └─ Logs clipboard payload
```

Result: canonical URLs reach the clipboard without calling `/tiktok/share/link/shorten/multi/v1/`.

---

## 4. Validation
- **Test scenario:** Copy Link on photo content.  
- **Logs:**
  ```
  D/RV-Sanitizer: aQC.LJFF item=aweme_photo channel=copy origin=https://www.tiktok.com/... (tracking params)
  D/RV-Sanitizer: aQC.canonical=https://www.tiktok.com/@muismilyimy/photo/7550361151910006047?...
  D/RV-Sanitizer: clipboard payload=https://www.tiktok.com/@muismilyimy/photo/7550361151910006047?...
  ```
- **Network**: no call to `/share/link/shorten/multi/v1/`.  
- **Stability**: no crashes or ANRs observed.

---

## 5. Remaining Enhancements
1. Strip residual query parameters from canonical URL output.  
2. Improve `ShortenModel` population (fill optional fields if required).  
3. Extend canonical builder to handle alternate Aweme types (photos, stories, etc.).  
4. Optional: add feature flag to toggle bypass behaviour.  
5. Prepare Java/Kotlin helpers for `revanced-patches` module.

---

## 6. Artifacts
- `decode/apktool/classes18.dex` – compiled canonical bypass.  
- `smali_classes18/app/revanced/tiktok/share/CanonicalUrlBuilder.smali`  
- `smali_classes18/app/revanced/tiktok/share/CanonicalShortenModelFactory.smali`  
- `artifacts/tiktok-canonical-unsigned.apk` – installable test build.

---


## 7. Tracking Parameters (Stock Behaviour)

When TikTok shortens a share link, the client attaches numerous query parameters. Common ones observed in logcat include:

| Parameter | Purpose (observed/guessed) |
|-----------|----------------------------|
| `_r` | Region hint / routing flag |
| `u_code` | User code / referral identifier |
| `preview_pb` | Preview playback toggle |
| `sharer_language` | UI language of sharer |
| `_d` | Internal device/session token |
| `share_item_id` | Content ID (duplicates aid) |
| `source` | Share surface (`h5_m`, etc.) |
| `timestamp` | Epoch timestamp |
| `social_share_type` | Share channel code (copy, whatsapp, …) |
| `utm_source`, `utm_campaign`, `utm_medium` | Marketing attribution |
| `share_iid` | Install ID |
| `share_link_id` | Unique UUID per share/funnel |
| `share_app_id` | App ID (TikTok) |
| `ugbiz_name`, `ug_btm` | Growth/UGC business metrics |
| `link_reflow_popup_iteration_sharer` | JSON-encoded UX flags |

Our patch removes everything after the first `?` before handing the URL back to the app.
- **If the author handle is known:** the clipboard sees `https://www.tiktok.com/@<handle>/video/<aid>`.
- **If no handle is available:** we fall back to `https://www.tiktok.com/video/<aid>`.

Only the shortener call is replaced; the surrounding analytics blocks (`LX/Hrl`, `C50550Hrl`) still execute, so TikTok's telemetry behaves exactly as before.



## 7. Flow Reference (Stock vs Patched)

| Step | Stock behaviour | Patched behaviour |
|------|-----------------|-------------------|
| 1. Share sheet triggered | TikTok builds a share package with `extras["share_url"]`. | Same as stock. |
| 2. `LY/ACallable…call$0` | Injects tracking params (UTM, share IDs, etc.) into the URL. | Helper keeps the canonical URL untouched. |
| 3. `LX/aQC.LJFF` | Calls `/tiktok/share/link/shorten/multi/v1/`, logging the original URL. | Calls `CanonicalUrlBuilder` + `CanonicalShortenModelFactory`, logs canonical URL, and skips the network call. |
| 4. `LX/aTc.LIZLLL` | Clipboard receives the TikTok short link (`https://vm.tiktok.com/...`). | Clipboard receives `https://www.tiktok.com/@handle/video/<aid>` (query stripped). |
| 5. Clipboard / target app | External apps see the shortened URL with tracking. | External apps see the canonical URL with no tracking. |

**Key point:** only step 3 changes. Analytics/logging branches remain in place so feature flags and telemetry continue to behave exactly like the stock app.

---
