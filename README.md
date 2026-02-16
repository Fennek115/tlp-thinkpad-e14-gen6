# TLP Configuration for ThinkPad E14 Gen 6 (Intel Core Ultra 5 125U)

Optimized TLP power management configuration for Lenovo ThinkPad E14 Gen 6 with Intel Core Ultra 5 125U processor.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TLP Version](https://img.shields.io/badge/TLP-1.9.1-blue.svg)](https://linrunner.de/tlp)
[![Arch Linux](https://img.shields.io/badge/Tested%20on-Arch%20Linux-1793D1.svg)](https://archlinux.org/)

## 📊 Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Idle power (AC) | ~15W | ~10-13W | ↓ 20-30% |
| Idle power (Battery) | ~15W | ~5-7W | ↓ 60-65% |
| Battery life (typical use) | 3-4 hours | 6-8 hours | +60-100% |
| CPU temperature (idle) | 56-62°C | 40-50°C | ↓ 15°C |

## ⚡ Features

- **Three power profiles:**
  - **AC Mode:** Balanced performance when plugged in
  - **Battery Mode:** Optimized efficiency for daily use
  - **Power-Saver Mode:** Maximum battery life (manual activation)

- **CPU Optimization:**
  - EPP (Energy Performance Preference) configuration
  - Turbo Boost control per mode
  - HWP Dynamic Boost for Intel Core Ultra series
  - Performance limits (100% AC, 80% BAT, 40% SAV)

- **Battery Care:**
  - Charge thresholds (75-80%) to extend battery lifespan
  - Expected 1.5x longer battery life
  - Temporary full charge override available

- **Hardware-Specific:**
  - Optimized for Intel Core Ultra 5 125U (Meteor Lake)
  - NVMe SSD Runtime Power Management
  - Intel Arc Graphics auto-management
  - ThinkPad ACPI integration

## 🖥️ Hardware Compatibility

**Primary Target:**
- Lenovo ThinkPad E14 Gen 6 (Intel)
- Intel Core Ultra 5 125U

**Should Work With:**
- ThinkPad E14/E16 Gen 6 (Intel variants)
- Other Lenovo laptops with Intel Core Ultra Series 1 (Meteor Lake)
- Intel CPUs with HWP support (Core i 6th gen or newer)

**Not Compatible With:**
- AMD CPUs (requires different configuration)
- Very old Intel CPUs without HWP (pre-6th gen)

## 📦 Installation

### Prerequisites

```bash
# Install TLP (Arch Linux)
sudo pacman -S tlp

# Other distributions
# Debian/Ubuntu: sudo apt install tlp
# Fedora: sudo dnf install tlp
```

### Quick Install

```bash
# Clone this repository
git clone https://github.com/Fennek115/tlp-thinkpad-e14-gen6.git
cd tlp-thinkpad-e14-gen6

# Backup existing configuration
sudo cp /etc/tlp.conf /etc/tlp.conf.backup
sudo cp -r /etc/tlp.d /etc/tlp.d.backup 2>/dev/null || true

# Install configuration files
sudo cp tlp.d/*.conf /etc/tlp.d/

# Apply configuration
sudo tlp start

# Verify
sudo tlp-stat -s
```

### Manual Install

1. Download the `.conf` files from the `tlp.d/` directory
2. Copy them to `/etc/tlp.d/`:
   ```bash
   sudo cp 10-ac-performance.conf /etc/tlp.d/
   sudo cp 20-battery-saver.conf /etc/tlp.d/
   sudo cp 30-ultra-powersave.conf /etc/tlp.d/
   sudo cp 40-battery-care.conf /etc/tlp.d/
   ```
3. Apply: `sudo tlp start`

## 🎯 Usage

### Automatic Mode Switching

TLP automatically switches between AC and Battery modes when you plug/unplug the charger. No manual intervention needed.

### Manual Mode Override

```bash
# Force Performance mode (even on battery)
sudo tlp performance

# Force Battery mode (even on AC)
sudo tlp balanced

# Activate Ultra Power-Saver mode
sudo tlp power-saver

# Return to automatic mode
sudo tlp start
```

### Battery Management

```bash
# Check battery status and thresholds
sudo tlp-stat -b

# Force full charge (bypass 80% threshold temporarily)
sudo tlp fullcharge BAT0

# Thresholds automatically restore after reaching 100%
```

### Monitoring

```bash
# Overall system status
sudo tlp-stat -s

# CPU configuration
sudo tlp-stat -p

# Quick verification
sudo tlp-stat -p | grep -E "(energy_performance|max_perf|no_turbo|hwp_dynamic)"
```

## 📁 File Structure

```
tlp.d/
├── 10-ac-performance.conf      # AC mode configuration
├── 20-battery-saver.conf       # Battery mode configuration
├── 30-ultra-powersave.conf     # Power-saver mode configuration
└── 40-battery-care.conf        # Battery charge thresholds
```

## ⚙️ Configuration Details

### AC Mode (10-ac-performance.conf)
- EPP: `balance_performance`
- Max Performance: `100%`
- Turbo Boost: **Enabled**
- HWP Dynamic Boost: **Enabled**
- Platform Profile: `balanced`

### Battery Mode (20-battery-saver.conf)
- EPP: `power`
- Max Performance: `80%`
- Turbo Boost: **Disabled**
- HWP Dynamic Boost: **Disabled**
- Platform Profile: `low-power`
- AHCI Runtime PM: **Enabled** (15s timeout)

### Power-Saver Mode (30-ultra-powersave.conf)
- EPP: `power`
- Max Performance: `50%`
- Turbo Boost: **Disabled**
- HWP Dynamic Boost: **Disabled**
- Platform Profile: `low-power`

### Battery Care (40-battery-care.conf)
- Start Charge: `75%`
- Stop Charge: `80%`
- Extends battery lifespan significantly

## 🔧 Customization

### Adjusting Battery Mode Performance

If you find battery mode too slow, edit `/etc/tlp.d/20-battery-saver.conf`:

```bash
# Less aggressive (more performance)
CPU_MAX_PERF_ON_BAT=90

# More aggressive (more battery life)
CPU_MAX_PERF_ON_BAT=70
```

Then apply: `sudo tlp start`

### Changing Battery Thresholds

Edit `/etc/tlp.d/40-battery-care.conf`:

```bash
# Maximum longevity (60-70%)
START_CHARGE_THRESH_BAT0=60
STOP_CHARGE_THRESH_BAT0=70

# Maximum capacity (90-100%)
START_CHARGE_THRESH_BAT0=90
STOP_CHARGE_THRESH_BAT0=100
```

## 📚 Documentation

- [Complete Analysis](docs/ANALISIS-COMPLETO.md) - Detailed technical analysis (Spanish)
- [Installation Guide](docs/GUIA-INSTALACION.md) - Step-by-step installation (Spanish)
- [Command Cheatsheet](docs/CHEATSHEET.md) - Quick reference for TLP commands (Spanish)
- [Official TLP Documentation](https://linrunner.de/tlp)

## 🐛 Troubleshooting

### TLP doesn't start or shows errors

```bash
# Check for conflicts with other power management services
systemctl status power-profiles-daemon

# If active, disable it
sudo systemctl stop power-profiles-daemon
sudo systemctl mask power-profiles-daemon

# Restart TLP
sudo systemctl restart tlp.service
```

### Battery thresholds not working

```bash
# Verify ThinkPad ACPI module is loaded
lsmod | grep thinkpad_acpi

# If not loaded
sudo modprobe thinkpad_acpi
echo "thinkpad_acpi" | sudo tee /etc/modules-load.d/thinkpad.conf

# Check thresholds
sudo tlp-stat -b | grep threshold
```

### High power consumption despite configuration

```bash
# Verify configuration is active
sudo tlp-stat -c

# Check CPU settings
sudo tlp-stat -p | grep -E "(energy_performance|max_perf|no_turbo)"

# Monitor power usage
sudo powertop
```

## 🤝 Contributing

Contributions are welcome! If you have improvements or configurations for similar hardware:

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add some improvement'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [TLP Project](https://linrunner.de/tlp) - Excellent power management tool
- [Arch Linux Community](https://archlinux.org/) - For comprehensive documentation
- Intel Core Ultra 5 125U - For having proper HWP support

## 📞 Support

If you encounter issues:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Review [TLP FAQ](https://linrunner.de/tlp/faq)
3. Open an issue on GitHub with:
   - Output of `sudo tlp-stat -s`
   - Output of `sudo tlp-stat -p`
   - Description of the problem

## 🔖 Version History

### v2.0 (2026-02-16)
- ✅ Added `CPU_HWP_DYN_BOOST` configuration (critical for Core Ultra CPUs)
- ✅ Added `AHCI_RUNTIME_PM` for NVMe power management
- ✅ Added `NMI_WATCHDOG` configuration
- ✅ Fixed Intel GPU configuration (now uses automatic management)
- ✅ Improved documentation
- ✅ Additional 1-2W power savings

### v1.0 (2026-02-16)
- ✅ Initial release
- ✅ Basic CPU, platform profile, and battery care configuration
- ✅ ~60% power consumption reduction

---

**Hardware:** ThinkPad E14 Gen 6 (21M80014CL) - Intel Core Ultra 5 125U  
**Tested on:** Arch Linux (kernel 6.18.7) - TLP 1.9.1  
**Author:** dust115  
**Last Updated:** 2026-02-16
