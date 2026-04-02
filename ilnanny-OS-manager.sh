#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  ilnanny-OS-manager.sh — MASTER SETUP 2026
#  Rileva automaticamente i dotfiles dal mount point della partizione
# ═══════════════════════════════════════════════════════════════════

# ── Colori ──────────────────────────────────────────────────────────
V="\e[32m"; R="\e[31m"; C="\e[36m"; G="\e[33m"; B="\e[1m"; RESET="\e[0m"
DIM="\e[2m"; UL="\e[4m"

# ── Rilevamento automatico DOTFILES ─────────────────────────────────
# Ordine di ricerca: variabile env → accanto allo script → mount points noti
_trova_dotfiles() {
    local candidati=(
        "${DOTFILES}"                        # variabile d'ambiente (se impostata)
        "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"          # stessa dir dello script
        "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"       # un livello su
        /media/Dati/dotfiles
        /mnt/Dati/dotfiles
        /media/"$USER"/Dati/dotfiles
        /mnt/dati/dotfiles
        /media/dati/dotfiles
        "$HOME/dotfiles"
    )
    for p in "${candidati[@]}"; do
        [[ -z "$p" ]] && continue
        # Valido se contiene almeno una sottodirectory tipica dei dotfiles
        if [[ -d "$p" ]] && \
           { [[ -d "$p/config" ]] || [[ -d "$p/bash" ]] || [[ -d "$p/scripts" ]]; }; then
            echo "$p"
            return 0
        fi
    done
    return 1
}

DOTFILES="$(_trova_dotfiles)"
if [[ -z "$DOTFILES" ]]; then
    echo -e "\e[31m\n  ✖  ERRORE CRITICO: dotfiles non trovati!\e[0m"
    echo -e "\e[33m  Controlla che la partizione dati-linux sia montata.\e[0m"
    echo -e "\e[33m  Puoi anche impostare: DOTFILES=/percorso/dotfiles ./ilnanny-OS-manager.sh\e[0m\n"
    exit 1
fi

# ── Symlink ~/dotfiles → sorgente reale (solo se esterna alla home) ──
# Se i dotfiles sono già in ~/dotfiles non serve nessun link.
# Su macchine senza partizione esterna funziona uguale: DOTFILES=~/dotfiles.
_crea_link_home_dotfiles() {
    local target="$HOME/dotfiles"
    local real_dotfiles
    real_dotfiles="$(readlink -f "$DOTFILES")"
    local real_target="$HOME/dotfiles"   # non segue symlink, è il path letterale

    # Se DOTFILES è già ~/dotfiles (o vi punta) → niente da fare
    [[ "$real_dotfiles" == "$(readlink -f "$real_target" 2>/dev/null)" ]] && return 0
    [[ "$real_dotfiles" == "$HOME/dotfiles" ]] && return 0

    # Sorgente esterna: crea/aggiorna il symlink in home
    if [[ -L "$target" ]]; then
        # Symlink esistente ma punta altrove → aggiorna
        [[ "$(readlink -f "$target")" != "$real_dotfiles" ]] && rm "$target" && ln -sf "$DOTFILES" "$target"
    elif [[ ! -e "$target" ]]; then
        # Non esiste → crea
        ln -sf "$DOTFILES" "$target"
    fi
    # Se esiste una dir reale ~/dotfiles (non symlink) → non toccare mai
}
_crea_link_home_dotfiles

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
    local msg="$1"
    echo -en "${G}  ❓  ${msg} [s/N] ${RESET}"
    read -r risposta
    [[ "$risposta" =~ ^[sS]$ ]]
}

attendi() {
    echo -e "\n${DIM}  Premi INVIO per continuare...${RESET}"
    read -r
}

