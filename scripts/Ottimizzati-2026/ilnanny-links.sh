#!/bin/bash
#==========================================================
#  ILNANNY SYMLINK GENERATOR - 2026
#  Gestione intelligente dei collegamenti per icone
#==========================================================

# Colori
VERDE='\033[0;32m'
GIALLO='\033[1;33m'
ROSSO='\033[0;31m'
NC='\033[0m'

echo -e "${GIALLO}=== 🔗 ILNANNY ICON SYMLINKER ===${NC}"

# 1. Selezione Cartella
read -e -p "Trascina qui la cartella delle icone (es. 16x16/places): " TARGET_DIR
TARGET_DIR=$(echo $TARGET_DIR | tr -d "'")

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${ROSSO}❌ Errore: Cartella non trovata!${NC}"
    exit 1
fi

cd "$TARGET_DIR" || exit

# 2. Funzione di creazione sicura
crea_link() {
    local ORIGINALE="$1"
    local LINK="$2"

    if [ ! -f "$ORIGINALE" ]; then
        echo -e "${ROSSO}[!] Salto: $ORIGINALE non esiste.${NC}"
        return
    fi

    if [ -L "$LINK" ] || [ -f "$LINK" ]; then
        # Se esiste già, non sovrascrivere a meno che non sia un link rotto
        return
    fi

    ln -s "$ORIGINALE" "$LINK"
    echo -e "${VERDE}Link creato: $LINK -> $ORIGINALE${NC}"
}

# 3. Modalità d'uso
echo -e "\n1) Link Standard (Folder, Edit, View)"
echo "2) Link personalizzato (Nome1 Nome2)"
echo "3) Esci"
read -p "Scegli opzione: " OPT

case $OPT in
    1)
        # Blocchi standard Freedesktop
        echo -e "${GIALLO}Creazione link standard in corso...${NC}"
        crea_link "folder.svg" "inode-directory.svg"
        crea_link "folder.svg" "gnome-fs-directory.svg"
        crea_link "edit-copy.svg" "gtk-copy.svg"
        crea_link "edit-cut.svg" "gtk-cut.svg"
        crea_link "edit-paste.svg" "gtk-paste.svg"
        crea_link "document-properties.svg" "gtk-properties.svg"
        crea_link "view-refresh.svg" "gtk-refresh.svg"
        crea_link "user-desktop.svg" "desktop.svg"
        ;;
    2)
        read -p "Nome file originale (es. icon.svg): " ORIG
        read -p "Nome del nuovo link (es. icon-shortcut.svg): " LNK
        crea_link "$ORIG" "$LNK"
        ;;
    *) exit ;;
esac

echo -e "\n${VERDE}✅ Operazione completata in $TARGET_DIR${NC}"
