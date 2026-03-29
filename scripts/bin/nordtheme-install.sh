#!/bin/bash

###############################################################################
#  NOME SCRIPT: nordtheme-install
#  AUTORE: ilnanny
#  Github: https://github.com/ilnanny75
#  DESCRIZIONE: Automazione post-installazione tema Nord (Aurora Palette)
###############################################################################

# --- TAVOLOZZA COLORI NORD (AURORA) ---
N11='\033[0;31m' # Rosso (nord11) - Errori
N14='\033[0;32m' # Verde (nord14) - Successo
N13='\033[0;33m' # Giallo (nord13) - Warning
N10='\033[0;34m' # Blu (nord10)   - Info
N15='\033[0;35m' # Viola (nord15)  - Intestazione
NC='\033[0m'     # No Color

clear
echo -e "${N15}###############################################################################${NC}"
echo -e "${N15}#                                                                             #${NC}"
echo -e "${N15}#             NORD THEME INSTALLER - AURORA EDITION BY ILNANNY                #${NC}"
echo -e "${N15}#                                                                             #${NC}"
echo -e "${N15}###############################################################################${NC}"
echo ""

# 1. CONTROLLO SUDO & DISTRO (Basato su Debian/Ubuntu)
if [ "$EUID" -eq 0 ]; then
  echo -e "${N11}[!] Non eseguire come root. Lo script userà sudo quando necessario.${NC}"
  exit 1
fi

# 2. VERIFICA E INSTALLAZIONE DIPENDENZE SORGENTE
check_system_deps() {
    echo -e "${N10}[*] Verifica strumenti di base (git, curl, npm)...${NC}"
    DEPS=(git curl nodejs npm)
    for dep in "${DEPS[@]}"; do
        if ! command -v $dep &> /dev/null; then
            echo -e "${N13}[!] $dep mancante. Installazione in corso...${NC}"
            sudo apt update && sudo apt install -y $dep
        else
            echo -e "${N14}[OK] $dep presente.${NC}"
        fi
    done
}

# 3. TEMA GTK (SISTEMA DARK CON ACCENTI AURORA)
install_gtk_nordic() {
    echo -e "${N10}[*] Installazione Tema GTK Nordic (Darker)...${NC}"
    sudo apt install -y gtk2-engines-murrine gtk2-engines-pixbuf
    mkdir -p ~/.themes
    if [ ! -d "$HOME/.themes/Nordic" ]; then
        git clone https://github.com/EliverLara/Nordic.git /tmp/Nordic
        cp -r /tmp/Nordic ~/.themes/
        echo -e "${N14}[OK] Tema Nordic installato in ~/.themes${NC}"
    else
        echo -e "${N13}[-] Tema Nordic già presente.${NC}"
    fi
}

# 4. GEANY (SCHEMI COLORE)
install_geany_nord() {
    echo -e "${N10}[*] Configurazione Geany...${NC}"
    GEANY_DIR="$HOME/.config/geany/colorschemes"
    mkdir -p "$GEANY_DIR"
    curl -sLo "$GEANY_DIR/nord.conf" https://raw.githubusercontent.com/nordtheme/geany/develop/src/nord.conf
    echo -e "${N14}[OK] Schema Nord aggiunto a Geany.${NC}"
}

# 5. XFCE TERMINAL
install_xfce_terminal() {
    echo -e "${N10}[*] Configurazione XFCE Terminal...${NC}"
    XFCE_DIR="$HOME/.local/share/xfce4/terminal/colorschemes"
    mkdir -p "$XFCE_DIR"
    curl -sLo "$XFCE_DIR/nord.theme" https://raw.githubusercontent.com/nordtheme/xfce4-terminal/develop/src/nord.theme
    echo -e "${N14}[OK] Schema Nord aggiunto al terminale.${NC}"
}

# 6. SFONDO (AURORA WALLPAPER)
install_wallpaper() {
    echo -e "${N10}[*] Scaricamento Wallpaper Nord Aurora...${NC}"
    mkdir -p ~/Pictures/Wallpapers
    curl -sLo ~/Pictures/Wallpapers/nord-aurora.png https://raw.githubusercontent.com/linuxdotexe/nord-backgrounds/master/wallpapers/aurora.png
    echo -e "${N14}[OK] Wallpaper salvato in ~/Pictures/Wallpapers/nord-aurora.png${NC}"
}

# --- ESECUZIONE ---

check_system_deps

echo -e "\n${N15}--- Selezione Moduli ---${NC}"
read -p "Installare Tema GTK Nordic? (s/n): " q1
[[ $q1 == "s" ]] && install_gtk_nordic

read -p "Installare Schema per Geany? (s/n): " q2
[[ $q2 == "s" ]] && install_geany_nord

read -p "Configurare XFCE Terminal? (s/n): " q3
[[ $q3 == "s" ]] && install_xfce_terminal

read -p "Scaricare Wallpaper Nord Aurora? (s/n): " q4
[[ $q4 == "s" ]] && install_wallpaper

echo -e "\n${N14}Installazione completata con successo, ilnanny!${NC}"
echo -e "${N10}Ricorda di attivare i temi manualmente nelle impostazioni delle app.${NC}"
