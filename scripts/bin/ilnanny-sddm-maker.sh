#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: SDDM Universal Maker. Genera temi personalizzati per il login 
# manager. Gestisce il ridimensionamento immagini (ImageMagick), 
# la creazione di metadati e l'anteprima in test-mode.
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# --- 1. RILEVAMENTO SISTEMA OPERATIVO ---
if [ -f /etc/arch-release ]; then
    OS="Arch"
    PKG_MGR="sudo pacman -S --needed"
    INSTALL_CMD="$PKG_MGR imagemagick xorg-xrandr"
elif [ -f /etc/debian_version ]; then
    OS="Debian"
    PKG_MGR="sudo apt update && sudo apt install -y"
    INSTALL_CMD="$PKG_MGR imagemagick x11-xserver-utils"
elif [ -f /etc/void-release ]; then
    OS="Void"
    PKG_MGR="sudo xbps-install -Sy"
    INSTALL_CMD="$PKG_MGR ImageMagick xrandr"
else
    OS="Unknown"
fi

clear
echo "============================================"
echo "   SDDM UNIVERSAL MAKER - OS: $OS"
echo "============================================"

# --- 2. CONTROLLO DIPENDENZE ---
if ! command -v identify &> /dev/null || ! command -v xrandr &> /dev/null; then
    echo "[!] Dipendenze mancanti rilevate."
    read -p "[?] Vuoi installarle ora con $OS? (s/n): " INSTALL_NOW
    if [[ "$INSTALL_NOW" == "s" ]]; then
        eval $INSTALL_CMD
    else
        echo "[!] Errore: Lo script richiede xrandr e imagemagick per funzionare."
        exit 1
    fi
fi

# --- 3. RILEVAMENTO RISOLUZIONE ---
RES=$(xrandr | grep '*' | awk '{print $1}' | head -n 1)
SCREEN_W=$(echo $RES | cut -d'x' -f1)
SCREEN_H=$(echo $RES | cut -d'x' -f2)

WORKING_DIR="$HOME/sddm_workspace"
SDDM_THEMES_DIR="/usr/share/sddm/themes"

# --- 4. CREAZIONE TEMA ---
read -p "[?] Nome del tema (es. Crucial_Lab): " THEME_NAME
FINAL_DIR="$WORKING_DIR/$THEME_NAME"
mkdir -p "$FINAL_DIR"

echo "[!] Risoluzione schermo: $RES. Formati consigliati: JPG/PNG."
read -e -p "[?] Trascina qui l'immagine di sfondo: " BG_PATH
BG_PATH=$(echo $BG_PATH | tr -d "'")

if [ -f "$BG_PATH" ]; then
    IMG_RES=$(identify -format "%wx%h" "$BG_PATH")
    IMG_W=$(echo $IMG_RES | cut -d'x' -f1)
    
    # OPZIONALE: Scurire l'immagine se troppo chiara
    read -p "[?] Vuoi scurire l'immagine del 30% per leggere meglio il login? (s/n): " DARKEN
    if [[ "$DARKEN" == "s" ]]; then
        convert "$BG_PATH" -brightness-contrast -30x0 "$FINAL_DIR/background.jpg"
        echo "[*] Immagine scurita e copiata."
    else
        cp "$BG_PATH" "$FINAL_DIR/background.jpg"
    fi
else
    echo "[!] Errore: File non trovato."
    exit 1
fi

# --- 5. GENERAZIONE FILE ---
cat <<EOF > "$FINAL_DIR/metadata.desktop"
[Appearance]
Name=$THEME_NAME
Description=Tema creato su $OS per SSD Crucial
Author=ilnanny
Screenshot=background.jpg
EOF

cat <<EOF > "$FINAL_DIR/theme.conf"
[General]
background=background.jpg
type=image
color=#ffffff
fontSize=11
EOF

# Tentativo di recuperare un Main.qml funzionante dal sistema
if [ -d "$SDDM_THEMES_DIR/debian-theme" ]; then
    cp "$SDDM_THEMES_DIR/debian-theme/Main.qml" "$FINAL_DIR/" 2>/dev/null
elif [ -d "$SDDM_THEMES_DIR/maya" ]; then
    cp "$SDDM_THEMES_DIR/maya/Main.qml" "$FINAL_DIR/" 2>/dev/null
fi

# --- 6. ANTEPRIMA E INSTALLAZIONE ---
echo "--------------------------------------------"
echo "[*] Avvio Anteprima su $OS..."
sddm-greeter --test-mode --theme "$FINAL_DIR"

read -p "[?] Ti piace? Lo installiamo nel sistema? (s/n): " INSTALLA
if [[ "$INSTALLA" == "s" ]]; then
    sudo cp -r "$FINAL_DIR" "$SDDM_THEMES_DIR/"
    
    read -p "[?] Vuoi attivarlo come predefinito in /etc/sddm.conf? (s/n): " ATTIVA
    if [[ "$ATTIVA" == "s" ]]; then
        # Nota: Alcune distro usano cartelle diverse, ma /etc/sddm.conf è lo standard
        echo -e "[Theme]\nCurrent=$THEME_NAME" | sudo tee /etc/sddm.conf
        echo "[OK] Tema impostato! Al riavvio vedrai le modifiche."
    fi
fi
