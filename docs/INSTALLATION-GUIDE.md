# Installation Guide - TLP Configuration for ThinkPad E14 Gen 6

Step-by-step guide to install and configure TLP for optimal power management.

---

## 📋 Prerequisites

### Required Hardware
- ✅ Lenovo ThinkPad E14 Gen 6 (Intel)
- ✅ Intel Core Ultra 5 125U (or similar Core Ultra Series 1)

### Required Software
```bash
# Arch Linux / Manjaro
sudo pacman -S tlp

# Debian / Ubuntu
sudo apt install tlp

# Fedora
sudo dnf install tlp

# Optional but recommended
sudo pacman -S powertop intel-gpu-tools  # Arch
```

---

## 🚀 Quick Installation

### Method 1: Automated Installation (Recommended)

```bash
# 1. Clone repository
git clone https://github.com/Fennek115/tlp-thinkpad-e14-gen6.git
cd tlp-thinkpad-e14-gen6

# 2. Create backup of existing configuration
sudo cp /etc/tlp.conf /etc/tlp.conf.backup
sudo mkdir -p ~/tlp-backup-$(date +%Y%m%d)
sudo cp -r /etc/tlp.d ~/tlp-backup-$(date +%Y%m%d)/ 2>/dev/null || true

# 3. Run installation script
sudo ./install.sh

# 4. Verify installation
sudo tlp-stat -s
```

### Method 2: Manual Installation

```bash
# 1. Download .conf files from GitHub

# 2. Create configuration directory if it doesn't exist
sudo mkdir -p /etc/tlp.d

# 3. Copy each file manually
sudo cp 10-ac-performance.conf /etc/tlp.d/
sudo cp 20-battery-saver.conf /etc/tlp.d/
sudo cp 30-ultra-powersave.conf /etc/tlp.d/
sudo cp 40-battery-care.conf /etc/tlp.d/

# 4. Apply configuration
sudo tlp start
```

---

## ✅ Post-Installation Verification

### 1. Verify TLP is Active

```bash
sudo tlp-stat -s
```

Expected output:
```
tlp = enabled, last run: ...
Power profile = balanced/AC (or low-power/BAT)
Power source = AC (or battery)
```

### 2. Verify CPU Configuration

```bash
sudo tlp-stat -p | grep -E "(energy_performance|max_perf|no_turbo|hwp_dynamic)"
```

**On AC you should see:**
```
energy_performance_preference = balance_performance [EPP]
max_perf_pct = 100 [%]
no_turbo = 0
hwp_dynamic_boost = 1
```

**On Battery you should see:**
```
energy_performance_preference = power [EPP]
max_perf_pct = 80 [%]
no_turbo = 1
hwp_dynamic_boost = 0
```

### 3. Verify NMI Watchdog

```bash
cat /proc/sys/kernel/nmi_watchdog
```

Should show: `0`

### 4. Verify Battery Thresholds

```bash
sudo tlp-stat -b | grep threshold
```

Expected output:
```
charge_control_start_threshold = 75 [%]
charge_control_end_threshold = 80 [%]
```

---

## 🔧 Additional Configuration

### Disable Conflicting Services

TLP may conflict with other power management services:

```bash
# Check if they're active
systemctl status power-profiles-daemon
systemctl status laptop-mode-tools

# If active, disable them
sudo systemctl stop power-profiles-daemon
sudo systemctl mask power-profiles-daemon
```

### Load ThinkPad ACPI Module

For battery thresholds to work:

```bash
# Check if loaded
lsmod | grep thinkpad_acpi

# If not loaded
sudo modprobe thinkpad_acpi

# To load automatically on boot
echo "thinkpad_acpi" | sudo tee /etc/modules-load.d/thinkpad.conf
```

---

## 🎯 First Use

### Test Automatic Mode Switching

1. **With charger connected:**
   ```bash
   sudo tlp-stat -p | grep energy_performance
   # Should show: balance_performance
   ```

2. **Disconnect charger:**
   ```bash
   # Wait 2-3 seconds
   sudo tlp-stat -p | grep energy_performance
   # Should show: power
   ```

