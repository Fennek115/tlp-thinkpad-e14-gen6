# TLP Cheatsheet - ThinkPad E14 Gen 6
#linux #tlp #power-management #thinkpad

---

## 🎯 Comandos Básicos

### Control de TLP
```bash
# Iniciar TLP y aplicar configuración
sudo tlp start

# Verificar estado general
sudo tlp-stat -s

# Ver estadísticas completas (muy verbose)
sudo tlp-stat

# Ver solo configuración activa
sudo tlp-stat -c
```

---

## 🔄 Cambio Manual de Modos

### Modos Disponibles
```bash
# Modo Performance (AC) - forzar incluso en batería
sudo tlp performance

# Modo Balanced (BAT) - forzar incluso en AC  
sudo tlp balanced

# Modo Power-Saver (SAV) - ultra ahorro
sudo tlp power-saver

# Volver a modo automático (AC/BAT según fuente)
sudo tlp start
```

> **Nota:** El modo automático cambia entre AC/BAT cuando conectas/desconectas el cargador

---

## 🔋 Gestión de Batería

### Ver Estado de Batería
```bash
# Ver todo sobre batería
sudo tlp-stat -b

# Ver solo umbrales de carga
sudo tlp-stat -b | grep threshold

# Ver capacidad y salud de batería
sudo tlp-stat -b | grep -E "(design|full|remaining)"
```

### Forzar Carga Completa (Bypass Temporal de Umbrales)
```bash
# Cargar hasta 100% una sola vez (ignora umbrales temporalmente)
sudo tlp fullcharge

# O especificar la batería (BAT0 o BAT1)
sudo tlp fullcharge BAT0

# Después de llegar a 100%, los umbrales se restauran automáticamente
```

### Resetear Umbrales Manualmente
```bash
# Aplicar umbrales configurados inmediatamente
sudo tlp setcharge
```

### Descargar Batería para Recalibración
```bash
# Descargar hasta cierto nivel (útil para recalibración)
# Por ejemplo, descargar hasta 70%
sudo tlp discharge BAT0
# (presiona Ctrl+C cuando llegue al nivel deseado)
```

---

## 💻 Monitoreo de CPU

### Estadísticas de Procesador
```bash
# Ver config completa de CPU
sudo tlp-stat -p

# Ver solo los parámetros clave
sudo tlp-stat -p | grep -E "(energy_performance|max_perf|no_turbo|hwp_dynamic|platform_profile)"

# Ver frecuencias actuales de cada core
sudo tlp-stat -p | grep "scaling_cur_freq"

# Ver temperaturas
sudo tlp-stat -t
```

### Verificar Parámetros Específicos
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

## 🎮 GPU Intel

### Estadísticas de GPU
```bash
# Ver config de GPU Intel
sudo tlp-stat -g

# Ver frecuencias actuales de GPU
cat /sys/class/drm/card*/gt_cur_freq_mhz

# Monitoreo en tiempo real (requiere intel-gpu-tools)
sudo intel_gpu_top
```

---

## 💾 Discos y Almacenamiento

### Estadísticas de Discos
```bash
# Ver config de discos y controladores
sudo tlp-stat -d

# Ver solo Runtime PM de discos
sudo tlp-stat -d | grep -i "runtime"

# Ver estado de NVMe
sudo tlp-stat -d | grep -i nvme
```

---

## 🌐 Dispositivos de Red

### WiFi
```bash
# Ver estado de power saving de WiFi
sudo tlp-stat -w

# Ver adaptador WiFi
iwconfig
```

### USB
```bash
# Ver estado de USB autosuspend
sudo tlp-stat -u

# Listar dispositivos USB
lsusb

# Ver qué dispositivos están excluidos de autosuspend
sudo tlp-stat -u | grep "Exclude"
```

---

## 🔧 Troubleshooting

### Verificar Errores
```bash
# Ver warnings de TLP
sudo tlp-stat -w

# Ver mensajes del sistema sobre TLP
journalctl -u tlp.service -b

# Ver últimas 50 líneas del log
journalctl -u tlp.service -n 50
```

### Conflictos con Otros Servicios
```bash
# Verificar si power-profiles-daemon está activo (conflicto)
systemctl status power-profiles-daemon

# Deshabilitar power-profiles-daemon si está activo
sudo systemctl stop power-profiles-daemon
sudo systemctl mask power-profiles-daemon
```

