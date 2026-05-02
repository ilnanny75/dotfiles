#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Configurazione personale Desktop XFCE4 
#
# Autore: ilnanny
# Mail  : <ilnannyhack@gmail.com>
# GitHub: <https://github.com/ilnanny75>
# ═══════════════════════════════════════════════════════════════════

# --- Controllo privilegi 
if [ "$EUID" -ne 0 ]; then 
  echo -e "\033[0;33m[!] Diritti di root necessari. Richiesta password in corso...\033[0m"
  exec sudo "$0" "$@"
fi

# --- Colori Nord
N8="\033[38;2;136;192;208m"
N10="\033[38;2;94;129;172m"
N13="\033[38;2;235;203;139m"
N14="\033[38;2;163;190;140m"
NC="\033[0m"

# --- Configurazione Percorsi GLOBALI 
THEME_DIR="/usr/share/themes/Nordic"
ICONS_DIR="/usr/share/icons/Lila-HD"
NORD_REPO="https://github.com/EliverLara/Nordic.git"
LILA_REPO="https://github.com/ilnanny75/Lila-HD-Icon-Theme-Official.git"
REAL_USER=${SUDO_USER:-$USER}

echo -e "${N10}>>> Avvio setup estetico GLOBALE (Clean Install) <<<${NC}"

# 1. Installazione tema Nordic
if [ -d "$THEME_DIR" ]; then
    echo -e "${N13}[*] Rimozione vecchia versione del tema...${NC}"
    rm -rf "$THEME_DIR"
fi

echo -e "${N8}[*] Scaricamento e ottimizzazione Nordic GTK...${NC}"
# Clone mirato per evitare il warning del branch 'master'
git clone --depth 1 --branch master "$NORD_REPO" "$THEME_DIR" -q > /dev/null 2>&1

# Pulizia .git e tutto ciò che non serve a XFCE
rm -rf "$THEME_DIR/.git"
find "$THEME_DIR" -mindepth 1 -maxdepth 1 \
    ! -name 'gtk-2.0' \
    ! -name 'gtk-3.0' \
    ! -name 'gtk-4.0' \
    ! -name 'xfwm4' \
    ! -name 'index.theme' \
    -exec rm -rf {} +

chmod -R 755 "$THEME_DIR"
echo -e "${N14}[V] Tema Nordic installato.${NC}"


# 2. Installazione icone  Lila-HD
if [ -d "$ICONS_DIR" ]; then
    echo -e "${N13}[*] Aggiornamento icone Lila-HD...${NC}"
    rm -rf "$ICONS_DIR"
fi

echo -e "${N8}[*] Scaricamento globale icone Lila-HD...${NC}"
git clone --depth 1 "$LILA_REPO" "$ICONS_DIR" -q > /dev/null 2>&1
rm -rf "$ICONS_DIR/.git"
chmod -R 755 "$ICONS_DIR"
echo -e "${N14}[V] Icone e Cursore installati.${NC}"


# 3. Impostazione Utenti
echo -e "${N13}[!] Applicazione tema all'utente: $REAL_USER...${NC}"

# Funzione helper per xfconf
apply_config() {
    sudo -u "$REAL_USER" xfconf-query -c "$1" -p "$2" -s "$3" --create
}

apply_config "xsettings" "/Net/ThemeName" "Nordic"
apply_config "xsettings" "/Net/IconThemeName" "Lila-HD"
apply_config "xsettings" "/Gtk/CursorThemeName" "Lila-HD"
apply_config "xfwm4" "/general/theme" "Nordic"


# 4. Cursore Mouse
mkdir -p /usr/share/icons/default
echo -e "[Icon Theme]\nInherits=Lila-HD" > /usr/share/icons/default/index.theme

echo -e "${N14}>>> Setup ompletato ! <<<${NC}"
