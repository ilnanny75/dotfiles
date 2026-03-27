#!/bin/bash
#==========================================================
#  ILNANNY MATEBOOK & SYSTEM MANAGER - 2026
#  Target: Huawei MateBook (Audio ES8336) & System Maintenance
#==========================================================

# Colori
VERDE='\033[0;32m'
ROSSO='\033[0;31m'
GIALLO='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Funzione per i privilegi di root
check_root() {
if [ "$EUID" -ne 0 ]; then
echo -e "${GIALLO}Richiesti privilegi di root...${NC}"
exec sudo "$0" "$@"
fi
}

# --- 🔊 FIX AUDIO MATEBOOK (ES8336) ---
fix_audio() {
check_root
echo -e "${CYAN}--- Configurazione Audio MateBook (ES8336) ---${NC}"

# Rilevamento Distro per firmware
if [ -f /etc/debian_version ]; then
INSTALL_CMD="apt install -y"
PKGS="firmware-sof-signed alsa-ucm-conf"
elif [ -f /etc/arch-release ]; then
INSTALL_CMD="pacman -S --noconfirm"
PKGS="sof-firmware alsa-ucm-conf"
else
echo -e "${ROSSO}Distribuzione non supportata automaticamente.${NC}"
return
fi

echo -e "${GIALLO}Installazione pacchetti necessari...${NC}"
$INSTALL_CMD $PKGS

# Modifica GRUB se non già presente
if ! grep -q "snd_intel_dspcfg.dsp_driver=1" /etc/default/grub; then
echo -e "${GIALLO}Aggiunta parametro driver al GRUB...${NC}"
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="snd_intel_dspcfg.dsp_driver=1 /' /etc/default/grub
update-grub || grub-mkconfig -o /boot/grub/grub.cfg
fi

# Caricamento forzato modulo (vecchio script audio)
if ! lsmod | grep -q snd_hda_intel; then
modprobe snd_hda_intel
fi

echo -e "${VERDE}Fix Audio completato! Riavvia per applicare le modifiche.${NC}"
}

# --- 🧹 PULIZIA SISTEMA ---
clean_all() {
check_root
echo -e "${CYAN}--- Manutenzione Disco e RAM ---${NC}"
# Pulizia cache utente
rm -rf ~/.cache/*
# Svuota Cestino
rm -rf ~/.local/share/Trash/files/*
# Svuota RAM Cache
sync && echo 3 > /proc/sys/vm/drop_caches
echo -e "${VERDE}Sistema ottimizzato e RAM svuotata.${NC}"
}

# --- 💀 KILL WINDOW ---
kill_win() {
echo -e "${GIALLO}Clicca sulla finestra da terminare (o Esc per annullare)...${NC}"
xkill || echo "Errore: xorg-xkill non trovato."
}

# --- 🔍 LISTA DRIVER ---
list_drivers() {
echo -e "${CYAN}--- Drivers in uso ---${NC}"
if command -v lshw &> /dev/null; then
lshw -short | grep -i "driver"
else
lsmod
fi
}

# --- MENU ---
clear
echo -e "${CYAN}=============================================="
echo -e "      ILNANNY MATEBOOK TOOLKIT 2026          "
echo -e "==============================================${NC}"
echo "1) [HARDWARE] Fix Audio ES8336 (MateBook)"
echo "2) [SISTEMA]  Pulizia Cache e RAM"
echo "3) [UTILITY]  Kill Window (X-Kill)"
echo "4) [INFO]     Elenca Driver in uso"
echo "5) Esci"
echo -e "${CYAN}----------------------------------------------${NC}"
read -p "Scegli un'opzione: " OPT

case $OPT in
1) fix_audio ;;
2) clean_all ;;
3) kill_win ;;
4) list_drivers ;;
5) exit 0 ;;
*) echo "Scelta non valida." ;;
esac
