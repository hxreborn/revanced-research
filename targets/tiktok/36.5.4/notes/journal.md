# Research Journal

## Session Log
- 2025-10-16 10:58 UTC — Apktool decode completed (3.4 GB output, real 27.3 s, user 160.6 s, sys 47.1 s). JADx runs with 4 and 1 threads crashed (SIGSEGV) after ~68 s and ~280 s; crash log `hs_err_pid1797451.log` reports peak RSS ≈14 GB. No deobf mapping generated yet.

## Key Findings
- Apktool output lives under `decode/apktool` with 50 smali splits (`smali`, `smali_classes2`…`smali_classes49`), `AndroidManifest.xml`, and `res/values/public.xml` for resource mapping.
- Native libs include multiple protectors (`libEncryptor.so`, `libfileprotect.so`, `libmetasec_ov.so`, `libpsiencrypt.so`, `libropaencrypt.so`) indicating layered anti-tamper/encryption.
- JADx emits partial output (`decode/jadx`, 1.6 GB) before crashing; cleanup between retries is required to avoid stale artifacts.

## Open Questions
- Can we stabilise decompilation via `jadx --threads-count 1 --no-imports --deobf` plus higher heap (e.g., `-JXmx16g`), or do we need to batch-process individual DEX files?
- Should we bake in FernFlower (`dex-tools` → `jar`) or smali-only diffing as fallbacks when JADx is unstable?
- What runtime instrumentation/bypass is required to neutralise native protectors (`libmetasec`, `libEncryptor`) once patches are deployed?

## Next Actions
- Enforce deterministic pipeline: clean `decode/*` before each run, log tool versions, and persist the base APK hash `b560a53fcea5246f03416556fead581cb49e37ff938c60ed10c8ec53defadb3c`.
- Retry decompilation with tuned JADx flags or alternate decompilers and capture heap/time metrics alongside crash logs.
- Build a share-link entry-point map (activities/services → `com/ss/android/ugc/aweme/share/improve/pkg/*`) and capture candidate fingerprints in `notes/fingerprints.md`.
