#!/bin/bash

# setup-target.sh - Automated target initialization for revanced-research
# Usage: ./scripts/setup-target.sh <package> <version>
# Example: ./scripts/setup-target.sh com.zhiliaoapp.musically 36.5.4

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Default values
FORCE=false

show_usage() {
    echo "Usage: $0 [OPTIONS] <package> <version>"
    echo ""
    echo "Create a new target target for reverse engineering."
    echo ""
    echo "ARGUMENTS:"
    echo "  package    Package name (e.g., com.zhiliaoapp.musically)"
    echo "  version    Version string (e.g., 36.5.4)"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help    Show this help message"
    echo "  -f, --force   Skip confirmation prompts"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 com.zhiliaoapp.musically 36.5.4"
    echo "  $0 com.google.android.youtube 19.15.34"
    echo "  $0 com.twitter.android 10.15.0 --force"
    exit 1
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                ;;
            *)
                if [[ -z "${PACKAGE:-}" ]]; then
                    PACKAGE="$1"
                elif [[ -z "${VERSION:-}" ]]; then
                    VERSION="$1"
                else
                    print_error "Too many arguments"
                    show_usage
                fi
                shift
                ;;
        esac
    done
}

validate_inputs() {
    if [[ -z "${PACKAGE:-}" || -z "${VERSION:-}" ]]; then
        print_error "Both PACKAGE and VERSION are required"
        show_usage
    fi

    validate_package "$PACKAGE" || show_usage
    validate_version "$VERSION" || show_usage
}

