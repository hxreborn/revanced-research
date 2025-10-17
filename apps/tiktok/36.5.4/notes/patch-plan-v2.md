# Patch Plan v2 – Share Link Sanitizer

**Target:** TikTok 36.5.4  
**Patch:** Share Link Sanitizer (phase 2)  
**Owner:** Codex agent session (2025-10-17)  

---

## 1. Objectives
- Re-validate the copy-link pipeline against the latest decompile.
- Insert canonical URL generation ahead of TikTok’s shortener.
- Instrument the flow with three logging checkpoints to prove the patch path.

---

## 2. Call Stack Overview
1. `AwemeSharePackage.LJIJJ(...)` prepares the share payload and writes the working URL into `extras["share_url"]`.  
   _Ref:_ `apps/tiktok/36.5.4/decode/jadx/jadx-no-deobf-normal/sources/com/ss/android/ugc/aweme/share/improve/pkg/AwemeSharePackage.java:279`
2. `LY/ACallableS112S0200000_17;->call$0` enriches `ShareInfo` with UTM params and, when enabled, calls `LX/aQC;->LJFF(...)` to hit the shortener.  
   _Ref:_ `apps/tiktok/36.5.4/decode/apktool/smali_classes18/Y/ACallableS112S0200000_17.smali:69`
3. `LX/aQC;->LJFF(...)` constructs the `/tiktok/share/link/shorten/multi/v1/` request, handles retries, and wraps the result in an Rx Single.  
   _Ref:_ `apps/tiktok/36.5.4/decode/apktool/smali_classes18/X/aQC.smali:560`
4. `LY/AfS62S0300000_17;->accept$2` merges the resolved URL with optional title text before clipboard dispatch.  
   _Ref:_ `apps/tiktok/36.5.4/decode/apktool/smali_classes18/Y/AfS62S0300000_17.smali:262`
5. `LX/aTc;->LIZLLL(...)` writes the final string into `ClipboardManager`.  
   _Ref:_ `apps/tiktok/36.5.4/decode/apktool/smali_classes18/X/aTc.smali:132`

> **Reminder:** The UI listener `LX/aqc;->onClick` exits before this pipeline and does not see clipboard mutations—explains the silent hook from the prior attempt.

---

## 3. Logging & Hook Plan

| Stage | Location | Purpose | Proposed Log |
|-------|----------|---------|--------------|
| Pre-shortening | `LY/ACallableS112S0200000_17;->call$0` | Record original share URL and the value returned; surface feature flag state | `Log.d("RV-Sanitizer", "call0 in=" + vShareUrl + " out=" + vReturn + " gate=" + C74211T9s.LJII())` |
| Shortener entry | `LX/aQC;->LJFF` | Inspect `itemType`, `channel`, `origin`; future swap point for canonical builder | `Log.d("RV-Sanitizer", "aQC before item=" + p1 + " channel=" + p2 + " origin=" + p3)` |
| Clipboard merge | `LY/AfS62S0300000_17;->accept$2` | Verify pipeline output before title concatenation | `Log.d("RV-Sanitizer", "accept2 final=" + p1)` |
| Clipboard write | `LX/aTc;->LIZLLL` | Confirm final clipboard payload | `Log.d("RV-Sanitizer", "clipboard payload=" + p1)` |

Implementation notes:
- Use `android/util/Log;->d` with tag `RV-Sanitizer`.
- Allocate spare registers for log strings to avoid clobbering live temps.
- Keep logs during verification; prune or guard them before upstream merge.

---

## 4. Patch Tasks
1. **Helper readiness**  
   - Ensure `CanonicalUrlBuilder` & `CanonicalShortenModelFactory` (from revanced-patches) are synced and usable.  
   - If missing, stub helpers locally with unit tests before wiring into smali.
2. **Shortener bypass (`LX/aQC;->LJFF`)**  
   - Add early exit to build canonical URL and return a `LX/JSy` Single when the gate allows.  
   - Retain analytics side-effects (timers, `LX/Hrl`) to avoid regression.  
   - Fallback to original path when canonicalisation fails or gate disables feature.
3. **Pre-shortening adjustments (`call$0`)**  
   - Skip UTM injection when returning canonical URL.  
   - Respect `C74211T9s.LJII()` toggle to keep stock behaviour when disabled.
4. **Logging injection**  
   - Apply the four logging hooks.  
   - Verify registers/reg-order for each insertion (`move-result`, etc.).
5. **Regression coverage**  
   - Standard copy-link flow.  
   - Share sheet with alternative surfaces (WhatsApp, email).  
   - Ads/restricted content.  
   - Gate disabled path (`C74211T9s.LJII() == true`).  
   - Ensure no requests hit `/tiktok/share/link/shorten/multi/v1/` in canonical mode.

---

## 5. Risks & Mitigations
- **Rx chain expectations**: Replacement must still return `LX/aX5` (Single). Keep method signature/return type intact.  
- **Register pressure**: Logging can increase register usage; adjust `.locals` counts as needed.  
- **Flag drift**: `C74211T9s.LJII()` might flip globally—guard canonical path accordingly.  
- **Telemetry impacts**: Maintain `LX/Hrl` logging to avoid analytics anomalies.

---

## 6. Verification Checklist
- [ ] `RV-Sanitizer:call0` shows canonical URL (no tracking params).  
- [ ] `RV-Sanitizer:aQC before` prints exactly once per copy action.  
- [ ] `RV-Sanitizer:accept2` message matches clipboard string.  
- [ ] `RV-Sanitizer:clipboard` logs canonical URL every run.  
- [ ] No shortener network calls observed in logcat / proxy.  
- [ ] Canonical links open directly to target content with no redirect chain.  

---

## 7. Handoff Notes
- After verification, migrate smali edits + helpers into `revanced-patches` module.  
- Update `notes/patch-plan.md` (primary plan) once v2 changes prove stable to keep AGENTS timeline consistent.  
- Remove or wrap debug logging prior to final patch submission if upstream prefers clean logs.

---

## 8. Next Steps (Open)
- [x] Inject logging at the four checkpoints and validate via `adb logcat`. _(2025-10-17 diagnostic build; see `artifacts/PROJECT_COMPLETION_SUMMARY.md`)_  
- [ ] Implement canonical URL shortcut inside `LX/aQC;->LJFF` with helper integration.  
- [ ] Update `LY/ACallableS112S0200000_17;->call$0` to skip UTM injection when canonicalising.  
- [ ] Run regression matrix (copy link, share sheet, ads/restricted) on device/emulator.  
- [ ] Port confirmed changes into `revanced-patches` and sync helper classes.
