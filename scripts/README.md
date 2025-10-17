# Scripts

Utility scripts for managing reverse engineering targets.

## check-tools.sh

Validates that all required reverse engineering tools are installed and properly configured.

```bash
./scripts/check-tools.sh
```

Checks: Java 17+, apktool, jadx, dex2jar, adb, rg, fd, disk/memory, CPU cores.

## cleanup.sh

Safely removes temporary files and regenerated outputs while preserving research data.

```bash
./scripts/cleanup.sh [OPTIONS]
./scripts/cleanup.sh -n                    # Dry run
./scripts/cleanup.sh -a                    # Clean all targets
./scripts/cleanup.sh -f                    # Force skip confirmation
```

Removes: `decode/`, `tmp/`, logs. Preserves: `apk/`, `notes/`, `artifacts/`.

## Shared Library

Scripts source `lib/common.sh` for validation, formatting, and error handling.

## Environment Variables

- `DEBUG=true` — Enable debug output
- `FORCE=true` — Skip confirmation prompts

## Dependencies

- Bash 4.0+
- Java 17+, apktool 2.12.x, jadx 1.5+, dex2jar 2.4+
- Android Platform Tools (adb)
- ripgrep (rg), fd, jq