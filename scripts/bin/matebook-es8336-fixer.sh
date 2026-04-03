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

# --- UTILITY: installa pacchetti in base alla distro ---
install_pkgs() {
    local pkgs="$*"
    case $DISTRO in
        arch)    pacman -Sy --noconfirm --needed $pkgs ;;
        debian)  apt update && apt install -y $pkgs ;;
        void)    xbps-install -Sy $pkgs ;;
    esac
}

# --- 🔊 FIX AUDIO MATEBOOK (ES8336) ---
fix_audio() {
    clear
    echo -e "${CYAN}=========================================="
    echo -e "   Fix Audio MateBook ES8336 / SOF-CML    "
    echo -e "==========================================${NC}"
    echo -e "${GIALLO}Sistema rilevato: $DISTRO${NC}"
    echo ""

    # --- Step 1: pacchetti firmware e UCM ---
    echo -e "${CYAN}[1/6] Installazione firmware SOF e alsa-ucm-conf...${NC}"
    case $DISTRO in
        arch)
            install_pkgs sof-firmware alsa-ucm-conf alsa-utils
            ;;
        debian)
            install_pkgs firmware-sof-signed alsa-ucm-conf alsa-utils
            ;;
        void)
            install_pkgs sof-firmware alsa-ucm-conf alsa-utils
            ;;
        *)
            echo -e "${ROSSO}Distribuzione non supportata automaticamente.${NC}"
            read -rp "Premi Invio per tornare al menu..."
            return
            ;;
    esac

    # --- Step 2: controllo ABI mismatch firmware SOF vs kernel ---
    echo ""
    echo -e "${CYAN}[2/6] Controllo ABI SOF firmware vs kernel...${NC}"
    ABI_MISMATCH=$(sudo dmesg 2>/dev/null | grep -i "sof" | grep "ABI" | grep -v "Kernel ABI" | \
        awk '/Firmware: ABI/{fw=$4} /Kernel ABI/{ker=$4; if(fw!=ker) print "MISMATCH: firmware="fw" kernel="ker}' | head -1)
    if [ -n "$ABI_MISMATCH" ]; then
        echo -e "${ROSSO}Attenzione: $ABI_MISMATCH${NC}"
        echo -e "${GIALLO}Il firmware SOF è disallineato rispetto al kernel. Aggiorna il firmware (già fatto sopra) e riavvia.${NC}"
    else
        echo -e "${VERDE}ABI SOF OK (o non rilevabile senza dmesg root).${NC}"
    fi

    # --- Step 3: parametro GRUB dsp_driver=1 ---
    echo ""
    echo -e "${CYAN}[3/6] Configurazione parametro GRUB (snd_intel_dspcfg.dsp_driver=1)...${NC}"
    if [ -f /etc/default/grub ]; then
        if ! grep -q "snd_intel_dspcfg.dsp_driver=1" /etc/default/grub; then
            sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="snd_intel_dspcfg.dsp_driver=1 /' /etc/default/grub
            case $DISTRO in
                debian) update-grub ;;
                arch|void) grub-mkconfig -o /boot/grub/grub.cfg ;;
            esac
            echo -e "${VERDE}Parametro GRUB aggiunto e grub aggiornato.${NC}"
        else
            echo -e "${VERDE}Parametro GRUB già presente, nessuna modifica.${NC}"
        fi
    else
        echo -e "${GIALLO}File /etc/default/grub non trovato, salto configurazione GRUB.${NC}"
    fi

    # --- Step 4: rilevamento e impostazione sink Speaker come default ---
    echo ""
    echo -e "${CYAN}[4/6] Rilevamento sink Speaker ES8336 e impostazione come default...${NC}"

    # Cerca il sink Speaker (non HDMI) tra quelli disponibili
    SPEAKER_SINK=$(pactl list sinks short 2>/dev/null | grep -i "speaker" | grep -v -i "hdmi" | awk '{print $2}' | head -1)

    if [ -n "$SPEAKER_SINK" ]; then
        echo -e "${VERDE}Sink Speaker trovato: $SPEAKER_SINK${NC}"

        # Imposta default runtime
        sudo -u "${SUDO_USER:-$USER}" pactl set-default-sink "$SPEAKER_SINK" 2>/dev/null || \
            PULSE_RUNTIME_PATH="/run/user/$(id -u "${SUDO_USER:-$(logname 2>/dev/null)}")/pulse" \
            pactl set-default-sink "$SPEAKER_SINK" 2>/dev/null

        # Rendi persistente per PipeWire/PulseAudio
        REAL_USER="${SUDO_USER:-$(logname 2>/dev/null)}"
        REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

        # PulseAudio
        PA_DEFAULT_DIR="$REAL_HOME/.config/pulse"
        mkdir -p "$PA_DEFAULT_DIR"
        echo "set-default-sink $SPEAKER_SINK" > "$PA_DEFAULT_DIR/default.pa.d/speaker-default.pa" 2>/dev/null || \
            echo "set-default-sink $SPEAKER_SINK" >> "$PA_DEFAULT_DIR/default.pa"
        chown -R "$REAL_USER":"$REAL_USER" "$PA_DEFAULT_DIR" 2>/dev/null

        # PipeWire (wireplumber)
        WP_DIR="$REAL_HOME/.config/wireplumber/main.lua.d"
        mkdir -p "$WP_DIR"
        cat > "$WP_DIR/51-speaker-default.lua" <<EOF
