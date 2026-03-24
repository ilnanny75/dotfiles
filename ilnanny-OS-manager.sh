#!/bin/bash

# Percorsi Locali
DOTFILES="$HOME/dotfiles"
THEMES_REPO="$HOME/Themes"

# Colori
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}    ILNANNY OS MANAGER - Control Panel    ${NC}"
echo -e "${BLUE}==========================================${NC}"

backup_configs() {
echo -e "${YELLOW}📦 Salvataggio config in locale...${NC}"
mkdir -p "$DOTFILES/config/openbox" "$DOTFILES/config/gtk-3.0" "$DOTFILES/config/geany"
cp ~/.config/openbox/*.xml "$DOTFILES/config/openbox/" 2>/dev/null
cp ~/.config/gtk-3.0/settings.ini "$DOTFILES/config/gtk-3.0/" 2>/dev/null
cp ~/.gtkrc-2.0 "$DOTFILES/config/" 2>/dev/null
cp ~/.bashrc "$DOTFILES/config/" 2>/dev/null
echo -e "${GREEN}✅ Backup locale OK!${NC}"
}

sync_themes() {
echo -e "${YELLOW}🎨 Sincronizzazione Temi...${NC}"
mkdir -p ~/.themes ~/.vim/colors ~/.config/geany/colorschemes
# Link Temi GTK
ln -sf "$THEMES_REPO/GTK-themes/"* ~/.themes/
# Link Temi Vim
ln -sf "$THEMES_REPO/Vim-themes/"* ~/.vim/colors/
# Link Geany (cerca i .conf nelle cartelle Extra)
find "$THEMES_REPO/GTK-themes/" -name "*.conf" -path "*/geany-colors/*" -exec ln -sf {} ~/.config/geany/colorschemes/ \;
echo -e "${GREEN}✅ Temi e Link OK!${NC}"
}

echo "1) Backup & Sync (Locale)"
echo "2) Backup & Push GitHub"
echo "3) Esci"
read -p "Opzione: " opt

case $opt in
1) backup_configs; sync_themes ;;
2) backup_configs; cd "$DOTFILES" && git add . && git commit -m "Update" && git push origin main ;;
3) exit 0 ;;
*) echo "Scelta non valida" ;;
esac
