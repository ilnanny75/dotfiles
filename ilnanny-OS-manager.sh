#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  ilnanny-OS-manager.sh — MASTER SETUP 2026
#  Gestore universale per Arch, Debian, Void
# ═══════════════════════════════════════════════════════════════════

# --- COLORI ---
V="\e[32m"  # Verde
R="\e[31m"  # Rosso
C="\e[36m"  # Ciano
G="\e[33m"  # Giallo
B="\e[1m"   # Bold
RESET="\e[0m"

# --- RILEVAMENTO SISTEMA ---
OS_ID=$(grep -w "ID" /etc/os-release | cut -d= -f2 | tr -d '"')

# --- FUNZIONI UTILITY ---
header() { clear; echo -e "${B}${C}󱓞  ilnanny LAB MANAGER — OS: ${OS_ID^^}${RESET}\n"; }
ok()     { echo -e "${V}✅ $*${RESET}"; }
info()   { echo -e "${C}ℹ️  $*${RESET}"; }

# --- CORE: CONFIGURAZIONE LABORATORIO ---
configura_lab() {
    header
    info "Inizio sincronizzazione dotfiles..."

    # 1. Creazione directory base
    mkdir -p ~/.bashrc.d ~/.config ~/.local/share/fonts ~/bin

    # 2. Gestione Nerd Fonts (Sposta quelli trovati nel repo e crea i link)
    if [ ! -d "$HOME/dotfiles/graphics/fonts" ]; then
        info "Creazione cartella fonts nel repo..."
        mkdir -p ~/dotfiles/graphics/fonts
        mv ~/.local/share/fonts/*Nerd* ~/dotfiles/graphics/fonts/ 2>/dev/null
    fi
    ln -sf ~/dotfiles/graphics/fonts/* ~/.local/share/fonts/
    fc-cache -f > /dev/null
    ok "Nerd Fonts pronti."

    # 3. Link Moduli Bash Universali (da bash/etc_bash/bashrc.d)
    info "Collegamento moduli Bash universali..."
    ln -sf ~/dotfiles/bash/etc_bash/bashrc.d/*.sh ~/.bashrc.d/

    # 4. Alias Specifici per Distro
    case "$OS_ID" in
        arch)
            info "Applicazione configurazione Arch..."
            ln -sf ~/dotfiles/Arch/etc/bash/bashrc.d/alias_arch ~/.bashrc.d/ ;;
        debian|mx)
            info "Applicazione configurazione Debian/MX..."
            ln -sf ~/dotfiles/Debian/etc/bash/bashrc.d/alias_debian ~/.bashrc.d/ ;;
        void)
            info "Applicazione configurazione Void..."
            ln -sf ~/dotfiles/Void/etc/bash/bashrc.d/alias_void ~/.bashrc.d/ ;;
    esac

    # 5. Link Script Binari (il cuore dei tuoi comandi)
    info "Link script in ~/bin..."
    ln -sf ~/dotfiles/scripts/bin/* ~/bin/
    chmod +x ~/dotfiles/scripts/bin/*

    # 6. Configurazione Ambienti Grafici (.config)
    info "Sincronizzazione cartelle .config..."
    for folder in geany gtk-3.0 openbox Thunar xfce4; do
        ln -sfn ~/dotfiles/config/"$folder" ~/.config/"$folder"
    done

    # 7. Bashrc Principale
    ln -sf ~/dotfiles/bash/etc_bash/bashrc ~/.bashrc

    ok "LABORATORIO CONFIGURATO CON SUCCESSO!"
    echo -e "${G}Ricarica con: source ~/.bashrc${RESET}"
}

# --- MENU PRINCIPALE ---
while true; do
    header
    echo -e "  ${V}1)${RESET} 󰑭  SETUP TOTALE (Auto-Detect OS)"
    echo -e "  ${V}2)${RESET} 󰊢  GIT MULTITOOL (Sincronizza Repo)"
    echo -e "  ${V}3)${RESET} 󰏫  EDIT README (Geany)"
    echo -e "  ${V}4)${RESET} 󱘲  CHECK LINK ROTTI"
    echo -e "  ${R}0)${RESET} 󰈆  ESCI"
    echo ""
    read -p "  Scegli opzione: " scelta

    case $scelta in
        1) configura_lab ;;
        2) bash ~/dotfiles/scripts/bin/git-multitool.sh ;;
        3) geany ~/dotfiles/README.md & ;;
        4) info "Ricerca link simbolici interrotti:"; find ~ -maxdepth 2 -xtype l ;;
        0) exit 0 ;;
        *) echo -e "${R}Opzione non valida!${RESET}" ;;
    esac
    echo -e "\n${G}Premi INVIO per tornare al menu...${RESET}"; read
done
