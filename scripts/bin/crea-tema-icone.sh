#!/bin/bash
#==========================================================
#  O.S.      : Gnu Linux
#  Author    : Cristian Pozzessere (ilnanny)
#  D.A.Page  : http://ilnanny.deviantart.com
#  Github    : https://github.com/ilnanny75
#==========================================================

read -p "Inserisci il nome del nuovo tema di icone: " NOMEPETEMA

BASE_DIR="$HOME/dotfiles/graphics/icons/$NOMEPETEMA"
SIZES=("16x16" "22x22" "24x24" "32x32" "48x48" "64x64" "96x96" "128x128" "256x256" "scalable")
CATS=("actions" "animations" "apps" "categories" "devices" "emblems" "emotes" "mimetypes" "places" "status")

echo "--- Creazione struttura Freedesktop per: $NOMEPETEMA ---"

mkdir -p "$BASE_DIR/templates/guide"

for s in "${SIZES[@]}"; do
    for c in "${CATS[@]}"; do
        mkdir -p "$BASE_DIR/$s/$c"
    done
done

# Creazione file index.theme base
cat <<EOF > "$BASE_DIR/index.theme"
[Icon Theme]
Name=$NOMEPETEMA
Comment=Creato da ilnanny (Cristian Pozzessere)
Inherits=Papirus,Adwaita,hicolor
Directories=$(echo "${SIZES[@]}" | sed 's/ /,/g')
EOF

echo "Struttura completata in: $BASE_DIR"

