#!/bin/bash

# Lila HD Icon Theme - Packager V2 (2026)
# Più pulito, più alto, più intelligente.

info_msg() { zenity --info --text="$1" --width=350; }
err_msg() { zenity --error --text="$1" --width=350; }

# 1. Capisce dove si trova (niente più domande!)
WORKDIR="$(cd "$(dirname "$0")" && pwd)"
cd "$WORKDIR"

# 2. Controllo Dipendenze
check_install() {
    if ! command -v $1 &> /dev/null; then
        zenity --question --text="Manca '$1'. Lo installiamo?" --width=300
        if [ $? -eq 0 ]; then
            pkexec apt-get update && pkexec apt-get install -y $1 || pkexec pacman -S --noconfirm $1
        fi
    fi
}
check_install "dpkg-deb"; check_install "tar"; check_install "alien"; check_install "zenity"

# 3. Finestra di Scelta (PIÙ ALTA)
SCELTA=$(zenity --list --checklist --title="Lila HD Packager V2" \
    --column="Scegli" --column="Pacchetto da creare" \
    TRUE "DEB (Debian/Ubuntu/MX)" \
    TRUE "TGZ (Universale)" \
    TRUE "RPM (Fedora/SUSE via Alien)" \
    --width=450 --height=400) # Altezza aumentata significativamente

if [ -z "$SCELTA" ]; then exit 1; fi

# 4. Preparazione Cartella Export
EXPORT_DIR="$WORKDIR/EXPORT_PACCHETTI"
mkdir -p "$EXPORT_DIR"
LOG_FILE="$EXPORT_DIR/build_log.txt"
echo "--- Build Log $(date) ---" > "$LOG_FILE"

# --- LOGICA DEB ---
if [[ $SCELTA == *"DEB"* ]]; then
    mkdir -p build-deb/usr/share/icons build-deb/DEBIAN
    cp -a Lila_HD* build-deb/usr/share/icons/ 2>>"$LOG_FILE"
    chmod -R 755 build-deb/usr/share/icons/
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
    dpkg-deb --build build-deb "$EXPORT_DIR/lila-hd-icon-theme-2026.deb" >>"$LOG_FILE" 2>&1
    rm -rf build-deb
fi

# --- LOGICA TGZ ---
if [[ $SCELTA == *"TGZ"* ]]; then
    tar --exclude=".git*" -cvzf "$EXPORT_DIR/lila-hd-icon-theme-2026.tar.gz" Lila_HD* >>"$LOG_FILE" 2>&1
fi

# --- LOGICA RPM ---
if [[ $SCELTA == *"RPM"* ]]; then
    DEB_FILE="$EXPORT_DIR/lila-hd-icon-theme-2026.deb"
    if [ -f "$DEB_FILE" ]; then
        cd "$EXPORT_DIR"
        pkexec alien -r -c "lila-hd-icon-theme-2026.deb" >>"$LOG_FILE" 2>&1
        cd "$WORKDIR"
    else
        err_msg "Per creare l'RPM serve prima il DEB. Riprova selezionandoli entrambi."
    fi
fi

# Pulizia finale residui
rm -rf build-deb build-rpm rpmbuild 2>/dev/null

info_msg "Lavoro terminato! Trovi tutto nella cartella:\n$EXPORT_DIR"
zenity --text-info --title="Log di Produzione" --filename="$LOG_FILE" --width=600 --height=400
