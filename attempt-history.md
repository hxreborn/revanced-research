# Global Attempt Tracker

Systematic tracking of all patch development attempts to avoid circles and learn from each iteration.

| Date | App | Version | Target | Method | Result | Notes |
|------|-----|---------|--------|--------|--------|-------|
| 2025-10-19 | tiktok | 36.5.4 | Canonical URLs | Smali: `const/4 v0, 0x0` at UEU.smali:150 | ❌ Failed on device | UEU.LIZJ() not called during share. Wrong interception point. |
| 2025-10-19 | tiktok | 36.5.4 | Canonical URLs | Hardcoded URL in UGk.LJ() smali_classes15/X/UGk.smali:3142 | ❌ URL never appeared | Method compiled into DEX but never executed. UGk.LJ() not in call stack. |
| 2025-10-19 | tiktok | 36.5.4 | Canonical URLs | Hardcoded URL in AwemeSharePackage.LJIJJ() after line 21729 | ❌ URL still shortened | Shortened URL already in List before LJIJJ receives it. Too late in pipeline. Need to find where URL gets shortened. |
