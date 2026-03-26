#!/bin/bash
#==========================================================
#  O.S.      : Gnu Linux
#  Author    : Cristian Pozzessere (ilnanny)
#  D.A.Page  : http://ilnanny.deviantart.com
#  Github    : https://github.com/ilnanny75
#==========================================================

echo "--- Ricerca Icone di Sistema ---"
read -p "Inserisci il nome dell'app o dell'icona (es: thunar o folder): " ICONA

echo "Cerco in /usr/share/icons e ~/.local/share/icons..."
find /usr/share/icons ~/.local/share/icons -name "*${ICONA}*" | grep -E ".svg|.png" | head -n 20

echo ""
echo "CONSIGLIO: Se stai creando un tema, inserisci il tuo file in:"
echo "tuo_tema/[dimensione]/apps/${ICONA}.svg"
