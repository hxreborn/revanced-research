#!/bin/bash

# check-tools.sh - Tool validation for revanced-research environment
# Validates availability and versions of required reverse engineering tools

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Counters for summary
TOTAL_TOOLS=0
PASSED_TOOLS=0
FAILED_TOOLS=0
WARNED_TOOLS=0

check_java() {
    ((TOTAL_TOOLS++))
    print_header "Java Environment"

    local java_info
    java_info=$(check_java_version)

    if [[ $? -eq 0 ]]; then
        print_success "Java $java_info (✓ ReVanced compatible)"
    else
        print_warning "Java $java_info (⚠ ReVanced requires Java 17+)"
        print_status "Consider upgrading: https://openjdk.org/"
        ((WARNED_TOOLS++))
        return 1
    fi

    # Check JAVA_HOME
    if [[ -n "${JAVA_HOME:-}" ]]; then
        print_success "JAVA_HOME set: $JAVA_HOME"
    else
        print_warning "JAVA_HOME not set (may cause issues with some tools)"
    fi

    # Check available memory
    local max_memory
    max_memory=$(java -XX:+PrintFlagsFinal -version 2>&1 | grep MaxHeapSize | awk '{print $4}' | head -1)
    if [[ -n "$max_memory" && "$max_memory" -gt 2147483648 ]]; then
        print_success "Java max heap: $((max_memory / 1024 / 1024))MB (✓ Good for large APKs)"
    else
        print_warning "Java max heap may be insufficient for large APKs"
        print_status "Consider increasing with -Xmx4g or -Xmx6g"
    fi
}

check_apktool() {
    ((TOTAL_TOOLS++))
    print_header "apktool"

    if ! command_exists "apktool"; then
        print_error "apktool not found"
        print_status "Install: https://ibotpeaches.github.io/Apktool/install/"
        return 1
    fi

    local version
    version=$(get_version "apktool" "--version")
    print_success "apktool $version"

    # Check for common issues
    local framework_dir="$HOME/.local/share/apktool/framework"
    if [[ -d "$framework_dir" ]]; then
        local frameworks
        frameworks=$(ls "$framework_dir" 2>/dev/null | wc -l)
        print_success "Framework directory: $frameworks framework(s) installed"
    else
        print_warning "No apktool frameworks found (may need for some APKs)"
        print_status "Frameworks will be downloaded automatically when needed"
    fi
}

check_jadx() {
    ((TOTAL_TOOLS++))
    print_header "jadx"

    if ! command_exists "jadx"; then
        print_error "jadx not found"
        print_status "Install: https://github.com/skylot/jadx/releases"
        return 1
    fi

    local version
    version=$(get_version "jadx" "--version")
    print_success "jadx $version"

    # Check for GUI
    if command_exists "jadx-gui"; then
        print_success "jadx-gui available"
    else
        print_warning "jadx-gui not found (GUI optional but useful)"
    fi

    # Check available memory for jadx
    local available_memory
    available_memory=$(get_available_memory)
    if [[ "$available_memory" != "Unknown" && "$available_memory" -gt 4096 ]]; then
        print_success "Available memory: ${available_memory}MB (✓ Good for jadx)"
    else
        print_warning "Available memory: ${available_memory}MB (⚠ May need to reduce threads)"
        print_status "Consider using: jadx --threads-count 1"
    fi
}

check_dex2jar() {
    ((TOTAL_TOOLS++))
    print_header "dex2jar"

    if ! command_exists "d2j-dex2jar"; then
        print_warning "dex2jar not found (optional)"
        print_status "Install: https://github.com/pxb1988/dex2jar"
        print_status "Useful for: DEX to JAR conversion, alternative to jadx"
        return 1
    fi

    local version
    version=$(get_version "d2j-dex2jar" "--version")
    print_success "dex2jar $version"
}

