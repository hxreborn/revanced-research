# revanced-research Scripts

Collection of utility scripts for managing reverse engineering targets.

## Scripts Overview

### 🚀 Target Management

#### `setup-target.sh`
Creates new target targets for reverse engineering.

```bash
./scripts/setup-target.sh <package> <version>
./scripts/setup-target.sh com.zhiliaoapp.musically 36.5.4
```

**Features:**
- Creates complete directory structure
- Copies documentation templates
- Generates placeholder files
- Validates inputs and handles existing targets

### 🛠️ Environment Validation

#### `check-tools.sh`
Validates that all required reverse engineering tools are installed and properly configured.

```bash
./scripts/check-tools.sh
```

**Checks:**
- Java 17+ compatibility
- apktool, jadx, dex2jar availability
- Android Platform Tools (adb, etc.)
- Search tools (rg, fd, jq)
- System resources (memory, disk, CPU)
- Existing target targets

### 🧹 Maintenance

#### `cleanup.sh`
Safely removes temporary files and regenerated outputs while preserving research data.

```bash
./scripts/cleanup.sh [OPTIONS]
./scripts/cleanup.sh -n                    # Dry run
./scripts/cleanup.sh -a                    # Clean all targets
./scripts/cleanup.sh -f                    # Force skip confirmation
```

**Safe deletions:**
- `decode/apktool/` - Can be regenerated from APK
- `decode/jadx/` - Can be regenerated from APK
- `tmp/` - Scratch files
- Tool logs and crash dumps

**Preserved:**
- `apk/` - Original APK files
- `notes/` - Research documentation
- `artifacts/` - Screenshots and evidence
- `scripts/` - Custom analysis scripts

## 📚 Shared Library

All scripts source the shared library `lib/common.sh` which provides:

### Colors & Symbols
- Consistent color output (RED, GREEN, YELLOW, BLUE, etc.)
- Unicode symbols (✅ ❌ ⚠️ ℹ️ 📁 📄)

### Common Functions
- `print_status()`, `print_success()`, `print_warning()`, `print_error()`
- `print_header()`, `print_divider()`
- `command_exists()`, `get_version()`
- `calculate_size()`, `format_bytes()`
- `confirm_action()`, `validate_directory()`
- `validate_repo_root()`, `validate_package()`, `validate_version()`

### Target Target Functions
- `is_target_target()` - Check if directory is a valid target
- `find_target_targets()` - Find all target targets
- `check_decode_outputs()` - Check if decompilation outputs exist

### System Utilities
- `get_available_memory()`, `get_cpu_cores()`, `get_disk_space()`
- `check_java_version()` - Comprehensive Java version checking
- `copy_with_progress()`, `safe_remove()`

### Error Handling
- Automatic error handling setup
- Debug logging capabilities
- Cleanup on exit functions

## 🔧 Usage Tips

### Environment Variables
- `DEBUG=true` - Enable debug output in scripts
- `FORCE=true` - Skip confirmation prompts (use with caution)

### Common Workflows

1. **Setup new research target:**
   ```bash
   ./scripts/check-tools.sh          # Validate environment
   ./scripts/setup-target.sh com.example.app 1.0.0  # Create target
   ```

2. **Clean up after research:**
   ```bash
   ./scripts/cleanup.sh -n           # Preview what will be deleted
   ./scripts/cleanup.sh              # Actually clean up
   ```

3. **Batch operations:**
   ```bash
   # Clean all targets
   ./scripts/cleanup.sh -a -f

   # Check all targets
   find targets -type d -name "apk" | while read apk_dir; do
       target=$(dirname "$apk_dir")
       echo "Checking: $target"
       check_decode_outputs "$target"
   done
   ```

## 🐛 Debugging

Enable debug mode to see detailed script execution:

```bash
DEBUG=true ./scripts/setup-target.sh com.example.app 1.0.0
```

## 🤝 Contributing

When adding new scripts:

1. **Source the common library:**
   ```bash
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "$SCRIPT_DIR/lib/common.sh"
   ```

2. **Use consistent function naming:**
   - Use descriptive names (`check_java`, `create_target`)
   - Group related functionality

3. **Handle errors gracefully:**
   - Use common error handling functions
   - Provide clear error messages
   - Set appropriate exit codes

4. **Add help documentation:**
   - Include usage examples
   - Document all options
   - Follow existing format

## 📋 Dependencies

All scripts require:
- Bash 4.0+
- Standard Unix utilities (find, grep, awk, etc.)
- The shared library `lib/common.sh`

Optional dependencies (checked by scripts):
- Java 17+
- apktool, jadx, dex2jar
- Android Platform Tools
- ripgrep, fd, jq
- Python 3+, Frida

---

**Note**: These scripts are designed to be run from the revanced-research root directory. They automatically validate the environment and provide helpful error messages if requirements aren't met.