#!/bin/bash
#==========================================================
# ILNANNY UNIVERSAL IDENTITY FIXER - 2026
# Bonifica totale: Testi, Git Config e History
#==========================================================

# Colori per il terminale
VERDE='\033[0;32m'
ROSSO='\033[0;31m'
GIALLO='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GIALLO}=== 🛠️ ILNANNY IDENTITY FIXER INTERATTIVO ===${NC}"

# 1. Input Dati
read -p "🔍 Nome da cercare (es. Erik Dubois): " OLD_NAME
read -p "📧 Email da cercare (es. erik.dubois@gmail.com): " OLD_EMAIL

NEW_NAME="ilnanny75"
NEW_EMAIL="ilnannyhack@gmail.com"

echo -e "\n${GIALLO}Recupero dati impostato:${NC}"
echo -e "Sostituirò [$OLD_NAME / $OLD_EMAIL] con [$NEW_NAME / $NEW_EMAIL]"
read -p "Confermi l'operazione su questa cartella? (s/n): " CONFIRM

if [[ $CONFIRM != "s" ]]; then
    echo -e "${ROSSO}Operazione annullata.${NC}"
    exit 1
fi

# 2. Bonifica file di testo
echo -e "\n${VERDE}1/4 - Bonifica file di testo in corso...${NC}"
find . -type f -not -path '*/.git/*' -exec sed -i "s/$OLD_EMAIL/$NEW_EMAIL/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/$OLD_NAME/$NEW_NAME/g" {} +

# 3. Aggiornamento Config Git Locale
echo -e "${VERDE}2/4 - Impostazione firma Git locale...${NC}"
git config user.name "$NEW_NAME"
git config user.email "$NEW_EMAIL"

# 4. Reset Autore ultimo commit
echo -e "${VERDE}3/4 - Riscrivo l'ultimo commit con la tua identità...${NC}"
git commit --amend --reset-author --no-edit > /dev/null 2>&1

# 5. Pigia Forzato
echo -e "${VERDE}4/4 - Sincronizzazione forzata su GitHub (Pigia Force)...${NC}"
git push origin $(git rev-parse --abbrev-ref HEAD) --force

echo -e "\n${GIALLO}✅ OPERAZIONE COMPLETATA!${NC}"
echo "Il repository ora è 100% di $NEW_NAME"