-- Imposta speaker ES8336 come uscita default (generato da matebook-es8336-fixer.sh)
default_sink = "$SPEAKER_SINK"
EOF
        chown -R "$REAL_USER":"$REAL_USER" "$WP_DIR" 2>/dev/null

        echo -e "${VERDE}Sink default impostato e reso persistente.${NC}"
    else
        echo -e "${GIALLO}Nessun sink Speaker rilevato al momento. Riprova dopo il riavvio.${NC}"
        echo -e "${GIALLO}Sink disponibili:${NC}"
        pactl list sinks short 2>/dev/null || echo "(pactl non disponibile)"
    fi

    # --- Step 5: unmute e volume al massimo ---
    echo ""
    echo -e "${CYAN}[5/6] Unmute e volume speaker al 100%...${NC}"
    REAL_USER="${SUDO_USER:-$(logname 2>/dev/null)}"
    if [ -n "$SPEAKER_SINK" ]; then
        sudo -u "$REAL_USER" pactl set-sink-mute "$SPEAKER_SINK" 0 2>/dev/null
        sudo -u "$REAL_USER" pactl set-sink-volume "$SPEAKER_SINK" 65536 2>/dev/null
        echo -e "${VERDE}Unmute applicato.${NC}"
    else
        echo -e "${GIALLO}Sink non trovato, salto unmute.${NC}"
    fi

    # --- Step 6: test audio ---
    echo ""
    echo -e "${CYAN}[6/6] Test audio con speaker-test...${NC}"
    if command -v speaker-test &>/dev/null; then
        echo -e "${GIALLO}Esecuzione test audio per 3 secondi (canale sinistro/destro)...${NC}"
        sudo -u "$REAL_USER" speaker-test -t wav -c 2 -l 1 2>/dev/null &
        SPKTEST_PID=$!
        sleep 4
        kill $SPKTEST_PID 2>/dev/null
    else
        echo -e "${GIALLO}speaker-test non trovato, installa alsa-utils per il test.${NC}"
    fi

    echo ""
    echo -e "${VERDE}============================================${NC}"
    echo -e "${VERDE}  Fix completato!${NC}"
    echo -e "${GIALLO}  Riavvia il sistema per applicare tutti${NC}"
    echo -e "${GIALLO}  i cambiamenti (GRUB + firmware SOF).${NC}"
    echo -e "${VERDE}============================================${NC}"
    read -rp "Premi Invio per tornare al menu..."
}

# --- 🧹 PULIZIA SISTEMA ---
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
