# TLP Configuration for ThinkPad E14 Gen 6 (Intel Core Ultra 5 125U)

> 🇪🇸 [Versión en Español](#configuración-tlp-para-thinkpad-e14-gen-6-intel-core-ultra-5-125u) | [Spanish Documentation](docs/)

Optimized TLP power management configuration for Lenovo ThinkPad E14 Gen 6 with Intel Core Ultra 5 125U processor (Meteor Lake).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TLP Version](https://img.shields.io/badge/TLP-1.9.1-blue.svg)](https://linrunner.de/tlp)
[![Tested on Arch](https://img.shields.io/badge/Tested%20on-Arch%20Linux-1793D1.svg)](https://archlinux.org/)

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
  - **Battery Mode:** Optimized efficiency for daily use (80% max performance)
  - **Power-Saver Mode:** Maximum battery life (50% max performance, manual activation)

- **CPU Optimization:**
  - EPP (Energy Performance Preference) configuration
  - Turbo Boost control per mode
  - HWP Dynamic Boost for Intel Core Ultra series
  - Performance limits optimized for each mode

- **Battery Care:**
  - Charge thresholds (75-80%) to extend battery lifespan
  - Expected 2-3x longer battery life
  - Temporary full charge override available with `sudo tlp fullcharge BAT0`

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

## 📦 Quick Installation

### Prerequisites

```bash
# Arch Linux / Manjaro
sudo pacman -S tlp

# Debian / Ubuntu
sudo apt install tlp

# Fedora
sudo dnf install tlp
```

### Install Configuration

```bash
# Clone repository
git clone https://github.com/Fennek115/tlp-thinkpad-e14-gen6.git
cd tlp-thinkpad-e14-gen6

# Run installation script
sudo ./install.sh

# Or manually
sudo cp tlp.d/*.conf /etc/tlp.d/
sudo tlp start
```

### Verify Installation

```bash
# Check status
sudo tlp-stat -s

# Check CPU configuration
sudo tlp-stat -p | grep -E "(energy_performance|max_perf|no_turbo|hwp_dynamic)"

# Expected on AC:
# energy_performance = balance_performance
# max_perf = 100%
# no_turbo = 0 (turbo enabled)
# hwp_dynamic_boost = 1

# Expected on Battery:
# energy_performance = power
# max_perf = 80%
# no_turbo = 1 (turbo disabled)
# hwp_dynamic_boost = 0
```

## 🎯 Usage

### Automatic Mode Switching

TLP automatically switches between AC and Battery modes when you plug/unplug the charger.

### Manual Mode Override

```bash
# Force Performance mode (even on battery)
sudo tlp performance

# Force Battery mode (even on AC)
sudo tlp balanced

# Activate Ultra Power-Saver mode (50% performance)
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

## 📁 Repository Structure

```
.
├── README.md                       # This file (bilingual)
├── LICENSE                         # MIT License
├── install.sh                      # Automated installation script
├── tlp.d/                          # TLP configuration files
│   ├── 10-ac-performance.conf      # AC mode settings
│   ├── 20-battery-saver.conf       # Battery mode settings
│   ├── 30-ultra-powersave.conf     # Power-saver mode settings
│   └── 40-battery-care.conf        # Battery charge thresholds
└── docs/                           # Documentation
    ├── CHEATSHEET.md               # Command reference (English)
    ├── CHEATSHEET.es.md            # Referencia de comandos (Español)
    ├── INSTALLATION-GUIDE.md       # Detailed installation (English)
    ├── GUIA-INSTALACION.md         # Guía detallada (Español)
    ├── TECHNICAL-ANALYSIS.md       # Technical details (English)
    └── ANALISIS-COMPLETO.md        # Análisis técnico (Español)
```

## ⚙️ Configuration Details

### AC Mode (`10-ac-performance.conf`)
- EPP: `balance_performance`
- Max Performance: `100%`
- Turbo Boost: **Enabled**
- HWP Dynamic Boost: **Enabled**
- Platform Profile: `balanced`

### Battery Mode (`20-battery-saver.conf`)
- EPP: `power`
- Max Performance: `80%`
- Turbo Boost: **Disabled**
- HWP Dynamic Boost: **Disabled**
- Platform Profile: `low-power`
- AHCI Runtime PM: **Enabled**

### Power-Saver Mode (`30-ultra-powersave.conf`)
- EPP: `power`
- Max Performance: `50%` (customized from default 40%)
- Turbo Boost: **Disabled**
- HWP Dynamic Boost: **Disabled**
- Platform Profile: `low-power`

### Battery Care (`40-battery-care.conf`)
- Start Charge: `75%`
- Stop Charge: `80%`

## 📚 Documentation

**English:**
- [Command Cheatsheet](docs/CHEATSHEET.md) - Quick reference
- [Installation Guide](docs/INSTALLATION-GUIDE.md) - Detailed setup
- [Technical Analysis](docs/TECHNICAL-ANALYSIS.md) - In-depth explanation

**Español:**
- [Hoja de Referencia](docs/CHEATSHEET.es.md) - Comandos útiles
- [Guía de Instalación](docs/GUIA-INSTALACION.es.md) - Instalación detallada
- [Análisis Técnico](docs/ANALISIS-COMPLETO.es.md) - Explicación completa

## 🐛 Troubleshooting

### Configuration not applying

```bash
# Check for conflicts
systemctl status power-profiles-daemon

# Disable if active
sudo systemctl stop power-profiles-daemon
sudo systemctl mask power-profiles-daemon

# Restart TLP
sudo systemctl restart tlp
sudo tlp start
```

### High power consumption

```bash
# Monitor power usage
sudo powertop

# Verify active configuration
sudo tlp-stat -c

# Check background processes
htop
```

See [Installation Guide](docs/INSTALLATION-GUIDE.md) for more troubleshooting steps.

## 🤝 Contributing

Contributions welcome! If you have:
- Improvements for similar hardware
- Translations
- Bug fixes

Please open an issue or pull request.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [TLP Project](https://linrunner.de/tlp) - Excellent power management tool
- [Arch Linux Community](https://archlinux.org/)
- Intel Core Ultra 5 125U - For proper HWP support

---
---
---

# Configuración TLP para ThinkPad E14 Gen 6 (Intel Core Ultra 5 125U)

> 🇬🇧 [English Version](#tlp-configuration-for-thinkpad-e14-gen-6-intel-core-ultra-5-125u) | [English Documentation](docs/)

Configuración optimizada de TLP para la gestión de energía en Lenovo ThinkPad E14 Gen 6 con procesador Intel Core Ultra 5 125U (Meteor Lake).

[![Licencia: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Versión TLP](https://img.shields.io/badge/TLP-1.9.1-blue.svg)](https://linrunner.de/tlp)
[![Probado en Arch](https://img.shields.io/badge/Probado%20en-Arch%20Linux-1793D1.svg)](https://archlinux.org/)

## 📊 Resultados

| Métrica | Antes | Después | Mejora |
|---------|-------|---------|--------|
| Consumo idle (AC) | ~15W | ~10-13W | ↓ 20-30% |
| Consumo idle (Batería) | ~15W | ~5-7W | ↓ 60-65% |
| Duración de batería | 3-4 horas | 6-8 horas | +60-100% |
| Temperatura CPU (idle) | 56-62°C | 40-50°C | ↓ 15°C |

## ⚡ Características

- **Tres perfiles de energía:**
  - **Modo AC:** Rendimiento balanceado cuando está enchufado
  - **Modo Batería:** Eficiencia optimizada para uso diario (80% rendimiento máx.)
  - **Modo Ultra-Ahorro:** Máxima duración de batería (50% rendimiento máx., activación manual)

- **Optimización de CPU:**
  - Configuración EPP (Energy Performance Preference)
  - Control de Turbo Boost por modo
  - HWP Dynamic Boost para serie Intel Core Ultra
  - Límites de rendimiento optimizados para cada modo

- **Cuidado de Batería:**
  - Umbrales de carga (75-80%) para extender vida útil
  - Vida útil esperada 2-3x más larga
  - Override temporal de carga completa con `sudo tlp fullcharge BAT0`

- **Específico para Hardware:**
  - Optimizado para Intel Core Ultra 5 125U (Meteor Lake)
  - Gestión de energía Runtime para SSD NVMe
  - Auto-gestión de gráficos Intel Arc
  - Integración con ThinkPad ACPI

## 🖥️ Compatibilidad de Hardware

**Objetivo Principal:**
- Lenovo ThinkPad E14 Gen 6 (Intel)
- Intel Core Ultra 5 125U

**Debería Funcionar Con:**
- ThinkPad E14/E16 Gen 6 (variantes Intel)
- Otras laptops Lenovo con Intel Core Ultra Series 1 (Meteor Lake)
- CPUs Intel con soporte HWP (Core i 6ta gen o más nuevo)

**No Compatible Con:**
- CPUs AMD (requiere configuración diferente)
- CPUs Intel muy antiguas sin HWP (pre-6ta gen)

## 📦 Instalación Rápida

### Prerequisitos

```bash
# Arch Linux / Manjaro
sudo pacman -S tlp

# Debian / Ubuntu
sudo apt install tlp

# Fedora
sudo dnf install tlp
```

### Instalar Configuración

```bash
# Clonar repositorio
git clone https://github.com/Fennek115/tlp-thinkpad-e14-gen6.git
cd tlp-thinkpad-e14-gen6

# Ejecutar script de instalación
sudo ./install.sh

# O manualmente
sudo cp tlp.d/*.conf /etc/tlp.d/
sudo tlp start
```

### Verificar Instalación

```bash
# Ver estado
sudo tlp-stat -s

# Ver configuración de CPU
sudo tlp-stat -p | grep -E "(energy_performance|max_perf|no_turbo|hwp_dynamic)"

# Esperado en AC:
# energy_performance = balance_performance
# max_perf = 100%
# no_turbo = 0 (turbo habilitado)
# hwp_dynamic_boost = 1

# Esperado en Batería:
# energy_performance = power
# max_perf = 80%
# no_turbo = 1 (turbo deshabilitado)
# hwp_dynamic_boost = 0
```

## 🎯 Uso

### Cambio Automático de Modos

TLP cambia automáticamente entre modos AC y Batería cuando conectas/desconectas el cargador.

### Override Manual de Modos

```bash
# Forzar modo Performance (incluso en batería)
sudo tlp performance

# Forzar modo Batería (incluso en AC)
sudo tlp balanced

# Activar modo Ultra-Ahorro (50% rendimiento)
sudo tlp power-saver

# Volver a modo automático
sudo tlp start
```

### Gestión de Batería

```bash
# Ver estado de batería y umbrales
sudo tlp-stat -b

# Forzar carga completa (bypass temporal del umbral 80%)
sudo tlp fullcharge BAT0
# Los umbrales se restauran automáticamente después de llegar a 100%
```

## 📁 Estructura del Repositorio

```
.
├── README.md                       # Este archivo (bilingüe)
├── LICENSE                         # Licencia MIT
├── install.sh                      # Script de instalación automatizada
├── tlp.d/                          # Archivos de configuración TLP
│   ├── 10-ac-performance.conf      # Configuración modo AC
│   ├── 20-battery-saver.conf       # Configuración modo Batería
│   ├── 30-ultra-powersave.conf     # Configuración modo Ultra-Ahorro
│   └── 40-battery-care.conf        # Umbrales de carga de batería
└── docs/                           # Documentación
    ├── CHEATSHEET.md               # Referencia de comandos (Inglés)
    ├── CHEATSHEET.es.md            # Referencia de comandos (Español)
    ├── INSTALLATION-GUIDE.md       # Instalación detallada (Inglés)
    ├── GUIA-INSTALACION.md         # Guía detallada (Español)
    ├── TECHNICAL-ANALYSIS.md       # Detalles técnicos (Inglés)
    └── ANALISIS-COMPLETO.md        # Análisis técnico (Español)
```

## ⚙️ Detalles de Configuración

### Modo AC (`10-ac-performance.conf`)
- EPP: `balance_performance`
- Rendimiento Máximo: `100%`
- Turbo Boost: **Habilitado**
- HWP Dynamic Boost: **Habilitado**
- Platform Profile: `balanced`

### Modo Batería (`20-battery-saver.conf`)
- EPP: `power`
- Rendimiento Máximo: `80%`
- Turbo Boost: **Deshabilitado**
- HWP Dynamic Boost: **Deshabilitado**
- Platform Profile: `low-power`
- AHCI Runtime PM: **Habilitado**

### Modo Ultra-Ahorro (`30-ultra-powersave.conf`)
- EPP: `power`
- Rendimiento Máximo: `50%` (personalizado desde 40% por defecto)
- Turbo Boost: **Deshabilitado**
- HWP Dynamic Boost: **Deshabilitado**
- Platform Profile: `low-power`

### Cuidado de Batería (`40-battery-care.conf`)
- Inicio de Carga: `75%`
- Detención de Carga: `80%`

## 📚 Documentación

**English:**
- [Command Cheatsheet](docs/CHEATSHEET.md) - Referencia rápida
- [Installation Guide](docs/INSTALLATION-GUIDE.md) - Configuración detallada
- [Technical Analysis](docs/TECHNICAL-ANALYSIS.md) - Explicación en profundidad

**Español:**
- [Hoja de Referencia](docs/CHEATSHEET.es.md) - Comandos útiles
- [Guía de Instalación](docs/GUIA-INSTALACION.es.md) - Instalación detallada
- [Análisis Técnico](docs/ANALISIS-COMPLETO.es.md) - Explicación completa

## 🐛 Solución de Problemas

### La configuración no se aplica

```bash
# Verificar conflictos
systemctl status power-profiles-daemon

# Deshabilitar si está activo
sudo systemctl stop power-profiles-daemon
sudo systemctl mask power-profiles-daemon

# Reiniciar TLP
sudo systemctl restart tlp
sudo tlp start
```

### Alto consumo de energía

```bash
# Monitorear consumo
sudo powertop

# Verificar configuración activa
sudo tlp-stat -c

# Ver procesos en segundo plano
htop
```

Consulta la [Guía de Instalación](docs/GUIA-INSTALACION.md) para más pasos de solución de problemas.

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Si tienes:
- Mejoras para hardware similar
- Traducciones
- Correcciones de bugs

Por favor abre un issue o pull request.

## 📄 Licencia

Licencia MIT - ver archivo [LICENSE](LICENSE) para detalles.

## 🙏 Agradecimientos

- [Proyecto TLP](https://linrunner.de/tlp) - Excelente herramienta de gestión de energía
- [Comunidad Arch Linux](https://archlinux.org/)
- Intel Core Ultra 5 125U - Por el soporte adecuado de HWP

---

**Hardware:** ThinkPad E14 Gen 6 (21M80014CL) - Intel Core Ultra 5 125U  
**Probado en:** Arch Linux (kernel 6.18.7) - TLP 1.9.1  
**Autor:** Fennek115  
**Última Actualización:** 2026-02-16
