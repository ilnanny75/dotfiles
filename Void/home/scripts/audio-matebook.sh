#!/bin/bash
#==========================================================
#  VOID LINUX - MATEBOOK ES8336 ULTIMATE FIXER
#  Target: Huawei MateBook + Void Linux + XFCE
#==========================================================

# Colori
VERDE='\033[0;32m'
ROSSO='\033[0;31m'
GIALLO='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Controllo Root
if [ "$EUID" -ne 0 ]; then
    echo -e "${GIALLO}Richiesti privilegi di root...${NC}"
    sudo "$0" "$@"
    exit $?
fi

echo -e "${CYAN}Inizio configurazione specifica per Void Linux...${NC}"

# 1. Installazione pacchetti XBPS
echo -e "${GIALLO}1/5 Installazione Driver e Pipewire...${NC}"
xbps-install -Sy sof-firmware alsa-ucm-conf alsa-utils pipewire wireplumber alsa-plugins-pulseaudio

# 2. Configurazione GRUB
echo -e "${GIALLO}2/5 Configurazione Parametri Kernel...${NC}"
if ! grep -q "snd_intel_dspcfg.dsp_driver=1" /etc/default/grub; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="snd_intel_dspcfg.dsp_driver=1 /' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    echo -e "${VERDE}GRUB aggiornato.${NC}"
else
    echo -e "${VERDE}GRUB già configurato.${NC}"
fi

# 3. Permessi Utente
REAL_USER=$(logname)
echo -e "${GIALLO}3/5 Aggiunta utente $REAL_USER ai gruppi audio...${NC}"
gpasswd -a $REAL_USER audio
gpasswd -a $REAL_USER video

# 4. Configurazione Avvio (XFCE / .xinitrc)
echo -e "${GIALLO}4/5 Configurazione avvio Pipewire...${NC}"
XINIT_FILE="/home/$REAL_USER/.xinitrc"
if [ ! -f "$XINIT_FILE" ]; then
    touch "$XINIT_FILE"
    chown $REAL_USER:$REAL_USER "$XINIT_FILE"
fi

# Aggiunge i comandi Pipewire se non ci sono
for cmd in "pipewire" "pipewire-pulse" "wireplumber"; do
    if ! grep -q "$cmd" "$XINIT_FILE"; then
        echo "$cmd &" >> "$XINIT_FILE"
    fi
done

# 5. Fix Canali Audio (Quello che hai scoperto tu!)
echo -e "${GIALLO}5/5 Pulizia canali mixer (Mute S/PDIF e canali secondari)...${NC}"
# Questo comando usa amixer per replicare quello che hai fatto tu in AlsaMixer
amixer -c 0 set Headphone 100% unmute 2>/dev/null
amixer -c 0 set Speaker mute 2>/dev/null
amixer -c 0 set 'S/PDIF' mute 2>/dev/null
amixer -c 0 set 'S/PDIF 1' mute 2>/dev/null
amixer -c 0 set 'S/PDIF 2' mute 2>/dev/null
# Salviamo la configurazione
alsactl store

echo -e "${VERDE}=============================================="
echo -e "         OPERAZIONE COMPLETATA!               "
echo -e "==============================================${NC}"
echo -e "1. Controlla con 'cat /proc/cmdline' dopo il riavvio."
echo -e "2. Assicurati che DBus sia attivo (sudo ln -s /etc/sv/dbus /var/service/)."
echo -e "3. Riavvia ora il sistema."