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
    print_error "Este script debe ejecutarse como root (con sudo)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_info "=========================================="
print_info "TLP Configuration Installation"
print_info "ThinkPad E14 Gen 6 - Core Ultra 5 125U"
print_info "=========================================="
echo ""

# Check TLP installed
print_info "Verificando instalación de TLP..."
if ! command -v tlp &> /dev/null; then
    print_error "TLP no está instalado"
    echo ""
    echo "Por favor instala TLP primero:"
    echo "  Arch Linux: sudo pacman -S tlp"
    echo "  Debian/Ubuntu: sudo apt install tlp"
    echo "  Fedora: sudo dnf install tlp"
    exit 1
fi
print_success "TLP instalado correctamente"
echo ""

# Create backup
print_info "Creando backup de configuración actual..."
BACKUP_DIR="$HOME/tlp-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f /etc/tlp.conf ]; then
    cp /etc/tlp.conf "$BACKUP_DIR/"
    print_success "Backup de /etc/tlp.conf creado"
fi

if [ -d /etc/tlp.d ] && [ "$(ls -A /etc/tlp.d)" ]; then
    cp -r /etc/tlp.d "$BACKUP_DIR/"
    print_success "Backup de /etc/tlp.d/ creado"
fi

print_success "Backup guardado en: $BACKUP_DIR"
echo ""

# Check for conflicting services
print_info "Verificando servicios conflictivos..."
CONFLICTS_FOUND=false

if systemctl is-active --quiet power-profiles-daemon; then
    print_warning "power-profiles-daemon está activo (puede conflictuar con TLP)"
    CONFLICTS_FOUND=true
fi

if [ "$CONFLICTS_FOUND" = true ]; then
    echo ""
    read -p "¿Deseas deshabilitar power-profiles-daemon? [s/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[SsYy]$ ]]; then
        systemctl stop power-profiles-daemon
        systemctl mask power-profiles-daemon
        print_success "power-profiles-daemon deshabilitado"
    else
        print_warning "ADVERTENCIA: Puede haber conflictos con power-profiles-daemon"
    fi
else
    print_success "No hay servicios conflictivos activos"
fi
echo ""

# Create tlp.d directory if doesn't exist
print_info "Preparando directorio /etc/tlp.d/..."
mkdir -p /etc/tlp.d
print_success "Directorio listo"
echo ""

# Install configuration files
print_info "Instalando archivos de configuración..."

if [ -d "$SCRIPT_DIR/tlp.d" ]; then
    cp "$SCRIPT_DIR/tlp.d"/*.conf /etc/tlp.d/
    chmod 644 /etc/tlp.d/*.conf
    print_success "Archivos de configuración instalados"
else
    print_error "Directorio tlp.d/ no encontrado"
    print_error "Asegúrate de ejecutar este script desde el directorio del repositorio"
    exit 1
fi
echo ""

# Check thinkpad_acpi module
print_info "Verificando módulo thinkpad_acpi..."
if lsmod | grep -q thinkpad_acpi; then
    print_success "Módulo thinkpad_acpi cargado"
else
    print_warning "Módulo thinkpad_acpi no está cargado"
    echo ""
    read -p "¿Deseas cargar el módulo thinkpad_acpi? [s/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[SsYy]$ ]]; then
        modprobe thinkpad_acpi
        echo "thinkpad_acpi" > /etc/modules-load.d/thinkpad.conf
        print_success "Módulo cargado y configurado para cargar en boot"
    fi
fi
echo ""

# Enable and start TLP
print_info "Habilitando y aplicando TLP..."
systemctl enable tlp.service
systemctl start tlp.service
tlp start

print_success "TLP habilitado y configuración aplicada"
echo ""

# Show status
print_info "=========================================="
print_info "INSTALACIÓN COMPLETADA"
print_info "=========================================="
echo ""

print_success "Configuración instalada exitosamente"
print_info "Backup guardado en: $BACKUP_DIR"
echo ""

print_info "Estado actual del sistema:"
echo ""
tlp-stat -s | grep -E "(System|TLP status|Power profile|Power source)"
echo ""

# Verification instructions
print_info "VERIFICACIÓN:"
echo ""
echo "1. Ver configuración de CPU:"
echo "   sudo tlp-stat -p | grep -E '(energy_performance|max_perf|no_turbo|hwp_dynamic)'"
echo ""
echo "2. Ver estado de batería:"
echo "   sudo tlp-stat -b | grep threshold"
echo ""
echo "3. Probar cambio automático:"
echo "   - Desconecta el cargador y ejecuta: sudo tlp-stat -s"
echo "   - Debe mostrar: Power profile = low-power/BAT"
echo ""
echo "4. Activar modo ultra-ahorro (manual):"
echo "   sudo tlp power-saver"
echo ""
echo "5. Forzar carga completa (bypass umbrales):"
echo "   sudo tlp fullcharge BAT0"
echo ""

print_success "¡Disfruta de tu ThinkPad optimizado!"
echo ""
print_info "Documentación completa en: docs/"
print_info "Cheatsheet de comandos: docs/CHEATSHEET.md"
