# Tooling & Environment

**App**: `<app-id>`  
**Version**: `<version>`  
**Analysis Date**: `YYYY-MM-DD`  
**Analyst**: `<your-name>`

---

## APK Provenance

### Source APK

**File**: `<filename.apk>`  
**Source**: `[APKMirror|APKPure|Google Play|Official Website|Other]`  
**Download Date**: `YYYY-MM-DD`

**Architecture**: `[universal|arm64-v8a|armeabi-v7a|x86|x86_64]`

### Integrity Verification

**SHA-256**: `<hash>`  
**MD5**: `<hash>` (optional)  
**File Size**: `XXX MB`

```bash
# Verification commands
sha256sum app-36.5.4.apk
# Expected: <hash>
```

### APK Metadata

**Package Name**: `com.example.app`  
**Version Name**: `36.5.4`  
**Version Code**: `365040123`  
**Min SDK**: `24` (Android 7.0)  
**Target SDK**: `34` (Android 14)

---

## System Environment

### Operating System

**OS**: `Linux 6.16.8-2-cachyos`  
**Architecture**: `x86_64`

### Java Environment

**Java Version**: `openjdk version "17.0.x"`  
**JAVA_HOME**: `/usr/lib/jvm/java-17-openjdk`

---

## Tool Versions

### Core RE Tools

#### apktool

**Version**: `2.12.0`

```bash
apktool --version
# 2.12.0
```

**Usage**:

```bash
# Decode APK
apktool -JXmx4g d app-36.5.4.apk -o decode/apktool/ -f
```

#### jadx

**Version**: `1.5.1`

```bash
jadx --version
# jadx 1.5.1
```

**Usage**:

```bash
# CLI export
jadx --threads-count 4 -d decode/jadx/ app-36.5.4.apk
```

---

## Decompilation Benchmarks

### apktool Performance

**Run 1** (Initial decode):
- Real time: `3m 24.5s`
- Max heap used: `3.2 GB`
- Output size: `1.4 GB`

**Run 2** (Reproducibility check):
- Real time: `3m 21.8s`
- Max heap used: `3.2 GB`
- Output size: `1.4 GB`

**Reproducibility**: Output is bit-for-bit identical

### jadx Performance

**Run 1** (With deobfuscation):
- Real time: `8m 12.3s`
- Max heap used: `5.1 GB`
- Output size: `982 MB`

**Reproducibility**: Minor formatting differences, core code identical

---

## Obfuscation Analysis

### Obfuscation Detection

**Detected Obfuscator**: `[None|ProGuard|R8|DexGuard|Unknown]`  
**Obfuscation Level**: `[NONE|LOW|MEDIUM|HIGH|EXTREME]`

**Characteristics**:
- Class name mangling: YES/NO
- Method name mangling: YES/NO
- String encryption: YES/NO
- Control flow obfuscation: YES/NO

### Deobfuscation Strategy

**Approach**:
1. String literal analysis
2. Android framework API calls
3. Class hierarchy reconstruction
4. Resource references

---

## Anti-Analysis Measures

### Detected Protections

- [ ] Root detection
- [ ] Emulator detection
- [ ] Debugger detection
- [ ] Integrity checks
- [ ] Certificate pinning

### Bypass Strategies

**Root Detection**: Magisk with Zygisk  
**Certificate Pinning**: Frida script or patch  
**Integrity Checks**: Hook verification methods

---

## Build Reproducibility

### Deterministic Builds

**Hypothesis**: apktool decode output should be deterministic.

**Test Result**: `[REPRODUCIBLE|NOT_REPRODUCIBLE]`

**Differences** (if any): Timestamps in apktool.yml, nondeterministic resource ordering

---

## Environment Setup Commands

### Initial Setup

```bash
# Create target workspace
mkdir -p targets/<app>/<ver>/{apk,decode/{apktool,jadx},notes,artifacts,tmp}
cp docs/templates/*.md targets/<app>/<ver>/notes/
cp -r docs/templates/scripts/ targets/<app>/<ver>/scripts/
```

### Decompilation Pipeline

```bash
cd targets/<app>/<ver>/scripts/

# apktool decode
apktool -JXmx4g d ../apk/<app>-<ver>.apk -o ../decode/apktool/ -f

# jadx export
jadx --threads-count 4 -d ../decode/jadx/ ../apk/<app>-<ver>.apk
```

---

## Known Issues

### apktool
- Issue: OOM on APKs > 200MB
- Workaround: Use `-JXmx8g` or higher

### jadx
- Issue: Hangs on certain methods
- Workaround: Skip deobfuscation or reduce threads

---

## Update Log

**YYYY-MM-DD**: Initial environment setup, apktool 2.12.0, jadx 1.5.1
