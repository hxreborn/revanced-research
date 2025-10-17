# Patch Plan – TikTok Share Link Sanitizer

**App / Version:** TikTok 36.5.4  
**Patch Name:** Share Link Sanitizer  
**Priority:** High  
**Current Status:** IMPLEMENTATION (helpers + smali integration in progress)  
**Last Updated:** 2025-10-17  

---

## 1. Objectives
- Deliver canonical share URLs (`https://www.tiktok.com/@handle/video/<aid>`) across all share surfaces.
- Remove TikTok tracking parameters by skipping the `/share/link/shorten/multi/v1/` API.
- Preserve analytics/telemetry and maintain behaviour when TikTok disables shortening.
- Validate the change locally with the RV-Sanitizer logging build before porting to ReVanced.

---

## 2. Current Architecture
1. `AwemeSharePackage.LJIJJ(...)` populates `extras["share_url"]` before invoking channels.  
2. `LY/ACallableS112S0200000_17;->call$0` loads Aweme + ShareInfo, currently injects UTM params, and calls `C98549aQC.LJFF`.  
3. `LX/aQC;->LJFF` constructs the shorten request and calls `IShortenUrlApi.getShareLinkShortenUel`.  
4. Rx observers resolve to `LY/AfS62S0300000_17;->accept$2`, which writes the result into the clipboard via `LX/aTc;->LIZLLL`.  
5. Diagnostic logging (2025-10-17 build) confirmed hooks at each stage and established canonical bypass targets.

---

## 3. Implementation Strategy

### 3.1 Helper Classes (Java → Smali)
- `CanonicalUrlBuilder.buildFromAweme(Aweme?, String?)`  
  - Prefer Aweme fields (`getAid()`, `getAuthor().getUniqueId()`).  
  - Fallback to parsing the original URL.  
  - Return canonical URL or original URL as safety.
- `CanonicalShortenModelFactory.create(String)`  
  - Produce `ShortenModel` (status 200, message “Success”, short/original URL = canonical).  
  - Wrap in existing pipeline via `LX/JSy`.
- Compile helpers, run `baksmali`, and place smali under `smali_classes18/app/revanced/tiktok/share/`.

### 3.2 Smali Edits
- **`LY/ACallableS112S0200000_17;->call$0`:**  
  - Invoke `CanonicalUrlBuilder` immediately after fetching `ShareInfo.getShareUrl()`.  
  - Replace ShareInfo URL with canonical string.  
  - Skip UTM injection block when canonical URL has no query parameters.  
  - Respect `C74211T9s.LJII()` for fallback behaviour.
- **`LX/aQC;->LJFF`:**  
  - After analytics timing setup, branch:  
    - If `C74211T9s.LJII()` returns true → execute stock fallback (no change).  
    - Else → call `CanonicalShortenModelFactory.create(canonicalUrl)` and return new `LX/JSy` instance, skipping network.  
  - Retain `LX/Hrl` logging so analytics remain intact.
- Bump `.locals` as needed and ensure all registers are preserved.

### 3.3 Build & Test Loop
1. Assemble `classes18.dex` with `smali`.  
2. Hot-swap into APK and align/sign (reuse existing workflow).  
3. Install on device (Pixel 9 Pro) and verify via logcat:  
   - `RV-Sanitizer:call0` / `aQC before` / `accept2` / `clipboard` all show canonical URLs.  
   - No network requests to `/share/link/shorten/multi/v1/`.

---

## 4. Tasks & Owners

| Task | Status | Notes |
|------|--------|-------|
| Implement helper classes (Java) and derive smali | ☐ | Compile via `javac` + `d8`, extract with `baksmali`. |
| Inject helper smali into apktool tree | ☐ | Place under `smali_classes18/app/revanced/tiktok/share/`. |
| Modify `call$0` to use canonical builder + skip UTM | ☐ | Requires `.locals` bump and branch guard. |
| Modify `aQC.LJFF` to return canonical Single | ☐ | Replace shortener invoke while preserving analytics. |
| Rebuild dex, hot-swap APK, reinstall | ☐ | Script already in `tooling.md` (diagnostic build workflow). |
| Verify logs + regression checklist | ☐ | Use `adb logcat -s RV-Sanitizer:D -v time`. |
| Port helpers + smali edits to `revanced-patches` | ☐ | After verification; create fingerprints & patch. |
| Remove temp helpers directory (`notes/helpers`) | ☐ | Once helpers are committed or moved upstream. |

---

## 5. Risks & Mitigations
- **Incomplete Aweme data:** Use URL parsing fallback; return original URL if aid missing.  
- **Register pressure:** Carefully adjust `.locals` and reuse temps to avoid clobbering state.  
- **Feature flag drift:** Always respect `C74211T9s.LJII()`; fall back to stock path when TikTok disables shortening.  
- **Telemetry regression:** Leave timing/logging intact so analytics pipelines remain unaffected.  
- **Rebuild issues:** Continue dex hot-swap workflow if apktool manifest errors persist (documented in `tooling.md`).

---

## 6. Verification Checklist
- [ ] `RV-Sanitizer:call0` shows canonical URL without query parameters.  
- [ ] `RV-Sanitizer:aQC before` emits once per share, no network request follows.  
- [ ] Clipboard log matches canonical URL for Copy Link.  
- [ ] Share sheet / external apps still receive valid URLs.  
- [ ] No crashes, ANRs, or missing analytics logs (`LX/Hrl`).  
- [ ] Feature flag off (`C74211T9s.LJII() == true`) falls back to stock behaviour.

---

## 7. Handoff to ReVanced
1. Move helper classes into `revanced-patches` (Kotlin/Java module).  
2. Create fingerprints for `call$0` and `aQC.LJFF`.  
3. Encode smali transformations as patch code (e.g., `MethodTransformer`).  
4. Wire into configuration (optional toggle).  
5. Add regression tests mirroring the diagnostic scenarios.  
6. Update documentation (`README`, `tooling`, `research-status`) with final verification results.

---

## 8. Open Items
- [x] Diagnostic logging build complete (`artifacts/tiktok-logged-install-final.apk`).  
- [ ] Helpers compiled & smali integrated.  
- [ ] Smali edits verified on-device.  
- [ ] Regression matrix executed (Copy Link, Share Sheet, channel chips, analytics).  
- [ ] Patch ported to `revanced-patches` with tests.

Keep this document as the single authoritative plan; remove or update any drafts instead of duplicating.***
**Precondition**: Patched TikTok on emulator  
**Steps**:
1. Copy canonical URL via TC-001
2. Open in browser or share to recipient
3. Verify video plays

**Expected**: Full video functionality  
**Verification**: No 404, no redirect loops, metadata displays  
**Status**: `[PASS|FAIL|BLOCKED]`

#### TC-006: Edge Cases
**Precondition**: Various video scenarios  
**Steps**:
1. Share video with special characters/emoji in username
2. Share from user profile (not feed)
3. Share live/story if available

**Expected**: All produce canonical URL consistently  
**Verification**: Same format across edge cases  
**Status**: `[PASS|FAIL|BLOCKED]`

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
