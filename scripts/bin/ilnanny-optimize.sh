#!/bin/bash
#==========================================================
# ILNANNY SVG OPTIMIZER - 2026
# Riduce il peso delle icone senza perdere qualità
#==========================================================

# Colori
VERDE='\033[0;32m'
GIALLO='\033[1;33m'
ROSSO='\033[0;31m'
NC='\033[0m'

echo -e "${GIALLO}=== 💎 ILNANNY SVG OPTIMIZER ===${NC}"

# Verifica se scriptexit o scour sono installati
if ! command -v scour &> /dev/null; then
    echo -e "${ROSSO}[!] Errore: 'scour' non è installato.${NC}"
    echo "Installa con: sudo apt install scour"
    exit 1
fi

read -e -p "Trascina la cartella delle icone da ottimizzare: " TARGET_DIR
TARGET_DIR=$(echo $TARGET_DIR | tr -d "'")

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${ROSSO}❌ Cartella non trovata!${NC}"
    exit 1
fi

cd "$TARGET_DIR" || exit

echo -e "${GIALLO}--- Inizio Ottimizzazione Massiva ---${NC}"

# Il cuore dell'ottimizzazione: pulisce i metadati e riduce i decimali
find . -name "*.svg" -type f | while read -r file; do
    echo -n "Ottimizzo: $file... "
    scour -i "$file" -o "$file.tmp" \
          --enable-viewboxing \
          --enable-id-stripping \
          --enable-comment-stripping \
          --shorten-ids \
          --indent=none \
          --precision=3

    # Se il file ottimizzato è più piccolo, sostituisci l'originale
    mv "$file.tmp" "$file"
    echo -e "${VERDE}[FATTO]${NC}"
done

echo -e "\n${VERDE}✅ Tutte le icone in $TARGET_DIR sono ora ultra-leggere!${NC}"