check_android_tools() {
    ((TOTAL_TOOLS++))
    print_header "Android Platform Tools"

    # Check adb
    if ! command_exists "adb"; then
        print_error "adb not found"
        print_status "Install: Android SDK Platform Tools"
        print_status "Download: https://developer.android.com/studio/releases/platform-tools"
        return 1
    fi

    local adb_version
    adb_version=$(get_version "adb" "version")
    print_success "adb $adb_version"

    # Check for connected devices
    local device_count
    device_count=$(adb devices 2>/dev/null | grep -c "device$" || echo "0")
    if [[ "$device_count" -gt 0 ]]; then
        print_success "$device_count device(s) connected"
    else
        print_warning "No devices connected (normal for offline analysis)"
    fi

    # Check optional Android tools
    local optional_tools=("apksigner" "zipalign")
    for tool in "${optional_tools[@]}"; do
        if command_exists "$tool"; then
            print_success "$tool available"
        else
            print_warning "$tool not found (optional)"
        fi
    done
}

check_frida() {
    ((TOTAL_TOOLS++))
    print_header "Frida (Runtime Analysis)"

    local frida_available=false

    if command_exists "frida"; then
        local version
        version=$(get_version "frida" "--version")
        print_success "frida $version (client)"
        frida_available=true
    else
        print_warning "frida not found (runtime analysis tool)"
        print_status "Install: pip install frida-tools"
        print_status "Useful for: Runtime hooking, dynamic analysis"
    fi

    if command_exists "python3"; then
        local frida_module
        frida_module=$(python3 -c "import frida; print(frida.__version__)" 2>/dev/null || echo "Not installed")
        if [[ "$frida_module" != "Not installed" ]]; then
            print_success "frida Python module v$frida_module"
        else
            print_warning "frida Python module not installed"
            print_status "Install: pip install frida-tools"
        fi
    fi

    if [[ "$frida_available" == true ]]; then
        print_status "Frida server setup required on target device"
        print_status "Download: https://github.com/frida/frida/releases"
    fi
}

check_search_tools() {
    ((TOTAL_TOOLS++))
    print_header "Search & Analysis Tools"

    # Check ripgrep
    if command_exists "rg"; then
        local version
        version=$(get_version "rg" "--version" | head -1 | awk '{print $2}')
        print_success "ripgrep $version"
    else
        print_warning "ripgrep not found"
        print_status "Install: https://github.com/BurntSushi/ripgrep"
        print_status "Alternative: Use grep (slower)"
    fi

    # Check fd
    if command_exists "fd"; then
        local version
        version=$(get_version "fd" "--version" | head -1 | awk '{print $2}')
        print_success "fd $version"
    else
        print_warning "fd not found"
        print_status "Install: https://github.com/sharkdp/fd"
        print_status "Alternative: Use find (slower)"
    fi

    # Check jq for JSON parsing
    if command_exists "jq"; then
        local version
        version=$(get_version "jq" "--version" | cut -d'-' -f1)
        print_success "jq $version"
    else
        print_warning "jq not found (JSON parsing)"
        print_status "Install: https://stedolan.github.io/jq/download/"
        print_status "Useful for: Analyzing API responses, configuration files"
    fi
}

check_system_resources() {
    ((TOTAL_TOOLS++))
    print_header "System Resources"

    # Check available disk space
    local available_space
    available_space=$(get_disk_space)
    print_success "Available disk space: $available_space"

    # Check if we have at least 10GB free
    local space_kb
    space_kb=$(df . | tail -1 | awk '{print $4}')
    if [[ "$space_kb" -gt 10485760 ]]; then  # 10GB in KB
        print_success "Sufficient space for large APK decompilation"
    else
        print_warning "Low disk space may limit large APK analysis"
    fi

    # Check memory
    local total_memory
    local available_memory
    total_memory=$(free -h | awk 'NR==2{printf "%.1f", $2}')
    available_memory=$(get_available_memory)
    print_success "Memory: ${available_memory}MB available / ${total_memory}GB total"

    if [[ "${available_memory}" != "Unknown" && "${available_memory%.*}" -gt 6 ]]; then
        print_success "Good memory for parallel decompilation"
    else
        print_warning "Limited memory - consider reducing thread counts"
    fi

    # Check CPU cores
    local cpu_cores
    cpu_cores=$(get_cpu_cores)
    print_success "CPU cores: $cpu_cores (affects jadx --threads-count)"
}

