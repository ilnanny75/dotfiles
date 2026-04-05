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
        /media/"$USER"/Dati/dotfiles
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
    echo -e "${R}\n  ✖  ERRORE CRITICO: dotfiles non trovati!${RESET}"
    exit 1
fi

OS_ID=$(grep -w "^ID" /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
OS_ID="${OS_ID:-unknown}"
LOG_FILE="/tmp/ilnanny-setup-$(date +%Y%m%d_%H%M%S).log"
ERRORI=0

# ── Helpers ─────────────────────────────────────────────────────────
ok()     { echo -e "${V}  ✅  $*${RESET}";   echo "[OK]  $*" >> "$LOG_FILE"; }
info()   { echo -e "${C}  ℹ️   $*${RESET}";   echo "[INF] $*" >> "$LOG_FILE"; }
warn()   { echo -e "${G}  ⚠️   $*${RESET}";   echo "[WRN] $*" >> "$LOG_FILE"; }
err()    { echo -e "${R}  ✖   $*${RESET}";   echo "[ERR] $*" >> "$LOG_FILE"; (( ERRORI++ )); }
step()   { echo -e "\n${B}${C}  ▶  $*${RESET}\n"; }
sep()    { echo -e "${DIM}${C}  ─────────────────────────────────────────${RESET}"; }

confirm() {
    echo -en "${G}  ❓  $1 [s/N] ${RESET}"
    read -r risposta
    [[ "$risposta" =~ ^[sS]$ ]]
}

header() {
    clear
    echo -e "${C}┌──────────────────────────────────────────────────┐${RESET}"
    echo -e "${C}│${B}    󱓞  ilnanny LAB MANAGER — MASTER 2026         ${RESET}${C}│${RESET}"
    printf "${C}│${RESET}    OS: %-42s ${C}│${RESET}\n" "${OS_ID^^}"
    printf "${C}│${RESET}    DOTFILES: %-38s ${C}│${RESET}\n" "$DOTFILES"
    echo -e "${C}└──────────────────────────────────────────────────┘${RESET}"
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
        info "Backup esistente: $(basename "$dst")"
    fi
    ln -sf "$src" "$dst" && ok "Link: ${dst/$HOME/~} -> Dotfiles"
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
    local src_root="$DOTFILES/config"
    local dst_root="$HOME/.config"
    mkdir -p "$dst_root"

    for src in "$src_root"/*; do
        local nome=$(basename "$src")
        local dst="$dst_root/$nome"
        
        if [ -e "$dst" ] || [ -L "$dst" ]; then
            if [ -d "$dst" ] && [ ! -L "$dst" ]; then
                mv "$dst" "${dst}.bak_$(date +%H%M%S)"
            else
                rm -rf "$dst"
            fi
        fi
        ln -sf "$src" "$dst" && ok "Config: $nome linkata"
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
    
    # 1. Riavvio Pannello (Gestione nativa XFCE per evitare errori DBus)
    if command -v xfce4-panel &>/dev/null; then
        xfce4-panel --restart 2>/dev/null
        ok "xfce4-panel riavviato"
    fi

    # 2. Riavvio altri componenti
    local comps=(xfsettingsd xfwm4 xfdesktop)
    for c in "${comps[@]}"; do
        if command -v "$c" &>/dev/null; then
            pkill -x "$c" 2>/dev/null
            sleep 0.2
            "$c" --daemon 2>/dev/null
            ok "$c riavviato"
        fi
    done
}

# ── Menu ────────────────────────────────────────────────────────────
while true; do
    header
    echo -e "  ${V}1)${RESET}  󰑭   SETUP TOTALE          ${DIM}(Soft + Config + Cache + Reload)${RESET}"
    echo -e "  ${V}2)${RESET}  󰒓   SOLO CONFIG           ${DIM}(Link + Cache + Reload)${RESET}"
    echo -e "  ${V}3)${RESET}  󰊢   GIT PUSH              ${DIM}(Sincronizza Lab)${RESET}"
    echo -e "  ${V}4)${RESET}  󰑓   RELOAD XFCE           ${DIM}(Cache + WM & Panel)${RESET}"
    echo -e ""
    echo -e "  ${R}0)${RESET}  󰈆   ESCI"
    echo ""
    sep
    echo -en "  ${B}${C}Scegli operazione: ${RESET}"
    read -r scelta

    case $scelta in
        1) install_deps; deploy_bashrc; deploy_bin; deploy_config; clean_cache; reload_xfce; echo -e "\nPremi INVIO..."; read ;;
        2) deploy_bashrc; deploy_bin; deploy_config; clean_cache; reload_xfce; echo -e "\nPremi INVIO..."; read ;;
        3) cd "$DOTFILES" && git status && confirm "Eseguire Push?" && git add -A && git commit -m "update $(date)" && git push; read ;;
        4) clean_cache; reload_xfce; sleep 2 ;;
        0) clear; echo -e "${C}  Ciao Cristian! 👋${RESET}\n"; exit 0 ;;
        *) warn "Scelta non valida." ; sleep 1 ;;
    esac
done
