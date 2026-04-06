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

confirm() {
    echo -en "${G}  [?] $1 [s/N] ${RESET}"
    read -r risposta
    [[ "$risposta" =~ ^[sS]$ ]]
}

# ── Header con cornice doppia allineata ──────────────────────────────
# Nota: printf con \e non funziona; i codici ANSI non hanno larghezza
# visibile, quindi la cornice viene calcolata sul testo puro.
header() {
    clear
    local FOLDER
    FOLDER=$(basename "$DOTFILES")

    # Larghezza interna fissa (caratteri visibili tra i bordi)
    local W=49

    # Righe della cornice con caratteri box-drawing doppi
    local TOP="╔$(printf '═%.0s' $(seq 1 $W))╗"
    local MID="╠$(printf '═%.0s' $(seq 1 $W))╣"
    local BOT="╚$(printf '═%.0s' $(seq 1 $W))╝"

    # Stampa una riga con bordi laterali, testo centrato/allineato a sx
    # $1 = testo visibile, $2 = colore opzionale
    _riga() {
        local testo="$1" colore="${2:-}"
        local pad=$(( W - ${#testo} - 1 ))
        printf "${C}║${RESET} ${colore}%-*s${RESET}${C}║${RESET}\n" "$((W-1))" "$testo"
    }

    echo -e "${C}${TOP}${RESET}"
    _riga ""
    _riga "  ilnanny LAB MANAGER - MASTER 2026" "${B}"
    _riga ""
    echo -e "${C}${MID}${RESET}"
    _riga "  OS      : ${OS_ID^^}"
    _riga "  DOTFILES: ${FOLDER}"
    _riga ""
    echo -e "${C}${BOT}${RESET}"
    echo ""
}

# ── Installazione dust su Debian via rustup + cargo ─────────────────
# I repo Debian hanno rust/cargo datati; rustup installa la versione
# stabile corrente e mette cargo in ~/.cargo/bin (nel PATH dopo reload).
_installa_dust_debian() {
    step "Installazione dust (Debian: rustup → cargo)"

    # Dipendenze build minime per rustup e du-dust
    sudo apt-get install -y curl build-essential pkg-config libssl-dev 2>/dev/null

    if ! command -v cargo &>/dev/null; then
        info "cargo non trovato — installo rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | sh -s -- -y --no-modify-path
        # Carica l'ambiente rust nella sessione corrente
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env" 2>/dev/null || \
            export PATH="$HOME/.cargo/bin:$PATH"
        ok "rustup installato"
    else
        info "cargo già presente: $(cargo --version)"
    fi

    if command -v cargo &>/dev/null; then
        info "Compilazione du-dust (può richiedere qualche minuto)..."
        cargo install du-dust 2>/dev/null && ok "dust installato" \
            || err "Errore durante la compilazione di du-dust"
    else
        err "cargo non disponibile, impossibile installare dust"
    fi
}

# ── Installazione Dipendenze ────────────────────────────────────────
install_deps() {
    step "Verifica software di sistema"
    declare -A PKGS

    # dust: su Arch/Void è nel repo come 'dust'; su Debian non c'è,
    # viene installato via cargo se disponibile oppure saltato.
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
                debian|mx) sudo apt-get update && sudo apt-get install -y "${da_installare[@]}"
                           # dust non è nei repo Debian: installa via cargo (rustup)
                           if ! command -v dust &>/dev/null; then
                               _installa_dust_debian
                           fi ;;
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

# ── Deploy NerdFonts ────────────────────────────────────────────────
# Crea symlink di dotfiles/NerdFonts/ in ~/.local/share/fonts/
# e aggiorna la cache font di sistema.
deploy_fonts() {
    step "Deploy NerdFonts → ~/.local/share/fonts"
    local src="$DOTFILES/NerdFonts"
    local dst="$HOME/.local/share/fonts"

    if [[ ! -d "$src" ]]; then
        warn "Cartella NerdFonts non trovata in: $src"
        return
    fi

    mkdir -p "$dst"

    # Symlink della cartella NerdFonts intera (mantiene struttura interna)
    safe_link "$src" "$dst/NerdFonts"

    # Aggiorna cache font
    if command -v fc-cache &>/dev/null; then
        fc-cache -fv "$dst" &>/dev/null
        ok "Cache font aggiornata"
    else
        warn "fc-cache non trovato, cache font non aggiornata"
    fi
}

# ── Pulizia Cache ───────────────────────────────────────────────────
clean_cache() {
    step "Pulizia cache XFCE"
    rm -rf ~/.cache/sessions/*
    rm -rf ~/.cache/xfce4/*
    ok "Cache pulita correttamente"
}

# ── Reload Ambiente XFCE ─────────────────────────────────────────────
# Nota sul problema del menu desktop freezato:
# Il bug era un race condition: xfwm4 --replace veniva lanciato prima
# che il vecchio processo terminasse, lasciando xfdesktop in uno stato
# inconsistente (menu tasto destro bloccato). 
# Fix: kill esplicito + attesa + riavvio ordinato dei componenti.
reload_xfce() {
    step "Ricarica ambiente XFCE"

    # 1. xfwm4 — kill esplicito poi riavvio (evita race con --replace)
    if command -v xfwm4 &>/dev/null; then
        pkill -x xfwm4 2>/dev/null
        sleep 1
        xfwm4 --daemon 2>/dev/null &
        sleep 1
        ok "xfwm4 riavviato"
    fi

    # 2. xfsettingsd — gestisce temi, font, input
    if command -v xfsettingsd &>/dev/null; then
        pkill -x xfsettingsd 2>/dev/null
        sleep 0.5
        xfsettingsd --daemon 2>/dev/null &
        sleep 0.5
        ok "xfsettingsd riavviato"
    fi

    # 3. xfdesktop — riavviato DOPO xfwm4 per evitare il freeze del menu
    if command -v xfdesktop &>/dev/null; then
        pkill -x xfdesktop 2>/dev/null
        sleep 1
        xfdesktop --daemon 2>/dev/null &
        sleep 0.5
        ok "xfdesktop riavviato"
    fi

    # 4. Pannello — per ultimo, dipende da wm e desktop pronti
    if command -v xfce4-panel &>/dev/null; then
        xfce4-panel --restart 2>/dev/null
        ok "Pannello riavviato"
    fi
}

# ── Menu ─────────────────────────────────────────────────────────────
while true; do
    header

    echo -e "${C}╔$(printf '═%.0s' $(seq 1 49))╗${RESET}"
    printf "${C}║${RESET}  ${V}1)${RESET}  %-43s${C}║${RESET}\n" "SETUP TOTALE"
    printf "${C}║${RESET}  ${V}2)${RESET}  %-43s${C}║${RESET}\n" "SOLO CONFIG"
    printf "${C}║${RESET}  ${V}3)${RESET}  %-43s${C}║${RESET}\n" "GIT PUSH"
    printf "${C}║${RESET}  ${V}4)${RESET}  %-43s${C}║${RESET}\n" "RELOAD XFCE"
    printf "${C}║${RESET}  ${V}5)${RESET}  %-43s${C}║${RESET}\n" "DEPLOY FONTS"
    printf "${C}║${RESET}  %-47s${C}║${RESET}\n" ""
    printf "${C}║${RESET}  ${R}0)${RESET}  %-43s${C}║${RESET}\n" "ESCI"
    echo -e "${C}╚$(printf '═%.0s' $(seq 1 49))╝${RESET}"
    echo ""
    echo -en "  ${B}${C}Scegli operazione: ${RESET}"
    read -r scelta

    case $scelta in
        1) install_deps; deploy_bashrc; deploy_bin; deploy_config; deploy_fonts; clean_cache; sleep 1; reload_xfce; echo -e "\nPremi INVIO..."; read ;;
        2) deploy_bashrc; deploy_bin; deploy_config; deploy_fonts; clean_cache; sleep 1; reload_xfce; echo -e "\nPremi INVIO..."; read ;;
        3) cd "$DOTFILES" && git status && confirm "Eseguire Push?" && git add -A && git commit -m "update $(date)" && git push; read ;;
        4) clean_cache; reload_xfce; sleep 2 ;;
        5) deploy_fonts; echo -e "\nPremi INVIO..."; read ;;
        0) clear; exit 0 ;;
        *) warn "Scelta non valida." ; sleep 1 ;;
    esac
done
