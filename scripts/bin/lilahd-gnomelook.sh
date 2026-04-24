#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Script specifico per: Lila-HD-Icon-Theme-Official
# Destinazione: OpenCode (OpenDesktop / Gnome-Look)
# ═══════════════════════════════════════════════════════════════════

# Colori per un output leggibile
V="\e[32m"
C="\e[36m"
R="\e[31m"
G="\e[33m"
RESET="\e[0m"

# Configurazione variabili (Fissate per evitare errori)
REPO_PATH="/media/ilnanny/dati-linux/Lila-HD-Icon-Theme-Official"
REPO_URL="https://www.opencode.net/ilnanny75/lila-hd-icon-theme-official-2026.git"
USER_EMAIL="cristianpozzessere@gmail.com"
USER_NAME="ilnanny75"

echo -e "${C}--- AVVIO AGGIORNAMENTO LILA-HD SU OPENCODE ---${RESET}"

# 1. Entra nella cartella corretta
cd "$REPO_PATH" || { echo -e "${R}Errore: Cartella non trovata!${RESET}"; exit 1; }

# 2. Forza l'identità corretta per questo repository
git config user.email "$USER_EMAIL"
git config user.name "$USER_NAME"
git config core.fileMode false

# 3. Verifica o imposta il remote origin
git remote set-url origin "$REPO_URL" 2>/dev/null || git remote add origin "$REPO_URL"

# 4. Indicizzazione file
echo -e "${V}Aggiunta modifiche in corso...${RESET}"
git add .

# 5. Messaggio di commit
echo -e "${G}Inserisci il messaggio per l'aggiornamento:${RESET}"
read -r messaggio
if [ -z "$messaggio" ]; then
    messaggio="Aggiornamento icone $(date +'%Y-%m-%d %H:%M')"
fi

git commit -m "$messaggio"

# 6. Scelta del tipo di Push
echo -e "${C}Scegli il tipo di invio:${RESET}"
echo -e "1) Push Normale (Consigliato)"
echo -e "2) Push Forzato (--force)"
read -p "Inserisci 1 o 2: " scelta

if [ "$scelta" == "2" ]; then
    echo -e "${R}Invio forzato in corso...${RESET}"
    git push -u origin main --force
else
    echo -e "${V}Invio normale in corso...${RESET}"
    git push -u origin main
fi

# 7. Esito finale
if [ $? -eq 0 ]; then
    echo -e "\n${V}✅ Lila-HD aggiornato con successo su OpenCode!${RESET}"
else
    echo -e "\n${R}❌ Errore durante il push. Verifica la connessione o i permessi.${RESET}"
fi
