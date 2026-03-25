#!/bin/bash
#==========================================================
# CONFIGURAZIONE AMBIENTE UTENTE ILNANNY 2026
#==========================================================

# --- 🎨 Colori ANSI (Variabili per il testo nel terminale) ---
red='\[\e[0;31m\]'                           # Rosso: per errori o avvisi critici
blue='\[\e[0;34m\]'                          # Blu: per nomi host o directory
cyan='\[\e[0;36m\]'                          # Ciano: per informazioni di sistema
green='\[\e[0;32m\]'                         # Verde: per successi e nomi utente
nc='\[\e[0m\]'                               # Reset: riporta il colore al predefinito

# --- ⚙️ Direttive e Variabili di Sistema ---
export LANG="it_IT.UTF-8"                    # Lingua di sistema: Italiano UTF-8
export LC_ALL="it_IT.UTF-8"                  # Forza localizzazione (date/ora) in Italiano
export XKBMAP="it"                           # Layout tastiera: Italiano
export TERM="xterm-256color"                 # Supporto colore: Esteso a 256 tonalità
export EDITOR="geany"                        # Editor di testo predefinito
export BROWSER="firefox"                     # Browser web predefinito
export FILEMANAGER="thunar"                  # Gestore file predefinito

# --- 📂 Gestione Percorsi (PATH) ---
# Aggiunge le tue cartelle script personali in cima alla lista delle priorità
export PATH="$HOME/dotfiles/scripts/bin:$HOME/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"       # Percorso standard per file di configurazione

# --- 📜 Gestione Cronologia (History) ---
export HISTSIZE=10000                        # Comandi mantenuti in memoria (RAM)
export HISTFILESIZE=20000                    # Righe salvate su disco (.bash_history)
export HISTCONTROL=ignoreboth:erasedups      # Elimina duplicati e comandi con spazio iniziale
export HISTIGNORE="ls:cd:exit:q:f:v"         # Esclude questi comandi brevi dalla cronologia

# --- 📖 Colori per le Pagine MAN (Manuali a colori con 'less') ---
export LESS_TERMCAP_mb=$'\E[01;31m'          # Testo lampeggiante: Rosso grassetto
export LESS_TERMCAP_md=$'\E[01;31m'          # Titoli e risalto: Rosso grassetto
export LESS_TERMCAP_me=$'\E[0m'              # Fine formattazione
export LESS_TERMCAP_se=$'\E[0m'              # Fine evidenziazione
export LESS_TERMCAP_so=$'\E[01;44;33m'       # Ricerca: Sfondo Blu, Testo Giallo
export LESS_TERMCAP_ue=$'\E[0m'              # Fine sottolineatura
export LESS_TERMCAP_us=$'\E[01;32m'          # Parole sottolineate: Verde grassetto

# --- 🌿 Variabili per lo Stato Git (Icone e colori) ---
export GIT_THEME_PROMPT_DIRTY="${red}✗${nc}"  # Icona X rossa: Modifiche pendenti
export GIT_THEME_PROMPT_CLEAN="${blue}✓${nc}" # Icona check blu: Repo pulito
export GIT_THEME_PROMPT_PREFIX="${green}|${nc}" # Separatore iniziale Git
export GIT_THEME_PROMPT_SUFFIX="${green}|${nc}" # Separatore finale Git

# --- 🔑 Sicurezza e Varie ---
export GPG_TTY=$(tty)                        # Collega il terminale per pinentry/GPG
