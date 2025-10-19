# Global Attempt Tracker

Systematic tracking of all patch development attempts to avoid circles and learn from each iteration.

| Date | App | Version | Target | Method | Result | Notes |
|------|-----|---------|--------|--------|--------|-------|
| 2025-10-19 | tiktok | 36.5.4 | Canonical URLs | Smali patch - Force v0=0 at UEU.smali:150 | ✅ APK built & signed | Patch: `const/4 v0, 0x0` forces canonical URL path. Fixed manifest resource error @1427046400. Ready for device testing. Docs: PATCH-STRATEGY.md, PHASE-2-STATUS.md, BUILD-COMPLETE.md |
