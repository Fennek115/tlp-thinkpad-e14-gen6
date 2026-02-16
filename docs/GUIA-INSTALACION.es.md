# Guía de Instalación Detallada
## TLP Configuration para ThinkPad E14 Gen 6

---

## 📋 Pre-requisitos

### Hardware Requerido
- ✅ Lenovo ThinkPad E14 Gen 6 (Intel)
- ✅ Intel Core Ultra 5 125U (o similar de la serie Core Ultra 1)
- ✅ Arch Linux (o derivados)

### Software Requerido
```bash
# Instalar TLP
sudo pacman -S tlp

# Opcional pero recomendado
sudo pacman -S powertop     # Para monitoreo
sudo pacman -S intel-gpu-tools  # Para ver stats de GPU
```

---

## 🚀 Instalación

### Método 1: Instalación Automática (Recomendado)

```bash
# 1. Clonar el repositorio
git clone https://github.com/yourusername/tlp-thinkpad-e14-gen6.git
cd tlp-thinkpad-e14-gen6

# 2. Hacer backup de configuración existente
sudo cp /etc/tlp.conf /etc/tlp.conf.backup
sudo mkdir -p ~/tlp-backup-$(date +%Y%m%d)
sudo cp -r /etc/tlp.d ~/tlp-backup-$(date +%Y%m%d)/ 2>/dev/null || true

# 3. Copiar archivos de configuración
sudo cp tlp.d/*.conf /etc/tlp.d/

# 4. Verificar que power-profiles-daemon no esté activo (conflicto)
systemctl status power-profiles-daemon

# Si está activo, deshabilitarlo
sudo systemctl stop power-profiles-daemon
sudo systemctl mask power-profiles-daemon

# 5. Habilitar y aplicar TLP
sudo systemctl enable tlp.service
sudo tlp start

# 6. Verificar que funcionó
sudo tlp-stat -s
```

### Método 2: Instalación Manual

```bash
# 1. Descargar los archivos .conf desde GitHub
# Puedes hacerlo desde la interfaz web o con wget/curl

# 2. Crear directorio de configuración si no existe
sudo mkdir -p /etc/tlp.d

# 3. Copiar cada archivo manualmente
sudo cp 10-ac-performance.conf /etc/tlp.d/
sudo cp 20-battery-saver.conf /etc/tlp.d/
sudo cp 30-ultra-powersave.conf /etc/tlp.d/
sudo cp 40-battery-care.conf /etc/tlp.d/

# 4. Aplicar configuración
sudo tlp start
```

---

## ✅ Verificación Post-Instalación

### 1. Verificar que TLP esté activo

```bash
sudo tlp-stat -s
```

Deberías ver:
```
tlp = enabled, last run: ...
Power profile = balanced/AC (o low-power/BAT)
Power source = AC (o battery)
```

### 2. Verificar configuración de CPU

```bash
sudo tlp-stat -p | grep -E "(energy_performance|max_perf|no_turbo|hwp_dynamic)"
```

**En AC deberías ver:**
```
energy_performance_preference = balance_performance [EPP]
max_perf_pct = 100 [%]
no_turbo = 0
hwp_dynamic_boost = 1
```

**En Batería deberías ver:**
```
energy_performance_preference = power [EPP]
max_perf_pct = 80 [%]
no_turbo = 1
hwp_dynamic_boost = 0
```

### 3. Verificar NMI Watchdog

```bash
cat /proc/sys/kernel/nmi_watchdog
```

Debe mostrar: `0`

### 4. Verificar umbrales de batería

```bash
sudo tlp-stat -b | grep threshold
```

Deberías ver:
```
charge_control_start_threshold = 75 [%]
charge_control_end_threshold = 80 [%]
```

---

## 🔧 Configuración Adicional

### Deshabilitar Servicios Conflictivos

TLP puede conflictuar con otros servicios de gestión de energía:

```bash
# Verificar si están activos
systemctl status power-profiles-daemon
systemctl status laptop-mode-tools

# Si alguno está activo, deshabilitarlo
sudo systemctl stop power-profiles-daemon
sudo systemctl mask power-profiles-daemon

sudo systemctl stop laptop-mode-tools
sudo systemctl mask laptop-mode-tools
```

### Cargar Módulo ThinkPad ACPI

Para que funcionen los umbrales de batería:

```bash
# Verificar si está cargado
lsmod | grep thinkpad_acpi

# Si no está cargado
sudo modprobe thinkpad_acpi

# Para cargarlo automáticamente en cada boot
echo "thinkpad_acpi" | sudo tee /etc/modules-load.d/thinkpad.conf
```

---

## 🎯 Primer Uso

### Probar Cambio Automático de Modos

1. **Con cargador conectado:**
   ```bash
   sudo tlp-stat -p | grep energy_performance
   # Debe mostrar: balance_performance
   ```

