#!/bin/bash
#==========================================================
# ILNANNY BOOTSTRAP 2026 - Installatore Universale
# Supporta: Debian, MX Linux, Arch Linux
#==========================================================

# Colori
VERDE='\033[0;32m'
ROSSO='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=== 🛠️ INIZIO PREPARAZIONE LABORATORIO ILNANNY ===${NC}"

# 1. Rilevamento Distribuzione
if [ -f /etc/debian_version ]; then
    PM="sudo apt"
    INSTALL_CMD="install -y"
    echo -e "${VERDE}[OK] Sistema Debian-based rilevato.${NC}"
elif [ -f /etc/arch-release ]; then
    PM="sudo pacman"
    INSTALL_CMD="-S --noconfirm"
    echo -e "${VERDE}[OK] Sistema Arch Linux rilevato.${NC}"
else
    echo -e "${ROSSO}[!] Distro non supportata automaticamente. Usa apt o pacman manualmente.${NC}"
    exit 1
fi

# 2. Lista Applicazioni Necessarie (Aggiungi qui quelle che vuoi)
APPS=(
    "zenity"       # Per i popup delle tue azioni Thunar
    "catfish"      # Per la ricerca file
    "imagemagick"  # Per PNG 2 JPG (comando convert)
    "inkscape"     # Per Svg2Png
    "vlc"          # Per i file multimediali
    "xterm"        # Per eseguire i tuoi script
    "git"          # Per gestire i dotfiles
    "geany"        # Il tuo editor preferito
    "scour"        # Per l'ottimizzatore SVG
    "curl"         # Per scaricare dati
)

echo -e "${CYAN}--- Controllo e Installazione Software ---${NC}"

for app in "${APPS[@]}"; do
    if command -v "$app" &> /dev/null; then
        echo -e "${VERDE}[V] $app è già installato.${NC}"
    else
        echo -e "${ROSSO}[ ] $app manca. Installazione in corso...${NC}"
        $PM $INSTALL_CMD "$app"
    fi
done

echo -e "${CYAN}--- Configurazione Link Simbolici ---${NC}"
# Qui colleghiamo il .bashrc se non è già linkato
if [ ! -L ~/.bashrc ]; then
    echo "Creazione link simbolico per .bashrc..."
    mv ~/.bashrc ~/.bashrc.bak
    ln -s ~/dotfiles/bash/etc_bash/bashrc_master ~/.bashrc
fi

echo -e "${VERDE}✅ LABORATORIO PRONTO! Riavvia il terminale.${NC}"
