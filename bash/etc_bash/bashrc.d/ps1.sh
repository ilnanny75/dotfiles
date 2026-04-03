#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Custom Shell Prompt (PS1). Versione simmetrica 2026. 
# Visualizza dinamicamente: stato ultimo comando (✔/✘), 
# info utente/host, percorso attuale e statistiche cartella (# file/peso).
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# --- Funzione Info: File e Peso --------------------------
prompt_dir_info() {
    local f=$(ls -1 2>/dev/null | wc -l)                # Conta i file presenti
    local s=$(ls -shd . 2>/dev/null | awk '{print $1}') # Peso totale cartella
    echo "$f files, $s"                                 # Output pulito
}

# --- Funzione Stato: Successo/Errore ---------------------
prompt_status() {
    if [ $? -eq 0 ]; then
        echo -e "\e[32m✔\e[0m"                         # Icona Verde (OK)
    else
        echo -e "\e[31m✘\e[0m"                         # Icona Rossa (Fail)
    fi
}

# --- Costruzione PS1 -------------------------------------
R="\[\e[01;31m\]"   # Rosso
B="\[\e[01;34m\]"   # Blu
W="\[\e[01;37m\]"   # Bianco
RS="\[\e[0m\]"      # Reset

export PS1="┌─[\$(prompt_status)]───[$W\u@\h$RS]───[$B\w$RS]───[$W\$(prompt_dir_info)$RS]\n└───▶ "
