# APK Build Guide for AMD Ryzen Systems
**TikTok 36.5.4 Canonical URL Patch**

**System**: AMD Ryzen 7 5700X3D (16 cores @ 4.15GHz), 31GB RAM
**OS**: Arch Linux
**Date**: 2025-10-19

---

## Problematic Issue

**apktool wrapper script** (`/usr/bin/apktool`) had permission issues when called from subshells in Bash tool. The wrapper is a bash script that invokes the jar.

**Solution**: Call the Java jar directly, bypassing the wrapper.

---

## Working Solution

### Direct JAR Invocation

**File**: `/usr/share/java/android-apktool/apktool.jar`

**Build Command (optimized for your system)**:
```bash
java -Xmx16384M -XX:+UseG1GC -XX:MaxGCPauseMillis=200 \
  -jar /usr/share/java/android-apktool/apktool.jar b \
  -f -j 14 <smali-directory> -o <output.apk>
```

### Parameters Explained

| Parameter | Value | Why |
|---|---|---|
| `-Xmx16384M` | 16GB | 50% of 31GB RAM for optimal GC |
| `-XX:+UseG1GC` | Enabled | G1 Garbage Collector (best for large heaps) |
| `-XX:MaxGCPauseMillis=200` | 200ms | GC pause target (balance between latency and throughput) |
| `-j 14` | 14 threads | 16 cores - 2 reserved for system |
| `-f` | Force | Overwrite existing APK |
| `-b` | Build | Build command for apktool |

---

## Pre-Build Checklist

Before running the build command:

- [ ] Navigate to test directory: `cd apps/tiktok/36.5.4/smali-tests/01-canonical-url/`
- [ ] Verify smali source: `ls -d smali-working/` exists
- [ ] Fix resource issues:
  - [ ] Rename PNG/JPEG mismatches: `mv res/drawable-xxhdpi/bs6.png res/drawable-xxhdpi/bs6.jpg`
  - [ ] Or delete non-critical: `rm -r res/drawable-xxhdpi/bs6.*`
- [ ] Check patch applied: `grep -n "const/4 v0, 0x0" smali-working/smali_classes15/X/UEU.smali`
  - Expected: Line 150 shows the patch

---

## Step-by-Step Build

```bash
#!/bin/bash

# Step 1: Navigate to test directory
cd /home/rafa/Documents/GitHub/revanced-research/apps/tiktok/36.5.4/smali-tests/01-canonical-url

# Step 2: Verify patch is applied
echo "Verifying patch..."
grep -n "const/4 v0, 0x0" smali-working/smali_classes15/X/UEU.smali || {
  echo "ERROR: Patch not found at line 150"
  exit 1
}

# Step 3: Fix known resource issues
echo "Fixing resource issues..."
if [ -f "smali-working/res/drawable-xxhdpi/bs6.png" ]; then
  echo "Found JPEG file with .png extension, renaming..."
  mv smali-working/res/drawable-xxhdpi/bs6.png smali-working/res/drawable-xxhdpi/bs6.jpg
fi

# Step 4: Build APK with optimized Ryzen settings
echo "Building patched APK with optimized JVM settings..."
java -Xmx16384M -XX:+UseG1GC -XX:MaxGCPauseMillis=200 \
  -jar /usr/share/java/android-apktool/apktool.jar b \
  -f -j 14 smali-working/ -o patched-tiktok-36.5.4.apk

# Step 5: Check result
if [ -f "patched-tiktok-36.5.4.apk" ]; then
  echo "✓ APK built successfully!"
  ls -lh patched-tiktok-36.5.4.apk
  echo ""
  echo "Next steps:"
  echo "1. Sign APK: jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA256 -keystore ~/.android/debug.keystore -storepass android patched-tiktok-36.5.4.apk androiddebugkey"
  echo "2. Align APK: zipalign -f 4 patched-tiktok-36.5.4.apk patched-aligned.apk"
  echo "3. Install: adb install patched-aligned.apk"
else
  echo "✗ APK build failed!"
  exit 1
fi
```