2. **Desconectar cargador:**
   ```bash
   # Esperar 2-3 segundos
   sudo tlp-stat -p | grep energy_performance
   # Debe mostrar: power
   ```

3. **Reconectar cargador:**
   ```bash
   # Esperar 2-3 segundos
   sudo tlp-stat -p | grep energy_performance
   # Debe mostrar: balance_performance
   ```

Si esto funciona, ¡todo está perfecto! ✅

### Probar Modo Ultra-Ahorro

```bash
# Activar modo power-saver
sudo tlp power-saver

# Verificar
sudo tlp-stat -p | grep max_perf
# Debe mostrar: max_perf_pct = 40 [%]

# Volver a modo automático
sudo tlp start
```

### Probar Bypass de Umbrales de Batería

```bash
# Forzar carga a 100% (ignora umbrales temporalmente)
sudo tlp fullcharge BAT0

# Verificar que esté cargando
sudo tlp-stat -b | grep "State"
# Debe mostrar: Charging

# Después de llegar a 100%, los umbrales se restauran automáticamente
```

---

## 🐛 Troubleshooting

### Problema: TLP no inicia o muestra errores

**Solución 1:** Verificar conflictos
```bash
systemctl status power-profiles-daemon
sudo systemctl mask power-profiles-daemon
```

**Solución 2:** Revisar logs
```bash
journalctl -u tlp.service -b
```

**Solución 3:** Verificar sintaxis de archivos
```bash
sudo tlp-stat -c
```

---

### Problema: Los umbrales de batería no funcionan

**Solución:**
```bash
# Verificar que el módulo esté cargado
lsmod | grep thinkpad_acpi

# Si no está, cargarlo
sudo modprobe thinkpad_acpi

# Verificar soporte
sudo tlp-stat -b | grep "supported"
```

---

### Problema: El consumo sigue siendo alto

**Diagnóstico:**
```bash
# Ver qué está consumiendo energía
sudo powertop

# Verificar configuración activa
sudo tlp-stat -c

# Ver CPU
sudo tlp-stat -p | head -20
```

**Posibles causas:**
1. Aplicaciones en segundo plano
2. Brillo de pantalla muy alto
3. Configuración no aplicada correctamente

---

## 📊 Monitoreo

### Herramientas Recomendadas

```bash
# Powertop - ver consumo en tiempo real
sudo powertop

# TLP Stats - estadísticas de TLP
sudo tlp-stat -s  # estado general
sudo tlp-stat -p  # CPU
sudo tlp-stat -b  # batería
sudo tlp-stat -d  # discos

# intel_gpu_top - monitorear GPU
sudo intel_gpu_top

# htop/btop - procesos
htop
```

---

## 🔄 Actualización

Si actualizas la configuración desde GitHub:

```bash
# Ir al directorio del repo
cd tlp-thinkpad-e14-gen6

# Hacer backup actual
sudo cp -r /etc/tlp.d ~/tlp-backup-$(date +%Y%m%d)

# Pull cambios
git pull

# Copiar nuevos archivos
sudo cp tlp.d/*.conf /etc/tlp.d/

# Aplicar
sudo tlp start
```

---

## 🗑️ Desinstalación

Si quieres volver a la configuración original:

```bash
# Restaurar desde backup
sudo cp ~/tlp-backup-FECHA/tlp.conf /etc/tlp.conf
sudo cp -r ~/tlp-backup-FECHA/tlp.d /etc/

# O eliminar archivos personalizados
sudo rm /etc/tlp.d/10-ac-performance.conf
sudo rm /etc/tlp.d/20-battery-saver.conf
sudo rm /etc/tlp.d/30-ultra-powersave.conf
sudo rm /etc/tlp.d/40-battery-care.conf

# Aplicar defaults
sudo tlp start
```

---

## 📞 Soporte

Si tienes problemas:

1. Lee la sección de [Troubleshooting](#-troubleshooting)
2. Revisa el [Cheatsheet](CHEATSHEET.es.md) de comandos
3. Consulta la [documentación oficial de TLP](https://linrunner.de/tlp)
4. Abre un issue en GitHub con:
   - Salida de `sudo tlp-stat -s`
   - Salida de `sudo tlp-stat -p`
   - Descripción del problema

---

## ✅ Checklist de Instalación

- [ ] TLP instalado (`sudo pacman -S tlp`)
- [ ] Backup de configuración original creado
- [ ] Archivos .conf copiados a `/etc/tlp.d/`
- [ ] power-profiles-daemon deshabilitado
- [ ] TLP habilitado y iniciado (`sudo systemctl enable tlp.service`)
- [ ] Configuración aplicada (`sudo tlp start`)
- [ ] Verificación en AC exitosa
- [ ] Verificación en BAT exitosa (desconectar cargador)
- [ ] NMI watchdog = 0
- [ ] Umbrales de batería configurados
- [ ] Modo ultra-ahorro probado
- [ ] Consumo monitoreado con powertop

---

*Última actualización: 2026-02-16*
