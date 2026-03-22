#!/bin/bash
#==========================================================
#  O.S.      : Gnu Linux
#  Author    : Cristian Pozzessere (ilnanny)
#  D.A.Page  : http://ilnanny.deviantart.com
#  Github    : https://github.com/ilnanny75
#==========================================================

echo "--- Controllo Qualità Tema Icone ---"
read -p "Percorso della cartella del tema: " THEME_PATH

if [ ! -f "$THEME_PATH/index.theme" ]; then
    echo "ERRORE: index.theme non trovato!"
else
    echo "OK: index.theme presente."
fi

# Controlla se ci sono icone a 0 byte (corrotte)
find "$THEME_PATH" -type f -size 0
echo "Controllo file vuoti completato."
