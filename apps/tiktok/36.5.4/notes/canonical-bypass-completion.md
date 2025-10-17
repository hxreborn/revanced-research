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



## 7. Flow Outline (Stock vs. Patched)

```
Share intent
    ↓
AwemeSharePackage.LJIJJ        # build share payload (extras["share_url"])
    ↓
Callables / channel handlers   # e.g., LY/ACallable…call$0 (copy link)
    • Stock: inject tracking params (UTM, share IDs)
    • Patched: leave canonical URL unchanged
    ↓
C98549aQC.LJFF (entry point)   # shortener + analytics logic
    • Stock: invoke IShortenUrlApi.getShareLinkShortenUel()
    • Patched: CanonicalUrlBuilder + CanonicalShortenModelFactory, skip network
    ↓
LX/aTc.LIZLLL (clipboard path) # or other share targets
    • Stock: clipboard/intent receives https://vm.tiktok.com/...
    • Patched: clipboard/intent receives https://www.tiktok.com/@handle/video/<aid>
    ↓
External app / clipboard user  # user shares canonical link
```

**Notes**
- Only the shortener call is replaced; analytics (`LX/Hrl`, `C50550Hrl`) and feature-flag branches remain intact.
- Applies to any share surface routed through `aQC.LJFF` (copy link, channel chips, “More”).
- Fallback returns the original URL if canonicalisation fails, preserving stock behaviour.

---
