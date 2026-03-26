#!/usr/bin/env bash
#================================================
#   VOID LINUX - MASTER SCRIPT (Integrato)
#   Author: Cristian Pozzessere (ilnanny75)
#================================================

# Colori
CYAN='\033[0;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Controllo root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Errore: Devi eseguire lo script con sudo!${NC}"
  exit 1
fi

header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "║      VOID LINUX - Master Setup Interattivo         ║"
    echo -e "╚════════════════════════════════════════════════════╝${NC}"
}

# 1. FUNZIONE INSTALLAZIONE SOFTWARE (Tutti i tuoi programmi!)
install_apps() {
    echo -e "\n${YELLOW}>> Installazione software dalla tua lista...${NC}"
    # Questa è la tua lista originale integrata
    APPS=(
        android-file-transfer-linux android-tools arc-theme bash-completion
        bleachbit chromium-bsu cmake conky curl deluge dosfstools ffmpeg
        file-roller fontconfig freetype geany gparted gimp git gvfs
        gvfs-mtp htop libreoffice-writer lnt-fonts moka-icon-theme
        mpv neofetch nitrogen ntfs-3g obconf p7zip pavucontrol picom
        rofi termite tint2 vlc wget xdotool xorg-fonts
    )

    xbps-install -Sy "${APPS[@]}"
    echo -e "${GREEN}Installazione completata!${NC}"
}

# 2. AGGIORNAMENTO E PULIZIA VIM SWAP
update_and_clean() {
    echo -e "\n${YELLOW}>> Aggiornamento sistema e pulizia .swp...${NC}"
    xbps-install -Suv
    find /home/$SUDO_USER/ -type f -name ".*.swp" -delete 2>/dev/null
    echo -e "${GREEN}Fatto.${NC}"
}

# 3. GESTORE PACCHETTI INTERATTIVO (Logica xpbsui.sh)
advanced_pkg_manager() {
    if ! command -v fzf >/dev/null 2>&1; then
        xbps-install -Sy fzf
    fi
    echo -e "${GREEN}Cerca pacchetti (TAB per selezione multipla, ESC esce):${NC}"
    pkg=$(xbps-query -Rs "" | sort -u | fzf -i --multi --reverse --preview 'xbps-query -R {2}' | awk '{print $2}')
    if [ -n "$pkg" ]; then
        xbps-install -Sy $pkg
    fi
}

# 4. CONFIGURAZIONE GRUPPI (Da utenti-gruppi)
setup_user() {
    echo -e "\n${GREEN}Configurazione gruppi per: $SUDO_USER${NC}"
    GRUPPI=(audio video wheel storage input networkmanager kvm vboxusers adbusers bluetooth)
    for g in "${GRUPPI[@]}"; do
        groupadd -f "$g"
        gpasswd -a "$SUDO_USER" "$g"
    done
}

# 5. RENDI ESEGUIBILI (Da rendi-eseguibile-tutti)
make_executable() {
    local dir="/home/$SUDO_USER/Scripts"
    if [ -d "$dir" ]; then
        echo -e "${YELLOW}Rendo eseguibili gli script in $dir...${NC}"
        find "$dir" -type f \( -name "*.sh" -o -name "*-pipemenu" \) -exec chmod +x {} +
        echo -e "${GREEN}Permessi aggiornati.${NC}"
    fi
}

# --- MENU PRINCIPALE ---
while true; do
    header
    echo -e "1) ${YELLOW}Aggiorna Sistema & Pulisci Swap${NC}"
    echo -e "2) ${CYAN}INSTALLA TUTTI I TUOI SOFTWARE${NC} (Lista Personale)"
    echo -e "3) ${GREEN}CERCA/INSTALLA SINGOLI PACCHETTI (fzf)${NC}"
    echo -e "4) Configura Gruppi Utente"
    echo -e "5) Rendi Eseguibili i tuoi Script (~/Scripts)"
    echo -e "6) Installa VirtualBox"
    echo -e "7) ${RED}ESECUZIONE COMPLETA (Nuova Installazione)${NC}"
    echo -e "q) Esci"
    echo -ne "\nScegli: "
    read -r opt

    case $opt in
        1) update_and_clean ;;
        2) install_apps ;;
        3) advanced_pkg_manager ;;
        4) setup_user ;;
        5) make_executable ;;
        6) xbps-install -Sy virtualbox-ose virtualbox-ose-dkms; setup_user ;;
        7) update_and_clean; install_apps; setup_user; make_executable ;;
        q) exit 0 ;;
        *) echo "Scelta errata." ; sleep 1 ;;
    esac
    echo -e "\nPremi un tasto per il menu..."
    read -n 1
done
