# Automation Scripts

Common RE task automation.

## Usage

```bash
cp docs/templates/scripts/* apps/<app>/<version>/scripts/
```

## Scripts

- **decompile-pipeline.sh** - End-to-end decompilation with metrics
- **detect-obfuscation.py** - Obfuscation pattern analysis  
- **enumerate-entry-points.py** - Android entry points extraction

## Environment

- `APKTOOL_HEAP` - apktool heap (default: 4g)
- `JADX_THREADS` - jadx threads (default: 4)  
- `JADX_HEAP` - jadx heap (default: 6g)

## Troubleshooting

- **apktool OOM**: `APKTOOL_HEAP=8g`
- **jadx hangs**: `ENABLE_DEOBF=false`
- **Permissions**: `chmod +x *.sh`