---

## Troubleshooting

### Issue: "Permission denied" when calling apktool

**Cause**: `/usr/bin/apktool` wrapper script has issues with Bash subshell execution

**Solution**: Use the jar directly as shown above

### Issue: "OutOfMemoryError: Java heap space"

**Cause**: Heap too small for 400MB+ APK

**Solution**: Increase `-Xmx` value. Current setting (16GB) is sufficient for 16-core system.

### Issue: "bs6.png: error: failed to read PNG signature"

**Cause**: File is JPEG but has .png extension (apktool decompilation quirk)

**Solution**: Rename to correct extension or delete
```bash
mv smali-working/res/drawable-xxhdpi/bs6.png smali-working/res/drawable-xxhdpi/bs6.jpg
```

### Issue: Build is slow or freezes

**Cause**: System swapping due to high GC pressure

**Solution**:
1. Reduce heap: `-Xmx12288M` (12GB)
2. Reduce threads: `-j 12` (12 threads instead of 14)
3. Monitor system: `watch -n 1 'free -h && top -bn1 | head -20'`

### Issue: "Could not write to file" error

**Cause**: Output directory doesn't exist or no write permission

**Solution**:
```bash
mkdir -p output_directory
chmod 755 output_directory
```

---

## Verification

### After Build

1. **Check file exists and size**:
   ```bash
   ls -lh patched-tiktok-36.5.4.apk
   # Expected: ~390-400MB
   ```

2. **Verify Smali was included**:
   ```bash
   unzip -l patched-tiktok-36.5.4.apk | grep classes15.dex
   # Expected: should list classes15.dex
   ```

3. **Check patch in DEX** (requires dexdump):
   ```bash
   unzip -p patched-tiktok-36.5.4.apk classes15.dex | strings | grep -i "canonical\|LIZJ"
   ```

---

## Performance Notes

### Ryzen 7 5700X3D Optimization

This CPU has:
- **8 cores / 16 threads** (note: actual count is 8, not 16 as initially thought)
- **L3 cache**: 96 MB (3D V-Cache)
- **Base clock**: 4.15 GHz

**Optimal settings for this system**:
- **Threads**: 8 (use all cores, not reserved)
- **Heap**: 16GB (still good)
- **GC**: G1GC (still appropriate)

**Alternative optimized command**:
```bash
java -Xmx16384M -XX:+UseG1GC -XX:MaxGCPauseMillis=200 \
  -jar /usr/share/java/android-apktool/apktool.jar b \
  -f -j 8 smali-working/ -o patched-tiktok-36.5.4.apk
```

---

## Success Criteria

✅ APK builds without errors
✅ File size ~390-400MB (similar to original)
✅ Contains patched classes15.dex
✅ Can be signed and aligned
✅ Can be installed via adb
✅ App launches without crashes

---

## Next Steps After Build

1. **Sign APK**:
   ```bash
   jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA256 \
     -keystore ~/.android/debug.keystore -storepass android \
     patched-tiktok-36.5.4.apk androiddebugkey
   ```

2. **Align APK**:
   ```bash
   zipalign -f 4 patched-tiktok-36.5.4.apk patched-aligned.apk
   ```

3. **Install on device/emulator**:
   ```bash
   adb install patched-aligned.apk
   ```

4. **Test canonical URL in shares**:
   - Open TikTok video
   - Share to WhatsApp/clipboard
   - Verify URL is `https://www.tiktok.com/@user/video/id`
   - NOT `https://vm.tiktok.com/...`

---

## References

- **apktool jar**: `/usr/share/java/android-apktool/apktool.jar`
- **Patch location**: `smali_classes15/X/UEU.smali:150`
- **Patch details**: See `PATCH-STRATEGY.md` and `PHASE-2-STATUS.md`

---

**Document Version**: 1.0
**Created**: 2025-10-19
**System**: AMD Ryzen 7 5700X3D, Arch Linux
**Status**: Ready for APK build
