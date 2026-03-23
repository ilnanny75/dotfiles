#!/bin/bash
#==========================================================
# ILNANNY GIT PUSH - 2026
#==========================================================

# 1. Controllo Identità (Per essere sicuri di non firmare come Erik!)
GIT_USER=$(git config user.name)
GIT_EMAIL=$(git config user.email)

echo -e "\033[1;33mStai firmando come: $GIT_USER ($GIT_EMAIL)\033[0m"

# 2. Sincronizzazione iniziale
echo "--- 📥 Controllo aggiornamenti remoti ---"
git pull origin main --rebase

# 3. Preparazione Commit
echo "--- 📂 Aggiunta file ---"
git add .

# 4. Messaggio Interattivo
echo "--- 📝 Messaggio del commit ---"
read -p "Cosa hai cambiato oggi? " msg
# Se premi invio senza scrivere nulla, mette un messaggio di default
msg=${msg:-"Aggiornamento ordinario Lab 2026"}

git commit -m "$msg"

# 5. Invio Finale
echo "--- 🚀 Invio a GitHub (Account: cristianpozzessere) ---"
git push origin main

echo -e "\033[0;32m✅ Operazione completata con successo!\033[0m"
