#!/bin/bash
#==========================================================
#  O.S.      : Gnu Linux - Debian/MX 2026
#  Author    : Cristian Pozzessere (ilnanny)
#  Function  : Crea struttura completa e index.theme avanzato
#==========================================================

# Colori per il terminale
VERDE='\033[0;32m'
GIALLO='\033[1;33m'
NC='\033[0m'

echo -e "${GIALLO}=== 🎨 GENERATORE TEMI ICONE ILNANNY ===${NC}"
read -p "Inserisci il nome del nuovo tema: " NOMEPETEMA

# Se l'utente non scrive nulla, usiamo un nome di default
NOMEPETEMA=${NOMEPETEMA:-"Nuovo-Tema-ilnanny"}

BASE_DIR="$HOME/dotfiles/graphics/icons/$NOMEPETEMA"
SIZES=("16x16" "22x22" "24x24" "32x32" "48x48" "64x64" "96x96" "128x128" "256x256")
CATS=("actions" "animations" "apps" "categories" "devices" "emblems" "emotes" "mimetypes" "places" "status")

echo -e "${VERDE}🚀 Creazione struttura in: $BASE_DIR${NC}"

# 1. Creazione cartelle fisiche
mkdir -p "$BASE_DIR/scalable/apps" # Scalabile è speciale
for s in "${SIZES[@]}"; do
    for c in "${CATS[@]}"; do
        mkdir -p "$BASE_DIR/$s/$c"
    done
done

# 2. Generazione index.theme PROFESSIONALE
cat <<EOF > "$BASE_DIR/index.theme"
[Icon Theme]
Name=$NOMEPETEMA
Comment=Created by ilnanny (Cristian Pozzessere) - 2026
Inherits=Papirus,Adwaita,hicolor
Example=folder

# Directory List
Directories=scalable/apps,$(echo "${SIZES[@]}" | sed 's/ /,/g' | sed 's/x/x/g')

[scalable/apps]
Size=256
Type=Scalable
MinSize=1
MaxSize=512

EOF

# 3. Aggiunta automatica delle sezioni per ogni dimensione
for s in "${SIZES[@]}"; do
    # Estraiamo solo il numero (es. da 16x16 prendiamo 16)
    VAL=$(echo $s | cut -d'x' -f1)
    for c in "${CATS[@]}"; do
        cat <<EOF >> "$BASE_DIR/index.theme"
[$s/$c]
Size=$VAL
Context=$(echo $c | sed 's/./\U&/')
Type=Fixed

EOF
    done
done

echo -e "${VERDE}✅ Struttura e index.theme completati!${NC}"
echo "Puoi iniziare a disegnare o copiare i tuoi SVG nelle cartelle."
