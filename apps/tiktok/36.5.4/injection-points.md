# Verified Injection Points - TikTok 36.5.4

## Test 01-canonical-url - 2025-10-19

- **Target**: UEU.LIZJ() method
- **Class**: `Lp003X/UEU;`
- **Method**: `LIZJ(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;`
- **Location**: `smali_classes15/X/UEU.smali:150`
- **Patch**: Force condition false to bypass shortened URL path
  - Insert: `const/4 v0, 0x0`
  - Effect: Skip condition at line 160, execute transformation block (lines 162-306)
- **Result**: ✅ APK built successfully (631 MB)
- **Deliverable**: `smali-tests/01-canonical-url/patched-tiktok-36.5.4.apk`

## What This Does

**Before patch**:
- UhW.LJII() returns true → skips transformation → returns shortened URL

**After patch**:
- Force v0 to 0 (false) → always executes transformation → returns canonical URL
