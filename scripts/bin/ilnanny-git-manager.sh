#!/usr/bin/env bash

# Colori per un output leggibile
V="\e[32m"
C="\e[36m"
R="\e[31m"
RESET="\e[0m"

git_setup() {
    echo -e "${C}--- AGGIORNAMENTO REPOSITORY ---${RESET}"

    # Entra nella cartella dei dotfiles (percorso assoluto per sicurezza)
    cd "$HOME/dotfiles" || exit

    # Aggiunge tutto, inclusi i nuovi font e icone
    git add .

    # Chiede il messaggio del commit
    echo -e "${V}Inserisci il messaggio del commit (es. 'Aggiunti font'):${RESET}"
    read -r messaggio

    if [ -z "$messaggio" ]; then
        messaggio="Aggiornamento automatico $(date +'%Y-%m-%d %H:%M')"
    fi

    git commit -m "$messaggio"

    echo -e "${C}Invio dei dati a GitHub...${RESET}"
    git push

    if [ $? -eq 0 ]; then
        echo -e "${V}✅ Operazione completata con successo!${RESET}"
    else
        echo -e "${R}❌ Errore durante il push. Controlla la connessione o i permessi.${RESET}"
    fi
}

# Esegue la funzione
git_setup
