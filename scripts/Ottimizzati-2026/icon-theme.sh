#!/bin/bash
#================================================
#================================================
#   O.S.      : Gnu Linux                       =
#   Author    : Cristian Pozzessere   = ilnanny =
#   D.A.Page  : http://ilnanny.deviantart.com   =
#   Github    : https://github.com/ilnanny75    =
#================================================
#   Project:    GTK & Icons Themes Installer    =
#================================================

[[ $(whoami) == 'root' ]] || exec sudo su -c "$0" root

echo "--- INSTALLATORE TEMI E ICONE ---"
read -e -p "Trascina qui la cartella contenente i temi (es. /media/Dati/Git/): " SRC_BASE

# Controllo percorsi
if [ ! -d "$SRC_BASE" ]; then
    echo "Errore: Percorso sorgente non trovato."
    exit 1
fi

echo "Installazione Temi GTK..."
cp -a -r "$SRC_BASE/GTK-themes/"* /usr/share/themes/ 2>/dev/null

echo "Installazione Icone Lila/Blender..."
# Copia selettiva per evitare errori
for folder in Blender Lila_HD; do
    if [ -d "$SRC_BASE/$folder" ]; then
        cp -a -r "$SRC_BASE/$folder"* /usr/share/icons/
    fi
done

echo "Aggiornamento database icone..."
gtk-update-icon-cache -f /usr/share/icons/Lila_HD 2>/dev/null

echo "Installazione completata!"
exit 0
