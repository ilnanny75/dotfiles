#!/bin/bash
#==========================================================
#  O.S.      : Gnu Linux
#  Author    : Cristian Pozzessere (ilnanny)
#  D.A.Page  : http://ilnanny.deviantart.com
#  Github    : https://github.com/ilnanny75
#==========================================================

echo "--- Generazione Symlink per Icone ---"
read -p "Trascina qui la cartella dove si trovano le icone: " TARGET_DIR
cd "$TARGET_DIR" || exit

# Funzione per creare link se il file originale esiste
crea_link() {
    if [ -f "$1" ] && [ ! -L "$2" ]; then
        ln -s "$1" "$2"
        echo "Link creato: $2 -> $1"
    fi
}

# Esempi comuni (aggiungine quanti ne vuoi)
crea_link "folder.svg" "inode-directory.svg"
crea_link "folder.svg" "gnome-fs-directory.svg"
crea_link "edit-copy.svg" "gtk-copy.svg"
crea_link "edit-cut.svg" "gtk-cut.svg"
crea_link "document-properties.svg" "gtk-properties.svg"
crea_link "view-refresh.svg" "gtk-refresh.svg"

echo "Operazione completata!"
