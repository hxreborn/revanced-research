# Automation Scripts

Scripts for automating common RE tasks.

## Usage

Copy scripts into your target workspace:

```bash
cp -r docs/templates/scripts/* apps/<app>/<version>/scripts/
cd apps/<app>/<version>/scripts/
```

## Scripts

### decompile-pipeline.sh

Automated end-to-end decompilation with metrics.

```bash
./decompile-pipeline.sh myapp 1.0.0 ~/myapp.apk
```

Environment variables:
- `APKTOOL_HEAP` - Heap for apktool (default: 4g)
- `JADX_THREADS` - Thread count (default: 4)
- `JADX_HEAP` - Heap for jadx (default: 6g)

### detect-obfuscation.py

Analyze and characterize obfuscation.

```bash
python3 detect-obfuscation.py ../decode/apktool/
```

Output: `artifacts/obfuscation-report.json`

### enumerate-entry-points.py

Extract Android entry points (activities, services, receivers, providers).

```bash
python3 enumerate-entry-points.py ../decode/apktool/
```

Output: `artifacts/entry-points.json`

## Tips

- Run `decompile-pipeline.sh` first to generate decode outputs
- Then run analysis scripts on the decode outputs
- Python scripts have no external dependencies
- All output saved to `artifacts/` directory

## Troubleshooting

**apktool OOM**: Increase heap with `APKTOOL_HEAP=8g`

**jadx hangs**: Disable deobfuscation with `ENABLE_DEOBF=false`

**Permission denied**: Make scripts executable: `chmod +x *.sh`
