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

OS_ID=$(grep -w "^ID" /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
OS_ID="${OS_ID:-unknown}"

# ── Funzioni Log ────────────────────────────────────────────────────
info()    { echo -e "${C}󰋼 ${B}INFO:${RESET} $1"; }
warn()    { echo -e "${G} ${B}WARN:${RESET} $1"; }
err()     { echo -e "${R}󰅚 ${B}ERRORE:${RESET} $1"; }
ok()      { echo -e "${V}󰄬 ${B}OK:${RESET} $1"; }
step()    { echo -e "\n${B}${C}  ▶  $*${RESET}\n"; }

confirm() {
    echo -en "${G}  [?] $1 [s/N] ${RESET}"
    read -r risposta
    [[ "$risposta" =~ ^[sS]$ ]]
}

# ── Header ──────────────────────────────────────────────────────────
header() {
    clear
    echo -e "${C}═════════════════════════════════════════════════════${RESET}"
    echo -e "${B}${V}    󰊠  ILNANNY OS-MANAGER v2.1 - [${C}${OS_ID^^}${V}]${RESET}"
    echo -e "${C}═════════════════════════════════════════════════════${RESET}"
}

# ── Installazione Dipendenze ────────────────────────────────────────
install_deps() {
    step "Verifica software di sistema su $OS_ID"
    declare -A PKGS
    PKGS[void]="curl wget github-cli xdg-user-dirs git tree dust"
    PKGS[arch]="curl wget github-cli xdg-user-dirs git tree dust"
    PKGS[debian]="curl wget gh xdg-user-dirs git tree"
    PKGS[mx]="${PKGS[debian]}"

    local pkg_list="${PKGS[$OS_ID]}"
    [[ -z "$pkg_list" ]] && return

    local da_installare=()
    for pkg in $pkg_list; do
        local cmd="$pkg"
        [[ "$pkg" == "github-cli" ]] && cmd="gh"
        command -v "$cmd" &>/dev/null || da_installare+=("$pkg")
    done

    if [[ ${#da_installare[@]} -gt 0 ]]; then
        if confirm "Installare componenti mancanti? (${da_installare[*]})"; then
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
    step "Deploy ~/.config"
    mkdir -p "$HOME/.config"
    for src in "$DOTFILES/config"/*; do
        target="$HOME/.config/$(basename "$src")"
        safe_link "$src" "$target"
    done
}

deploy_fonts() {
    step "Deploy NerdFonts"
    local src="$DOTFILES/NerdFonts"
    local dst="$HOME/.local/share/fonts"
    [[ ! -d "$src" ]] && { warn "Cartella NerdFonts non trovata"; return; }
    mkdir -p "$dst"
    safe_link "$src" "$dst/NerdFonts"
    command -v fc-cache &>/dev/null && fc-cache -fv "$dst" &>/dev/null
}

# ── Gestione Wallpaper ──────────────────────────────────────────────
deploy_wallpapers() {
    step "Deploy Wallpapers → /usr/share/wallpapers"
    local src="$DOTFILES/graphics/wallpapers"
    local dst="/usr/share/wallpapers"
    [[ ! -d "$src" ]] && { warn "Wallpapers non trovati in $src"; return; }

    info "Richiesta sudo per sincronizzare /usr/share"
    if [[ -d "$dst" && ! -L "$dst" ]]; then
        sudo mv "$dst" "${dst}.bak_$(date +%H%M%S)"
    elif [[ -L "$dst" ]]; then
        sudo rm "$dst"
    fi
    sudo cp -r "$src" "$dst" && ok "Wallpapers copiati."
}

# ── Utility e Ricarica ──────────────────────────────────────────────
clean_cache() {
    step "Pulizia cache"
    rm -rf ~/.cache/sessions/*
    rm -rf ~/.cache/xfce4/*
    ok "Cache pulita."
}

reload_xfce() {
    step "Ricarica XFCE"
    pkill -x xfwm4; sleep 1; xfwm4 & 
    pkill -x xfsettingsd; sleep 0.5; xfsettingsd --daemon &
    pkill -x xfdesktop; sleep 1; xfdesktop --daemon &
    command -v xfce4-panel &>/dev/null && xfce4-panel --restart
    ok "Ambiente ricaricato."
}

_leggi_guide() {
    local doc_dir="${DOTFILES}/docs/emergency_guides"
    [[ ! -d "$doc_dir" ]] && { err "Guide non trovate"; return; }
    cd "$doc_dir" || return
    local files=(*.md)
    echo -e "${C}󰋖 SELEZIONA GUIDA:${RESET}"
    select g in "${files[@]}"; do
        [[ -n "$g" ]] && { command -v glow >/dev/null 2>&1 && glow -p "$g" || less "$g"; break; }
    done
    cd - >/dev/null
}

# ── Menu Master ─────────────────────────────────────────────────────
while true; do
    header
    echo -e "${C}╔$(printf '═%.0s' $(seq 1 49))╗${RESET}"
    printf "${C}║${RESET}  ${V}1)${RESET}  🚀 %-40s${C}║${RESET}\n" "SETUP TOTALE SISTEMA"
    printf "${C}║${RESET}  ${V}2)${RESET}  ⚙️  %-40s${C}║${RESET}\n" "SOLO CONFIGURAZIONE"
    printf "${C}║${RESET}  ${V}3)${RESET}  󰊢 %-41s${C}║${RESET}\n" "GIT PUSH"
    printf "${C}║${RESET}  ${V}4)${RESET}  󱓞 %-41s${C}║${RESET}\n" "RICARICA XFCE"
    printf "${C}║${RESET}  ${V}5)${RESET}  󱓞 %-41s${C}║${RESET}\n" "DEPLOY NERD FONTS"
    printf "${C}║${RESET}  %-47s${C}║${RESET}\n" ""
    printf "${C}║${RESET}  ${G}6)${RESET}  󰋖 %-41s${C}║${RESET}\n" "LEGGI GUIDE EMERGENZA"
    printf "${C}║${RESET}  ${R}0)${RESET}  󰈆 %-41s${C}║${RESET}\n" "ESCI"
    echo -e "${C}╚$(printf '═%.0s' $(seq 1 49))╝${RESET}"
    echo ""
    echo -en "  ${B}${C}󰘳 Inserisci codice: ${RESET}"
    read -r scelta

    case $scelta in
        1) install_deps; deploy_bashrc; deploy_bin; deploy_config; deploy_fonts; deploy_wallpapers; clean_cache; reload_xfce; echo -e "\nPremi INVIO..."; read -r ;;
        2) deploy_bashrc; deploy_bin; deploy_config; deploy_fonts; deploy_wallpapers; clean_cache; reload_xfce; echo -e "\nPremi INVIO..."; read -r ;;
        3) cd "$DOTFILES" && git add -A && git commit -m "update $(date)" && git push; read -rp "Premi INVIO..." ;;
        4) clean_cache; reload_xfce; sleep 2 ;;
        5) deploy_fonts; read -r ;;
        6) _leggi_guide ;;
        0) clear; exit 0 ;;
        *) warn "Scelta non valida."; sleep 1 ;;
    esac
done
