# Global Attempt Tracker

Systematic tracking of all patch development attempts to avoid circles and learn from each iteration.

| Date | App | Version | Target | Method | Result | Notes |
|------|-----|---------|--------|--------|--------|-------|
| 2025-10-19 | tiktok | 36.5.4 | Canonical URLs | Smali: `const/4 v0, 0x0` at UEU.smali:150 | ❌ Failed | UEU.LIZJ() not called during share. Wrong interception point. |
| 2025-10-19 | tiktok | 36.5.4 | Canonical URLs | Hardcoded URL in UGk.LJ() smali_classes15/X/UGk.smali:3142 | ❌ Failed | Method compiled but never executed. UGk.LJ() not in call stack. |
| 2025-10-19 | tiktok | 36.5.4 | Canonical URLs | Hardcoded URL in AwemeSharePackage.LJIJJ() after line 21729 | ❌ Failed | Shortened URL already in List before LJIJJ receives it. Too late in pipeline. |
| 2025-10-19 | tiktok | 36.5.4 | Canonical URLs | Logging in AwemeSharePackage.LJIJJLI() line 2795 | ✅ BREAKTHROUGH | URL is CANONICAL at entry: `https://www.tiktok.com/@user/video/ID?params`. Shortened by UEU.LIZLLL() at line 2889. Found the source! |
| 2025-10-20 | tiktok | 36.5.4 | Bypass Shortening | Phase 5: vm./vt. detection + canonical swap in UEU.LIZLLL() | ⚠️ SUPERSEDED | Patch compiled, app stable, but discovery: UEa.LIZ() returns canonical URLs with massive tracking blob, not shortened URLs. Strategy pivot required. |
| 2025-10-20 | tiktok | 36.5.4 | Strip Tracking | Phase 6: URL parameter sanitizer - strip everything after '?' | ✅ SUCCESS | 89% size reduction (568→63 chars). Whitelist approach removes all 18 tracking params. Production-ready, no debug logs. See `apps/tiktok/36.5.4/` for details. |
