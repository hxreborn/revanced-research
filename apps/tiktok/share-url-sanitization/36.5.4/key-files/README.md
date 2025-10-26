# Key Smali Files - Share URL Sanitization Patch

These are the key bytecode files that were patched for share URL sanitization validation.

## Files

- **Trill (UEU.smali)**: URL transformer/sanitizer injection point
  - Class: `p003X.UEU`
  - Method: `LIZLLL(int, String, String, String)`
  - Location: `smali_classes15/X/UEU.smali` in base.apk

- **Musically (aOp.smali)**: URL transformer/sanitizer injection point
  - Class: `p003X.C98464aOp` (obfuscated as `aOp`)
  - Method: `LIZLLL(int, String, String, String)`
  - Location: `smali_classes18/X/aOp.smali` in base.apk

See parent README.md for complete technical details and patch implementation.
