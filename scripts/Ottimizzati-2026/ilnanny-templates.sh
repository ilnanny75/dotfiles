#!/bin/bash
#==========================================================
# ILNANNY ICON TEMPLATE GENERATOR - 2026
# Crea istantaneamente una base SVG perfetta per le icone
#==========================================================

# Colori
VERDE='\033[0;32m'
GIALLO='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=== 🎨 ILNANNY TEMPLATE CREATOR ===${NC}"

# 1. Chiedi il nome dell'icona
read -p "Nome della nuova icona (es: miamod.svg): " ICON_NAME
# Aggiungi .svg se l'utente se lo dimentica
[[ $ICON_NAME != *.svg ]] && ICON_NAME="$ICON_NAME.svg"

# 2. Scelta della dimensione (Standard Freedesktop)
echo -e "\nScegli la dimensione della griglia:"
echo "1) 16x16  (Small)"
echo "2) 24x24  (Standard)"
echo "3) 48x48  (Large)"
echo "4) 64x64  (HD)"
echo "5) 128x128 (Ultra)"
read -p "Opzione [1-5]: " SIZE_OPT

case $SIZE_OPT in
    1) SIZE=16 ;;
    2) SIZE=24 ;;
    3) SIZE=48 ;;
    4) SIZE=64 ;;
    5) SIZE=128 ;;
    *) SIZE=64 ;; # Default
esac

# 3. Creazione del file SVG (Codice base pulito)
cat <<EOF > "$ICON_NAME"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg width="${SIZE}" height="${SIZE}" viewBox="0 0 ${SIZE} ${SIZE}" version="1.1" xmlns="http://www.w3.org/2000/svg">
  <g id="bg_layer" style="display:inline">
    <rect width="${SIZE}" height="${SIZE}" style="fill:none;stroke:none" />
  </g>
  <g id="icon_layer">
    <circle cx="$((SIZE/2))" cy="$((SIZE/2))" r="$((SIZE/4))" style="fill:#333333;fill-opacity:0.2" />
  </g>
</svg>
EOF

echo -e "\n${VERDE}✅ File creato: ${ICON_NAME} (${SIZE}x${SIZE})${NC}"
echo -e "${GIALLO}💡 Suggerimento: Ora aprilo con 'geany ${ICON_NAME}' o 'inkscape ${ICON_NAME}'${NC}"
