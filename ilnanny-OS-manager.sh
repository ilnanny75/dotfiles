#!/bin/bash
#==========================================================
#  ILNANNY OS MANAGER - 2026 EDITION (Final Fix)
#==========================================================

DOTFILES="$HOME/dotfiles"
THEMES_REPO="$HOME/Themes"

# Colori
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

clear
echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}    ILNANNY OS MANAGER - 2026 EDITION     ${NC}"
echo -e "${BLUE}==========================================${NC}"

setup_system_defaults() {
    echo -e "${YELLOW}⚙️ Configurazione Geany e Terminale...${NC}"

    # --- Fix Geany ---
    local GEANY_CONF="$HOME/.config/geany/geany.conf"
    local DOT_GEANY="$DOTFILES/config/geany/geany.conf"
    mkdir -p "$HOME/.config/geany"

    if [ -f "$DOT_GEANY" ]; then
        if [ -f "$GEANY_CONF" ] && [ ! -L "$GEANY_CONF" ]; then
            mv "$GEANY_CONF" "${GEANY_CONF}.bk"
        fi
        ln -sf "$DOT_GEANY" "$GEANY_CONF"
        echo -e "${GREEN}✅ Link Geany creato (Backup .bk salvato)${NC}"
    fi

    # --- Fix Terminale (Elimina avviso unsafe-paste) ---
    xfconf-query -c xfce4-terminal -p /unsafe-paste -n -t bool -s false 2>/dev/null
    echo -e "${GREEN}✅ Avviso 'Incolla non sicuro' rimosso per sempre!${NC}"

    # --- Defaults ---
    xdg-mime default geany.desktop text/plain 2>/dev/null
    echo -e "${GREEN}✅ Impostazioni di sistema completate!${NC}"
}

backup_configs() {
    echo -e "${YELLOW}📦 Sincronizzo configurazioni verso Dotfiles...${NC}"
    mkdir -p "$DOTFILES/config/openbox" "$DOTFILES/config/gtk-3.0" "$DOTFILES/config/geany" "$DOTFILES/config/Thunar"

    # Backup file reali nel repository
    [ -f ~/.config/openbox/rc.xml ] && cp ~/.config/openbox/*.xml "$DOTFILES/config/openbox/"
    [ -f ~/.config/Thunar/uca.xml ] && cp ~/.config/Thunar/uca.xml "$DOTFILES/config/Thunar/"
    [ -f ~/.bashrc ] && cp ~/.bashrc "$DOTFILES/config/"

    echo -e "${GREEN}✅ Backup salvato!${NC}"
}

sync_themes() {
    echo -e "${YELLOW}🎨 Sincronizzo Temi...${NC}"
    mkdir -p ~/.themes ~/.config/geany/colorschemes
    ln -sf "$THEMES_REPO/GTK-themes/"* ~/.themes/ 2>/dev/null
    echo -e "${GREEN}✅ Temi linkati!${NC}"
}

echo -e "1) ${BLUE}Configurazione Totale${NC} (Geany + Terminale + Temi)"
echo -e "2) ${YELLOW}Esegui Backup${NC}"
echo -e "3) Esci"
read -p "Scegli: " opt

case $opt in
    1) setup_system_defaults; backup_configs; sync_themes ;;
    2) backup_configs ;;
    3) exit 0 ;;
    *) echo "Scelta non valida" ;;
esac
