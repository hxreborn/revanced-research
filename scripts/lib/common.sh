#!/bin/bash

# common.sh - Shared library for revanced-research scripts
# Provides common functions, colors, and utilities

# Ensure this file is sourced, not executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This file should be sourced, not executed"
    exit 1
fi

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[1;37m'
export NC='\033[0m' # No Color

# Symbols
export CHECK_MARK='✅'
export CROSS_MARK='❌'
export WARNING='⚠️'
export INFO='ℹ️'
export FOLDER='📁'
export FILE='📄'

# ========================================
# Print Functions
# ========================================

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_divider() {
    echo -e "${BLUE}----------------------------------------${NC}"
}

# ========================================
# Utility Functions
# ========================================

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get version with fallback
get_version() {
    local cmd="$1"
    local version_flag="$2"
    local fallback="${3:-Unknown version}"

    if command_exists "$cmd"; then
        "$cmd" $version_flag 2>/dev/null || echo "$fallback"
    else
        echo "Not found"
    fi
}

# Calculate directory size
calculate_size() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        du -sh "$dir" 2>/dev/null | cut -f1 || echo "Unknown"
    else
        echo "0"
    fi
}

# Format bytes to human readable
format_bytes() {
    local bytes=$1
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$(( bytes / 1024 ))KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$(( bytes / 1048576 ))MB"
    else
        echo "$(( bytes / 1073741824 ))GB"
    fi
}

# Confirm action with user
confirm_action() {
    local message="${1:-Continue?}"
    local default="${2:-N}"

    if [[ "${FORCE:-false}" == true ]]; then
        return 0
    fi

    echo -e "${YELLOW}$message (y/N):${NC} " >&2
    read -r -n 1 response
    echo >&2

    if [[ $response =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_directory() {
    local dir="$1"
    local description="${2:-Directory}"

    if [[ ! -d "$dir" ]]; then
        print_error "$description not found: $dir"
        return 1
    fi
    return 0
}

validate_repo_root() {
    if [[ ! -d "templates" && ! -d "apps" && ! -f "AGENTS.md" ]]; then
        print_error "Must be run from revanced-research root directory"
        print_status "Expected: templates/, apps/, and AGENTS.md"
        return 1
    fi
    return 0
}

# ========================================
# Target Target Functions
# ========================================

is_target_target() {
    local dir="$1"
    [[ -d "$dir/apk" && -d "$dir/notes" && -d "$dir/decode" ]]
}

find_target_targets() {
    local search_dir="${1:-.}"
    find "$search_dir" -type d -name "apk" -printf '%h\n' | while read -r apk_dir; do
        local target_dir
        target_dir="$(dirname "$apk_dir")"
        if is_target_target "$target_dir"; then
            echo "$target_dir"
        fi
    done | sort
}

validate_package() {
    local package="$1"
    if [[ ! "$package" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        print_error "Package name contains invalid characters: $package"
        return 1
    fi
    return 0
}

validate_version() {
    local version="$1"
    if [[ ! "$version" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        print_error "Version contains invalid characters: $version"
        return 1
    fi
    return 0
}

# ========================================
# File Operation Functions
# ========================================

safe_remove() {
    local path="$1"
    local description="${2:-File/directory}"

    if [[ ! -e "$path" ]]; then
        return 0
    fi

    if confirm_action "Remove $description: $path?"; then
        if rm -rf "$path" 2>/dev/null; then
            print_success "Removed: $path"
            return 0
        else
            print_error "Failed to remove: $path"
            return 1
        fi
    else
        print_status "Cancelled removal of: $path"
        return 1
    fi
}

copy_with_progress() {
    local src="$1"
    local dest="$2"
    local description="${3:-Copying files}"

    print_status "$description..."

    if cp -r "$src" "$dest" 2>/dev/null; then
        print_success "Copied: $src → $dest"
        return 0
    else
        print_error "Failed to copy: $src → $dest"
        return 1
    fi
}

# ========================================
# System Resource Functions
# ========================================

get_available_memory() {
    if command_exists "free"; then
        free -m | awk 'NR==2{printf "%.0f", $7}'
    else
        echo "Unknown"
    fi
}

get_cpu_cores() {
    if command_exists "nproc"; then
        nproc
    elif [[ -f /proc/cpuinfo ]]; then
        grep -c "^processor" /proc/cpuinfo
    else
        echo "1"
    fi
}

get_disk_space() {
    local path="${1:-.}"
    if command_exists "df"; then
        df -h "$path" | tail -1 | awk '{print $4}'
    else
        echo "Unknown"
    fi
}

# ========================================
# Tool Detection Functions
# ========================================

check_java_version() {
    if ! command_exists "java"; then
        echo "Not found"
        return 1
    fi

    local version
    version=$(java -version 2>&1 | head -1 | cut -d'"' -f2)

    # Extract major version
    local major_version
    major_version=$(echo "$version" | sed -E 's/^1\.?([0-9]+).*/\1/')

    echo "$version (major: $major_version)"

    if [[ "$major_version" -ge 17 ]]; then
        return 0
    else
        return 1
    fi
}

check_decode_outputs() {
    local target="$1"
    local has_apktool=false
    local has_jadx=false

    if [[ -d "$target/decode/apktool" ]] && [[ "$(ls -A "$target/decode/apktool" 2>/dev/null)" ]]; then
        has_apktool=true
    fi

    if [[ -d "$target/decode/jadx" ]] && [[ "$(ls -A "$target/decode/jadx" 2>/dev/null)" ]]; then
        has_jadx=true
    fi

    echo "apktool: $has_apktool, jadx: $has_jadx"

    if [[ "$has_apktool" == true || "$has_jadx" == true ]]; then
        return 0
    else
        return 1
    fi
}

# ========================================
# Progress and Summary Functions
# ========================================

show_progress() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local desc="${4:-Progress}"

    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "\r%s: [" "$desc"
    printf "%*s" "$filled" | tr ' ' '█'
    printf "%*s" "$empty" | tr ' ' '░'
    printf "] %d%% (%d/%d)" "$percentage" "$current" "$total"

    if [[ $current -eq $total ]]; then
        echo
    fi
}

generate_table() {
    local headers=("$@")
    local separator=""

    # Build separator line
    for header in "${headers[@]}"; do
        separator+="-"
        separator+=$(printf "%*s" "${#header}" | tr ' ' '-')
        separator+=" "
    done

    # Print headers
    printf "%s\n" "${headers[*]}"
    printf "%s\n" "$separator"
}

# ========================================
# Error Handling
# ========================================

setup_error_handling() {
    set -euo pipefail

    # Trap errors and show context
    trap 'print_error "Script failed at line $LINENO: $BASH_COMMAND"' ERR
}

cleanup_on_exit() {
    local cleanup_function="$1"
    trap "$cleanup_function" EXIT
}

# ========================================
# Debug Functions
# ========================================

enable_debug() {
    if [[ "${DEBUG:-false}" == true ]]; then
        set -x
        print_status "Debug mode enabled"
    fi
}

debug_log() {
    if [[ "${DEBUG:-false}" == true ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1" >&2
    fi
}

# ========================================
# Initialization
# ========================================

init_common() {
    # Set up basic error handling
    setup_error_handling

    # Enable debug if requested
    enable_debug

    debug_log "Common library initialized"
}

# Auto-initialize when sourced
init_common