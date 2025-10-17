# TikTok 36.5.4 – Canonical URL Bypass Completion Report

**Status:** ✅ Operational  
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

## 6. Porting Checklist (revanced-patches)
- [ ] Copy helper logic into module (Kotlin/Java).  
- [ ] Create fingerprints for `call$0` and `aQC.LJFF`.  
- [ ] Inject bytecode transformations via MethodTransformer.  
- [ ] Add configuration/flag if desired.  
- [ ] Add regression tests mirroring diagnostic scenarios.  
- [ ] Validate on additional TikTok versions (36.6.x, 37.x, etc.).

---

## 7. Files to Preserve
- `decode/apktool/classes18.dex` – compiled canonical bypass.  
- `smali_classes18/app/revanced/tiktok/share/CanonicalUrlBuilder.smali`  
- `smali_classes18/app/revanced/tiktok/share/CanonicalShortenModelFactory.smali`  
- `artifacts/tiktok-canonical-unsigned.apk` – installable test build.

---

## 8. Next Steps
1. Refine canonical builder to drop tracking query parameters.  
2. Integrate changes into `revanced-patches` and ship as a formal patch.  
3. Repeat validation on fresh builds after integration.
# End of Report
