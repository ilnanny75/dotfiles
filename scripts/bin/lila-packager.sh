#!/bin/bash

# Lila HD Icon Theme - Packager Automatizzato 2026
info_msg() { zenity --info --text="$1" --width=300; }
err_msg() { zenity --error --text="$1" --width=300; }

# 1. Controllo Sistema e Dipendenze
OS_TYPE=$(lsb_release -si 2>/dev/null || cat /etc/os-release | grep ^ID= | cut -d= -f2 | tr -d '"')

check_install() {
    if ! command -v $1 &> /dev/null; then
        zenity --question --text="Manca '$1'. Lo installiamo?" --width=300
        if [ $? -eq 0 ]; then
            pkexec apt-get update && pkexec apt-get install -y $1 || pkexec pacman -S --noconfirm $1 || pkexec dnf install -y $1
        else
            err_msg "Necessario $1 per continuare."; exit 1
        fi
    fi
}

check_install "dpkg-deb"
check_install "tar"
check_install "zenity"
if [[ "$OS_TYPE" == "MX" || "$OS_TYPE" == "debian" || "$OS_TYPE" == "ubuntu" ]]; then
    check_install "alien"
fi

# 2. Selezione Cartella
WORKDIR=$(zenity --file-selection --directory --title="Seleziona la cartella Lila-HD-icon-theme-master" --filename="$(pwd)")
if [ -z "$WORKDIR" ]; then exit 1; fi
cd "$WORKDIR"

# 3. Scelta Pacchetti
SCELTA=$(zenity --list --checklist --title="Lila HD Packager" \
    --column="Scegli" --column="Pacchetto" \
    TRUE "DEB" TRUE "TGZ" FALSE "RPM" --width=350 --height=250)

LOG_FILE="$WORKDIR/build_log.txt"
echo "--- Build Log $(date) ---" > "$LOG_FILE"

# --- LOGICA DEB ---
if [[ $SCELTA == *"DEB"* ]]; then
    mkdir -p build-deb/usr/share/icons build-deb/DEBIAN
    # USARE -a PER MANTENERE I SYMLINK TRA LE CARTELLE
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
 Includes new AI icons (ChatGPT, Gemini, Claude, Mistral).
EOF
    dpkg-deb --build build-deb lila-hd-icon-theme-2026.deb >>"$LOG_FILE" 2>&1
    rm -rf build-deb
    info_msg "DEB Creato!"
fi

# --- LOGICA TGZ ---
if [[ $SCELTA == *"TGZ"* ]]; then
    # ESCLUDERE .GIT E MANTENERE I SYMLINK
    tar --exclude=".git*" -cvzf lila-hd-icon-theme-2026.tar.gz Lila_HD* >>"$LOG_FILE" 2>&1
    info_msg "TGZ Creato!"
fi

# --- LOGICA RPM ---
if [[ $SCELTA == *"RPM"* ]]; then
    if [ -f "lila-hd-icon-theme-2026.deb" ]; then
        # Genera RPM rinominato correttamente
        pkexec alien -r -c lila-hd-icon-theme-2026.deb >>"$LOG_FILE" 2>&1
        info_msg "RPM Creato da DEB!"
    else
        err_msg "Crea prima il DEB!"
    fi
fi

zenity --text-info --title="Log Finale" --filename="$LOG_FILE" --width=500 --height=400
