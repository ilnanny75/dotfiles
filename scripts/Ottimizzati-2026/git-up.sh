#!/bin/bash
#==========================================================
# ILNANNY GIT-UP - Sincronizzazione Totale 2026
#==========================================================

echo "--- 🔄 Sincronizzazione con GitHub ---"
git pull origin main --rebase

# Pulizia: Ignora file temporanei di Geany o Inkscape se presenti
echo "--- 🧹 Pulizia file temporanei ---"
find . -name "*~" -delete
find . -name "*.swp" -delete

echo "--- 📂 Preparazione file ---"
git add --all .

echo "####################################"
echo "  SCRIVI IL TUO COMMENTO!"
echo "####################################"
read -p "> " input
input=${input:-"Update $(date +'%d-%m-%Y %H:%M')"}

# Commit con data e ora automatica se non scrivi nulla
git commit -m "$input"

echo "--- 🚀 Invio a GitHub (Branch: main) ---"
git push -u origin main

echo "################################################################"
echo "###             REPOSITORY AGGIORNATO CON SUCCESSO           ###"
echo "################################################################"
