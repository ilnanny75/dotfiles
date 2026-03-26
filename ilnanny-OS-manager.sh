#!/usr/bin/env bash
#==========================================================
#   ILNANNY MASTER-SCRIPT 2026 - UNIVERSAL EDITION
#   Sistemi: Void Linux, Debian/MX, Arch Linux
#   Hardware: MateBook ES8336 & Universal
#==========================================================

CYAN='\033[0;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Rilevamento OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS=$(uname -s)
fi

header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "║      ILNANNY MASTER-SCRIPT 2026 - OS: ${YELLOW}$OS${CYAN}      ║"
    echo -e "╚════════════════════════════════════════════════════╝${NC}"
}

# 1. DEPLOY DOTFILES (Link Simbolici)
deploy_configs() {
    echo -e "\n${YELLOW}>> Sincronizzazione Dotfiles per $OS...${NC}"
    USER_HOME="/home/$SUDO_USER"
    [ "$SUDO_USER" == "" ] && USER_HOME="$HOME"
    DOT_DIR="$USER_HOME/dotfiles"

    # Creazione cartelle base
    mkdir -p "$USER_HOME/.config"
    mkdir -p "$USER_HOME/.themes"

    # Link .config (Openbox, Geany, Thunar, ecc)
    for folder in "$DOT_DIR/config/"*; do
        ln -sf "$folder" "$USER_HOME/.config/$(basename "$folder")"
    done

    # Link Editor e X
    ln -sf "$DOT_DIR/editors/.vimrc" "$USER_HOME/.vimrc"
    ln -sf "$DOT_DIR/editors/.nanorc" "$USER_HOME/.nanorc"
    ln -sf "$DOT_DIR/Void/home/.xinitrc" "$USER_HOME/.xinitrc"

    # Link Alias (Specifico per OS)
    mkdir -p /etc/bash/bashrc.d
    if [ "$OS" == "void" ]; then
        sudo ln -sf "$DOT_DIR/Void/etc/bash/bashrc.d/alias_void" /etc/bash/bashrc.d/alias_void
    else
        sudo ln -sf "$DOT_DIR/bash/etc_bash/bashrc.d/alias.sh" /etc/bash/bashrc.d/alias.sh
    fi

    # Permessi Script
    chmod +x "$DOT_DIR/scripts/bin/"*.sh
    echo -e "${GREEN}Deploy completato!${NC}"
}

# 2. INSTALLAZIONE SOFTWARE (Multi-Distro)
install_software() {
    APPS="geany git htop mpv nitrogen gvfs gvfs-mtp fzf vlc bleachbit"
    echo -e "\n${YELLOW}>> Installazione software su $OS...${NC}"

    case $OS in
        void) sudo xbps-install -Sy $APPS ;;
        debian|mx) sudo apt update && sudo apt install -y $APPS ;;
        arch) sudo pacman -Sy $APPS ;;
        *) echo -e "${RED}Sistema non supportato.${NC}" ;;
    esac
}

# 3. FIX AUDIO MATEBOOK (Solo se necessario)
fix_matebook() {
    MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
    if [[ "$MODEL" == *"MateBook"* && "$OS" == "void" ]]; then
        echo -e "${GREEN}MateBook rilevato su Void. Applico fix audio...${NC}"
        sudo xbps-install -Sy sof-firmware alsa-ucm-conf
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    else
        echo -e "${YELLOW}Fix non necessario o hardware diverso.${NC}"
    fi
}

# 4. MANUTENZIONE & README
show_info() {
    echo -e "\n1) WIKI 2) MEMO 3) TASTI 4) GIT"
    read -p "Scegli: " choice
    case $choice in
        1) less ~/dotfiles/WIKI_LINUX.md ;;
        2) less ~/dotfiles/MEMORANDUM.md ;;
        3) less "~/dotfiles/scorciatoie da tastiera.md" ;;
        4) less ~/dotfiles/PROMEMORIA_GIT.md ;;
    esac
}

# --- MENU PRINCIPALE ---
while true; do
    header
    echo -e "1) ${CYAN}DEPLOY DOTFILES${NC} (Link configurazioni)"
    echo -e "2) ${YELLOW}INSTALLA SOFTWARE${NC} (Auto-rilevamento)"
    echo -e "3) ${RED}FIX HARDWARE${NC} (MateBook)"
    echo -e "4) ${GREEN}LEGGI DOCUMENTAZIONE${NC} (Wiki/Memo)"
    echo -e "q) Esci"
    echo -ne "\nOpzione: "
    read -r opt
    case $opt in
        1) deploy_configs ;;
        2) install_software ;;
        3) fix_matebook ;;
        4) show_info ;;
        q) exit 0 ;;
    esac
    echo -e "\nPremi Invio..."
    read
done
