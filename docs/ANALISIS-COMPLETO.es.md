# Análisis Completo de Configuración TLP
## ThinkPad E14 Gen 6 - Intel Core Ultra 5 125U
### Revisión Exhaustiva vs Documentación Oficial TLP 1.9.1

---

## RESUMEN EJECUTIVO

Después de revisar:
- ✅ Especificaciones completas del Intel Core Ultra 5 125U (Meteor Lake)
- ✅ Documentación oficial de TLP 1.9.1 (linrunner.de)
- ✅ Archivo tlp.conf 1.9.1 completo sin configurar
- ✅ Características del ThinkPad E14 Gen 6 (modelo 21M80014CL)

He identificado **VARIOS PARÁMETROS IMPORTANTES** que faltaban en la configuración inicial.

---

## ESPECIFICACIONES DEL HARDWARE

### Intel Core Ultra 5 125U (Meteor Lake)

**Arquitectura:**
- 12 cores totales:
  - 2 P-cores (Performance): 1.3 GHz base → 4.3 GHz turbo (con Hyper-Threading)
  - 8 E-cores (Efficient): 800 MHz base → 3.6 GHz turbo
  - 2 LP E-cores (Low Power Efficient): 700 MHz base → 2.1 GHz turbo
- 14 threads totales (solo los P-cores tienen HT)
- 12 MB L3 Cache

**Consumo de Energía:**
- **Processor Base Power:** 15W (lo que el OEM configura como TDP nominal)
- **Maximum Turbo Power:** 57W (PL2 - picos cortos de rendimiento)
- **Minimum Assured Power:** 12W (consumo mínimo garantizado)

**Características Relevantes para TLP:**
- ✅ Soporta intel_pstate driver en modo activo (HWP - Hardware P-States)
- ✅ Soporta EPP (Energy Performance Preference) - HWP.EPP
- ✅ Soporta Turbo Boost 2.0
- ✅ Soporta HWP Dynamic Boost
- ✅ NO soporta EPB (porque tiene EPP, son mutuamente excluyentes)

**GPU Integrada:**
- Intel Arc Graphics (4-cores)
- Frecuencias: 800 MHz mín → 1850 MHz máx
- Basada en arquitectura Xe-LPG

### ThinkPad E14 Gen 6 (Intel) - Modelo 21M80014CL

**Almacenamiento:**
- NVMe SSD (PCIe 4.0)
- NO tiene disco mecánico HDD

**Conectividad:**
- Wi-Fi 6E (802.11ax)
- Bluetooth 5.2
- 1x Thunderbolt 4
- USB-A 3.2 Gen 1, Gen 2
- USB-C 3.2 Gen 2x2

**Características de Energía:**
- Batería interna (no removible)
- Soporta Battery Care (umbrales de carga) vía thinkpad_acpi

---

## PARÁMETROS QUE FALTABAN EN LA CONFIGURACIÓN INICIAL

### 1. ⚠️ CRÍTICO: CPU_HWP_DYN_BOOST

**Qué es:** Dynamic Boost mejora la respuesta del sistema aumentando dinámicamente el P-state mínimo cuando una tarea que estaba esperando I/O es seleccionada para ejecutarse.

**Por qué es importante:** El Core Ultra 5 125U soporta esta característica (requiere Core i 6th gen o newer con intel_pstate en modo activo). Ayuda con la respuesta en cargas interactivas sin desperdiciar energía constantemente.

**Configuración recomendada:**
```bash
CPU_HWP_DYN_BOOST_ON_AC=1      # Habilitar en AC para mejor respuesta
CPU_HWP_DYN_BOOST_ON_BAT=0     # Deshabilitar en batería para ahorrar energía
CPU_HWP_DYN_BOOST_ON_SAV=0     # Deshabilitar en modo ultra-ahorro
```

**Impacto:** Sin configurar este parámetro, estamos dejando el comportamiento al azar (depende del kernel). Es mejor ser explícitos.

---

### 2. ⚠️ IMPORTANTE: AHCI_RUNTIME_PM y AHCI_RUNTIME_PM_TIMEOUT

