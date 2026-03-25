#!/bin/bash
#==========================================================
# CONFIGURAZIONE AMBIENTE UTENTE ILNANNY 2026
#==========================================================

# --- 🎨 Colori ANSI (Variabili testo) --------------------
red='\[\e[0;31m\]'                           # Rosso: Errori o avvisi
blue='\[\e[0;34m\]'                          # Blu: Directory o Host
cyan='\[\e[0;36m\]'                          # Ciano: Info secondarie
green='\[\e[0;32m\]'                         # Verde: Successo o Utente
nc='\[\e[0m\]'                               # Reset: Torna al predefinito

# --- ⚙️ Variabili di Sistema -----------------------------
export LANG="it_IT.UTF-8"                    # Lingua sistema: Italiano
export LC_ALL="it_IT.UTF-8"                  # Forza localizzazione
export XKBMAP="it"                           # Layout tastiera: Italiano
export TERM="xterm-256color"                 # Supporto colore 256 tonalità
export EDITOR="geany"                        # Editor predefinito
export BROWSER="firefox"                     # Browser predefinito
export FILEMANAGER="thunar"                  # Gestore file predefinito

# --- 📂 Gestione Percorsi (PATH) -------------------------
export PATH="$HOME/dotfiles/scripts/bin:$HOME/bin:$PATH" # Priorità ai tuoi script
export XDG_CONFIG_HOME="$HOME/.config"       # Percorso configurazioni

# --- 📜 Cronologia (History) -----------------------------
export HISTSIZE=10000                        # Comandi in memoria RAM
export HISTFILESIZE=20000                    # Righe salvate su disco
export HISTCONTROL=ignoreboth:erasedups      # Gestione duplicati cronologia
export HISTIGNORE="ls:cd:exit:q:f:v"         # Comandi da non salvare

# --- 📖 Colori Pagine MAN (Less) -------------------------
export LESS_TERMCAP_mb=$'\E[01;31m'          # Inizio lampeggiante: Rosso
export LESS_TERMCAP_md=$'\E[01;31m'          # Inizio grassetto: Rosso
export LESS_TERMCAP_me=$'\E[0m'              # Fine formattazione
export LESS_TERMCAP_se=$'\E[0m'              # Fine evidenziazione
export LESS_TERMCAP_so=$'\E[01;44;33m'       # Ricerca: Sfondo Blu
export LESS_TERMCAP_ue=$'\E[0m'              # Fine sottolineatura
export LESS_TERMCAP_us=$'\E[01;32m'          # Sottolineatura: Verde

export GPG_TTY=$(tty)                        # Collega terminale a GPG
