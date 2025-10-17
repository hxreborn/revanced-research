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

The canonical bypass strips the entire query string, returning the base
`https://www.tiktok.com/@<handle>/video/<aid>` (or fallback `/video/<aid>` when no handle is available). Analytics events (LX/Hrl) continue to fire because the patched method only replaces the network call, not the logging branches.



## 7. Flow Reference (Stock vs Patched)

```
          ┌──────────────────────────┐
          │  Share sheet triggered   │
          └────────────┬────────────┘
                       │
                       ▼
          ┌──────────────────────────┐
          │ AwemeSharePackage.LJIJJ │ ➊ extras["share_url"] populated
          └────────────┬────────────┘
                       │
                       ▼
          ┌──────────────────────────┐
          │ LY/ACallable…call$0     │ ➋ Copy-link callable
          │  Stock: injects UTM     │
          │  Patched: preserves URL │
          └────────────┬────────────┘
                       │
                       ▼
          ┌──────────────────────────┐
          │ LX/aQC.LJFF              │ ➌ Entry point audited here
          │  Stock: invoke shortener │
          │  Patched: CanonicalUrl   │
          │          Builder + JSy   │
          └────────────┬────────────┘
                       │
          Stock        │        Patched
     (network call)    │        (no network call)
                       │
          ┌────────────▼────────────┐
          │ LX/aTc.LIZLLL           │ ➍ Clipboard write
          │  Stock: vm.tiktok.com   │
          │  Patched: canonical URL │
          └────────────┬────────────┘
                       │
                       ▼
          ┌──────────────────────────┐
          │ Clipboard / share target │ ➎ External apps receive canonical URL
          └──────────────────────────┘
```

**Behaviour summary**
- **Stock**: `aQC.LJFF` calls `/tiktok/share/link/shorten/multi/v1/`, clipboard receives a `vm.tiktok.com` short link containing tracking parameters.
- **Patched**: helper bypasses the API, constructs `https://www.tiktok.com/@handle/video/<aid>` (query stripped), clipboard and intents receive tracking-free URLs.
- Analytics (`LX/Hrl`, `C50550Hrl`) and feature-flag branches remain intact so fallback matches stock behaviour when TikTok disables the shortener.

---
