#!/bin/bash

# Lila HD Icon Theme - Packager V3 (Marzo 2026)
# Con sistema di recupero RPM se il metodo standard fallisce.

info_msg() { zenity --info --text="$1" --width=400; }
err_msg() { zenity --error --text="$1" --width=400; }

WORKDIR="$(cd "$(dirname "$0")" && pwd)"
cd "$WORKDIR"

# 1. Scelta pacchetti (Finestra Alta)
SCELTA=$(zenity --list --checklist --title="Lila HD Packager V3" \
    --column="Scegli" --column="Pacchetto da creare" \
    TRUE "DEB (Debian/Ubuntu/MX)" \
    TRUE "TGZ (Universale)" \
    TRUE "RPM (Fedora/SUSE via Alien)" \
    --width=450 --height=450)

if [ -z "$SCELTA" ]; then exit 1; fi

EXPORT_DIR="$WORKDIR/EXPORT_PACCHETTI"
mkdir -p "$EXPORT_DIR"
LOG_FILE="$EXPORT_DIR/build_log.txt"
DEB_NAME="lila-hd-icon-theme-2026.deb"

echo "--- Build Log $(date) ---" > "$LOG_FILE"

# --- 2. CREAZIONE DEB (Base obbligatoria) ---
if [[ $SCELTA == *"DEB"* ]] || [[ $SCELTA == *"RPM"* ]]; then
    echo "[1/3] Creazione DEB..."
    mkdir -p build-deb/usr/share/icons build-deb/DEBIAN
    cp -a Lila_HD* build-deb/usr/share/icons/ 2>>"$LOG_FILE"
    cat <<EOF > build-deb/DEBIAN/control
Package: lila-hd-icon-theme
Version: 3.0-2026
Section: gnome
Priority: optional
Architecture: all
Maintainer: ilnanny75
Description: Lila HD Icon Theme (2026 Edition)
 Includes AI icons: ChatGPT, Gemini, Claude, Mistral, DeepL.
EOF
    dpkg-deb --build build-deb "$EXPORT_DIR/$DEB_NAME" >>"$LOG_FILE" 2>&1
    rm -rf build-deb
    ok_deb=true
fi

# --- 3. CREAZIONE TGZ ---
if [[ $SCELTA == *"TGZ"* ]]; then
    echo "[2/3] Creazione TGZ..."
    tar --exclude=".git*" -cvzf "$EXPORT_DIR/lila-hd-icon-theme-2026.tar.gz" Lila_HD* >>"$LOG_FILE" 2>&1
fi

# --- 4. CREAZIONE RPM (PER ULTIMO CON RECOVERY) ---
if [[ $SCELTA == *"RPM"* ]]; then
    echo "[3/3] Tentativo creazione RPM..."

    # Verifica se ALIEN è installato
    if ! command -v alien &> /dev/null; then
        err_msg "ERRORE: 'alien' non è installato. Impossibile creare l'RPM.\n\nInstallo con: sudo apt install alien"
        echo "Fallito: alien non trovato" >> "$LOG_FILE"
    else
        cd "$EXPORT_DIR"
        # TENTATIVO 1: Comando Standard
        if ! sudo alien -r -c "$DEB_NAME" >>"$LOG_FILE" 2>&1; then
            echo "Tentativo 1 fallito. Provo con il comando di emergenza (-g)..." >> "$LOG_FILE"

            # TENTATIVO 2: Comando di emergenza (Generazione directory)
            if sudo alien -r -c -g "$DEB_NAME" >>"$LOG_FILE" 2>&1; then
                info_msg "RPM generato tramite modalità emergenza (-g).\nControlla la cartella EXPORT."
            else
                err_msg "Anche il tentativo di emergenza RPM è fallito. Controlla il log."
            fi
        fi
        cd "$WORKDIR"
    fi
fi

# Pulizia finale
rm -rf build-deb build-rpm rpmbuild 2>/dev/null

info_msg "Processo terminato!\nI file sono in: $EXPORT_DIR"
zenity --text-info --title="Log Finale" --filename="$LOG_FILE" --width=600 --height=400