3. **Reconnect charger:**
   ```bash
   # Wait 2-3 seconds
   sudo tlp-stat -p | grep energy_performance
   # Should show: balance_performance
   ```

If this works, everything is perfect! ✅

### Test Ultra Power-Saver Mode

```bash
# Activate power-saver mode
sudo tlp power-saver

# Verify
sudo tlp-stat -p | grep max_perf
# Should show: max_perf_pct = 50 [%]

# Return to automatic mode
sudo tlp start
```

### Test Battery Threshold Bypass

```bash
# Force full charge to 100% (temporarily ignores thresholds)
sudo tlp fullcharge BAT0

# Check it's charging
sudo tlp-stat -b | grep "State"
# Should show: Charging

# After reaching 100%, thresholds automatically restore
```

---

## 🐛 Troubleshooting

### Problem: TLP won't start or shows errors

**Solution 1:** Check conflicts
```bash
systemctl status power-profiles-daemon
sudo systemctl mask power-profiles-daemon
```

**Solution 2:** Review logs
```bash
journalctl -u tlp.service -b
```

**Solution 3:** Verify file syntax
```bash
sudo tlp-stat -c
```

---

### Problem: Battery thresholds don't work

**Solution:**
```bash
# Verify module is loaded
lsmod | grep thinkpad_acpi

# If not, load it
sudo modprobe thinkpad_acpi

# Check support
sudo tlp-stat -b | grep "supported"
```

---

### Problem: High power consumption

**Diagnosis:**
```bash
# See what's consuming power
sudo powertop

# Verify active configuration
sudo tlp-stat -c

# View CPU
sudo tlp-stat -p | head -20
```

**Possible causes:**
1. Background applications
2. Screen brightness too high
3. Configuration not applied correctly

---

## 📊 Monitoring

### Recommended Tools

```bash
# Powertop - real-time power consumption
sudo powertop

# TLP Stats - TLP statistics
sudo tlp-stat -s  # general status
sudo tlp-stat -p  # CPU
sudo tlp-stat -b  # battery
sudo tlp-stat -d  # disks

# intel_gpu_top - monitor GPU
sudo intel_gpu_top

# htop/btop - processes
htop
```

---

## 🔄 Updates

If you update configuration from GitHub:

```bash
# Go to repo directory
cd tlp-thinkpad-e14-gen6

# Backup current configuration
sudo cp -r /etc/tlp.d ~/tlp-backup-$(date +%Y%m%d)

# Pull changes
git pull

# Copy new files
sudo cp tlp.d/*.conf /etc/tlp.d/

# Apply
sudo tlp start
```

---

## 🗑️ Uninstallation

To revert to original configuration:

```bash
# Restore from backup
sudo cp ~/tlp-backup-DATE/tlp.conf /etc/tlp.conf
sudo cp -r ~/tlp-backup-DATE/tlp.d /etc/

# Or delete custom files
sudo rm /etc/tlp.d/10-ac-performance.conf
sudo rm /etc/tlp.d/20-battery-saver.conf
sudo rm /etc/tlp.d/30-ultra-powersave.conf
sudo rm /etc/tlp.d/40-battery-care.conf

# Apply defaults
sudo tlp start
```

---

## ✅ Installation Checklist

- [ ] TLP installed
- [ ] Backup of original configuration created
- [ ] .conf files copied to `/etc/tlp.d/`
- [ ] power-profiles-daemon disabled
- [ ] TLP enabled and started
- [ ] Configuration applied
- [ ] Successful AC verification
- [ ] Successful BAT verification (disconnect charger)
- [ ] NMI watchdog = 0
- [ ] Battery thresholds configured
- [ ] Ultra power-saver mode tested
- [ ] Power consumption monitored with powertop

---

## 📞 Support

If you have problems:

1. Check [Troubleshooting](#-troubleshooting) section
2. Review [Command Cheatsheet](CHEATSHEET.md)
3. Consult [official TLP documentation](https://linrunner.de/tlp)
4. Open an issue on GitHub with:
   - Output of `sudo tlp-stat -s`
   - Output of `sudo tlp-stat -p`
   - Problem description

---

*Last updated: 2026-02-16*
