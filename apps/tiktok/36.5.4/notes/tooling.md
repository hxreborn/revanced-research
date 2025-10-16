# Tooling & Environment

## Inputs
- APK: `apk/<file>.apk`
- Hash: `sha256sum apk/<file>.apk`

## Tool Versions
| Tool   | Version | Flags |
|--------|---------|-------|
| apktool |         | `-JXmx4g d` |
| jadx    |         | `--threads-count 4 --deobf` |
| frida   |         | |

## Commands Used
```
# Example
apktool -JXmx4g d apk/<file>.apk -o decode/apktool -f
jadx --threads-count 4 -d decode/jadx apk/<file>.apk
```

## Notes
- Store any troubleshooting tips here.
