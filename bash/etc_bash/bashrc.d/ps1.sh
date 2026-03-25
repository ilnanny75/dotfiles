#!/bin/bash
#==========================================================
# PS1 ILNANNY 2026 - Versione Grafica Pulita
#==========================================================

# --- Funzione Info Cartella: Calcola file e peso ---
prompt_dir_info() {
    local files=$(ls -1 2>/dev/null | wc -l)                # Conta i file nella cartella attuale
    local size=$(ls -shd . 2>/dev/null | awk '{print $1}')  # Estrae la dimensione totale occupata
    echo "$files files, $size"                              # Restituisce la stringa formattata
}

# --- Funzione Stato: Mostra ✔ verde o ✘ rosso ---
prompt_status() {
    if [ $? -eq 0 ]; then
        echo -e "\e[32m✔\e[0m"                             # Icona successo in verde
    else
        echo -e "\e[31m✘\e[0m"                             # Icona errore in rosso
    fi
}

# --- Costruzione del Prompt ---
# Nota: Usiamo variabili per i colori per rendere il PS1 più leggibile nel codice
R="\[\e[01;31m\]"   # Rosso
G="\[\e[01;32m\]"   # Verde
B="\[\e[01;34m\]"   # Blu
W="\[\e[01;37m\]"   # Bianco
RS="\[\e[0m\]"      # Reset colore

export PS1="┌─[\$(prompt_status)]───[$W\u@\h$RS]───[$B\w$RS]───[$W\$(prompt_dir_info)$RS]\n└───▶ "
