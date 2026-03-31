#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  ilnanny-OS-manager.sh — MASTER SETUP 2026 (FULL VERSION)
# ═══════════════════════════════════════════════════════════════════

V="\e[32m"
R="\e[31m"
C="\e[36m"
G="\e[33m"
B="\e[1m"
RESET="\e[0m"

OS_ID=$(grep -w "ID" /etc/os-release | cut -d= -f2 | tr -d '"')
DOTFILES=~/dotfiles

header() {
    clear
    echo -e "${B}${C}󱓞  ilnanny LAB MANAGER — OS: ${OS_ID^^}${RESET}"
    echo -e "${C}─────────────────────────────────────────────────────${RESET}\n"
}

ok()     { echo -e "${V}✅ $*${RESET}"; }
info()   { echo -e "${C}ℹ️  $*${RESET}"; }
warn()   { echo -e "${G}⚠️  $*${RESET}"; }

# --- CONTROLLO E INSTALLAZIONE SOFTWARE ---
install_deps() {
    info "Verifica software di sistema e compilazione..."
    case "$OS_ID" in
        void)
            # Software base + Strumenti per compilare il tema
            sudo xbps-install -Sy curl wget github-cli xdg-user-dirs \
                               autoconf automake pkg-config gtk+3-devel git inkscape
            ;;
        arch)
            sudo pacman -Sy --needed curl wget github-cli xdg-user-dirs \
                                    autoconf automake pkgconf gtk3 git inkscape
            ;;
        debian|mx)
            sudo apt update && sudo apt install -y curl wget gh xdg-user-dirs \
                                    autoconf automake pkg-config libgtk-3-dev git inkscape
            ;;
    esac
    ok "Software installati."
}

# --- COMPILAZIONE TEMA ARC HiDPI ---
install_arc_hidpi() {
    if [ -d "$HOME/.local/share/themes/Arc-Dark" ]; then
        info "Tema Arc HiDPI già installato."
        return
    fi

    info "Compilazione Tema Arc-Dark HiDPI (192 DPI)..."
    mkdir -p /tmp/arc-build
    # Scarica il sorgente dal repo che hai indicato
    curl -L https://github.com/loichu/arc-theme-xfwm4-hidpi/archive/refs/heads/master.tar.gz | tar xz -C /tmp/arc-build --strip-components=1
    
    cd /tmp/arc-build || return
    # Configurazione specifica per Xfce/GTK3
    ./autogen.sh --prefix="$HOME/.local" --disable-cinnamon --disable-gnome-shell --disable-metacity --disable-unity --with-gnome=3.22
    make install
    
    cd - > /dev/null
    rm -rf /tmp/arc-build
    ok "Tema Arc HiDPI installato in ~/.local/share/themes/"
}

bonifica_files() {
    info "Pulizia automatica dei file (rimozione numeri di riga)..."
    find "$DOTFILES" -type f \( -name "*.sh" -o -name "*.md" -o -name "bashrc" -o -name "alias*" \) \
        -not -path '*/.git/*' \
        -exec sed -i 's/^[[:space:]]*[0-9]\+[[:space:]]\+//' {} +
    ok "File bonificati."
}

safe_link() {
    local src="$1"
    local dst="$2"
    if [ -L "$dst" ]; then rm "$dst"
    elif [ -e "$dst" ]; then
        mv "$dst" "${dst}.bak_$(date +%Y%m%d_%H%M%S)"
    fi
    ln -sf "$src" "$dst"
}

deploy_config() {
    local src_root="$DOTFILES/config"
    local dst_root="$HOME/.config"
    for src in "$src_root"/*; do
        [ -e "$src" ] || continue
        safe_link "$src" "$dst_root/$(basename "$src")"
    done
    ok "Config linkate."
}

configura_lab() {
    header
    install_deps        # Installa i compilatori e i tool
    install_arc_hidpi   # Compila il tema con bottoni grandi
    bonifica_files
    
    info "Fix Cartelle Home (Italiano)..."
    xdg-user-dirs-update --force

    mkdir -p ~/.bashrc.d ~/.config ~/.local/share/fonts ~/bin
    ln -sf "$DOTFILES"/bash/etc_bash/bashrc.d/* ~/.bashrc.d/

    case "$OS_ID" in
        void) [ -d "$DOTFILES/Void/etc/bash/bashrc.d" ] && ln -sf "$DOTFILES"/Void/etc/bash/bashrc.d/* ~/.bashrc.d/ ;;
        arch) [ -d "$DOTFILES/Arch/etc/bash/bashrc.d" ] && ln -sf "$DOTFILES"/Arch/etc/bash/bashrc.d/* ~/.bashrc.d/ ;;
    esac

    ln -sf "$DOTFILES"/scripts/bin/* ~/bin/
    chmod +x "$DOTFILES"/scripts/bin/*
    safe_link "$DOTFILES/bash/etc_bash/bashrc" ~/.bashrc
    deploy_config

    ok "SETUP COMPLETATO!"
    echo -e "${G}1. Ricarica bash: source ~/.bashrc"
    echo -e "2. Impostazioni -> Gestore Finestre -> Seleziona Arc-Dark (HiDPI)${RESET}"
}

# --- MENU ---
while true; do
    header
    echo -e "  ${V}1)${RESET} 󰑭  SETUP TOTALE"
    echo -e "  ${V}2)${RESET} 󰊢  GIT PIGIA"
    echo -e "  ${R}0)${RESET} 󰈆  ESCI"
    read -p "  Scegli: " scelta
    case $scelta in
        1) configura_lab ;;
        2) bash "$DOTFILES"/scripts/bin/ilnanny-git-manager.sh ;;
        0) exit 0 ;;
    esac
    echo -e "\nPremi INVIO..."; read
done
