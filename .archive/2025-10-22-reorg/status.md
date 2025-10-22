# Project Status Dashboard

**Last Updated:** 2025-10-20
**Phase:** 2 (Smali Validation)
**Target:** TikTok 36.5.4 - Share URL canonicalization

---

## ✅ Verified Facts

- **Canonical URL entry point found:** `AwemeSharePackage.LJIJJLI()` at line 2795
- **URL status at entry:** Full canonical (`https://www.tiktok.com/@user/video/ID?params...`)
- **Shortening orchestrator:** `UEU.LIZLLL()` at line 2889 converts canonical to short link
- **All share channels affected:** WhatsApp, Twitter, SMS, clipboard all use same shortened URL
- **Method call chain verified:** Entry point to shortening confirmed through smali inspection
- **Register pressure:** Method uses all 5 available registers (v0-v4), no temp space

---

## ❓ Open Questions

1. **Can Wu4 async wrapper be bypassed?** (Unknown if constructor can create pass-through)
2. **Are earlier interception points available?** (Before LJIJJLI?)
3. **Is DEX verification compatible with register-constrained patches?** (Type conflicts when inserting code)
4. **Can callback chain be overridden?** (Intercept LIZLLL result instead of bypassing?)

---

## 📋 Next Steps

1. **Immediate:** Study Wu4 pattern and similar LIZLLL usages to understand return type
2. **Option A:** Bypass shortening via false/noop return from LIZLLL call
3. **Option B:** Find URL before LIZLLL call and pass canonical through chain
4. **Option C:** Search for earlier canonical URL source (before LJIJJLI)
5. **Test:** Each approach in smali-tests/0X-* with verification logs

---

## References

- **Injection Points:** `apps/tiktok/36.5.4/injection-points.md`
- **Obfuscation Map:** `apps/tiktok/36.5.4/obfuscation-map.md`
- **Attempt History:** `attempt-history.md`
- **Verification Analysis:** `apps/tiktok/36.5.4/verification/`
