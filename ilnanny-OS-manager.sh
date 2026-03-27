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

header() {
    clear
    echo -e "${B}${C}󱓞  ilnanny LAB MANAGER — OS: ${OS_ID^^}${RESET}"
    echo -e "${C}─────────────────────────────────────────────────────${RESET}\n"
}

ok()     { echo -e "${V}✅ $*${RESET}"; }
info()   { echo -e "${C}ℹ️  $*${RESET}"; }
warn()   { echo -e "${G}⚠️  $*${RESET}"; }

bonifica_files() {
    info "Pulizia automatica dei file (rimozione numeri di riga)..."
    # Pulisce sh, md, bashrc e alias da numeri iniziali fantasma
    find ~/dotfiles -type f \( -name "*.sh" -o -name "*.md" -o -name "bashrc" -o -name "alias*" \) -not -path '*/.git/*' -exec sed -i 's/^[[:space:]]*[0-9]\+[[:space:]]\+//' {} +
    ok "Tutti i file nel repository sono stati bonificati."
}

configura_lab() {
    header
    bonifica_files
    info "Sincronizzazione dotfiles per ${OS_ID^^}..."

    # 1. Cartelle base
    mkdir -p ~/.bashrc.d ~/.config ~/.local/share/fonts ~/bin
    rm -rf ~/.bashrc.d/*

    # 2. Link Moduli Universali
    ln -sf ~/dotfiles/bash/etc_bash/bashrc.d/* ~/.bashrc.d/

    # 3. Logica Multi-OS
    case "$OS_ID" in
        arch)
            info "Attivazione moduli specifici ARCH..."
            [ -d ~/dotfiles/Arch/etc/bash/bashrc.d ] && ln -sf ~/dotfiles/Arch/etc/bash/bashrc.d/* ~/.bashrc.d/ ;;
        debian|mx)
            info "Attivazione moduli specifici DEBIAN/MX..."
            [ -d ~/dotfiles/Debian/etc/bash/bashrc.d ] && ln -sf ~/dotfiles/Debian/etc/bash/bashrc.d/* ~/.bashrc.d/ ;;
        void)
            info "Attivazione moduli specifici VOID..."
            [ -d ~/dotfiles/Void/etc/bash/bashrc.d ] && ln -sf ~/dotfiles/Void/etc/bash/bashrc.d/* ~/.bashrc.d/ ;;
    esac

    # 4. Link Eseguibili e Bashrc
    ln -sf ~/dotfiles/scripts/bin/* ~/bin/
    chmod +x ~/dotfiles/scripts/bin/*
    ln -sf ~/dotfiles/bash/etc_bash/bashrc ~/.bashrc

    # 5. Configurazione Grafica (Openbox, Geany, ecc.)
    for folder in geany gtk-3.0 openbox Thunar xfce4; do
        if [ -d ~/dotfiles/config/"$folder" ]; then
            ln -sfn ~/dotfiles/config/"$folder" ~/.config/"$folder"
        fi
    done

    ok "LABORATORIO CONFIGURATO CON SUCCESSO!"
    echo -e "${G}Ricarica con: source ~/.bashrc${RESET}"
}

# --- MENU PRINCIPALE ---
while true; do
    header
    echo -e "  ${V}1)${RESET} 󰑭  SETUP TOTALE (Auto-Detect OS & Fix)"
    echo -e "  ${V}2)${RESET} 󰊢  GIT PIGIA (Upload rapido)"
    echo -e "  ${V}3)${RESET} 🛠️  GIT MULTITOOL (Gestione avanzata)"
    echo -e "  ${V}4)${RESET} 🧹  BONIFICA MANUALE (Fix numeri riga)"
    echo -e "  ${V}5)${RESET} 󰏫  EDIT README (Geany)"
    echo -e "  ${R}0)${RESET} 󰈆  ESCI"
    echo ""
    read -p "  Scegli opzione: " scelta

    case $scelta in
        1) configura_lab ;;
        2) bash ~/dotfiles/scripts/bin/ilnanny-git-manager.sh ;;
        3) bash ~/dotfiles/scripts/bin/git-multitool.sh ;;
        4) bonifica_files ;;
        5) geany ~/dotfiles/README.md & ;;
        0) exit 0 ;;
        *) echo -e "${R}Opzione non valida!${RESET}" ;;
    esac
    echo -e "\n${G}Premi INVIO per tornare al menu...${RESET}"; read
done
