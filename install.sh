#!/bin/bash

# ==============================================================================
# TLP Configuration Installation Script
# ThinkPad E14 Gen 6 - Intel Core Ultra 5 125U
# ==============================================================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check root
if [ "$EUID" -ne 0 ]; then 
    print_error "This script must be run as root (with sudo)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_info "=========================================="
print_info "TLP Configuration Installation"
print_info "ThinkPad E14 Gen 6 - Core Ultra 5 125U"
print_info "=========================================="
echo ""

# Check TLP installed
print_info "Checking TLP installation..."
if ! command -v tlp &> /dev/null; then
    print_error "TLP is not installed"
    echo ""
    echo "Please install TLP first:"
    echo "  Arch Linux: sudo pacman -S tlp"
    echo "  Debian/Ubuntu: sudo apt install tlp"
    echo "  Fedora: sudo dnf install tlp"
    exit 1
fi
print_success "TLP installed correctly"
echo ""

# Create backup
print_info "Creating backup of current configuration..."
BACKUP_DIR="$HOME/tlp-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f /etc/tlp.conf ]; then
    cp /etc/tlp.conf "$BACKUP_DIR/"
    print_success "Backup of /etc/tlp.conf created"
fi

if [ -d /etc/tlp.d ] && [ "$(ls -A /etc/tlp.d)" ]; then
    cp -r /etc/tlp.d "$BACKUP_DIR/"
    print_success "Backup of /etc/tlp.d/ created"
fi

print_success "Backup saved in: $BACKUP_DIR"
echo ""

# Check for conflicting services
print_info "Checking for conflicting services..."
CONFLICTS_FOUND=false

if systemctl is-active --quiet power-profiles-daemon; then
    print_warning "power-profiles-daemon is active (may conflict with TLP)"
    CONFLICTS_FOUND=true
fi

if [ "$CONFLICTS_FOUND" = true ]; then
    echo ""
    read -p "Do you want to disable power-profiles-daemon? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        systemctl stop power-profiles-daemon
        systemctl mask power-profiles-daemon
        print_success "power-profiles-daemon disabled"
    else
        print_warning "WARNING: There may be conflicts with power-profiles-daemon"
    fi
else
    print_success "No conflicting services active"
fi
echo ""

# Create tlp.d directory if doesn't exist
print_info "Preparing /etc/tlp.d/ directory..."
mkdir -p /etc/tlp.d
print_success "Directory ready"
echo ""

# Install configuration files
print_info "Installing configuration files..."

if [ -d "$SCRIPT_DIR/tlp.d" ]; then
    cp "$SCRIPT_DIR/tlp.d"/*.conf /etc/tlp.d/
    chmod 644 /etc/tlp.d/*.conf
    print_success "Configuration files installed"
else
    print_error "tlp.d/ directory not found"
    print_error "Make sure to run this script from the repository directory"
    exit 1
fi
echo ""

# Check thinkpad_acpi module
print_info "Checking thinkpad_acpi module..."
if lsmod | grep -q thinkpad_acpi; then
    print_success "thinkpad_acpi module loaded"
else
    print_warning "thinkpad_acpi module is not loaded"
    echo ""
    read -p "Do you want to load the thinkpad_acpi module? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        modprobe thinkpad_acpi
        echo "thinkpad_acpi" > /etc/modules-load.d/thinkpad.conf
        print_success "Module loaded and configured to load on boot"
    fi
fi
echo ""

# Enable and start TLP
print_info "Enabling and applying TLP..."
systemctl enable tlp.service
systemctl start tlp.service
tlp start

print_success "TLP enabled and configuration applied"
echo ""

# Show status
print_info "=========================================="
print_info "INSTALLATION COMPLETED"
print_info "=========================================="
echo ""

print_success "Configuration installed successfully"
print_info "Backup saved in: $BACKUP_DIR"
echo ""

print_info "Current system status:"
echo ""
tlp-stat -s | grep -E "(System|TLP status|Power profile|Power source)"
echo ""

# Verification instructions
print_info "VERIFICATION:"
echo ""
echo "1. Check CPU configuration:"
echo "   sudo tlp-stat -p | grep -E '(energy_performance|max_perf|no_turbo|hwp_dynamic)'"
echo ""
echo "2. Check battery status:"
echo "   sudo tlp-stat -b | grep threshold"
echo ""
echo "3. Test automatic switching:"
echo "   - Unplug charger and run: sudo tlp-stat -s"
echo "   - Should show: Power profile = low-power/BAT"
echo ""
echo "4. Activate ultra power-saver (manual):"
echo "   sudo tlp power-saver"
echo ""
echo "5. Force full charge (bypass thresholds):"
echo "   sudo tlp fullcharge BAT0"
echo ""

print_success "Enjoy your optimized ThinkPad!"
echo ""
print_info "Complete documentation in: docs/"
print_info "Command cheatsheet: docs/CHEATSHEET.md"
