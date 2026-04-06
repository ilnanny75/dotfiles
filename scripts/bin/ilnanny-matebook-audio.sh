#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: MateBook & System Manager. Fix specifico per l'audio ES8336, 
# gestione moduli kernel e pulizia profonda del sistema (cache/RAM).
# Supporta Arch, Debian e Void Linux.
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

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

# --- UTILITY: installa pacchetti in base alla distro ---
install_pkgs() {
    local pkgs="$*"
    case $DISTRO in
        arch)    pacman -Sy --noconfirm --needed $pkgs ;;
        debian)  apt update && apt install -y $pkgs ;;
        void)    xbps-install -Sy $pkgs ;;
    esac
}

# --- 🔊 FIX AUDIO MATEBOOK (ES8336) AGGIORNATO ---
fix_audio() {
    clear
    echo -e "${CYAN}=========================================="
    echo -e "   Fix Audio MateBook ES8336 / SOF-CML    "
    echo -e "==========================================${NC}"
    echo -e "${GIALLO}Sistema rilevato: $DISTRO${NC}"

    # 1. Installazione firmware corretti
    echo -e "${CYAN}[1/5] Installazione firmware SOF...${NC}"
    case $DISTRO in
        arch)   install_pkgs sof-firmware alsa-ucm-conf alsa-utils ;;
        debian) install_pkgs firmware-sof-signed alsa-ucm-conf alsa-utils ;;
        void)   install_pkgs sof-firmware alsa-ucm-conf alsa-utils ;;
    esac

    # 2. Pulizia GRUB (Rimuove il parametro che bloccava la scheda)
    echo -e "${CYAN}[2/5] Configurazione GRUB (Rimozione dsp_driver=1)...${NC}"
    if [ -f /etc/default/grub ]; then
        # Eliminiamo il parametro se presente per far caricare i driver SOF moderni
        sed -i 's/snd_intel_dspcfg.dsp_driver=1 //' /etc/default/grub
        case $DISTRO in
            debian) update-grub ;;
            arch|void) grub-mkconfig -o /boot/grub/grub.cfg ;;
        esac
    fi

    # 3. Configurazione Quirk e Moduli
    echo -e "${CYAN}[3/5] Applicazione Quirk per Speaker...${NC}"
    echo "options snd_soc_sof_8336 quirk=0x01" > /etc/modprobe.d/es8336.conf

    # 4. Gestione Init per Void Linux
    if [ "$DISTRO" == "void" ]; then
        if [ -d /etc/sv/alsa ]; then
            ln -s /etc/sv/alsa /var/service/ 2>/dev/null
        fi
    fi

    # 5. Salvataggio ALSA (Per ricordare che Speaker deve stare in MM)
    echo -e "${CYAN}[4/5] Salvataggio configurazione ALSA...${NC}"
    echo -e "${GIALLO}Nota: Imposta Speaker su MM in alsamixer se non senti nulla!${NC}"
    alsactl store

    echo -e "${VERDE}Fix completato. Riavvia per applicare le modifiche.${NC}"
    read -rp "Premi Invio per tornare al menu..."
}

# --- 🧹 PULIZIA SISTEMA (TUA FUNZIONE ORIGINALE) ---
clean_all() {
    echo -e "${CYAN}--- Manutenzione Sistema ---${NC}"
    case $DISTRO in
        debian) apt autoremove -y && apt autoclean ;;
        arch)   pacman -Sc --noconfirm ;;
        void)   xbps-remove -Oy ;;
    esac

    rm -rf ~/.cache/*
    sync && echo 3 > /proc/sys/vm/drop_caches
    echo -e "${VERDE}Pulizia terminata.${NC}"
    read -rp "Premi Invio..."
}

# --- MENU PRINCIPALE ---
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
    read -rp "Scegli un'opzione: " OPT

    case $OPT in
        1) fix_audio ;;
        2) clean_all ;;
        3) xkill || echo -e "${ROSSO}xkill non trovato.${NC}"; sleep 2 ;;
        4) lsmod | head -n 20; read -rp "Premi Invio..." ;;
        5) exit 0 ;;
        *) echo "Scelta non valida."; sleep 1 ;;
    esac
done