**Qué es:** Runtime Power Management para controladores SATA/AHCI y discos NVMe.

**Por qué es importante:** Tu ThinkPad tiene un NVMe SSD. El runtime PM permite que el controlador del disco entre en estados de bajo consumo cuando no está en uso activo.

**Configuración recomendada:**
```bash
AHCI_RUNTIME_PM_ON_AC=on       # Deshabilitado en AC (mejor respuesta)
AHCI_RUNTIME_PM_ON_BAT=auto    # Habilitado en batería (ahorro de energía)

# Timeout: cuántos segundos de inactividad antes de suspender
AHCI_RUNTIME_PM_TIMEOUT=15     # 15 segundos es un buen balance
```

**Impacto:** Puede ahorrar 0.5-1W adicional cuando el disco no está en uso activo. En un NVMe esto es menos dramático que en un HDD, pero sigue siendo relevante.

---

### 3. ⚠️ IMPORTANTE: NMI_WATCHDOG

**Qué es:** El Non-Maskable Interrupt Watchdog es una característica de debugging del kernel que constantemente interrumpe la CPU para detectar lockups.

**Por qué es importante:** Cuando está habilitado (default en muchas distros), previene que la CPU entre en estados C-states más profundos, consumiendo energía innecesariamente.

**Configuración recomendada:**
```bash
NMI_WATCHDOG=0     # Deshabilitar (ahorra energía)
```

**Impacto:** TLP por defecto lo deshabilita, pero es bueno ser explícito. Puede ahorrar 0.5-1W.

**Nota:** Solo necesitas NMI_WATCHDOG=1 si estás debuggeando problemas del kernel.

---

### 4. ⚠️ MODERADO: DISK_APM_LEVEL

**Qué es:** Advanced Power Management level para discos.

**Por qué podría no ser relevante:** Los discos NVMe modernos generalmente no soportan APM (es una característica de discos SATA/ATA). Sin embargo, no hace daño configurarlo por si acaso conectas discos externos.

**Configuración recomendada:**
```bash
#DISK_APM_LEVEL_ON_AC="254 254"     # Máximo rendimiento
#DISK_APM_LEVEL_ON_BAT="128 128"   # Balance (default de TLP)
```

**Decisión:** Dejarlo comentado (usar defaults de TLP) ya que tu laptop tiene NVMe.

---

### 5. ⚠️ MODERADO: MEM_SLEEP (Modo de Suspensión)

**Qué es:** Controla el modo de suspensión del sistema.

**Opciones:**
- `s2idle` (Idle Standby): Suspensión ligera por software, consume un poco más pero es más compatible
- `deep` (Suspend to RAM): Suspensión profunda, consume menos pero puede tener problemas de compatibilidad

**Según tu tlp-stat:**
```
Suspend mode   = [s2idle]
```

Tu sistema actualmente usa s2idle, que es el más compatible y recomendado para laptops modernas.

**Configuración recomendada:**
```bash
# Dejarlo sin configurar - usar el default del sistema (s2idle)
# Cambiar a 'deep' solo si tienes problemas de duración en suspensión
#MEM_SLEEP_ON_AC=s2idle
#MEM_SLEEP_ON_BAT=deep
```

**Decisión:** **NO configurar** esto a menos que tengas problemas específicos de duración en suspensión. El default (s2idle) es más seguro y funciona bien en ThinkPads modernos.

---

### 6. ⚠️ MENOR: SOUND_POWER_SAVE

**Qué está en mi config:** Tenía esto diferenciado (0 en AC, 1 en BAT)

**Qué dice TLP default:** 1 en ambos modos

**Por qué:** El valor de 1 segundo es recomendado para sistemas con PulseAudio/PipeWire (que es lo que usas en Arch Linux moderno). No causa problemas audibles y ahorra energía.

**Configuración corregida:**
```bash
SOUND_POWER_SAVE_ON_AC=1       # Cambio: era 0, ahora 1
SOUND_POWER_SAVE_ON_BAT=1
SOUND_POWER_SAVE_CONTROLLER=Y
```

