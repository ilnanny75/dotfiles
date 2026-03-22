#!/bin/bash
#==========================================================
#  O.S.      : Gnu Linux
#  Author    : Cristian Pozzessere (ilnanny)
#  D.A.Page  : http://ilnanny.deviantart.com
#  Github    : https://github.com/ilnanny75
#==========================================================

echo "--- Ottimizzazione SVG (Scour) ---"
read -p "Cartella da ottimizzare: " DIR
cd "$DIR" || exit

mkdir -p optimized
for f in *.svg; do
    scour -i "$f" -o "optimized/$f" --enable-viewboxing --enable-id-stripping --enable-comment-stripping --shorten-ids --indent=none
done
echo "Icone ottimizzate nella cartella 'optimized'!"