### Reload de Configuración
```bash
# Después de editar archivos en /etc/tlp.d/
sudo tlp start

# Para ver qué configuración está activa
sudo tlp-stat -c
```

---

## 📊 Monitoreo de Consumo

### Herramientas Complementarias
```bash
# Powertop - monitoreo de consumo en tiempo real
sudo powertop

# Ver consumo estimado actual
sudo powertop --auto-tune  # aplicar tunables (cuidado, puede conflictuar con TLP)

# s-tui - interfaz visual para CPU
s-tui

# Verificar consumo de paquete de CPU
sudo tlp-stat -t | grep "Package"
```

---

## 📝 Configuración

### Ubicación de Archivos
```bash
# Archivo principal (usar solo como referencia)
/etc/tlp.conf

# Archivos drop-in (AQUÍ van tus personalizaciones)
/etc/tlp.d/10-ac-performance.conf
/etc/tlp.d/20-battery-saver.conf
/etc/tlp.d/30-ultra-powersave.conf
/etc/tlp.d/40-battery-care.conf

# Editar configuración
sudo nano /etc/tlp.d/20-battery-saver.conf

# Después de editar, aplicar cambios
sudo tlp start
```

---

## 🎯 Casos de Uso Comunes

### Escenario: Necesito cargar a 100% una vez
```bash
# Forzar carga completa (ignora umbrales temporalmente)
sudo tlp fullcharge BAT0

# Los umbrales se restauran automáticamente después
```

### Escenario: Voy a estar desconectado mucho tiempo
```bash
# Activar modo ultra-ahorro
sudo tlp power-saver

# Verificar que esté activo
sudo tlp-stat -s

# Cuando vuelvas a uso normal
sudo tlp start
```

### Escenario: Necesito rendimiento máximo ahora
```bash
# Forzar modo performance (incluso en batería)
sudo tlp performance

# Verificar
sudo tlp-stat -p | grep "energy_performance"

# Volver a automático
sudo tlp start
```

### Escenario: Quiero ver si TLP está ahorrando energía
```bash
# Comparar consumo antes/después
sudo powertop  # ver watts totales

# Ver si CPU está en frecuencias bajas
sudo tlp-stat -p | grep "scaling_cur_freq"

# Ver si turbo está deshabilitado (en batería debe ser 1)
cat /sys/devices/system/cpu/intel_pstate/no_turbo
```

---

## 🔍 Quick Reference

### Verificación Rápida del Sistema
```bash
# One-liner para ver estado completo
sudo tlp-stat -s && echo "---" && sudo tlp-stat -p | grep -E "(energy_performance|max_perf|no_turbo|hwp_dynamic|platform_profile)"
```

### Alias Útiles (agregar a ~/.bashrc o ~/.zshrc)
```bash
# Alias para comandos comunes
alias tlp-status='sudo tlp-stat -s'
alias tlp-cpu='sudo tlp-stat -p'
alias tlp-bat='sudo tlp-stat -b'
alias tlp-full='sudo tlp fullcharge BAT0'
alias tlp-save='sudo tlp power-saver && echo "Modo ultra-ahorro activado"'
alias tlp-normal='sudo tlp start && echo "Modo automático activado"'
alias tlp-perf='sudo tlp performance && echo "Modo performance activado"'
```

---

## 📚 Recursos

- **Documentación oficial:** https://linrunner.de/tlp
- **Configuración en GitHub:** https://github.com/Fennek115/tlp-thinkpad-e14-gen6
- **TLP FAQ:** https://linrunner.de/tlp/faq

---

## ⚙️ Mi Configuración Actual

### Umbrales de Batería
- **Inicio de carga:** 75%
- **Detención de carga:** 80%
- **Comando para bypass:** `sudo tlp fullcharge BAT0`

### Modos Configurados
- **AC:** balance_performance, 100% rendimiento, turbo ON
- **BAT:** power, 80% rendimiento, turbo OFF  
- **SAV:** power, 40% rendimiento, turbo OFF (manual)

### Consumo Esperado
- **AC idle:** ~10-13W
- **BAT idle:** ~5-7W
- **SAV idle:** ~4-6W

---

*Última actualización: 2026-02-16*
*Hardware: ThinkPad E14 Gen 6 - Intel Core Ultra 5 125U*