**Impacto:** Muy menor (quizás 0.1W), pero es mejor seguir la recomendación oficial.

---

### 7. ⚠️ CONFIRMACIÓN: CPU_DRIVER_OPMODE

**Qué es:** Selecciona el modo de operación del driver de CPU.

**Para intel_pstate (tu caso):**
- `active`: Modo recomendado para CPUs con HWP (Core i 6th gen+)
- `passive`: Solo para CPUs antiguas sin HWP (Core i 5th gen o anteriores)

**Tu CPU:** Core Ultra 5 125U tiene HWP, así que debe usar modo `active`.

**Configuración:**
```bash
# Dejar SIN CONFIGURAR - el kernel automáticamente selecciona 'active' para CPUs con HWP
# Solo configurar si tienes problemas específicos
#CPU_DRIVER_OPMODE_ON_AC=active
#CPU_DRIVER_OPMODE_ON_BAT=active
#CPU_DRIVER_OPMODE_ON_SAV=active
```

**Decisión:** **NO configurar** - dejar que el kernel use su lógica automática (que selecciona 'active' para tu CPU).

---

### 8. ⚠️ OPCIONAL: RUNTIME_PM_DRIVER_DENYLIST

**Qué es:** Excluye ciertos drivers del Runtime Power Management.

**Default de TLP:**
```bash
RUNTIME_PM_DRIVER_DENYLIST="mei_me nouveau radeon xhci_hcd"
```

**Por qué estos drivers:**
- `mei_me`: Intel Management Engine - puede causar problemas si se suspende
- `nouveau`: Driver open-source de NVIDIA - puede causar problemas
- `radeon`: Driver AMD antiguo - puede causar problemas  
- `xhci_hcd`: Controlador USB 3.0 - puede causar problemas con dispositivos USB

**Tu hardware:**
- ✅ NO tienes GPU NVIDIA (no necesitas nouveau)
- ✅ NO tienes GPU AMD (no necesitas radeon)
- ❓ `mei_me` puede estar presente (Intel ME)
- ❓ `xhci_hcd` definitivamente presente (USB 3.x)

**Configuración recomendada:**
```bash
# Usar el default de TLP - es conservador y funciona bien
# Solo modificar si tienes problemas específicos con USB
#RUNTIME_PM_DRIVER_DENYLIST="mei_me nouveau radeon xhci_hcd"
```

**Decisión:** Dejar en default (no configurar explícitamente).

---

### 9. ⚠️ VERIFICACIÓN: PLATFORM_PROFILE

**Configuración actual:** Ya está incluida correctamente

**Valores según tlp-stat:**
```
/sys/firmware/acpi/platform_profile_choices = low-power balanced performance
```

Tu laptop soporta los tres perfiles. ✅ Correcto.

**Mi configuración:**
```bash
PLATFORM_PROFILE_ON_AC=balanced        # ✅ Correcto
PLATFORM_PROFILE_ON_BAT=low-power      # ✅ Correcto
PLATFORM_PROFILE_ON_SAV=low-power      # ✅ Correcto
```

**Nota sobre la documentación:** Los defaults de TLP son:
- AC: performance
- BAT: balanced
- SAV: low-power

**Mi elección de `balanced` en AC en lugar de `performance`:**
- `performance` puede hacer que los ventiladores corran más fuerte
- `balanced` da excelente rendimiento sin ruido excesivo
- Para trabajo normal, `balanced` es más que suficiente

**Decisión:** Mantener mi configuración actual (balanced/low-power/low-power).

---

## PARÁMETROS CORRECTAMENTE OMITIDOS

Estos parámetros están bien sin configurar porque:

### DISK_SPINDOWN_TIMEOUT
- Solo relevante para discos mecánicos (HDD)
- Tu laptop tiene NVMe SSD
- ✅ Correcto no configurar

### DISK_IOSCHED
- El kernel moderno usa buenos defaults (mq-deadline para NVMe)
- Solo cambiar si tienes problemas específicos de I/O
- ✅ Correcto no configurar