create_directory_structure() {
    local target_dir="targets/$PACKAGE/$VERSION"

    print_header "Creating Directory Structure"
    print_status "Package: $PACKAGE"
    print_status "Version: $VERSION"
    print_status "Target: $target_dir"

    # Create the full directory structure
    local dirs=(
        "$target_dir/apk"
        "$target_dir/decode/apktool"
        "$target_dir/decode/jadx"
        "$target_dir/notes"
        "$target_dir/artifacts"
        "$target_dir/scripts/frida"
        "$target_dir/scripts/helpers"
        "$target_dir/scripts/validation"
        "$target_dir/tmp"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        debug_log "Created directory: $dir"
    done

    print_success "Directory structure created"
}

copy_templates() {
    local target_dir="targets/$PACKAGE/$VERSION"
    local notes_dir="$target_dir/notes"

    print_header "Copying Templates"

    if [[ ! -d "templates" ]]; then
        print_error "Templates directory not found"
        return 1
    fi

    # Copy all markdown templates
    local template_files
    mapfile -t template_files < <(find templates -name "*.md" -type f 2>/dev/null)

    if [[ ${#template_files[@]} -eq 0 ]]; then
        print_warning "No template files found in templates/"
        return 0
    fi

    for template in "${template_files[@]}"; do
        if cp "$template" "$notes_dir/" 2>/dev/null; then
            debug_log "Copied: $(basename "$template")"
        else
            print_error "Failed to copy: $(basename "$template")"
            return 1
        fi
    done

    # Copy target index template to main target directory
    if [[ -f "templates/target-index.md" ]]; then
        if cp "templates/target-index.md" "$target_dir/index.md" 2>/dev/null; then
            debug_log "Copied target index template"
        else
            print_error "Failed to copy target index template"
            return 1
        fi
    fi

    print_success "Templates copied to $notes_dir"
}

create_placeholders() {
    local target_dir="targets/$PACKAGE/$VERSION"

    print_header "Creating Placeholder Files"

    # Create README for the target
    local readme_content
    readme_content=$(cat << EOF
# $PACKAGE v$VERSION Research Target

Research target for $PACKAGE version $VERSION.

## Quick Start

1. Drop the APK in \`apk/\` directory
2. Update \`notes/tooling.md\` with APK hash and tool versions
3. Run decompilation:
   \`\`\`bash
   apktool -JXmx4g d apk/<apk-file>.apk -o decode/apktool -f
   jadx --threads-count 4 -d decode/jadx apk/<apk-file>.apk
   \`\`\`
4. Document findings in \`notes/journal.md\`

## Directory Structure

- \`apk/\` - Pristine APK files
- \`decode/\` - Decompiled outputs (apktool, jadx)
- \`notes/\` - Research documentation and templates
- \`artifacts/\` - Screenshots, logs, and evidence
- \`scripts/\` - Custom analysis scripts
- \`tmp/\` - Temporary scratch files

## Documentation

See \`notes/\` directory for detailed documentation templates.

---
*Target created on $(date)*
EOF
)

    echo "$readme_content" > "$target_dir/README.md"
    debug_log "Created README.md"

    # Create .gitkeep for directories that should exist but be empty
    touch "$target_dir/tmp/.gitkeep"
    touch "$target_dir/artifacts/.gitkeep"
    debug_log "Created .gitkeep files"

    # Create example analysis script
    local example_script
    example_script=$(cat << 'EOF'
#!/bin/bash

# Example analysis script for this target
# Customize based on your research needs

set -euo pipefail

# Source common library if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../lib/common.sh" ]]; then
    source "$SCRIPT_DIR/../lib/common.sh"
fi

PACKAGE="example"
VERSION="example"

echo "Running analysis for $PACKAGE v$VERSION..."

# Example: Search for specific strings
if command_exists "rg"; then
    rg "share_link" decode/apktool/smali*/ -n || echo "No matches found"
else
    echo "ripgrep not found, install with: apt install ripgrep"
fi

# Example: Find all activities
if command_exists "rg"; then
    rg "\.class.*Activity;" decode/apktool/smali*/ --only-matching
fi

echo "Analysis complete."
EOF
)

    echo "$example_script" > "$target_dir/scripts/example-analysis.sh"
    chmod +x "$target_dir/scripts/example-analysis.sh"
    debug_log "Created example analysis script"

    print_success "Placeholder files created"
}

create_summary() {
    local target_dir="targets/$PACKAGE/$VERSION"

    print_header "Target Summary"

    echo "${CHECK_MARK} Package: $PACKAGE"
    echo "${CHECK_MARK} Version: $VERSION"
    echo "${CHECK_MARK} Target: $target_dir"
    echo ""
    echo "${INFO} Next Steps:"
    echo "1. Copy APK to $target_dir/apk/"
    echo "2. Update $target_dir/notes/tooling.md with APK details"
    echo "3. Run decompilation commands:"
    echo "   apktool -JXmx4g d apk/<file>.apk -o decode/apktool -f"
    echo "   jadx --threads-count 4 -d decode/jadx apk/<file>.apk"
    echo "4. Start documenting findings in notes/journal.md"
    echo ""
    echo "${INFO} Quick commands:"
    echo "  cd $target_dir"
    echo "  # Copy APK"
    echo "  cp /path/to/apk.apk apk/"
    echo "  # Record hash"
    echo "  sha256sum apk/apk.apk"
}

check_existing_target() {
    local target_dir="targets/$PACKAGE/$VERSION"

    if [[ -d "$target_dir" && $(ls -A "$target_dir" 2>/dev/null) ]]; then
        print_warning "Target $PACKAGE/$VERSION already exists and is not empty"
        print_status "Contents:"
        ls -la "$target_dir" | head -10
        echo ""

        if [[ "$FORCE" != true ]]; then
            if ! confirm_action "Overwrite existing target?"; then
                print_status "Operation cancelled"
                exit 0
            fi
        fi

        print_status "Proceeding with target setup..."
    fi
}

main() {
    print_header "revanced-research Target Setup"
    print_divider

    parse_arguments "$@"
    validate_repo_root || exit 1
    validate_inputs
    check_existing_target

    print_status "Setting up target for $PACKAGE v$VERSION..."

    create_directory_structure
    copy_templates
    create_placeholders

    print_success "Target setup complete!"
    print_divider

    create_summary
}

export FORCE="$FORCE"
main "$@"