#!/bin/bash

###############################################################################
#  NOME SCRIPT: nordtheme-install
#  AUTORE: ilnanny
#  Github: https://github.com/ilnanny75
#  DESCRIZIONE: Automazione post-installazione tema Nord (Aurora Palette)
###############################################################################

# --- Colori Nord ---
N8="#88C0D0" # Frost
N10="#5E81AC" # Arctic Ocean
N13="#EBCB8B" # Aurora Yellow
N14="#A3BE8C" # Aurora Green
NC="\033[0m"

echo -e "${N10}>>> Avvio installazione Nord Theme (Solo Sistema) <<<${NC}"

# 1. Cartelle di base
mkdir -p ~/.themes ~/.icons

# 2. Download Temi GTK (Nordic)
if [ ! -d "$HOME/.themes/Nordic" ]; then
    echo -e "${N8}[*] Scaricamento tema Nordic GTK...${NC}"
    git clone https://github.com/EliverLara/Nordic.git ~/.themes/Nordic
else
    echo -e "${N14}[V] Tema Nordic già presente.${NC}"
fi

# 3. Download Icone (Nordic Folders / Papirus Nord)
if [ ! -d "$HOME/.icons/Nordic-Folders" ]; then
    echo -e "${N8}[*] Scaricamento icone Nordic...${NC}"
    git clone https://github.com/EliverLara/Nordic-Folders.git ~/.icons/Nordic-Folders
else
    echo -e "${N14}[V] Icone Nordic già presenti.${NC}"
fi

# 4. Applicazione dei temi al sistema (XFCE)
echo -e "${N13}[!] Applicazione impostazioni XFCE...${NC}"
xfconf-query -c xsettings -p /Net/ThemeName -s "Nordic"
xfconf-query -c xfwm4 -p /general/theme -s "Nordic"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Nordic-Folders"

echo -e "${N14}>>> Installazione completata! <<<${NC}"
echo -e "I tuoi file di Geany non sono stati toccati."
