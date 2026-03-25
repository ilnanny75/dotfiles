#!/bin/bash
#==========================================================
# UTILITY ILNANNY 2026 - Estrattore e Info
#==========================================================

# --- 📦 Estrattore Universale ----------------------------
extract() {                                             # Gestione archivi
    arg="$1"; shift
    case $arg in
        -e|--extract)
            if [[ $1 && -e $1 ]]; then
                case $1 in
                    *.tar.bz2|*.tbz2) tar xvjf "$1" ;;  # Estrae bzip2
                    *.tar.gz|*.tgz)   tar xvzf "$1" ;;  # Estrae gzip
                    *.zip)            unzip "$1"    ;;  # Estrae zip
                    *.7z|*.7zip)      7za e "$1"    ;;  # Estrae 7zip
                    *.rar)            unrar x "$1"  ;;  # Estrae rar
                    *) echo "'$1' non supportato"   ;;  # Errore formato
                esac
            fi ;;
        -n|--new)                                       # Crea archivi
            case $1 in
                *.zip) shift; zip -9r "$@" ;;           # Crea zip compresso
                *.7z)  shift; 7z a -mx9 "$@" ;;         # Crea 7z massimo
            esac ;;
    esac
}

# --- 🔍 Info Macchina ------------------------------------
ii() {                                                  # Riepilogo sistema
    echo -e "\nSei su: \e[1;31m$HOSTNAME\e[m"           # Nome Host
    echo -e "\n\e[1;31mKernel:\e[m "; uname -a          # Versione Kernel
    echo -e "\n\e[1;31mMemoria:\e[m"; free -h           # RAM leggibile
    echo -e "\n\e[1;31mIP Loc.:\e[m "; hostname -I       # IP Locale
}
