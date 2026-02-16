# Technical Analysis - TLP Configuration

Detailed explanation of configuration decisions and hardware-specific optimizations.

---

## 🖥️ Hardware Specifications

### Intel Core Ultra 5 125U (Meteor Lake)

**Architecture:**
- 12 total cores:
  - 2 P-cores (Performance): 1.3 GHz base → 4.3 GHz turbo (with Hyper-Threading)
  - 8 E-cores (Efficient): 800 MHz base → 3.6 GHz turbo
  - 2 LP E-cores (Low Power Efficient): 700 MHz base → 2.1 GHz turbo
- 14 total threads (only P-cores have HT)
- 12 MB L3 Cache

**Power Consumption:**
- **Processor Base Power:** 15W (OEM configured nominal TDP)
- **Maximum Turbo Power:** 57W (PL2 - short performance bursts)
- **Minimum Assured Power:** 12W (guaranteed minimum consumption)

**Relevant Features for TLP:**
- ✅ Supports intel_pstate driver in active mode (HWP - Hardware P-States)
- ✅ Supports EPP (Energy Performance Preference) - HWP.EPP
- ✅ Supports Turbo Boost 2.0
- ✅ Supports HWP Dynamic Boost
- ✅ Does NOT support EPB (because it has EPP, they're mutually exclusive)

**Integrated GPU:**
- Intel Arc Graphics (4-cores)
- Frequencies: 800 MHz min → 1850 MHz max
- Based on Xe-LPG architecture

---

## 🔑 Key Configuration Parameters

### 1. CPU_ENERGY_PERF_POLICY (EPP)

**What it is:** Energy Performance Preference for CPUs with HWP support.

**Available values (in order of increasing power saving):**
- `performance` - Maximum performance, high consumption
- `balance_performance` - Good performance with moderate consumption
- `default` - Kernel default (translates to balance_performance)
- `balance_power` - Balance favoring power saving
- `power` - Maximum power saving

**Our configuration:**
- AC: `balance_performance` (good performance without excessive heat)
- BAT: `power` (aggressive power saving)
- SAV: `power` (maximum power saving)

**Why this matters:** EPP is THE most important parameter for modern Intel CPUs. Has more impact than frequency scaling or governors.

---

### 2. CPU_MAX_PERF

**What it is:** Performance limit as percentage of total available.

**How it works:** Limits maximum P-state CPU can reach. At 80%, CPU won't use more than 80% of its maximum capacity, which in practice means lower maximum frequencies.

**Our configuration:**
- AC: `100%` (no limits)
- BAT: `80%` (limit to ~3.0-3.2 GHz max)
- SAV: `50%` (limit to ~1.8-2.0 GHz max) - *customized from default 40%*

**Impact:** Direct control over maximum CPU performance and consumption.

---

### 3. CPU_BOOST

**What it is:** Turbo Boost control (Intel) / Core Performance Boost (AMD).

**How it works:** 
- `0` = disable (CPU limited to base frequencies)
- `1` = allow (CPU can exceed base frequency if thermal/power budget available)

**Our configuration:**
- AC: `1` (enabled - allow turbo up to 4.3 GHz)
- BAT: `0` (disabled - stay at more efficient frequencies)
- SAV: `0` (disabled)

**Why disable on battery:** Turbo boost is the #1 battery life enemy. Consumes disproportionately more power for relatively small performance gain.

**Impact:** Disabling turbo on battery can save 40-50% consumption in CPU-intensive tasks.

---

### 4. CPU_HWP_DYN_BOOST (NEW - IMPORTANT)

**What it is:** HWP Dynamic Boost improves responsiveness by dynamically raising minimum P-state when a task previously waiting on I/O becomes runnable.

**Requirements:** Intel Core i 6th gen or newer with intel_pstate in active mode.

**Our configuration:**
- AC: `1` (enabled - better interactive response)
- BAT: `0` (disabled - avoid unnecessary consumption spikes)
- SAV: `0` (disabled)

**Why it matters:** Specific to modern CPUs with HWP. Many configurations miss this parameter.

**Impact:** ~0.2W savings on battery + better responsiveness on AC.

---

### 5. PLATFORM_PROFILE

**What it is:** System-wide operating profile affecting not just CPU but entire platform (I/O controllers, memory, firmware).

**Available options on ThinkPad E14 Gen 6:**
- `performance` - Maximum performance
- `balanced` - Balance between performance and consumption
- `low-power` - Maximum power saving

**Our configuration:**
- AC: `balanced` (good performance without excessive fan noise)
- BAT: `low-power` (maximum platform-wide savings)
- SAV: `low-power`

**Why not 'performance' on AC:** `performance` makes fans run louder and system hotter without significant real-world benefit for typical tasks.

---

### 6. AHCI_RUNTIME_PM (NEW - IMPORTANT)

**What it is:** Runtime Power Management for AHCI/NVMe controllers.

**How it works:** Allows disk controller to enter low power states when not actively reading/writing.

**Our configuration:**
- AC: `on` (disabled - better responsiveness, no wake-up latency)
- BAT: `auto` (enabled - power savings)

**Timeout:** `15` seconds of inactivity before suspending

**Impact:** 0.5-1W savings when disk inactive. Important for NVMe SSDs.

---

### 7. NMI_WATCHDOG

**What it is:** Non-Maskable Interrupt Watchdog for kernel debugging.

**Problem:** When enabled, constantly interrupts CPU preventing it from entering deep C-states.

**Our configuration:** `0` (disabled)

**Impact:** 0.5-1W savings by allowing deeper C-states.

**When to enable:** Only for kernel debugging. Normal users should keep disabled.

---

## 📊 Expected Results

### Power Consumption (Idle)

| Mode | Before | After | Savings |
|------|--------|-------|---------|
| AC | ~15W | ~10-13W | 20-30% |
| BAT | ~15W | ~5-7W | 60-65% |
| SAV | ~15W | ~4-6W | 70-75% |

### Battery Life (50Wh typical battery)

| Mode | Estimated Duration |
|------|-------------------|
| BAT (light use) | 6-8 hours |
| BAT (typical use) | 5-6 hours |
| SAV (light use) | 8-10 hours |

### CPU Behavior

| Mode | Typical Freq | Max Freq | Turbo | Temp (idle) |
|------|-------------|----------|-------|-------------|
| AC | 1.5-2.5 GHz | 4.3 GHz | ON | 50-55°C |
| BAT | 0.8-2.0 GHz | 3.2 GHz | OFF | 40-50°C |
| SAV | 0.8-1.5 GHz | 2.0 GHz | OFF | 40-45°C |

---

## 🔬 Why These Values

### CPU_MAX_PERF_ON_BAT=80% (not 60% or 100%)

**Why 80%:**
- Allows good burst performance when needed (3.0-3.2 GHz)
- Prevents reaching most power-hungry frequencies (>3.5 GHz)
- Good balance for daily tasks (browsing, office, programming)

**Too low (60%):** May feel sluggish for some tasks  
**Too high (90-100%):** Minimal additional savings vs BAT mode purpose

### CPU_MAX_PERF_ON_SAV=50% (customized from 40%)

**Why 50% (custom):**
- Original default was 40%
- User found 40% too restrictive for their needs
- 50% provides slightly better responsiveness while maintaining excellent savings

**Flexibility:** This is the beauty of the modular configuration - easy to customize.

---

## 🎯 Configuration Philosophy

### AC Mode: "Balanced Performance"
Not "maximum performance" but "balanced". Why?
- Most tasks don't need constant 4.3 GHz
- Fans stay quieter
- System stays cooler
- Negligible real-world performance difference for typical work

### Battery Mode: "Practical Efficiency"
Not "maximum savings" but "practical". Why?
- Still very usable for daily work
- Good battery life (6-8 hours)
- Only activate SAV when truly needed

### SAV Mode: "Emergency/Maximum Duration"
Manual activation only. Why?
- Noticeably slower - not for regular use
- For specific situations (long flight, low battery, etc.)
- User decides when to make the tradeoff

---

## 🔧 Hardware-Specific Optimizations

### For Intel Core Ultra 5 125U Specifically:

1. **HWP Dynamic Boost:** Must be configured (many guides miss this)
2. **EPP over governor:** Modern CPUs use EPP, not traditional governors
3. **Platform Profile:** Controls entire SoC, not just CPU
4. **No EPB:** This CPU uses EPP, EPB doesn't apply

### For ThinkPad E14 Gen 6 Specifically:

1. **Battery thresholds:** Supported via thinkpad_acpi
2. **No dGPU:** Only integrated graphics, no AMD/NVIDIA config needed
3. **NVMe SSD:** Runtime PM matters (not traditional disk APM)
4. **Single battery:** No BAT1 configuration needed

---

## 📚 References

- [Intel Core Ultra 5 125U Specs](https://www.intel.la/content/www/xl/es/products/sku/237330/intel-core-ultra-5-processor-125u-12m-cache-up-to-4-30-ghz/specifications.html)
- [TLP Documentation](https://linrunner.de/tlp/settings/processor.html)
- [Intel HWP Documentation](https://docs.kernel.org/admin-guide/pm/intel_pstate.html)
- [ThinkPad ACPI Documentation](https://www.kernel.org/doc/html/latest/admin-guide/laptops/thinkpad-acpi.html)

---

*Last updated: 2026-02-16*  
*Hardware: ThinkPad E14 Gen 6 - Intel Core Ultra 5 125U*
