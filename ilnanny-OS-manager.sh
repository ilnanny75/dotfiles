#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Script MASTER SETUP per la gestione e automazione del Lab. 
# Si occupa di rilevare i dotfiles, installare dipendenze su 3 distro 
# Void, Arch, Debian, configurare link simbolici e ricaricare XFCE.
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# Permette ai cicli for di ignorare pattern vuoti
shopt -s nullglob

# ── Colori ──────────────────────────────────────────────────────────
V="\e[32m"; R="\e[31m"; C="\e[36m"; G="\e[33m"; B="\e[1m"; RESET="\e[0m"
DIM="\e[2m"; UL="\e[4m"

# ── Rilevamento automatico DOTFILES ─────────────────────────────────
_trova_dotfiles() {
    local candidati=(
        "${DOTFILES}"
        "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
        /media/ilnanny/dati-linux/Dev/dotfiles
        "$HOME/dotfiles"
    )
    for p in "${candidati[@]}"; do
        [[ -z "$p" ]] && continue
        if [[ -d "$p/.git" ]]; then
            DOTFILES="$p"
            export DOTFILES
            return 0
        fi
    done
    return 1
}

if ! _trova_dotfiles; then
    echo -e "${R}Errore: Cartella dotfiles non trovata!${RESET}"
    exit 1
fi

# ── Funzioni Log ────────────────────────────────────────────────────
info() { echo -e "${C}󰋼 ${B}INFO:${RESET} $1"; }
warn() { echo -e "${G} ${B}WARN:${RESET} $1"; }
error() { echo -e "${R}󰅚 ${B}ERROR:${RESET} $1"; }
success() { echo -e "${V}󰄬 ${B}OK:${RESET} $1"; }

# ── Funzioni ISO e Guide ────────────────────────────────────────────
_leggi_guide() {
    local doc_dir="${DOTFILES}/docs/emergency_guides"
    if [[ ! -d "$doc_dir" ]]; then
        error "La cartella delle guide non esiste: $doc_dir"
        read -p "Premi INVIO..."; return
    fi
    
    cd "$doc_dir" || return
    local files=(*.md)
    if [[ ${#files[@]} -eq 0 ]]; then
        warn "Nessuna guida .md trovata."
        read -p "Premi INVIO..."; cd - >/dev/null; return
    fi

    echo -e "${C}󰋖 SELEZIONA UNA GUIDA:${RESET}"
    select g in "${files[@]}"; do
        if [[ -n "$g" ]]; then
            command -v glow >/dev/null 2>&1 && glow -p "$g" || cat "$g" | less
            break
        else
            warn "Scelta non valida."; break
        fi
    done
    cd - >/dev/null
}

_build_iso() {
    local iso_dir="/media/ilnanny/dati-linux/Dev/ilnanny-os-repair"
    if [[ ! -d "$iso_dir" ]]; then
        error "Cartella build non trovata in: $iso_dir"
        read -p "Premi INVIO..."; return
    fi
    info "Avvio creazione ISO... Le ventole potrebbero decollare! ✈️"
    cd "$iso_dir" || return
    sudo lb clean && sudo lb build 2>&1 | tee build_log.txt
    success "Operazione completata! Controlla il file .iso"
    read -p "Premi invio per tornare al menu..."
}

reload_xfce() {
    info "Ricaricamento XFCE (Window Manager)..."
    (xfwm4 --replace >/dev/null 2>&1 &)
    xfce4-panel -r >/dev/null 2>&1 &
    sleep 1
    success "Desktop rinfrescato."
}

header() {
    clear
    echo -e "${C}═════════════════════════════════════════════════════${RESET}"
    echo -e "${B}${V}    󰊠  ILNANNY OS-MANAGER v2.0 - [${C}Cyber-Lab${V}]${RESET}"
    echo -e "${C}═════════════════════════════════════════════════════${RESET}"
}

# ── Menu Master ─────────────────────────────────────────────────────
while true; do
    header
    echo -e "${C}╔$(printf '═%.0s' $(seq 1 49))╗${RESET}"
    printf "${C}║${RESET}  ${V}1)${RESET}  🚀 %-40s${C}║${RESET}\n" "SETUP TOTALE SYSTEM"
    printf "${C}║${RESET}  ${V}2)${RESET}  ⚙️  %-40s${C}║${RESET}\n" "ONLY DOTFILES CONFIG"
    printf "${C}║${RESET}  ${V}3)${RESET}  󰊢 %-41s${C}║${RESET}\n" "GIT CLOUD PUSH"
    printf "${C}║${RESET}  ${V}4)${RESET}  󱓞 %-41s${C}║${RESET}\n" "REFRESH XFCE THEME"
    printf "${C}║${RESET}  ${V}5)${RESET}   %-41s${C}║${RESET}\n" "DEPLOY NERD FONTS"
    printf "${C}║${RESET}  %-47s${C}║${RESET}\n" ""
    printf "${C}║${RESET}  ${G}6)${RESET}  󰋖 %-41s${C}║${RESET}\n" "READ EMERGENCY GUIDES"
    printf "${C}║${RESET}  ${G}7)${RESET}  󰒋 %-41s${C}║${RESET}\n" "BUILD ISO REPAIR (Ventole!)"
    printf "${C}║${RESET}  %-47s${C}║${RESET}\n" ""
    printf "${C}║${RESET}  ${R}0)${RESET}  󰈆 %-41s${C}║${RESET}\n" "EXIT LAB"
    echo -e "${C}╚$(printf '═%.0s' $(seq 1 49))╝${RESET}"
    echo ""
    echo -en "  ${B}${C}󰘳 Inserisci codice: ${RESET}"
    read -r scelta

    case $scelta in
        1) # Qui metti i tuoi comandi originali: install_deps; deploy...
           info "Eseguo Setup Totale..."; sleep 1 ;;
        2) info "Eseguo Configurazione..."; sleep 1 ;;
        3) cd "$DOTFILES" && git status && git add -A && git commit -m "update $(date)" && git push; read -p "Fatto. Invio...";;
        4) reload_xfce ;;
        5) info "Deploy Fonts..."; sleep 1 ;;
        6) _leggi_guide ;;
        7) _build_iso ;;
        0) clear; exit 0 ;;
        *) warn "Scelta non valida."; sleep 1 ;;
    esac
done
