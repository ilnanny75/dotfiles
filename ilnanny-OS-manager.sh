#!/bin/bash

# --- COLORI ---
VERDE='\033[0;32m'
BLU='\033[0;34m'
GIALLO='\033[1;33m'
ROSSO='\033[0;31m'
NC='\033[0m'

# --- LISTA SOFTWARE INDISPENSABILI ---
APPS="zenity imagemagick inkscape gtklp curl wget xterm vlc catfish"

# --- FUNZIONI ---
header() {
    clear
    echo -e "${BLU}===============================================${NC}"
    echo -e "${BLU}      ilnanny MASTER DOTFILES MANAGER 2026     ${NC}"
    echo -e "${BLU}===============================================${NC}"
}

# --- MENU ---
header
echo -e "Scegli un'azione:"
echo -e "0) ${GIALLO}[PREPARE]${NC} Installa Software Indispensabili (Sudo)"
echo -e "1) ${VERDE}[RESTORE]${NC} Applica dotfiles al sistema (Link Simbolici)"
echo -e "2) ${BLU}[BACKUP]${NC} Salva config attuale nel repo dotfiles"
echo -e "3) ${ROSSO}[CLEAN]${NC} Rimuovi vecchi script duplicati"
echo -e "4) ESCI"
read -p "Opzione [0-4]: " opt

case $opt in
    0)
        header
        echo -e "${GIALLO}--> Aggiorno i repository e installo le dipendenze...${NC}"
        sudo apt update && sudo apt install -y $APPS
        echo -e "${VERDE}✔ Software installato correttamente!${NC}"
        ;;
    1)
        header
        echo -e "${GIALLO}--> Applicazione Link Simbolici...${NC}"
        # Bash
        ln -sf ~/dotfiles/bash/etc_bash/bashrc ~/.bashrc
        # Thunar
        mkdir -p ~/.config/Thunar
        ln -sf ~/dotfiles/config/Thunar/uca.xml ~/.config/Thunar/uca.xml
        ln -sf ~/dotfiles/config/Thunar/accels.scm ~/.config/Thunar/accels.scm
        ln -sf ~/dotfiles/config/Thunar/renamerrc ~/.config/Thunar/renamerrc
        # XFCE
        xfconfd --terminate 2>/dev/null
        mkdir -p ~/.config/xfce4
        ln -sf ~/dotfiles/config/xfce4/xfconf ~/.config/xfce4/xfconf
        # Scripts
        mkdir -p ~/bin
        ln -sf ~/dotfiles/scripts/bin/* ~/bin/
        echo -e "${VERDE}✔ Sistema ripristinato!${NC}"
        ;;
    2)
        header
        echo -e "${BLU}--> Salvataggio configurazioni nel repo...${NC}"
        cp ~/.config/Thunar/uca.xml ~/dotfiles/config/Thunar/
        mkdir -p ~/dotfiles/config/xfce4
        cp -r ~/.config/xfce4/xfconf ~/dotfiles/config/xfce4/
        echo -e "${VERDE}✔ Backup completato.${NC}"
        ;;
    3)
        header
        rm -v ~/dotfiles/install.sh ~/dotfiles/ilnanny-setup.sh ~/dotfiles/scripts/bin/ilnanny-bootstrap.sh 2>/dev/null
        echo -e "${VERDE}✔ Pulizia completata.${NC}"
        ;;
    *)
        exit 0
        ;;
esac
