#!/bin/bash
#==========================================================
#  ILNANNY GIT CONFIG - 2026 (Double ID Version)
#==========================================================

echo "--- Configurazione Identità Git ---"

# 1. IDENTITÀ AUTORE (Quella che appare nei commit)
AUTHOR_NAME="ilnanny75"
AUTHOR_EMAIL="ilnannyhack@gmail.com"

git config --global user.name "$AUTHOR_NAME"
git config --global user.email "$AUTHOR_EMAIL"
git config --global core.editor "geany"
git config --global init.defaultBranch main

echo -e "\n✅ Autore impostato: $AUTHOR_NAME ($AUTHOR_EMAIL)"
echo -e "⚠️  Ricorda: Per il login GitHub usa: cristianpozzessere@gmail.com"

# 2. TEST CONNESSIONE (Opzionale)
echo -e "\nVuoi testare la connessione a GitHub? (s/n)"
read -p "> " TEST
if [[ $TEST == "s" ]]; then
    ssh -T git@github.com 2>&1 | grep "successfully authenticated" || echo "Verifica le tue credenziali per cristianpozzessere@gmail.com"
fi
