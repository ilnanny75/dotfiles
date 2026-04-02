#!/usr/bin/env bash
# ==============================================================================
#  postinstall.sh — Script di Post-Installazione e Verifica Software
#  Autore  : ilnanny / Cristian
#  Versione: 2.1 (Aggiornata con Glow e Geany-Plugins)
#  Distro  : Arch Linux | Debian/Ubuntu | Void Linux
#  Lingua  : Italiano
# ==============================================================================

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
#  COLORI E STILE
# ─────────────────────────────────────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
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

rileva_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case $ID in
            arch) DISTRO="arch" ;;
            debian|ubuntu|linuxmint|mx) DISTRO="debian" ;;
            void) DISTRO="void" ;;
            *) error "Distribuzione non supportata ($ID)."; exit 1 ;;
        esac
        info "Rilevata distribuzione: ${BOLD}$ID${RESET}"
    else
        error "Impossibile rilevare la distribuzione."; exit 1
    fi
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
    titolo "Installazione Strumenti di Sistema"
    case $DISTRO in
        arch)   sudo pacman -S --noconfirm base-devel git wget curl ufw glow ;;
        debian) sudo apt install -y build-essential git wget curl ufw glow ;;
        void)   sudo xbps-install -Sy base-devel git wget curl ufw glow ;;
    esac
    info "Strumenti di sistema e Glow installati."
}

installa_dev() {
    titolo "Sviluppo ed Editor"
    case $DISTRO in
        arch)   sudo pacman -S --noconfirm geany geany-plugins visual-studio-code-bin ;;
        debian) sudo apt install -y geany geany-plugin-markdown ;;
        void)   sudo xbps-install -Sy geany geany-plugins ;;
    esac
    info "Geany e plugin Markdown installati."
}

installa_desktop() {
    titolo "Ambienti Desktop / WM"
    info "Installazione DE predefinita (esempio: XFCE/Mate)..."
    # Aggiungi qui i tuoi pacchetti specifici se necessario
}

installa_grafica() {
    titolo "Grafica"
    case $DISTRO in
        arch)   sudo pacman -S --noconfirm gimp inkscape vlc ;;
        debian) sudo apt install -y gimp inkscape vlc ;;
        void)   sudo xbps-install -Sy gimp inkscape vlc ;;
    esac
}

installa_office() {
    titolo "Office"
    case $DISTRO in
        arch)   sudo pacman -S --noconfirm libreoffice-fresh ;;
        debian) sudo apt install -y libreoffice ;;
        void)   sudo xbps-install -Sy libreoffice ;;
    esac
}

installa_temi() {
    titolo "Temi e Aspetto"
    # Personalizza in base alle tue preferenze
    info "Installazione temi completata."
}

installa_browser() {
    titolo "Browser Web"
    case $DISTRO in
        arch)   sudo pacman -S --noconfirm firefox chromium ;;
        debian) sudo apt install -y firefox-esr chromium ;;
        void)   sudo xbps-install -Sy firefox chromium ;;
    esac
}

personalizza_terminale() {
    titolo "Personalizzazione Terminale"
    info "Configurazione Bash/Zsh e Alias..."
    # Aggiunta alias per Glow
    echo "alias markdown='glow'" >> ~/.bashrc
}

installa_nerd_fonts() {
    titolo "Nerd Fonts"
    info "Installazione font per il terminale..."
}

verifica_software() {
    titolo "Verifica Software Installato"
    for sw in git curl glow geany; do
        if command -v $sw &> /dev/null; then
            echo -e "${GREEN}[INSTAL]${RESET} $sw"
        else
            echo -e "${RED}[MANCAN]${RESET} $sw"
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  MENU PRINCIPALE
# ─────────────────────────────────────────────────────────────────────────────
menu_principale() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}POST-INSTALL MANAGER — ilnanny v2.1${RESET}"
        echo -e "${DIM}----------------------------------------${RESET}"
        echo -e " 1) Ambienti Grafici / WM"
        echo -e " 2) Applicazioni Grafiche"
        echo -e " 3) Suite Office"
        echo -e " 4) Strumenti di Sistema (Glow, UFW...)"
        echo -e " 5) Temi e Icone"
        echo -e " 6) Browser Web"
        echo -e " 7) Sviluppo (Geany + Markdown)"
        echo -e " 8) Personalizzazione Terminale"
        echo -e " 9) Nerd Fonts"
        echo -e " v) Verifica Software"
        echo -e " a) Aggiorna Sistema"
        echo -e " t) INSTALLAZIONE TOTALE"
        echo -e " q) Esci"
        echo -en "\nScegli un'opzione: "
        read -r opt

        case $opt in
            1) installa_desktop ; pausa ;;
            2) installa_grafica ; pausa ;;
            3) installa_office  ; pausa ;;
            4) installa_sistema ; pausa ;;
            5) installa_temi    ; pausa ;;
            6) installa_browser ; pausa ;;
            7) installa_dev     ; pausa ;;
            8) personalizza_terminale ; pausa ;;
            9) installa_nerd_fonts ; pausa ;;
            v|V) verifica_software ; pausa ;;
            a|A) aggiorna_sistema ; pausa ;;
            t|T)
                aggiorna_sistema
                installa_sistema
                installa_dev
                verifica_software
                pausa ;;
            q|Q) exit 0 ;;
            *) warn "Opzione non valida." ; sleep 1 ;;
        esac
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────
main() {
    rileva_distro
    menu_principale
}

main "$@"
