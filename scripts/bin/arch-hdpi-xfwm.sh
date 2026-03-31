#!/usr/bin/env bash

# Colori per i messaggi
V="\e[32m"
C="\e[36m"
RESET="\e[0m"

echo -e "${C} Richards installazione Arc-Theme HiDPI (Bottoni Grandi)...${RESET}"

# 1. Installazione dipendenze necessarie su Void Linux
echo -e "${C} Installazione dipendenze (xbps)...${RESET}"
sudo xbps-install -Sy autoconf automake pkg-config gtk+3-devel git inkscape

# 2. Creazione cartella temporanea e download
mkdir -p /tmp/arc-hidpi
cd /tmp/arc-hidpi || exit

echo -e "${C} Scaricamento sorgenti da GitHub...${RESET}"
# Scarichiamo il repository che hai trovato
curl -L https://github.com/loichu/arc-theme-xfwm4-hidpi/archive/refs/heads/master.tar.gz | tar xz --strip-components=1

# 3. Configurazione e Compilazione
# Usiamo il prefisso ~/.local per installarlo solo per il tuo utente senza sporcare il sistema
echo -e "${C} Compilazione del tema (DPI 192)...${RESET}"
./autogen.sh --prefix="$HOME/.local" \
             --disable-cinnamon \
             --disable-gnome-shell \
             --disable-metacity \
             --disable-unity \
             --with-gnome=3.22

# 4. Installazione
make install

# 5. Pulizia
cd ~
rm -rf /tmp/arc-hidpi

echo -e "${V}✅ INSTALLAZIONE COMPLETATA!${RESET}"
echo -e "${C}-------------------------------------------------------${RESET}"
echo -e "Per attivare i bottoni grandi:"
echo -e "1. Vai in 'Impostazioni' -> 'Gestore delle Finestre'"
echo -e "2. Seleziona 'Arc-Dark' (quello installato in .local)"
echo -e "3. Aumenta il 'Carattere del titolo' a 12 o 14 per alzare la barra"
echo -e "${C}-------------------------------------------------------${RESET}"
