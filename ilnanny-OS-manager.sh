#!/bin/bash

# Percorsi
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
    echo -e "${YELLOW}⚙️ Impostazione Geany e Defaults...${NC}"
    if ! grep -q "EDITOR='geany'" ~/.bashrc; then
        echo "export EDITOR='geany'" >> ~/.bashrc
        echo "export VISUAL='geany'" >> ~/.bashrc
    fi
    xdg-mime default geany.desktop text/plain 2>/dev/null
    echo -e "${GREEN}✅ Geany e Terminale configurati!${NC}"
}

backup_configs() {
    echo -e "${YELLOW}📦 Sincronizzo configurazioni...${NC}"
    mkdir -p "$DOTFILES/config/openbox" "$DOTFILES/config/gtk-3.0" "$DOTFILES/config/geany" "$DOTFILES/config/Thunar"
    cp ~/.config/openbox/*.xml "$DOTFILES/config/openbox/" 2>/dev/null
    cp ~/.config/gtk-3.0/settings.ini "$DOTFILES/config/gtk-3.0/" 2>/dev/null
    cp ~/.config/Thunar/uca.xml "$DOTFILES/config/Thunar/" 2>/dev/null
    cp ~/.gtkrc-2.0 "$DOTFILES/config/" 2>/dev/null
    cp ~/.bashrc "$DOTFILES/config/" 2>/dev/null
    echo -e "${GREEN}✅ Backup (incluso UCA.xml) salvato!${NC}"
}

sync_themes() {
    echo -e "${YELLOW}🎨 Sincronizzo Temi e Styles...${NC}"
    mkdir -p ~/.themes ~/.vim/colors ~/.config/geany/colorschemes
    ln -sf "$THEMES_REPO/GTK-themes/"* ~/.themes/
    ln -sf "$THEMES_REPO/Vim-themes/"* ~/.vim/colors/
    find "$THEMES_REPO/GTK-themes/" -name "*.conf" -path "*/geany-colors/*" -exec ln -sf {} ~/.config/geany/colorschemes/ \;
    echo -e "${GREEN}✅ Temi e Link pronti!${NC}"
}

echo -e "1) ${BLUE}Full Sync${NC} (Backup + Temi + Defaults)"
echo -e "2) ${YELLOW}GitHub Push${NC} (Backup + Upload)"
echo -e "3) ${GREEN}Solo Temi${NC}"
echo -e "4) Esci"
read -p "Scegli: " opt

case $opt in
    1) setup_system_defaults; backup_configs; sync_themes ;;
    2) backup_configs; cd "$DOTFILES" && git add . && git commit -m "Update $(date +%d-%m-%Y)" && git push origin main ;;
    3) sync_themes ;;
    4) exit 0 ;;
    *) echo "Scelta non valida" ;;
esac
