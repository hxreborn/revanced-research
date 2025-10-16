# Patch Plan

## Goal
- Strip tracking params from TikTok share links (align with ReVanced share sanitizer behaviour) without breaking deep links.

## Entry Points
- `com/ss/android/ugc/aweme/share/improve/pkg/AwemeSharePackage::LIZLLL` (descriptor TBD) — constructs share payload map.
- `com/ss/android/ugc/aweme/sharer/model/SharePackage` derivatives — fallback if primary builder fails.

## Bytecode Strategy
1. Fingerprint builder method via literals (`"share_link"`, `"share_link_id"`) and parameter signature (context, aweme, channel).
2. Inject extension bridge call before the URL is finalised; replace original string in map.
3. Ensure register allocation leaves sanitized URL stored back into the map or request object while preserving native guard calls.

## Extension Changes
- `extensions/tiktok/.../SanitizeSharingLinksPatch` (to be created) invoking shared sanitizer util.
- Provide mapping for sanitized parameters and logging hook for validation.

## Bypass & Risk
- Native protectors (`libmetasec`, `libEncryptor`) may checksum code; limit instruction churn and consider inlining sanitiser to mimic existing patterns.
- Sanitizing too aggressively could break campaign analytics; gate behaviour behind option or fallback to original URL on failure.

## Validation
- Manual share flows (copy link, share to clipboard, share to social apps) on emulator/device.
- Verify sanitized URLs retain working redirects; monitor `logcat` for protector violations or crashes.

## Determinism Checklist
- Clean `decode/apktool` and `decode/jadx` before rebuilding patches.
- Re-run decode/decompile and diff artefacts (`sha256sum AndroidManifest.xml`, `diff -ruN smali`).
