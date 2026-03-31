#!/bin/bash
#==========================================================
#  ILNANNY MATEBOOK & SYSTEM MANAGER - 2026 (MULTI-DISTRO)
#  Supporto: Debian/Ubuntu, Arch Linux, Void Linux
#==========================================================

# Colori
VERDE='\033[0;32m'
ROSSO='\033[0;31m'
GIALLO='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Forza privilegi di root all'avvio
if [ "$EUID" -ne 0 ]; then
    echo -e "${GIALLO}Richiesti privilegi di root...${NC}"
    sudo "$0" "$@"
    exit $?
fi

# --- RILEVAMENTO DISTRO ROBUSTO ---
detect_distro() {
    if [ -f /etc/void-release ] || command -v xbps-install &> /dev/null; then
        DISTRO="void"
    elif [ -f /etc/arch-release ] || command -v pacman &> /dev/null; then
        DISTRO="arch"
    elif [ -f /etc/debian_version ] || command -v apt &> /dev/null; then
        DISTRO="debian"
    else
        DISTRO="unknown"
    fi
}

detect_distro

# --- 🔊 FIX AUDIO MATEBOOK (ES8336) ---
fix_audio() {
    clear
    echo -e "${CYAN}--- Configurazione Audio MateBook (ES8336) ---${NC}"
    echo -e "${GIALLO}Sistema rilevato: $DISTRO${NC}"

    case $DISTRO in
        debian)
            INSTALL_CMD="apt update && apt install -y"
            PKGS="firmware-sof-signed alsa-ucm-conf"
            UPDATE_GRUB="update-grub"
            ;;
        arch)
            INSTALL_CMD="pacman -Sy --noconfirm --needed"
            PKGS="sof-firmware alsa-ucm-conf"
            UPDATE_GRUB="grub-mkconfig -o /boot/grub/grub.cfg"
            ;;
        void)
            INSTALL_CMD="xbps-install -Sy"
            PKGS="sof-firmware alsa-ucm-conf alsa-utils"
            UPDATE_GRUB="grub-mkconfig -o /boot/grub/grub.cfg" 
            ;;
        *)
            echo -e "${ROSSO}Distribuzione non supportata automaticamente.${NC}"
            read -p "Premi Invio per tornare al menu..."
            return
            ;;
    esac

    echo -e "${GIALLO}Installazione pacchetti in corso...${NC}"
    $INSTALL_CMD $PKGS

    # Modifica GRUB
    if [ -f /etc/default/grub ]; then
        if ! grep -q "snd_intel_dspcfg.dsp_driver=1" /etc/default/grub; then
            echo -e "${GIALLO}Configurazione GRUB (snd_intel_dspcfg.dsp_driver=1)...${NC}"
            sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="snd_intel_dspcfg.dsp_driver=1 /' /etc/default/grub
            $UPDATE_GRUB || grub-mkconfig -o /boot/grub/grub.cfg
        else
            echo -e "${VERDE}Parametro GRUB già configurato.${NC}"
        fi
    fi

    modprobe snd_hda_intel 2>/dev/null
    echo -e "${VERDE}Operazione completata con successo!${NC}"
    echo -e "${GIALLO}Riavvia il computer per rendere effettivi i cambiamenti.${NC}"
    read -p "Premi Invio..."
}

# --- 🧹 PULIZIA SISTEMA ---
clean_all() {
    echo -e "${CYAN}--- Manutenzione Sistema ---${NC}"
    case $DISTRO in
        debian) apt autoremove -y && apt autoclean ;;
        arch) pacman -Sc --noconfirm ;;
        void) xbps-remove -Oy ;;
    esac
    
    rm -rf ~/.cache/*
    sync && echo 3 > /proc/sys/vm/drop_caches
    echo -e "${VERDE}Pulizia terminata.${NC}"
    read -p "Premi Invio..."
}

# --- MENU ---
while true; do
    clear
    echo -e "${CYAN}=============================================="
    echo -e "      ILNANNY MATEBOOK TOOLKIT 2026          "
    echo -e "      OS: ${GIALLO}$DISTRO${NC} (Root Active)      "
    echo -e "==============================================${NC}"
    echo "1) [HARDWARE] Fix Audio ES8336 (MateBook)"
    echo "2) [SISTEMA]  Pulizia Cache e RAM"
    echo "3) [UTILITY]  Kill Window (xkill)"
    echo "4) [INFO]     Elenca Moduli Caricati"
    echo "5) Esci"
    echo -e "${CYAN}----------------------------------------------${NC}"
    read -p "Scegli un'opzione: " OPT

    case $OPT in
        1) fix_audio ;;
        2) clean_all ;;
        3) xkill || echo -e "${ROSSO}xkill non trovato.${NC}"; sleep 2 ;;
        4) lsmod | head -n 20; read -p "Premi Invio..." ;;
        5) exit 0 ;;
        *) echo "Scelta non valida."; sleep 1 ;;
    esac
done
