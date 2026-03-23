#!/bin/bash
#==========================================================
# ILNANNY IDENTITY FIXER - 2026
# Rimuove le tracce di vecchie collaborazioni dai file
#==========================================================

# --- CONFIGURAZIONE ---
OLD_EMAIL="ilnannyhack@gmail.com"
OLD_NAME="ilnanny75"

NEW_EMAIL="ilnannyhack@gmail.com"
NEW_NAME="ilnanny75"
# ----------------------

echo "🚀 Inizio bonifica identità in corso..."

# Sostituzione nei file di testo
# Usiamo 'sed' per cambiare il nome e l'email ovunque
find . -type f -not -path '*/.git/*' -exec sed -i "s/$OLD_EMAIL/$NEW_EMAIL/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/$OLD_NAME/$NEW_NAME/g" {} +

echo "✅ Sostituzioni completate nei file."

# Configurazione Git Locale per questo repository
git config user.name "$NEW_NAME"
git config user.email "$NEW_EMAIL"

echo "✅ Configurazione Git aggiornata per questo repo."
echo "Ora puoi fare 'pigia' e i meriti saranno tuoi!"
