#!/bin/bash
# Script semplificato per il tuo nuovo inizio
echo "--- Controllo aggiornamenti remoti ---"
git pull

echo "--- Aggiunta file ---"
git add .

echo "--- Messaggio del commit ---"
read -p "Cosa hai cambiato oggi? " msg

git commit -m "$msg"

echo "--- Invio a GitHub ---"
git push origin main
