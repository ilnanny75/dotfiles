#!/bin/bash
#==========================================================
#  O.S.      : Gnu Linux
#  Author    : Cristian Pozzessere (ilnanny)
#  D.A.Page  : http://ilnanny.deviantart.com
#  Github    : https://github.com/ilnanny75
#==========================================================

echo "--- Generatore Template SVG ilnanny ---"
read -p "Nome dell'icona (es: nuova-icona): " NAME
read -p "Dimensione (es: 48): " SIZE

FILE="$HOME/dotfiles/graphics/icons/templates/$NAME-$SIZE.svg"
mkdir -p "$HOME/dotfiles/graphics/icons/templates"

cat <<EOF > "$FILE"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg width="${SIZE}" height="${SIZE}" viewBox="0 0 ${SIZE} ${SIZE}" version="1.1" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="none" stroke="#ff00ff" stroke-width="0.1" opacity="0.2"/>
  </svg>
EOF

echo "Template creato in: $FILE"
inkscape "$FILE" &