### DISK_DEVICES
- TLP auto-detecta discos correctamente
- ✅ Correcto no configurar

### BAY_POWEROFF
- Tu laptop no tiene UltraBay/MediaBay
- ✅ Correcto no configurar

### RADEON_DPM_* y AMDGPU_ABM_*
- No tienes GPU AMD
- ✅ Correcto no configurar

---

## CONFIGURACIÓN DEFINITIVA MEJORADA

Basado en este análisis exhaustivo, aquí están los cambios que debemos hacer:

### AGREGAR a todos los archivos de configuración:

1. **CPU_HWP_DYN_BOOST** - CRÍTICO para tu CPU
2. **AHCI_RUNTIME_PM** - IMPORTANTE para tu NVMe
3. **NMI_WATCHDOG** - Ser explícitos sobre deshabilitar
4. **SOUND_POWER_SAVE_ON_AC** - Cambiar de 0 a 1

### MANTENER sin cambios:

- ✅ CPU_ENERGY_PERF_POLICY
- ✅ CPU_MAX_PERF
- ✅ CPU_BOOST
- ✅ PLATFORM_PROFILE
- ✅ Configuración de batería (START/STOP_CHARGE_THRESH)
- ✅ PCIE_ASPM
- ✅ RUNTIME_PM
- ✅ USB_AUTOSUSPEND
- ✅ WIFI_PWR
- ✅ SATA_LINKPWR

### CORREGIDO:

- ✅ INTEL_GPU_* (ya corregido - ahora comentado)

---

## IMPACTO ESPERADO DE LOS CAMBIOS

### Con la configuración mejorada:

| Parámetro | Ahorro Estimado | Mejora Funcional |
|-----------|----------------|------------------|
| CPU_HWP_DYN_BOOST | Menor (~0.2W) | ✅ Mejor respuesta interactiva en AC |
| AHCI_RUNTIME_PM | 0.5-1W | ✅ NVMe entra en bajo consumo |
| NMI_WATCHDOG=0 | 0.5-1W | ✅ CPU accede a C-states profundos |
| SOUND_POWER_SAVE_ON_AC=1 | ~0.1W | - |

**Total adicional:** ~1-2W de ahorro en idle

**Consumo esperado final:**
- **AC idle:** 10-13W (vs 15-16W original)
- **BAT idle:** 5-7W (vs 16W original)  
- **SAV idle:** 4-6W (vs 16W original)

---

## RESUMEN DE DECISIONES

### ✅ AGREGAR:
1. CPU_HWP_DYN_BOOST (3 valores: AC/BAT/SAV)
2. AHCI_RUNTIME_PM (2 valores: AC/BAT)
3. AHCI_RUNTIME_PM_TIMEOUT (1 valor global)
4. NMI_WATCHDOG (1 valor global)

### ✅ MODIFICAR:
1. SOUND_POWER_SAVE_ON_AC: 0 → 1

### ✅ MANTENER SIN CONFIGURAR (usar defaults):
1. CPU_DRIVER_OPMODE (kernel auto-selecciona 'active')
2. MEM_SLEEP (usar s2idle que ya funciona)
3. DISK_APM_LEVEL (no aplica a NVMe)
4. RUNTIME_PM_DRIVER_DENYLIST (default funciona bien)

### ✅ YA CORREGIDO:
1. INTEL_GPU_* (ahora comentado correctamente)

---

## CONCLUSIÓN

La configuración inicial que preparé era **bastante buena y cubría lo esencial** (CPU, platform profile, turbo boost, batería), pero le faltaban algunos parámetros importantes que pueden dar **1-2W adicionales de ahorro** y mejor comportamiento del sistema.

Los parámetros más importantes que faltaban eran:
1. **CPU_HWP_DYN_BOOST** - Específico para tu CPU moderna
2. **AHCI_RUNTIME_PM** - Importante para el NVMe
3. **NMI_WATCHDOG** - Detalles que importan

