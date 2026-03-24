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

backup_configs() {
    echo -e "${YELLOW}📦 Sincronizzo configurazioni...${NC}"
    mkdir -p "$DOTFILES/config/openbox" "$DOTFILES/config/gtk-3.0" "$DOTFILES/config/geany"
    cp ~/.config/openbox/*.xml "$DOTFILES/config/openbox/" 2>/dev/null
    cp ~/.config/gtk-3.0/settings.ini "$DOTFILES/config/gtk-3.0/" 2>/dev/null
    cp ~/.gtkrc-2.0 "$DOTFILES/config/" 2>/dev/null
    cp ~/.bashrc "$DOTFILES/config/" 2>/dev/null
    echo -e "${GREEN}✅ Configs salvate in dotfiles!${NC}"
}

sync_themes() {
    echo -e "${YELLOW}🎨 Sincronizzo Temi e Styles...${NC}"
    mkdir -p ~/.themes ~/.vim/colors ~/.config/geany/colorschemes
    # Link Temi GTK
    ln -sf "$THEMES_REPO/GTK-themes/"* ~/.themes/
    # Link Temi Vim
    ln -sf "$THEMES_REPO/Vim-themes/"* ~/.vim/colors/
    # Link Geany (cerca i .conf nei temi)
    find "$THEMES_REPO/GTK-themes/" -name "*.conf" -path "*/geany-colors/*" -exec ln -sf {} ~/.config/geany/colorschemes/ \;
    echo -e "${GREEN}✅ Temi, Vim e Geany pronti!${NC}"
}

upload_github() {
    echo -e "${YELLOW}☁️ Carico su GitHub...${NC}"
    cd "$DOTFILES" && git add . && git commit -m "Update $(date +%d-%m-%Y)" && git push origin main
    echo -e "${GREEN}✅ GitHub aggiornato!${NC}"
}

echo -e "1) ${BLUE}Full Sync${NC} (Backup + Link Temi)"
echo -e "2) ${YELLOW}GitHub Push${NC} (Backup + Upload)"
echo -e "3) ${GREEN}Solo Temi${NC} (Aggiorna link)"
echo -e "4) Esci"
read -p "Scegli un opzione: " opt

case $opt in
    1) backup_configs; sync_themes ;;
    2) backup_configs; upload_github ;;
    3) sync_themes ;;
    4) exit 0 ;;
    *) echo "Scelta non valida" ;;
esac
