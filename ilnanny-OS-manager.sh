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
        /media/Dati/dotfiles
        /mnt/Dati/dotfiles
        "$HOME/dotfiles"
    )
    for p in "${candidati[@]}"; do
        [[ -z "$p" ]] && continue
        if [[ -d "$p" ]] && { [[ -d "$p/config" ]] || [[ -d "$p/bash" ]]; }; then
            echo "$p"
            return 0
        fi
    done
    return 1
}

DOTFILES="$(_trova_dotfiles)"
if [[ -z "$DOTFILES" ]]; then
    echo -e "${R}  [!] ERRORE: dotfiles non trovati!${RESET}"
    exit 1
fi

OS_ID=$(grep -w "^ID" /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
OS_ID="${OS_ID:-unknown}"

# ── Helpers ─────────────────────────────────────────────────────────
ok()     { echo -e "${V}  [OK]  $*${RESET}"; }
info()   { echo -e "${C}  [INF] $*${RESET}"; }
warn()   { echo -e "${G}  [WRN] $*${RESET}"; }
err()    { echo -e "${R}  [ERR] $*${RESET}"; }
step()   { echo -e "\n${B}${C}  ▶  $*${RESET}\n"; }
sep()    { echo -e "${DIM}${C}  ─────────────────────────────────────────${RESET}"; }

confirm() {
    echo -en "${G}  [?] $1 [s/N] ${RESET}"
    read -r risposta
    [[ "$risposta" =~ ^[sS]$ ]]
}

# ── Header (Versione Open - No Glitch) ──────────────────────────────
header() {
    clear
    local FOLDER=$(basename "$DOTFILES")
    echo -e "${C}───────────────────────────────────────────────────${RESET}"
    echo -e "${B}    ilnanny LAB MANAGER - MASTER 2026${RESET}"
    echo -e "${DIM}    OS: ${OS_ID^^}${RESET}"
    echo -e "${DIM}    DOTFILES: ${FOLDER}${RESET}"
    echo -e "${C}───────────────────────────────────────────────────${RESET}"
    echo ""
}

# ── Installazione Dipendenze ────────────────────────────────────────
install_deps() {
    step "Verifica software di sistema"
    declare -A PKGS
    PKGS[void]="curl wget github-cli xdg-user-dirs git"
    PKGS[arch]="curl wget github-cli xdg-user-dirs git"
    PKGS[debian]="curl wget gh xdg-user-dirs git"
    PKGS[mx]="${PKGS[debian]}"

    local pkg_list="${PKGS[$OS_ID]}"
    [[ -z "$pkg_list" ]] && return

    local da_installare=()
    for pkg in $pkg_list; do
        local cmd="$pkg"; [[ "$pkg" == "github-cli" ]] && cmd="gh"
        command -v "$cmd" &>/dev/null || da_installare+=("$pkg")
    done

    if [[ ${#da_installare[@]} -gt 0 ]]; then
        if confirm "Installare componenti mancanti?"; then
            case "$OS_ID" in
                void)      sudo xbps-install -Sy "${da_installare[@]}" ;;
                arch)      sudo pacman -Sy --needed --noconfirm "${da_installare[@]}" ;;
                debian|mx) sudo apt-get update && sudo apt-get install -y "${da_installare[@]}" ;;
            esac
        fi
    else
        ok "Sistema aggiornato."
    fi
}

# ── Gestione Link Simbolici ─────────────────────────────────────────
safe_link() {
    local src="$1" dst="$2"
    [[ ! -e "$src" ]] && return
    
    if [ -L "$dst" ]; then 
        rm "$dst"
    elif [ -e "$dst" ]; then
        mv "$dst" "${dst}.bak_$(date +%H%M%S)"
    fi
    ln -sf "$src" "$dst" && ok "Link: $(basename "$dst")"
}

deploy_bashrc() {
    step "Configurazione Bash"
    mkdir -p ~/.bashrc.d
    safe_link "$DOTFILES/bash/etc_bash/bashrc" ~/.bashrc
    for f in "$DOTFILES"/bash/etc_bash/bashrc.d/*; do
        safe_link "$f" ~/.bashrc.d/"$(basename "$f")"
    done
}

deploy_bin() {
    step "Script ~/bin"
    mkdir -p ~/bin
    for f in "$DOTFILES"/scripts/bin/*; do
        chmod +x "$f"
        safe_link "$f" ~/bin/"$(basename "$f")"
    done
}

deploy_config() {
    step "Deploy ~/.config (Link Diretti)"
    for src in "$DOTFILES/config"/*; do
        safe_link "$src" "$HOME/.config/$(basename "$src")"
    done
}

# ── Pulizia Cache ───────────────────────────────────────────────────
clean_cache() {
    step "Pulizia cache XFCE"
    rm -rf ~/.cache/sessions/*
    rm -rf ~/.cache/xfce4/*
    ok "Cache pulita correttamente"
}

# ── Reload Ambiente ─────────────────────────────────────────────────
reload_xfce() {
    step "Ricarica ambiente XFCE"
    
    if command -v xfce4-panel &>/dev/null; then
        xfce4-panel --restart 2>/dev/null
        ok "Pannello riavviato"
    fi

    if command -v xfwm4 &>/dev/null; then
        # Uso di --replace per Debian/XFCE stabilità
        xfwm4 --replace --daemon 2>/dev/null &
        sleep 1
        ok "xfwm4 ricaricato"
    fi

    local comps=(xfsettingsd xfdesktop)
    for c in "${comps[@]}"; do
        if command -v "$c" &>/dev/null; then
            pkill -x "$c" 2>/dev/null
            sleep 0.3
            "$c" --daemon 2>/dev/null
            ok "$c riavviato"
        fi
    done
}

# ── Menu ────────────────────────────────────────────────────────────
while true; do
    header
    echo -e "  ${V}1)${RESET}  SETUP TOTALE"
    echo -e "  ${V}2)${RESET}  SOLO CONFIG"
    echo -e "  ${V}3)${RESET}  GIT PUSH"
    echo -e "  ${V}4)${RESET}  RELOAD XFCE"
    echo -e ""
    echo -e "  ${R}0)${RESET}  ESCI"
    echo ""
    sep
    echo -en "  ${B}${C}Scegli operazione: ${RESET}"
    read -r scelta

    case $scelta in
        1) install_deps; deploy_bashrc; deploy_bin; deploy_config; clean_cache; sleep 1; reload_xfce; echo -e "\nPremi INVIO..."; read ;;
        2) deploy_bashrc; deploy_bin; deploy_config; clean_cache; sleep 1; reload_xfce; echo -e "\nPremi INVIO..."; read ;;
        3) cd "$DOTFILES" && git status && confirm "Eseguire Push?" && git add -A && git commit -m "update $(date)" && git push; read ;;
        4) clean_cache; reload_xfce; sleep 2 ;;
        0) clear; exit 0 ;;
        *) warn "Scelta non valida." ; sleep 1 ;;
    esac
done
