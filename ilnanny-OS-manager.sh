#!/bin/bash

# --- COLORI ---
VERDE='\033[0;32m'
BLU='\033[0;34m'
GIALLO='\033[1;33m'
ROSSO='\033[0;31m'
NC='\033[0m'

# --- LISTA SOFTWARE ---
APPS="zenity imagemagick inkscape gtklp curl wget xterm vlc catfish openbox obconf obmenu-generator tint2 lxappearance feh nitrogen lxsession-logout"

# --- FUNZIONI ---
header() {
    clear
    echo -e "${BLU}===============================================${NC}"
    echo -e "${BLU}      ilnanny MASTER DOTFILES MANAGER 2026     ${NC}"
    echo -e "${BLU}===============================================${NC}"
}

# Funzione per il backup intelligente: copia solo se NON è un link
smart_cp() {
    local sorgente=$1
    local destinazione=$2
    if [ -e "$sorgente" ]; then
        if [ ! -L "$sorgente" ]; then
            cp -r "$sorgente" "$destinazione"
            echo -e "${VERDE}  [OK]${NC} Salvato: $(basename "$sorgente")"
        else
            echo -e "${GIALLO}  [SKIP]${NC} $(basename "$sorgente") è già un link attivo."
        fi
    fi
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
        echo -e "${GIALLO}--> Applicazione Link Simbolici (Restore)...${NC}"

        # 1. BASH
        ln -sf ~/dotfiles/bash/etc_bash/bashrc ~/.bashrc

        # 2. THUNAR
        mkdir -p ~/.config/Thunar
        ln -sf ~/dotfiles/config/Thunar/uca.xml ~/.config/Thunar/uca.xml
        ln -sf ~/dotfiles/config/Thunar/accels.scm ~/.config/Thunar/accels.scm
        ln -sf ~/dotfiles/config/Thunar/renamerrc ~/.config/Thunar/renamerrc

        # 3. XFCE
        xfconfd --terminate 2>/dev/null
        mkdir -p ~/.config/xfce4
        ln -sf ~/dotfiles/config/xfce4/xfconf ~/.config/xfce4/xfconf

        # 4. GEANY (Config e Temi)
        mkdir -p ~/.config/geany/colorschemes
        ln -sf ~/dotfiles/config/geany/geany.conf ~/.config/geany/geany.conf
        ln -sf ~/dotfiles/themes/geany/*.conf ~/.config/geany/colorschemes/

        # 5. OPENBOX (Config e Temi)
        mkdir -p ~/.config/openbox
        mkdir -p ~/.themes
        ln -sf ~/dotfiles/config/openbox/rc.xml ~/.config/openbox/rc.xml
        ln -sf ~/dotfiles/config/openbox/menu.xml ~/.config/openbox/menu.xml
        # Link per ogni cartella tema trovata nel repo themes
        for tema in ~/dotfiles/themes/openbox/*/; do
            [ -d "$tema" ] && ln -sf "$tema" ~/.themes/$(basename "$tema")
        done

        # 6. SCRIPTS PERSONALI
        mkdir -p ~/bin
        ln -sf ~/dotfiles/scripts/bin/* ~/bin/

        echo -e "${VERDE}✔ Sistema ripristinato correttamente!${NC}"
        ;;

    2)
        header
        echo -e "${BLU}--> Salvataggio configurazioni nel repo (Backup)...${NC}"

        # Thunar
        mkdir -p ~/dotfiles/config/Thunar
        smart_cp ~/.config/Thunar/uca.xml ~/dotfiles/config/Thunar/
        smart_cp ~/.config/Thunar/renamerrc ~/dotfiles/config/Thunar/
        smart_cp ~/.config/Thunar/accels.scm ~/dotfiles/config/Thunar/

        # XFCE
        mkdir -p ~/dotfiles/config/xfce4
        smart_cp ~/.config/xfce4/xfconf ~/dotfiles/config/xfce4/

        # Geany
        mkdir -p ~/dotfiles/config/geany
        smart_cp ~/.config/geany/geany.conf ~/dotfiles/config/geany/

        # Openbox
        mkdir -p ~/dotfiles/config/openbox
        smart_cp ~/.config/openbox/rc.xml ~/dotfiles/config/openbox/
        smart_cp ~/.config/openbox/menu.xml ~/dotfiles/config/openbox/

        echo -e "\n${VERDE}✔ Backup completato. I file sono al sicuro nel repo.${NC}"
        ;;

    3)
        header
        echo -e "${ROSSO}--> Pulizia file obsoleti...${NC}"
        rm -v ~/dotfiles/install.sh ~/dotfiles/ilnanny-setup.sh ~/dotfiles/scripts/bin/ilnanny-bootstrap.sh 2>/dev/null
        echo -e "${VERDE}✔ Pulizia completata.${NC}"
        ;;

    *)
        header
        echo "Uscita..."
        exit 0
        ;;
esac
