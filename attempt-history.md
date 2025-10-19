# Global Attempt Tracker

Systematic tracking of all patch development attempts to avoid circles and learn from each iteration.

| Date | App | Version | Target | Method | Result | Notes |
|------|-----|---------|--------|--------|--------|-------|
| 2025-10-19 | tiktok | 36.5.4 | Canonical URLs | Smali: `const/4 v0, 0x0` at UEU.smali:150 | ❌ Failed | UEU.LIZJ() not called during share. Wrong interception point. |
| 2025-10-19 | tiktok | 36.5.4 | Canonical URLs | Hardcoded URL in UGk.LJ() smali_classes15/X/UGk.smali:3142 | ❌ Failed | Method compiled but never executed. UGk.LJ() not in call stack. |
| 2025-10-19 | tiktok | 36.5.4 | Canonical URLs | Hardcoded URL in AwemeSharePackage.LJIJJ() after line 21729 | ❌ Failed | Shortened URL already in List before LJIJJ receives it. Too late in pipeline. |
| 2025-10-19 | tiktok | 36.5.4 | Canonical URLs | Logging in AwemeSharePackage.LJIJJLI() line 2795 | ✅ BREAKTHROUGH | URL is CANONICAL at entry: `https://www.tiktok.com/@user/video/ID?params`. Shortened by UEU.LIZLLL() at line 2889. Found the source! |
