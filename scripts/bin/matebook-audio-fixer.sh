#!/bin/bash

# Project: MateBook Audio Fixer (ES8336)
# Repository: https://github.com/ilnanny75/matebook-audio-fixer
# License: MIT

# --- Auto-Sudo ---
if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

# --- Language Selection ---
echo "Select your language / Seleziona la lingua:"
echo "1) English  2) Italiano  3) Français  4) Español  5) Deutsch"
read -p "Option (1-5): " lang_opt

case $lang_opt in
    2) L_START="Inizio configurazione..."; L_DISTRO="Distribuzione rilevata:"; L_INST="Vuoi installare"; L_GRUB="Vuoi applicare la modifica al GRUB?"; L_REBOOT="Vuoi riavviare ora?"; L_FINISH="Operazione completata!";;
    3) L_START="Démarrage della configuration..."; L_DISTRO="Distribution détectée:"; L_INST="Voulez-vous installer"; L_GRUB="Appliquer le correctif GRUB?"; L_REBOOT="Redémarrer maintenant?"; L_FINISH="Opération terminée!";;
    4) L_START="Iniciando configuración..."; L_DISTRO="Distribución detectada:"; L_INST="¿Quieres instalar"; L_GRUB="¿Aplicar el fix de GRUB?"; L_REBOOT="¿Reiniciar ahora?"; L_FINISH="¡Operación completada!";;
    5) L_START="Konfiguration wird gestartet..."; L_DISTRO="Distribution erkannt:"; L_INST="Möchten Sie installieren"; L_GRUB="GRUB-Fix anwenden?"; L_REBOOT="Jetzt neu starten?"; L_FINISH="Vorgang abgeschlossen!";;
    *) L_START="Starting configuration..."; L_DISTRO="Detected distro:"; L_INST="Do you want to install"; L_GRUB="Apply GRUB fix?"; L_REBOOT="Reboot now?"; L_FINISH="Operation completed!";;
esac

clear
echo "======================================================"
echo "        MATEBOOK AUDIO FIXER (ES8336)                "
echo "======================================================"
echo "$L_START"

# --- Distro Detection ---
if [ -f /etc/debian_version ]; then
    DISTRO="debian"; INSTALL_CMD="apt install -y"; PKG_SOF="firmware-sof-signed"; PKG_UCM="alsa-ucm-conf"; CHECK="dpkg -l | grep"
elif [ -f /etc/arch-release ]; then
    DISTRO="arch"; INSTALL_CMD="pacman -S --noconfirm"; PKG_SOF="sof-firmware"; PKG_UCM="alsa-ucm-conf"; CHECK="pacman -Qs"
else
    echo "Distro not supported."; exit 1
fi

echo "$L_DISTRO $DISTRO"

# --- Logic ---
install_pkg() {
    if ! $CHECK "$1" > /dev/null 2>&1; then
        read -p "$L_INST $1? (y/n): " c
        [[ $c == [yYsS] ]] && $INSTALL_CMD "$1"
    fi
}

install_pkg "$PKG_SOF"
install_pkg "$PKG_UCM"

# --- GRUB ---
read -p "$L_GRUB (y/n): " g
if [[ $g == [yYsS] ]]; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="snd_intel_dspcfg.dsp_driver=3 /' /etc/default/grub
    [ "$DISTRO" == "debian" ] && update-grub || grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "======================================================"
echo "            $L_FINISH"
echo "======================================================"
read -p "$L_REBOOT (y/n): " r
[[ $r == [yYsS] ]] && reboot
