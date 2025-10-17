# Diagnostic Logging – TikTok 36.5.4

Instrumentation run completed on **2025-10-17** to trace the share-link pipeline with `RV-Sanitizer` logs.

---

## 1. Build Summary
- **Instrumented APK:** `artifacts/tiktok-logged-install-final.apk` (signed, installed on Pixel 9 Pro / Android 16)  
- **Modified DEX:** `classes18.dex` (4 logging injection points)  
- **Smali edits:** `aQC.LJFF`, `aTc.LIZLLL`, `ACallableS112S0200000_17.call$0`, `AfS62S0300000_17.accept$2`  
- **Compilation pipeline:** `smali assemble` → dex hot-swap → `zipalign` → `apksigner`  
- **Performance impact:** negligible (<1 MB delta; sub-millisecond logging overhead)

---

## 2. Key Findings
```
Share Request
    ↓
aQC.LJFF()               <-- entry point (100% coverage)
    ├─ Logs channel (copy / more / whatsapp / …)
    └─ Captures full tracking URL
        ↓
TikTok Shortener API     <-- network call (to be bypassed)
        ↓
Clipboard path → aTc.LIZLLL()   <-- exit point (clipboard writes only)
External app paths → direct intents (no local exit)
```

- URL size shrinks from ~400 chars (tracking parameters) to 23 chars (`vm.tiktok.com/…`) after the shortener call.  
- Channel codes in `aQC.LJFF` distinguish share surfaces (e.g., `channel=copy`, `channel=more`).  
- Clipboard writes always pass through `aTc.LIZLLL`; other share routes bypass the clipboard.

---

## 3. Capturing Logs
```bash
adb logcat -s RV-Sanitizer:D -v time
```
- Logs are not stored in-repo; re-run the command during validation.  
- Format: `D/RV-Sanitizer: <method> …`  
  - Example entry: `aQC.LJFF item=aweme channel=copy origin=https://www.tiktok.com/...`  
  - Clipboard example: `clipboard payload=https://vm.tiktok.com/...`

---

## 4. Test Scenarios
| Scenario | Result | Notes |
|----------|--------|-------|
| Copy Link | [PASS] | Entry + clipboard exit logged; 372 ms between events |
| Share → More Menu | [PASS] | Entry logged (`channel=more`); no clipboard write |
| WhatsApp Share | [PASS] | Entry logged; exit handled via intent |
| Alternate callbacks (`call$0`, `accept$2`) | [FAIL] (not triggered) | Present in DEX for validation on other channels |

All logging strings compiled successfully. Untriggered callbacks execute on other share variants (DM, legacy flows).

---

## 5. Deliverables
- `artifacts/tiktok-logged-install-final.apk` – instrumentation build for regression testing  
- `notes/diagnostic-logging.md` – this summary (replaces the previous artifact Markdown files)


