#!/bin/bash
#==========================================================
# UTILITY ILNANNY 2026 - Funzioni TTY e Sistema
#==========================================================

# --- 📦 Estrazione e Compressione File ---
extract() {                                                     # Funzione universale per estrarre/creare archivi
    arg="$1"; shift                                             # Gestisce il primo argomento (-e o -n)
    case $arg in
        -e|--extract)                                           # Modalità estrazione
            if [[ $1 && -e $1 ]]; then                          # Verifica se il file esiste
                case $1 in
                    *.tar.bz2|*.tbz2) tar xvjf "$1" ;;          # Estrae archivi bzip2
                    *.tar.gz|*.tgz)   tar xvzf "$1" ;;          # Estrae archivi gzip
                    *.tar.xz)         tar xpvf "$1" ;;          # Estrae archivi xz
                    *.tar)            tar xvf "$1"  ;;          # Estrae archivi tar semplici
                    *.zip)            unzip "$1"    ;;          # Estrae file zip
                    *.7z|*.7zip)      7za e "$1"    ;;          # Estrae file 7zip
                    *.rar)            unrar x "$1"  ;;          # Estrae file rar
                    *) printf "'%s' non supportato" "$1" ;;     # Errore formato sconosciuto
                esac
            fi ;;
        -n|--new)                                               # Modalità creazione nuovo archivio
            case $1 in
                *.tar.gz)  shift; tar -cvzf "$@"    ;;          # Crea un nuovo tar.gz
                *.zip)     shift; zip -9r "$@"      ;;          # Crea un nuovo zip alla massima compressione
                *.7z)      shift; 7z a -mx9 "$@"    ;;          # Crea un nuovo 7z alla massima compressione
            esac ;;
    esac
}

# --- 🔍 Informazioni di Sistema (ii) ---
ii() {                                                          # Mostra un riepilogo completo della macchina
    echo -e "\nSei connesso su: \e[1;31m$HOSTNAME\e[m"          # Mostra il nome della macchina
    echo -e "\n\e[1;31mKernel:\e[m "; uname -a                  # Mostra versione kernel e architettura
    echo -e "\n\e[1;31mUtenti:\e[m "; who | awk '{print $1}'    # Elenca gli utenti attualmente loggati
    echo -e "\n\e[1;31mData:\e[m   "; date                      # Mostra data e ora attuale
    echo -e "\n\e[1;31mUptime:\e[m "; uptime                    # Mostra da quanto tempo il PC è acceso
    echo -e "\n\e[1;31mMemoria:\e[m"; free -h                   # Mostra la RAM libera in formato leggibile
    echo -e "\n\e[1;31mDisco:\e[m  "; df -hT /                  # Mostra lo spazio su disco della root
    echo -e "\n\e[1;31mIP Loc.:\e[m "; hostname -I               # Mostra l'indirizzo IP locale
}

# --- 🌿 Supporto Gentoo (se presente) ---
alias emerge='emerge --color=y'                                 # Forza l'uso dei colori in emerge
alias eix='eix -F'                                              # Formattazione ottimizzata per eix

# ________________________  Fine del file utility.sh