header() {
    clear
    echo -e "${B}${C}"
    echo "  ╔═══════════════════════════════════════════════════╗"
    echo "  ║    󱓞  ilnanny LAB MANAGER — MASTER SETUP 2026    ║"
    printf "  ║    OS: %-42s║\n" "${OS_ID^^}"
    printf "  ║    DOTFILES: %-38s║\n" "$DOTFILES"
    echo "  ╚═══════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# ────────────────────────────────────────────────────────────────────
# 1. INSTALLA DIPENDENZE (skip se già presenti)
# ────────────────────────────────────────────────────────────────────
install_deps() {
    step "Verifica e installazione software"

    # Pacchetti per distro
    declare -A PKGS
    PKGS[void]="curl wget github-cli xdg-user-dirs autoconf automake pkg-config gtk+3-devel git inkscape"
    PKGS[arch]="curl wget github-cli xdg-user-dirs autoconf automake pkgconf gtk3 git inkscape"
    PKGS[debian]="curl wget gh xdg-user-dirs autoconf automake pkg-config libgtk-3-dev git inkscape"
    PKGS[mx]="${PKGS[debian]}"

    local pkg_list="${PKGS[$OS_ID]}"
    if [[ -z "$pkg_list" ]]; then
        warn "Distro '$OS_ID' non riconosciuta, skip installazione pacchetti."
        return
    fi

    # Controlla quali sono già installati
    local da_installare=()
    for pkg in $pkg_list; do
        # Normalizza: github-cli → gh su arch/void
        local cmd="$pkg"
        [[ "$pkg" == "github-cli" ]] && cmd="gh"
        [[ "$pkg" == "pkg-config" || "$pkg" == "pkgconf" ]] && cmd="pkg-config"
        [[ "$pkg" == "gtk+3-devel" || "$pkg" == "gtk3" || "$pkg" == "libgtk-3-dev" ]] && cmd="gtk3-demo" # approssimativo
        [[ "$pkg" == "xdg-user-dirs" ]] && cmd="xdg-user-dirs-update"

        if command -v "$cmd" &>/dev/null; then
            info "$(printf '%-22s' "$pkg") già installato — skip"
        else
            da_installare+=("$pkg")
        fi
    done

    if [[ ${#da_installare[@]} -eq 0 ]]; then
        ok "Tutti i pacchetti già presenti."
        return
    fi

    info "Da installare: ${da_installare[*]}"
    if ! confirm "Installare i pacchetti mancanti?"; then
        warn "Installazione pacchetti saltata."
        return
    fi

    case "$OS_ID" in
        void)    sudo xbps-install -Sy "${da_installare[@]}" ;;
        arch)    sudo pacman -Sy --needed --noconfirm "${da_installare[@]}" ;;
        debian|mx) sudo apt-get update -qq && sudo apt-get install -y "${da_installare[@]}" ;;
    esac && ok "Pacchetti installati." || err "Errore installazione pacchetti."
}

# ────────────────────────────────────────────────────────────────────
# 2. TEMA ARC HiDPI
# ────────────────────────────────────────────────────────────────────
install_arc_hidpi() {
    step "Tema Arc-Dark HiDPI"
    if [ -d "$HOME/.local/share/themes/Arc-Dark" ]; then
        ok "Tema Arc HiDPI già installato — skip."
        return
    fi
    info "Compilazione Arc-Dark HiDPI (192 DPI)..."
    local build_dir
    build_dir=$(mktemp -d)
    trap 'rm -rf "$build_dir"' RETURN

    curl -sL https://github.com/loichu/arc-theme-xfwm4-hidpi/archive/refs/heads/master.tar.gz \
        | tar xz -C "$build_dir" --strip-components=1 || { err "Download tema fallito."; return; }

    cd "$build_dir" || return
    ./autogen.sh --prefix="$HOME/.local" \
        --disable-cinnamon --disable-gnome-shell \
        --disable-metacity --disable-unity \
        --with-gnome=3.22 >> "$LOG_FILE" 2>&1 \
    && make install >> "$LOG_FILE" 2>&1 \
    && ok "Tema Arc HiDPI installato in ~/.local/share/themes/" \
    || err "Compilazione tema fallita. Vedi $LOG_FILE"
    cd - > /dev/null
}

# ────────────────────────────────────────────────────────────────────
# 3. SYMLINK BASH + BIN
# ────────────────────────────────────────────────────────────────────
safe_link() {
    local src="$1" dst="$2"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        local bak="${dst}.bak_$(date +%Y%m%d_%H%M%S)"
        mv "$dst" "$bak"
        info "Backup: $(basename "$dst") → $(basename "$bak")"
    fi
    ln -sf "$src" "$dst" && ok "Link: ${dst/$HOME/~} → ${src/$HOME/~}" \
                         || err "Impossibile linkare $dst"
}

deploy_bashrc() {
    step "Configurazione Bash"
    mkdir -p ~/.bashrc.d

    # bashrc principale
    if [ -f "$DOTFILES/bash/etc_bash/bashrc" ]; then
        safe_link "$DOTFILES/bash/etc_bash/bashrc" ~/.bashrc
    else
        warn "bashrc non trovato in $DOTFILES/bash/etc_bash/bashrc"
    fi

    # bashrc.d comuni
    if [ -d "$DOTFILES/bash/etc_bash/bashrc.d" ]; then
        for f in "$DOTFILES"/bash/etc_bash/bashrc.d/*; do
            [ -f "$f" ] || continue
            safe_link "$f" ~/.bashrc.d/"$(basename "$f")"
        done
    fi

    # bashrc.d specifici per distro
    local distro_dir=""
    case "$OS_ID" in
        void) distro_dir="$DOTFILES/Void/etc/bash/bashrc.d" ;;
        arch) distro_dir="$DOTFILES/Arch/etc/bash/bashrc.d" ;;
        debian|mx) distro_dir="$DOTFILES/Debian/etc/bash/bashrc.d" ;;
    esac
    if [ -d "$distro_dir" ]; then
        info "Aggiungo bashrc.d per $OS_ID..."
        for f in "$distro_dir"/*; do
            [ -f "$f" ] || continue
            safe_link "$f" ~/.bashrc.d/"$(basename "$f")"
        done
    fi
}

deploy_bin() {
    step "Script ~/bin"
    mkdir -p ~/bin
    if [ -d "$DOTFILES/scripts/bin" ]; then
        for f in "$DOTFILES"/scripts/bin/*; do
            [ -f "$f" ] || continue
            chmod +x "$f"
            safe_link "$f" ~/bin/"$(basename "$f")"
        done
    else
        warn "Directory $DOTFILES/scripts/bin non trovata — skip."
    fi
}

# ────────────────────────────────────────────────────────────────────
# 4. DEPLOY .config (link O copia, a scelta)
# ────────────────────────────────────────────────────────────────────
deploy_config() {
    step "Deploy ~/.config"
    local src_root="$DOTFILES/config"
    local dst_root="$HOME/.config"
    mkdir -p "$dst_root"

    if [ ! -d "$src_root" ]; then
        warn "Directory $src_root non trovata — skip .config."
        return
    fi

    for src in "$src_root"/*/; do
        [ -d "$src" ] || continue
        local nome
        nome="$(basename "$src")"
        local dst="$dst_root/$nome"

        if [ -L "$dst" ]; then
            rm "$dst"
        elif [ -d "$dst" ]; then
            local bak="${dst}.bak_$(date +%Y%m%d_%H%M%S)"
            mv "$dst" "$bak"
            info "Backup cartella: $nome → $(basename "$bak")"
        fi
        # Copia ricorsiva → sovrascrive tutto con i tuoi file
        cp -r "$src" "$dst" && ok "Config copiata: $nome" || err "Errore copia: $nome"
    done

    # File singoli in config/ (non cartelle)
    for src in "$src_root"/*; do
        [ -f "$src" ] || continue
        local nome
        nome="$(basename "$src")"
        safe_link "$src" "$dst_root/$nome"
    done
}

# ────────────────────────────────────────────────────────────────────
# 5. RELOAD XFCE COMPLETO
# ────────────────────────────────────────────────────────────────────
reload_xfce() {
    step "Ricarica ambiente XFCE"

    # Ricarica configurazione xfsettingsd (tema, font, icone, ecc.)
    if command -v xfsettingsd &>/dev/null; then
        pkill -x xfsettingsd 2>/dev/null
        sleep 0.5
        xfsettingsd --daemon 2>/dev/null
        ok "xfsettingsd riavviato"
    fi

    # Ricarica pannello XFCE
    if command -v xfce4-panel &>/dev/null; then
        xfce4-panel --restart 2>/dev/null
        ok "xfce4-panel riavviato"
    fi

    # Ricarica gestore finestre Xfwm4
    if command -v xfwm4 &>/dev/null; then
        pkill -x xfwm4 2>/dev/null; sleep 0.3
        xfwm4 --replace --daemon 2>/dev/null
        ok "xfwm4 riavviato"
    fi

    # Ricarica desktop (xfdesktop)
    if command -v xfdesktop &>/dev/null; then
        xfdesktop --reload 2>/dev/null
        ok "xfdesktop ricaricato"
    fi

    # Thunar — daemon (per mount automatici e apertura rapida)
    if command -v thunar &>/dev/null; then
        pkill -x thunar 2>/dev/null; sleep 0.2
        thunar --daemon 2>/dev/null &
        ok "Thunar daemon riavviato"
    fi

    # Terminale: xfce4-terminal legge da ~/.config/xfce4/terminal/ già aggiornato
    ok "xfce4-terminal leggerà la nuova config al prossimo avvio"

    # Notifica visiva se disponibile
    if command -v notify-send &>/dev/null; then
        notify-send -i dialog-information "ilnanny LAB" "XFCE ricaricato con successo! 🎉"
    fi
}

reload_bash() {
    step "Ricarica Bash"
    # Source non funziona in subshell, stampiamo il comando
    echo -e "${G}${B}"
    echo "  ┌─────────────────────────────────────────────────┐"
    echo "  │  Per ricaricare bash nel terminale corrente:    │"
    echo "  │                                                 │"
    echo "  │    source ~/.bashrc                             │"
    echo "  │                                                 │"
    echo "  └─────────────────────────────────────────────────┘"
    echo -e "${RESET}"
    ok "Bash verrà ricaricata alla prossima apertura del terminale."
}

# ────────────────────────────────────────────────────────────────────
# 6. BONIFICA FILE (rimuove numeri di riga spurii)
# ────────────────────────────────────────────────────────────────────
bonifica_files() {
    step "Bonifica file dotfiles"
    if ! confirm "Rimuovere numeri di riga spurii dai file?"; then
        info "Bonifica saltata."
        return
    fi
    find "$DOTFILES" -type f \( -name "*.sh" -o -name "*.md" -o -name "bashrc" -o -name "alias*" \) \
        -not -path '*/.git/*' \
        -exec sed -i 's/^[[:space:]]*[0-9]\+[[:space:]]\+//' {} + \
    && ok "File bonificati." || err "Errore durante bonifica."
}

# ────────────────────────────────────────────────────────────────────
# SETUP TOTALE
# ────────────────────────────────────────────────────────────────────
configura_lab() {
    header
    echo -e "${C}  DOTFILES rilevati in: ${B}$DOTFILES${RESET}"
    echo -e "${C}  LOG sessione:          ${B}$LOG_FILE${RESET}\n"
    sep

    if ! confirm "Avviare il SETUP TOTALE?"; then
        warn "Setup annullato."
        attendi; return
    fi

    ERRORI=0

    install_deps
    sep
    install_arc_hidpi
    sep

    step "Cartelle Home (struttura XDG)"
    xdg-user-dirs-update --force 2>/dev/null && ok "Cartelle XDG aggiornate."
    mkdir -p ~/.bashrc.d ~/.config ~/.local/share/fonts ~/bin
    ok "Directory base create."
    sep

    deploy_bashrc
    sep
    deploy_bin
    sep
    deploy_config
    sep
    bonifica_files
    sep
    reload_xfce
    sep
    reload_bash
    sep

    echo -e "\n${B}"
    if [[ $ERRORI -eq 0 ]]; then
        echo -e "  ${V}╔══════════════════════════════════════════╗"
        echo    "  ║   ✅  SETUP COMPLETATO SENZA ERRORI!    ║"
        echo -e "  ╚══════════════════════════════════════════╝${RESET}"
    else
        echo -e "  ${G}╔══════════════════════════════════════════════════╗"
        printf  "  ║  ⚠️  SETUP COMPLETATO CON %d ERRORI/AVVISI     ║\n" "$ERRORI"
        echo -e "  ║  Vedi: %-42s║\n" "$LOG_FILE"
        echo -e "  ╚══════════════════════════════════════════════════╝${RESET}"
    fi

    attendi
}

# ────────────────────────────────────────────────────────────────────
# SOLO CONFIG (senza software)
# ────────────────────────────────────────────────────────────────────
solo_config() {
    header
    ERRORI=0
    deploy_bashrc; sep
    deploy_bin;    sep
    deploy_config; sep
    reload_xfce;   sep
    reload_bash
    [[ $ERRORI -eq 0 ]] && ok "Config ridistribuita." || warn "$ERRORI errori. Vedi $LOG_FILE"
    attendi
}

# ────────────────────────────────────────────────────────────────────
# GIT PUSH
# ────────────────────────────────────────────────────────────────────
git_push() {
    header
    local git_mgr="$DOTFILES/scripts/bin/ilnanny-git-manager.sh"
    if [ -x "$git_mgr" ]; then
        bash "$git_mgr"
    else
        step "Git rapido"
        cd "$DOTFILES" || return
        git status
        sep
        echo -en "${C}  Messaggio commit: ${RESET}"
        read -r msg
        [[ -z "$msg" ]] && msg="update: $(date '+%Y-%m-%d %H:%M')"
        git add -A && git commit -m "$msg" && git push \
            && ok "Push completato." || err "Errore git push."
        cd - > /dev/null
    fi
    attendi
}

# ────────────────────────────────────────────────────────────────────
# MENU PRINCIPALE
# ────────────────────────────────────────────────────────────────────
while true; do
    header
    echo -e "  ${B}OPERAZIONI DISPONIBILI${RESET}\n"
    echo -e "  ${V}1)${RESET}  󰑭   SETUP TOTALE          ${DIM}(software + config + XFCE reload)${RESET}"
    echo -e "  ${V}2)${RESET}  󰒓   SOLO CONFIG           ${DIM}(symlink + .config + reload, no software)${RESET}"
    echo -e "  ${V}3)${RESET}  󰊢   GIT PUSH              ${DIM}(commit & push dotfiles)${RESET}"
    echo -e "  ${V}4)${RESET}  󰃢   BONIFICA FILE         ${DIM}(pulizia numeri di riga)${RESET}"
    echo -e "  ${V}5)${RESET}  󰏔   INSTALLA TEMA ARC     ${DIM}(compila Arc-Dark HiDPI)${RESET}"
    echo -e "  ${V}6)${RESET}  󰑓   RELOAD XFCE           ${DIM}(riavvia panel/wm/thunar/terminale)${RESET}"
    echo -e ""
    echo -e "  ${R}0)${RESET}  󰈆   ESCI"
    echo ""
    sep
    echo -en "  ${B}${C}Scegli: ${RESET}"
    read -r scelta

    case $scelta in
        1) configura_lab ;;
        2) solo_config ;;
        3) git_push ;;
        4) header; bonifica_files; attendi ;;
        5) header; install_arc_hidpi; attendi ;;
        6) header; reload_xfce; attendi ;;
        0) clear; echo -e "${C}  Ciao Cristian! 👋${RESET}\n"; exit 0 ;;
        *) warn "Scelta non valida." ; sleep 1 ;;
    esac
done
