# TLP Command Cheatsheet - ThinkPad E14 Gen 6

Quick reference for TLP commands and common operations.

---

## 🎯 Basic Commands

### TLP Control
```bash
# Start TLP and apply configuration
sudo tlp start

# Check general status
sudo tlp-stat -s

# View complete statistics (very verbose)
sudo tlp-stat

# View only active configuration
sudo tlp-stat -c
```

---

## 🔄 Manual Mode Switching

### Available Modes
```bash
# Performance mode (AC) - force even on battery
sudo tlp performance

# Balanced mode (BAT) - force even on AC  
sudo tlp balanced

# Power-Saver mode (SAV) - ultra power saving
sudo tlp power-saver

# Return to automatic mode (AC/BAT based on power source)
sudo tlp start
```

> **Note:** Automatic mode switches between AC/BAT when you plug/unplug the charger

---

## 🔋 Battery Management

### View Battery Status
```bash
# View everything about battery
sudo tlp-stat -b

# View only charge thresholds
sudo tlp-stat -b | grep threshold

# View capacity and battery health
sudo tlp-stat -b | grep -E "(design|full|remaining)"
```

### Force Full Charge (Temporary Threshold Bypass)
```bash
# Charge to 100% once (temporarily ignores thresholds)
sudo tlp fullcharge BAT0

# After reaching 100%, thresholds automatically restore
```

### Manually Reset Thresholds
```bash
# Apply configured thresholds immediately
sudo tlp setcharge
```

---

## 💻 CPU Monitoring

### Processor Statistics
```bash
# View complete CPU configuration
sudo tlp-stat -p

# View only key parameters
sudo tlp-stat -p | grep -E "(energy_performance|max_perf|no_turbo|hwp_dynamic|platform_profile)"

# View current frequencies for each core
sudo tlp-stat -p | grep "scaling_cur_freq"

# View temperatures
sudo tlp-stat -t
```

### Verify Specific Parameters
```bash
# Energy Performance Preference (EPP)
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference

# Turbo boost (0=ON, 1=OFF)
cat /sys/devices/system/cpu/intel_pstate/no_turbo

# Dynamic boost (0=OFF, 1=ON)
cat /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost

# Platform profile
cat /sys/firmware/acpi/platform_profile

# NMI Watchdog (0=OFF, 1=ON)
cat /proc/sys/kernel/nmi_watchdog
```

---

## 🎮 Intel GPU

### GPU Statistics
```bash
# View Intel GPU configuration
sudo tlp-stat -g

# View current GPU frequencies
cat /sys/class/drm/card*/gt_cur_freq_mhz

# Real-time monitoring (requires intel-gpu-tools)
sudo intel_gpu_top
```

---

## 💾 Disks and Storage

### Disk Statistics
```bash
# View disk and controller configuration
sudo tlp-stat -d

# View only disk Runtime PM
sudo tlp-stat -d | grep -i "runtime"

# View NVMe status
sudo tlp-stat -d | grep -i nvme
```

---

## 🌐 Network Devices

### WiFi
```bash
# View WiFi power saving status
sudo tlp-stat -w

# View WiFi adapter
iwconfig
```

### USB
```bash
# View USB autosuspend status
sudo tlp-stat -u

# List USB devices
lsusb

# View devices excluded from autosuspend
sudo tlp-stat -u | grep "Exclude"
```

---

## 🔧 Troubleshooting

### Check for Errors
```bash
# View TLP warnings
sudo tlp-stat -w

# View system messages about TLP
journalctl -u tlp.service -b

# View last 50 log lines
journalctl -u tlp.service -n 50
```

### Conflicts with Other Services
```bash
# Check if power-profiles-daemon is active (conflict)
systemctl status power-profiles-daemon

# Disable power-profiles-daemon if active
sudo systemctl stop power-profiles-daemon
sudo systemctl mask power-profiles-daemon
```

### Reload Configuration
```bash
# After editing files in /etc/tlp.d/
sudo tlp start

# To see active configuration
sudo tlp-stat -c
```

---

## 📊 Power Consumption Monitoring

### Complementary Tools
```bash
# Powertop - real-time power consumption monitoring
sudo powertop

# s-tui - visual interface for CPU
s-tui

# Check CPU package consumption
sudo tlp-stat -t | grep "Package"
```

---

## 📝 Configuration

### File Locations
```bash
# Main file (use only as reference)
/etc/tlp.conf

# Drop-in files (YOUR customizations go HERE)
/etc/tlp.d/10-ac-performance.conf
/etc/tlp.d/20-battery-saver.conf
/etc/tlp.d/30-ultra-powersave.conf
/etc/tlp.d/40-battery-care.conf

# Edit configuration
sudo nano /etc/tlp.d/20-battery-saver.conf

# After editing, apply changes
sudo tlp start
```

---

## 🎯 Common Use Cases

### Scenario: I need to charge to 100% once
```bash
# Force full charge (temporarily ignores thresholds)
sudo tlp fullcharge BAT0

# Thresholds automatically restore after reaching 100%
```

### Scenario: I'll be disconnected for a long time
```bash
# Activate ultra power-saver mode
sudo tlp power-saver

# Check it's active
sudo tlp-stat -s

# When returning to normal use
sudo tlp start
```

### Scenario: I need maximum performance now
```bash
# Force performance mode (even on battery)
sudo tlp performance

# Verify
sudo tlp-stat -p | grep "energy_performance"

# Return to automatic
sudo tlp start
```

### Scenario: Want to see if TLP is saving power
```bash
# Compare consumption before/after
sudo powertop  # view total watts

# See if CPU is at low frequencies
sudo tlp-stat -p | grep "scaling_cur_freq"

# See if turbo is disabled (on battery should be 1)
cat /sys/devices/system/cpu/intel_pstate/no_turbo
```

---

## 🔍 Quick Reference

### Quick System Check One-liner
```bash
# One-liner to view complete status
sudo tlp-stat -s && echo "---" && sudo tlp-stat -p | grep -E "(energy_performance|max_perf|no_turbo|hwp_dynamic|platform_profile)"
```

### Useful Aliases (add to ~/.bashrc or ~/.zshrc)
```bash
# Aliases for common commands
alias tlp-status='sudo tlp-stat -s'
alias tlp-cpu='sudo tlp-stat -p'
alias tlp-bat='sudo tlp-stat -b'
alias tlp-full='sudo tlp fullcharge BAT0'
alias tlp-save='sudo tlp power-saver && echo "Ultra power-saver activated"'
alias tlp-normal='sudo tlp start && echo "Automatic mode activated"'
alias tlp-perf='sudo tlp performance && echo "Performance mode activated"'
```

---

## 📚 Resources

- **Official documentation:** https://linrunner.de/tlp
- **Configuration on GitHub:** https://github.com/Fennek115/tlp-thinkpad-e14-gen6
- **TLP FAQ:** https://linrunner.de/tlp/faq

---

## ⚙️ Current Configuration

### Battery Thresholds
- **Start charge:** 75%
- **Stop charge:** 80%
- **Bypass command:** `sudo tlp fullcharge BAT0`

### Configured Modes
- **AC:** balance_performance, 100% performance, turbo ON
- **BAT:** power, 80% performance, turbo OFF  
- **SAV:** power, 50% performance, turbo OFF (manual)

### Expected Consumption
- **AC idle:** ~10-13W
- **BAT idle:** ~5-7W
- **SAV idle:** ~4-6W

---

*Last updated: 2026-02-16*  
*Hardware: ThinkPad E14 Gen 6 - Intel Core Ultra 5 125U*
