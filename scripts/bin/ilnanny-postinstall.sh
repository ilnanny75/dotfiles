#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Master script di post-installazione per Arch, Debian e Void. 
# Installa suite software, temi, font e ottimizza il sistema.
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
#  COLORI E STILE
# ─────────────────────────────────────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"

LOG_FILE="$HOME/postinstall.log"

# ─────────────────────────────────────────────────────────────────────────────
#  FUNZIONI DI UTILITÀ
# ─────────────────────────────────────────────────────────────────────────────
titolo() { echo -e "\n${BLUE}${BOLD}=== $1 ===${RESET}\n"; }
info()   { echo -e "${GREEN}[INFO]${RESET} $1"; }
warn()   { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error()  { echo -e "${RED}[ERROR]${RESET} $1"; }

pausa() {
    echo -e "\n${DIM}Premi un tasto per continuare...${RESET}"
    read -n 1 -s -r
}

chiedi() {
    echo -en "${CYAN}Installare $1? (s/n): ${RESET}"
    read -r risposta
    [[ "$risposta" =~ ^[Ss]$ ]]
}

rileva_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case $ID in
            arch) DISTRO="arch" ;;
            debian|ubuntu|linuxmint|mx) DISTRO="debian" ;;
            void) DISTRO="void" ;;
            *) error "Distribuzione non supportata ($ID)."; exit 1 ;;
        esac
        info "Distribuzione rilevata: ${BOLD}$ID${RESET}"
    fi
}

installa_pkg() {
    local p_arch=$1 p_deb=$2 p_void=$3
    case $DISTRO in
        arch)   [ -n "$p_arch" ] && sudo pacman -S --noconfirm $p_arch ;;
        debian) [ -n "$p_deb" ]  && sudo apt install -y $p_deb ;;
        void)   [ -n "$p_void" ] && sudo xbps-install -Sy $p_void ;;
    esac
}

# ─────────────────────────────────────────────────────────────────────────────
#  FUNZIONI DI INSTALLAZIONE
# ─────────────────────────────────────────────────────────────────────────────

aggiorna_sistema() {
    titolo "Aggiornamento Sistema"
    case $DISTRO in
        arch)   sudo pacman -Syu --noconfirm ;;
        debian) sudo apt update && sudo apt upgrade -y ;;
        void)   sudo xbps-install -Syu ;;
    esac
}

installa_sistema() {
    titolo "Strumenti di Sistema"
    chiedi "Git, Wget e Curl" && installa_pkg "git wget curl" "git wget curl" "git wget curl"
    chiedi "UFW (Firewall)" && installa_pkg "ufw" "ufw" "ufw"
    chiedi "Glow (Markdown)" && installa_pkg "glow" "glow" "glow"
    chiedi "Unzip e Fontconfig" && installa_pkg "unzip fontconfig" "unzip fontconfig" "unzip fontconfig"
}

installa_dev() {
    titolo "Sviluppo ed Editor"
    chiedi "Geany (+ plugin)" && installa_pkg "geany geany-plugins" "geany geany-plugins" "geany geany-plugins"
    
    chiedi "Visual Studio Code" && {
        case $DISTRO in
            arch) installa_pkg "code" "" "" ;;
            debian)
                # Installazione dipendenze per repository esterni
                sudo apt update
                sudo apt install -y curl gpg apt-transport-https
                # Configurazione repository Microsoft
                curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/ms-vscode.gpg
                echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ms-vscode.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
                sudo apt update
                sudo apt install -y code
                ;;
            void) installa_pkg "" "" "vscode" ;;
        esac
    }
}

installa_grafica() {
    titolo "Grafica e Video"
    chiedi "GIMP" && installa_pkg "gimp" "gimp" "gimp"
    chiedi "VLC" && installa_pkg "vlc" "vlc" "vlc"
    chiedi "Inkscape" && installa_pkg "inkscape" "inkscape" "inkscape"
}

installa_browser() {
    titolo "Browser Web"
    chiedi "Firefox" && {
        if [ "$DISTRO" == "debian" ]; then installa_pkg "" "firefox-esr" ""; else installa_pkg "firefox" "" "firefox"; fi
    }
    chiedi "Chromium" && installa_pkg "chromium" "chromium" "chromium"
}

installa_temi_icone() {
    titolo "Temi e Icone"
    mkdir -p ~/.icons ~/.themes
    TEMP_THEMES=$(mktemp -d)

    if chiedi "Icon Theme Lila-HD"; then
        git clone --depth 1 https://github.com/ilnanny75/Lila-HD-Icon-Theme-Official "$TEMP_THEMES/Lila-HD"
        cp -r "$TEMP_THEMES/Lila-HD" ~/.icons/
    fi

    if chiedi "Tema GTK Nordic"; then
        git clone --depth 1 https://github.com/EliverLara/Nordic "$TEMP_THEMES/Nordic"
        cp -r "$TEMP_THEMES/Nordic" ~/.themes/
    fi

    rm -rf "$TEMP_THEMES"
}

installa_nerd_fonts() {
    titolo "Nerd Fonts - Selezione Retina"
    
    if chiedi "JetBrainsMono Nerd Font (Retina/Regular)"; then
        FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerd"
        mkdir -p "$FONT_DIR"
        TEMP_DIR=$(mktemp -d)
        
        if wget -q --show-progress -P "$TEMP_DIR" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz; then
            tar -xf "$TEMP_DIR/JetBrainsMono.tar.xz" -C "$TEMP_DIR"
            find "$TEMP_DIR" -name "*Retina*" -exec cp {} "$FONT_DIR/" \;
            find "$TEMP_DIR" -name "*Regular*" -exec cp {} "$FONT_DIR/" \;
            
            fc-cache -f -v > /dev/null
            info "Installazione completata."
        fi
        rm -rf "$TEMP_DIR"
    fi
}

installa_flatpak() {
    titolo "Gestione Flatpak"
    if chiedi "Flatpak e Flathub"; then
        installa_pkg "flatpak" "flatpak" "flatpak"
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
#  MENU PRINCIPALE
# ─────────────────────────────────────────────────────────────────────────────
menu_principale() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}POST-INSTALL MANAGER — ilnanny v2.6${RESET}"
        echo -e "${DIM}----------------------------------------${RESET}"
        echo -e " 1) Applicazioni Grafiche"
        echo -e " 2) Strumenti di Sistema"
        echo -e " 3) Browser Web"
        echo -e " 4) Sviluppo (Geany, VSCode)"
        echo -e " 5) Temi e Icone"
        echo -e " 6) Flatpak + Flathub"
        echo -e " 7) Nerd Fonts (LEGGERO)"
        echo -e " a) Aggiorna Sistema"
        echo -e " q) Esci"
        echo -en "\nScelta opzione: "
        read -r opt

        case $opt in
            1) installa_grafica ; pausa ;;
            2) installa_sistema ; pausa ;;
            3) installa_browser ; pausa ;;
            4) installa_dev     ; pausa ;;
            5) installa_temi_icone ; pausa ;;
            6) installa_flatpak ; pausa ;;
            7) installa_nerd_fonts ; pausa ;;
            a|A) aggiorna_sistema ; pausa ;;
            q|Q) exit 0 ;;
            *) warn "Opzione non valida." ; sleep 1 ;;
        esac
    done
}

main() {
    rileva_distro
    menu_principale
}

main "$@"
