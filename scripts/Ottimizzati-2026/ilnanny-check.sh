#!/bin/bash
#==========================================================
#  ILNANNY ICON CHECKER - 2026
#  Ispezione tecnica profonda per temi icone
#==========================================================

# Colori
VERDE='\033[0;32m'
ROSSO='\033[0;31m'
GIALLO='\033[1;33m'
NC='\033[0m'

echo -e "${GIALLO}=== 🔍 ILNANNY QUALITY CONTROL - TEMA ICONE ===${NC}"
read -e -p "Trascina qui la cartella del tema (o scrivi il percorso): " THEME_PATH

# Rimuove eventuali apici se hai trascinato la cartella nel terminale
THEME_PATH=$(echo $THEME_PATH | tr -d "'")

if [ ! -d "$THEME_PATH" ]; then
    echo -e "${ROSSO}❌ Errore: La cartella non esiste!${NC}"
    exit 1
fi

echo -e "\n${GIALLO}--- 1. Verifica Struttura Base ---${NC}"
if [ ! -f "$THEME_PATH/index.theme" ]; then
    echo -e "${ROSSO}[!] index.theme MANCANTE!${NC}"
else
    echo -e "${VERDE}[OK] index.theme trovato.${NC}"
fi

echo -e "\n${GIALLO}--- 2. Verifica Integrità File ---${NC}"
EMPTY_FILES=$(find "$THEME_PATH" -type f -size 0 | wc -l)
if [ "$EMPTY_FILES" -gt 0 ]; then
    echo -e "${ROSSO}[!] Trovati $EMPTY_FILES file corrotti (0 byte):${NC}"
    find "$THEME_PATH" -type f -size 0
else
    echo -e "${VERDE}[OK] Nessun file a 0 byte trovato.${NC}"
fi

echo -e "\n${GIALLO}--- 3. Verifica Permessi e Autore ---${NC}"
# Controlla se ci sono file che appartengono a root
ROOT_FILES=$(find "$THEME_PATH" -user root | wc -l)
if [ "$ROOT_FILES" -gt 0 ]; then
    echo -e "${ROSSO}[!] ATTENZIONE: $ROOT_FILES file sono di proprietà di ROOT!${NC}"
    echo "Consiglio: lancia ilnanny-identity-fixer.sh su questa cartella."
else
    echo -e "${VERDE}[OK] Tutti i file appartengono correttamente a $(whoami).${NC}"
fi

echo -e "\n${GIALLO}--- 4. Verifica Formati Estremi ---${NC}"
NON_SVG=$(find "$THEME_PATH" -type f ! -name "*.svg" ! -name "index.theme" ! -name "icon-theme.cache" | wc -l)
if [ "$NON_SVG" -gt 0 ]; then
    echo -e "${GIALLO}[?] Trovati $NON_SVG file che non sono SVG (controlla se sono necessari).${NC}"
else
    echo -e "${VERDE}[OK] Solo file SVG presenti.${NC}"
fi

echo -e "\n${VERDE}✅ Ispezione completata per: $THEME_PATH${NC}"
