#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
# Nota: Automatizza l'invio al repository Git della cartella corrente.
#
# Autore: ilnanny 2026
# ═══════════════════════════════════════════════════════════════════════

# Colori
V="\e[32m"
C="\e[36m"
R="\e[31m"
RESET="\e[0m"

git_setup() {
    # 1. Verifica se sei in un repository Git
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo -e "${R}Errore: Questa cartella non è un repository Git.${RESET}"
        exit 1
    fi

    # Recupera il nome del repository 
    REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
    echo -e "${C}--- AGGIORNAMENTO REPOSITORY: ${REPO_NAME} ---${RESET}"

    # Mantiene l'impostazione per Fedora/SELinux
    git config core.fileMode false

    # Aggiunge tutto
    git add .

    # Chiede il messaggio del commit
    echo -e "${V}Inserisci il messaggio del commit:${RESET}"
    read -r messaggio

    if [ -z "$messaggio" ]; then
        messaggio="Aggiornamento automatico $(date +'%Y-%m-%d %H:%M')"
    fi

    git commit -m "$messaggio"

    # Rileva il ramo corrente in modo dinamico (non solo 'main')
    CURRENT_BRANCH=$(git branch --show-current)

    echo -e "${C}Invio dei dati a GitHub sul ramo ${CURRENT_BRANCH}...${RESET}"
    
    # Push dinamico sul ramo corrente
    if ! git push origin "$CURRENT_BRANCH" 2>/dev/null; then
        echo -e "${V}Configurazione del ramo upstream e invio...${RESET}"
        git push --set-upstream origin "$CURRENT_BRANCH"
    fi

    if [ $? -eq 0 ]; then
        echo -e "${V}✅ Operazione completata con successo su ${REPO_NAME}!${RESET}"
    else
        echo -e "${R}❌ Errore durante l'invio dei dati.${RESET}"
    fi
}

git_setup