check_targets_directory() {
    ((TOTAL_TOOLS++))
    print_header "Targets Directory"

    if [[ ! -d "targets" ]]; then
        print_error "targets directory not found"
        print_status "Create: mkdir -p targets"
        return 1
    fi

    print_success "targets directory exists"

    # Count existing targets
    local target_count
    target_count=$(find targets -maxdepth 2 -type d -name "apk" | wc -l)
    if [[ "$target_count" -gt 0 ]]; then
        print_success "Found $target_count target target(s)"

        # Show a few examples
        local examples
        examples=$(find targets -maxdepth 2 -type d -name "apk" | head -3 | sed 's|/apk||' | sed 's|targets/||')
        if [[ -n "$examples" ]]; then
            print_status "Examples:"
            echo "$examples" | while read -r example; do
                echo "  ${FOLDER} $example"
            done
        fi
    else
        print_status "No target targets found yet"
        print_status "Create one with: ./scripts/setup-target.sh <package> <version>"
    fi
}

provide_recommendations() {
    print_header "Recommendations"

    echo "${INFO} Based on your current setup:"
    echo ""

    # Check for critical missing tools
    local critical_missing=()

    if ! command_exists "java"; then
        critical_missing+=("Install Java 17+")
    fi

    if ! command_exists "apktool"; then
        critical_missing+=("Install apktool")
    fi

    if ! command_exists "jadx"; then
        critical_missing+=("Install jadx")
    fi

    if ! command_exists "adb"; then
        critical_missing+=("Install Android Platform Tools")
    fi

    if [[ ${#critical_missing[@]} -gt 0 ]]; then
        print_error "Critical missing tools:"
        for missing in "${critical_missing[@]}"; do
            echo "  ${CROSS_MARK} $missing"
        done
        echo ""
    fi

    # Optional but recommended
    echo "${INFO} Optional but recommended improvements:"
    if ! command_exists "rg"; then
        echo "  • Install ripgrep for faster code searching"
    fi
    if ! command_exists "frida"; then
        echo "  • Install Frida for runtime analysis"
    fi
    if ! command_exists "jq"; then
        echo "  • Install jq for JSON processing"
    fi

    echo ""
    echo "${INFO} Performance tips:"
    echo "  • Use apktool -JXmx4g for large APKs"
    local cpu_cores
    cpu_cores=$(get_cpu_cores)
    if [[ "$cpu_cores" -gt 4 ]]; then
        echo "  • Use jadx --threads-count 4"
    else
        echo "  • Use jadx --threads-count $cpu_cores"
    fi
    echo "  • Consider using SSD storage for better I/O performance"
    echo ""
    echo "${INFO} Workflow tips:"
    echo "  • Use ./scripts/setup-target.sh <package> <version> to create new targets"
    echo "  • Use ./scripts/cleanup.sh to clean temporary files safely"
}

print_summary() {
    print_header "Summary"
    echo "Total tools checked: $TOTAL_TOOLS"
    echo "${CHECK_MARK} Passed: $PASSED_TOOLS"
    echo "${WARNING} Warnings: $WARNED_TOOLS"
    echo "${CROSS_MARK} Failed: $FAILED_TOOLS"

    if [[ $FAILED_TOOLS -eq 0 ]]; then
        print_success "All critical tools are available!"
        echo "${INFO} Your environment is ready for reverse engineering."
    else
        print_error "$FAILED_TOOLS critical tool(s) missing"
        echo "${WARNING} Please install missing tools before proceeding."
    fi

    if [[ $WARNED_TOOLS -gt 0 ]]; then
        echo ""
        print_warning "$WARNED_TOOLS tool(s) have warnings"
        echo "${INFO} Consider addressing these for optimal performance."
    fi
}

main() {
    print_header "revanced-research Tool Validation"
    print_divider

    # Run all checks
    check_java || ((FAILED_TOOLS++))
    check_apktool || ((FAILED_TOOLS++))
    check_jadx || ((FAILED_TOOLS++))
    check_dex2jar || ((PASSED_TOOLS++))
    check_android_tools || ((FAILED_TOOLS++))
    check_frida || ((PASSED_TOOLS++))
    check_search_tools || ((PASSED_TOOLS++))
    check_system_resources || ((PASSED_TOOLS++))
    check_targets_directory || ((FAILED_TOOLS++))

    # Provide recommendations
    provide_recommendations

    # Print summary
    print_summary

    # Exit with appropriate code
    if [[ $FAILED_TOOLS -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main "$@"