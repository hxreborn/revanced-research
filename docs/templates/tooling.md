# Tooling & Reproducibility

**App**: `<app-id>`
**Version**: `<version>`
**APK SHA-256**: `[hash here]`
**Date**: `YYYY-MM-DD`

---

## Environment

### Tool Versions

| Tool | Version | Command |
|------|---------|---------|
| Java | `java -version` output | e.g., `openjdk version "21.0.2"` |
| apktool | `apktool --version` output | e.g., `2.12` |
| jadx | `jadx --version` output | e.g., `1.5.0` |
| CFR | `java -jar cfr.jar --version` output | e.g., `0.152` |
| dex2jar | `d2j-dex2jar --version` output | e.g., `2.4` |

### System Specs

- **CPU Cores**: N
- **RAM**: XGB total, YGB available during analysis
- **Disk**: ZGB free

---

## Commands Run

### 1. apktool Decode

```bash
apktool -JXmx4g d apps/<app>/<version>/apk/<app>-<version>.apk \
  -o apps/<app>/<version>/decode/apktool/ -f
```

**Duration**: Xs
**Output Size**: XXX MB
**Log**: `artifacts/apktool-decode.log`

---

### 2. jadx Decompilation

```bash
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms4g -Xmx16g"
export THREADS=4
./scripts/run-jadx.sh apps/<app>/<version>/apk/<app>-<version>.apk \
  apps/<app>/<version>
```

**Duration**: Xs
**Output Size**: XXX GB
**Java Files**: N
**Errors**: M (X%)
**Log**: `artifacts/jadx-export.log`

---

### 3. DEX to JAR Conversion

```bash
cd apps/<app>/<version>/tmp/dex
for dex in *.dex; do d2j-dex2jar "$dex" -o ../dex2jar/"${dex%.dex}.jar"; done
```

**Duration**: Xs total
**Output JAR Count**: N
**Total Size**: XXX MB
**Warnings**: (e.g., "GLITCH: LO/O;-><clinit>()V in classes6.dex")

---

### 4. CFR Analysis (Per-DEX)

**Clean slate before running:**
```bash
rm -rf apps/<app>/<version>/decode/cfr/classes*
```

**Run CFR on critical DEX files:**

```bash
# classes8.dex (contains CopyLinkChannel - FP-001)
java -jar /path/to/cfr.jar apps/<app>/<version>/decode/dex2jar/classes8.jar \
  --outputdir apps/<app>/<version>/decode/cfr/classes8

# classes18.dex (contains C98444aOV - FP-002)
java -jar /path/to/cfr.jar apps/<app>/<version>/decode/dex2jar/classes18.jar \
  --outputdir apps/<app>/<version>/decode/cfr/classes18
```

**CFR Runtime Summary:**
| JAR | Duration | Classes | Methods | Warnings |
|-----|----------|---------|---------|----------|
| classes8.jar | Xs | N | N | - |
| classes18.jar | Xs | N | N | - |

---

## Performance Metrics

### Decompilation Comparison

| Tool | Duration | Output Size | Quality | Notes |
|------|----------|-------------|---------|-------|
| apktool | Xs | XXX MB | Resources + smali | Reliable for resources |
| jadx | Xs | XXX GB | Readable Java | Best for obfuscated code |
| CFR (classes8) | Xs | XXX MB | Good type inference | Per-DEX faster |
| CFR (classes18) | Xs | XXX MB | Good type inference | Per-DEX faster |

---

## Known Issues & Workarounds

### Issue: ...
**Symptom**: ...
**Workaround**: ...
**Resolution**: ...

---

## Reproducibility Checklist

- [ ] Exact Java version matches (major.minor.patch)
- [ ] apktool command includes `-JXmx4g` flag
- [ ] jadx command includes `--deobf` flag
- [ ] dex2jar warnings documented (if any)
- [ ] CFR run on same JAR versions
- [ ] All commands logged with exact parameters
- [ ] Output sizes recorded for comparison
