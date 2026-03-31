#!/usr/bin/env bash
# ==============================================================================
#  postinstall.sh — Script di Post-Installazione e Verifica Software
#  Autore  : ilnanny / Cristian
#  Versione: 2.0
#  Distro  : Arch Linux | Debian/Ubuntu | Void Linux
#  Lingua  : Italiano
# ==============================================================================
#
#  UTILIZZO:
#    chmod +x postinstall.sh
#    ./postinstall.sh
#
#  STRUTTURA DEI MENU:
#    1. Ambienti Grafici / Window Manager
#    2. Applicazioni Grafiche (GIMP, Inkscape…)
#    3. Suite Office
#    4. Strumenti di Sistema
#    5. Temi GTK / Icone / Cursori
#    6. Browser Web
#    7. Sviluppo (editor, IDE, linguaggi…)
#    8. Personalizzazione Terminale
#    9. Nerd Fonts
#   10. Verifica software installato
#   11. Aggiornamento sistema
#
# ==============================================================================

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
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

BG_BLUE="\033[44m"
BG_GREEN="\033[42m"
BG_RED="\033[41m"

# ─────────────────────────────────────────────────────────────────────────────
#  FUNZIONI DI OUTPUT
# ─────────────────────────────────────────────────────────────────────────────

info()    { echo -e "${CYAN}${BOLD}[INFO]${RESET}  $*"; }
ok()      { echo -e "${GREEN}${BOLD}[ OK ]${RESET}  $*"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARN]${RESET}  $*"; }
errore()  { echo -e "${RED}${BOLD}[ERR ]${RESET}  $*" >&2; }
titolo()  { echo -e "\n${BG_BLUE}${WHITE}${BOLD}  $*  ${RESET}\n"; }
sezione() { echo -e "\n${MAGENTA}${BOLD}══════════════════════════════════════════${RESET}"; \
            echo -e "${MAGENTA}${BOLD}  $*${RESET}"; \
            echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════${RESET}\n"; }
voce()    { echo -e "  ${CYAN}▸${RESET} $*"; }
sep()     { echo -e "${DIM}──────────────────────────────────────────${RESET}"; }

# Pausa con invito
pausa() { echo -e "\n${DIM}Premi INVIO per continuare...${RESET}"; read -r; }

# ─────────────────────────────────────────────────────────────────────────────
#  LOG FILE
# ─────────────────────────────────────────────────────────────────────────────
LOG_FILE="$HOME/postinstall_$(date +%Y%m%d_%H%M%S).log"
# Ridirigiamo solo gli errori interni; le operazioni vengono stampate a video E nel log
exec > >(tee -a "$LOG_FILE") 2>&1

info "Log salvato in: $LOG_FILE"

# ─────────────────────────────────────────────────────────────────────────────
#  RILEVAMENTO DISTRIBUZIONE
# ─────────────────────────────────────────────────────────────────────────────
rileva_distro() {
    DISTRO=""
    PKG_INSTALL=""
    PKG_QUERY=""
    AUR_HELPER=""

    if [ -f /etc/arch-release ]; then
        DISTRO="arch"
        # Cerca helper AUR disponibile
        for helper in yay paru trizen; do
            if command -v "$helper" &>/dev/null; then
                AUR_HELPER="$helper"
                break
            fi
        done
        PKG_INSTALL="${AUR_HELPER:-pacman} -S --noconfirm --needed"
        PKG_QUERY="pacman -Qi"
        ok "Distribuzione rilevata: ${BOLD}Arch Linux${RESET}"
        [ -n "$AUR_HELPER" ] && info "AUR helper: $AUR_HELPER" || warn "Nessun AUR helper trovato. Uso pacman."

    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
        PKG_INSTALL="apt-get install -y"
        PKG_QUERY="dpkg -s"
        ok "Distribuzione rilevata: ${BOLD}Debian/Ubuntu${RESET}"

    elif [ -f /etc/void-release ] || grep -qi "void" /etc/os-release 2>/dev/null; then
        DISTRO="void"
        PKG_INSTALL="xbps-install -Sy"
        PKG_QUERY="xbps-query -S"
        ok "Distribuzione rilevata: ${BOLD}Void Linux${RESET}"

    else
        errore "Distribuzione non supportata. Lo script supporta: Arch, Debian/Ubuntu, Void Linux."
        exit 1
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
#  INSTALLAZIONE PACCHETTI (con gestione errori)
# ─────────────────────────────────────────────────────────────────────────────

# Mappa pacchetti per distro: arch|debian|void
# Uso: pkg_nome "pacchetto-arch" "pacchetto-debian" "pacchetto-void"
installa_pkgs() {
    # Riceve un array di nomi pacchetto già selezionati per la distro corrente
    local pkgs=("$@")
    if [ ${#pkgs[@]} -eq 0 ]; then
        warn "Nessun pacchetto da installare."; return 0
    fi
    info "Installo: ${pkgs[*]}"
    if ! sudo $PKG_INSTALL "${pkgs[@]}"; then
        errore "Alcuni pacchetti potrebbero non essere stati installati correttamente."
    fi
}

# Controlla se un pacchetto è già installato
e_installato() {
    local pkg="$1"
    case "$DISTRO" in
        arch)  pacman -Qi "$pkg" &>/dev/null ;;
        debian) dpkg -s "$pkg" &>/dev/null ;;
        void)  xbps-query -S "$pkg" &>/dev/null ;;
    esac
}

# ─────────────────────────────────────────────────────────────────────────────
#  MENU GENERICO MULTI-SELEZIONE
#  Uso: multi_menu "Titolo" item1 item2 item3 …
#  Ritorna gli indici scelti in SELEZIONE[]
# ─────────────────────────────────────────────────────────────────────────────
SELEZIONE=()

multi_menu() {
    local titolo="$1"; shift
    local voci=("$@")
    local scelte=()
    local n=${#voci[@]}

    sezione "$titolo"
    echo -e "  ${DIM}Inserisci i numeri separati da spazio (es: 1 3 5) oppure ${BOLD}0${RESET}${DIM} per tutti, ${BOLD}q${RESET}${DIM} per saltare.${RESET}\n"

    local i=1
    for v in "${voci[@]}"; do
        printf "  ${CYAN}%2d${RESET}. %s\n" "$i" "$v"
        ((i++))
    done
    sep
    echo -ne "\n  ${BOLD}Scelta: ${RESET}"
    read -r -a input

    SELEZIONE=()
    for s in "${input[@]}"; do
        if [[ "$s" == "q" ]]; then
            SELEZIONE=(); return 0
        elif [[ "$s" == "0" ]]; then
            SELEZIONE=()
            for j in $(seq 0 $((n-1))); do SELEZIONE+=("$j"); done
            return 0
        elif [[ "$s" =~ ^[0-9]+$ ]] && (( s >= 1 && s <= n )); then
            SELEZIONE+=($((s-1)))
        else
            warn "Valore non valido ignorato: $s"
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  MENU SINGOLA SCELTA
# ─────────────────────────────────────────────────────────────────────────────
SCELTA_SINGOLA=""

menu_singolo() {
    local titolo="$1"; shift
    local voci=("$@")
    local n=${#voci[@]}

    sezione "$titolo"
    echo -e "  ${DIM}Scegli un'opzione (${BOLD}q${RESET}${DIM} per saltare):${RESET}\n"

    local i=1
    for v in "${voci[@]}"; do
        printf "  ${CYAN}%2d${RESET}. %s\n" "$i" "$v"
        ((i++))
    done
    sep
    echo -ne "\n  ${BOLD}Scelta: ${RESET}"
    read -r s

    SCELTA_SINGOLA=""
    if [[ "$s" == "q" ]]; then return 0
    elif [[ "$s" =~ ^[0-9]+$ ]] && (( s >= 1 && s <= n )); then
        SCELTA_SINGOLA="${voci[$((s-1))]}"
    else
        warn "Scelta non valida."
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
#  AGGIORNAMENTO SISTEMA
# ─────────────────────────────────────────────────────────────────────────────
aggiorna_sistema() {
    sezione "Aggiornamento del sistema"
    case "$DISTRO" in
        arch)   sudo pacman -Syu --noconfirm ;;
        debian) sudo apt-get update && sudo apt-get upgrade -y ;;
        void)   sudo xbps-install -Su ;;
    esac
    ok "Sistema aggiornato."
}

# ─────────────────────────────────────────────────────────────────────────────
#  1. AMBIENTI GRAFICI / WINDOW MANAGER
# ─────────────────────────────────────────────────────────────────────────────
installa_desktop() {
    # Definizione: "Etichetta|arch|debian|void"
    local voci_label=(
        "Openbox (WM leggero)"
        "i3-gaps / i3wm"
        "bspwm + sxhkd"
        "Qtile"
        "Fluxbox"
        "XFCE4 (DE completo)"
        "LXQt (DE leggero)"
        "MATE"
        "Budgie"
        "Cinnamon"
    )

    # Pacchetti per architettura: arch | debian | void
    declare -A PKG_ARCH PKG_DEB PKG_VOID
    PKG_ARCH=(
        [0]="openbox obconf obmenu-generator tint2 nitrogen"
        [1]="i3-gaps i3status i3blocks dmenu"
        [2]="bspwm sxhkd polybar rofi"
        [3]="qtile"
        [4]="fluxbox"
        [5]="xfce4 xfce4-goodies lightdm lightdm-slick-greeter"
        [6]="lxqt sddm"
        [7]="mate mate-extra lightdm"
        [8]="budgie-desktop"
        [9]="cinnamon"
    )
    PKG_DEB=(
        [0]="openbox obconf tint2 nitrogen"
        [1]="i3 i3status i3blocks dmenu"
        [2]="bspwm sxhkd polybar rofi"
        [3]="qtile"
        [4]="fluxbox"
        [5]="xfce4 xfce4-goodies lightdm"
        [6]="lxqt sddm"
        [7]="mate-desktop-environment lightdm"
        [8]="budgie-desktop"
        [9]="cinnamon"
    )
    PKG_VOID=(
        [0]="openbox obconf tint2 nitrogen"
        [1]="i3 i3status i3blocks dmenu"
        [2]="bspwm sxhkd polybar rofi"
        [3]="qtile"
        [4]="fluxbox"
        [5]="xfce4 xfce4-goodies lightdm"
        [6]="lxqt sddm"
        [7]="mate mate-extra lightdm"
        [8]=""
        [9]=""
    )

    # Pacchetti comuni (display server, utility)
    local comuni_arch="xorg-server xorg-xinit xorg-xrandr arandr picom dunst rofi"
    local comuni_deb="xorg xinit x11-xserver-utils arandr picom dunst rofi"
    local comuni_void="xorg xinit arandr dunst rofi"

    multi_menu "Ambienti Grafici / Window Manager" "${voci_label[@]}"

    if [ ${#SELEZIONE[@]} -eq 0 ]; then
        warn "Nessun ambiente selezionato. Skip."; return 0
    fi

    # Prima installa i pacchetti base comuni
    info "Installo dipendenze comuni X.org…"
    case "$DISTRO" in
        arch)   installa_pkgs $comuni_arch ;;
        debian) installa_pkgs $comuni_deb ;;
        void)   installa_pkgs $comuni_void ;;
    esac

    for idx in "${SELEZIONE[@]}"; do
        local label="${voci_label[$idx]}"
        info "Installo: $label"
        local pkgs=""
        case "$DISTRO" in
            arch)   pkgs="${PKG_ARCH[$idx]}" ;;
            debian) pkgs="${PKG_DEB[$idx]}" ;;
            void)   pkgs="${PKG_VOID[$idx]}" ;;
        esac
        if [ -z "$pkgs" ]; then
            warn "$label non disponibile su questa distro. Skip."
        else
            installa_pkgs $pkgs
            ok "$label installato."
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  2. APPLICAZIONI GRAFICHE
# ─────────────────────────────────────────────────────────────────────────────
installa_grafica() {
    local voci_label=(
        "GIMP (editor immagini)"
        "Inkscape (vettoriale)"
        "Krita (pittura digitale)"
        "Darktable (RAW/fotografia)"
        "RawTherapee"
        "Shotwell (gestione foto)"
        "Digikam"
        "Pinta (alternativa Paint)"
        "Kdenlive (video editing)"
        "Handbrake (conversione video)"
        "VLC (player multimediale)"
        "MPV (player leggero)"
        "Audacity (audio editor)"
        "Blender (3D)"
        "Scribus (DTP)"
    )

    declare -A GA_ARCH GA_DEB GA_VOID
    GA_ARCH=([0]="gimp" [1]="inkscape" [2]="krita" [3]="darktable" [4]="rawtherapee"
             [5]="shotwell" [6]="digikam" [7]="pinta" [8]="kdenlive" [9]="handbrake"
             [10]="vlc" [11]="mpv" [12]="audacity" [13]="blender" [14]="scribus")
    GA_DEB=([0]="gimp" [1]="inkscape" [2]="krita" [3]="darktable" [4]="rawtherapee"
            [5]="shotwell" [6]="digikam" [7]="pinta" [8]="kdenlive" [9]="handbrake"
            [10]="vlc" [11]="mpv" [12]="audacity" [13]="blender" [14]="scribus")
    GA_VOID=([0]="gimp" [1]="inkscape" [2]="krita" [3]="darktable" [4]="rawtherapee"
             [5]="" [6]="digikam" [7]="pinta" [8]="kdenlive" [9]="handbrake"
             [10]="vlc" [11]="mpv" [12]="audacity" [13]="blender" [14]="scribus")

    multi_menu "Applicazioni Grafiche e Multimediali" "${voci_label[@]}"
    [ ${#SELEZIONE[@]} -eq 0 ] && return 0

    for idx in "${SELEZIONE[@]}"; do
        local pkgs=""
        case "$DISTRO" in
            arch)   pkgs="${GA_ARCH[$idx]}" ;;
            debian) pkgs="${GA_DEB[$idx]}" ;;
            void)   pkgs="${GA_VOID[$idx]}" ;;
        esac
        [ -z "$pkgs" ] && { warn "${voci_label[$idx]}: non disponibile. Skip."; continue; }
        installa_pkgs $pkgs && ok "${voci_label[$idx]} installato."
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  3. SUITE OFFICE
# ─────────────────────────────────────────────────────────────────────────────
installa_office() {
    local voci_label=(
        "LibreOffice (suite completa)"
        "LibreOffice Fresh (versione bleeding edge)"
        "OnlyOffice"
        "WPS Office (AUR/Flatpak)"
        "Evince (PDF/documenti)"
        "Okular (PDF avanzato)"
        "Masterpdf Editor"
        "Zathura (PDF leggero)"
        "Calibre (eBook)"
        "Thunderbird (email)"
        "Geary (email GNOME)"
    )

    declare -A OF_ARCH OF_DEB OF_VOID
    OF_ARCH=([0]="libreoffice-still" [1]="libreoffice-fresh" [2]="onlyoffice-bin"
             [3]="wps-office" [4]="evince" [5]="okular" [6]="masterpdfeditor"
             [7]="zathura zathura-pdf-mupdf" [8]="calibre" [9]="thunderbird" [10]="geary")
    OF_DEB=([0]="libreoffice" [1]="libreoffice" [2]="onlyoffice-desktopeditors"
            [3]="" [4]="evince" [5]="okular" [6]=""
            [7]="zathura zathura-djvu" [8]="calibre" [9]="thunderbird" [10]="geary")
    OF_VOID=([0]="libreoffice" [1]="libreoffice" [2]=""
             [3]="" [4]="evince" [5]="okular" [6]=""
             [7]="zathura zathura-pdf-mupdf" [8]="calibre" [9]="thunderbird" [10]="geary")

    multi_menu "Suite Office e Documenti" "${voci_label[@]}"
    [ ${#SELEZIONE[@]} -eq 0 ] && return 0

    for idx in "${SELEZIONE[@]}"; do
        local pkgs=""
        case "$DISTRO" in
            arch)   pkgs="${OF_ARCH[$idx]}" ;;
            debian) pkgs="${OF_DEB[$idx]}" ;;
            void)   pkgs="${OF_VOID[$idx]}" ;;
        esac
        [ -z "$pkgs" ] && { warn "${voci_label[$idx]}: non disponibile su questa distro. Considera Flatpak."; continue; }
        installa_pkgs $pkgs && ok "${voci_label[$idx]} installato."
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  4. STRUMENTI DI SISTEMA
# ─────────────────────────────────────────────────────────────────────────────
installa_sistema() {
    local voci_label=(
        "GParted (gestore partizioni)"
        "ntfs-3g (supporto NTFS)"
        "gvfs + gvfs-mtp (mount automatico)"
        "udiskie (mount automatico USB)"
        "Thunar (file manager)"
        "Nautilus (file manager GNOME)"
        "PCManFM (file manager leggero)"
        "Nemo (file manager Cinnamon)"
        "htop (monitor processi)"
        "btop (monitor avanzato)"
        "neofetch (info sistema)"
        "fastfetch (info sistema veloce)"
        "baobab (analisi disco)"
        "Bleachbit (pulizia sistema)"
        "Timeshift (backup/snapshot)"
        "rsync (sincronizzazione file)"
        "Unrar/Unzip/7zip (archivi)"
        "NetworkManager + nmtui"
        "Blueman (bluetooth)"
        "PulseAudio / PipeWire"
        "pavucontrol (controllo audio)"
        "xdg-utils (mime/default apps)"
        "Flatpak (supporto app flatpak)"
        "AppArmor / Firewalld"
    )

    declare -A SIS_ARCH SIS_DEB SIS_VOID
    SIS_ARCH=(
        [0]="gparted" [1]="ntfs-3g" [2]="gvfs gvfs-mtp gvfs-smb"
        [3]="udiskie" [4]="thunar thunar-volman thunar-archive-plugin"
        [5]="nautilus" [6]="pcmanfm" [7]="nemo"
        [8]="htop" [9]="btop" [10]="neofetch" [11]="fastfetch"
        [12]="baobab" [13]="bleachbit" [14]="timeshift"
        [15]="rsync" [16]="unrar unzip p7zip"
        [17]="networkmanager nm-connection-editor"
        [18]="blueman" [19]="pipewire pipewire-pulse wireplumber"
        [20]="pavucontrol" [21]="xdg-utils"
        [22]="flatpak" [23]="apparmor firewalld"
    )
    SIS_DEB=(
        [0]="gparted" [1]="ntfs-3g" [2]="gvfs gvfs-backends"
        [3]="udiskie" [4]="thunar thunar-volman thunar-archive-plugin"
        [5]="nautilus" [6]="pcmanfm" [7]="nemo"
        [8]="htop" [9]="btop" [10]="neofetch" [11]="fastfetch"
        [12]="baobab" [13]="bleachbit" [14]="timeshift"
        [15]="rsync" [16]="unrar unzip p7zip-full"
        [17]="network-manager network-manager-gnome"
        [18]="blueman" [19]="pipewire pipewire-pulse"
        [20]="pavucontrol" [21]="xdg-utils"
        [22]="flatpak" [23]="apparmor firewalld"
    )
    SIS_VOID=(
        [0]="gparted" [1]="ntfs-3g" [2]="gvfs gvfs-mtp"
        [3]="udiskie" [4]="Thunar thunar-volman"
        [5]="nautilus" [6]="pcmanfm" [7]=""
        [8]="htop" [9]="btop" [10]="neofetch" [11]=""
        [12]="baobab" [13]="bleachbit" [14]=""
        [15]="rsync" [16]="unrar unzip p7zip"
        [17]="NetworkManager" [18]="blueman"
        [19]="pipewire wireplumber" [20]="pavucontrol"
        [21]="xdg-utils" [22]="flatpak" [23]="apparmor"
    )

    multi_menu "Strumenti di Sistema" "${voci_label[@]}"
    [ ${#SELEZIONE[@]} -eq 0 ] && return 0

    for idx in "${SELEZIONE[@]}"; do
        local pkgs=""
        case "$DISTRO" in
            arch)   pkgs="${SIS_ARCH[$idx]}" ;;
            debian) pkgs="${SIS_DEB[$idx]}" ;;
            void)   pkgs="${SIS_VOID[$idx]}" ;;
        esac
        [ -z "$pkgs" ] && { warn "${voci_label[$idx]}: non disponibile su questa distro. Skip."; continue; }
        installa_pkgs $pkgs && ok "${voci_label[$idx]} installato."
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  5. TEMI GTK / ICONE / CURSORI / FONT DI SISTEMA
# ─────────────────────────────────────────────────────────────────────────────
installa_temi() {
    local voci_label=(
        "--- TEMI GTK ---"
        "Adwaita / Adwaita-dark (GNOME default)"
        "Arc Theme (flat moderno)"
        "Materia Theme (Material Design)"
        "Nordic Theme (dark nord)"
        "Catppuccin GTK"
        "Dracula GTK Theme"
        "Orchis Theme"
        "--- ICONE ---"
        "Papirus Icon Theme"
        "Numix Icon Theme"
        "Tela Icons"
        "Beautyline Icons (AUR)"
        "Flat Remix Icons"
        "--- CURSORI ---"
        "Bibata Cursor"
        "Breeze Cursor (KDE)"
        "Xcursor-themes"
        "--- FONT DI SISTEMA ---"
        "Noto Fonts (Unicode)"
        "Liberation Fonts"
        "Cantarell Fonts"
        "DejaVu Fonts"
        "--- STRUMENTI ---"
        "lxappearance (gestione tema GTK)"
        "qt5ct (tema Qt5)"
        "kvantum (tema Qt avanzato)"
    )

    declare -A TEM_ARCH TEM_DEB TEM_VOID
    TEM_ARCH=(
        [0]="" [1]="gnome-themes-extra" [2]="arc-gtk-theme"
        [3]="materia-gtk-theme" [4]="nordic-theme" [5]="catppuccin-gtk-theme-mocha"
        [6]="dracula-gtk-theme" [7]="orchis-theme"
        [8]="" [9]="papirus-icon-theme" [10]="numix-icon-theme"
        [11]="tela-icon-theme" [12]="beautyline" [13]="flat-remix"
        [14]="" [15]="bibata-cursor-theme" [16]="breeze-icons" [17]="xcursor-themes"
        [18]="" [19]="noto-fonts noto-fonts-emoji" [20]="ttf-liberation"
        [21]="cantarell-fonts" [22]="ttf-dejavu"
        [23]="" [24]="lxappearance" [25]="qt5ct" [26]="kvantum"
    )
    TEM_DEB=(
        [0]="" [1]="gnome-themes-extra" [2]="arc-theme"
        [3]="materia-gtk-theme" [4]="" [5]=""
        [6]="" [7]=""
        [8]="" [9]="papirus-icon-theme" [10]="numix-icon-theme"
        [11]="" [12]="" [13]="flat-remix"
        [14]="" [15]="" [16]="breeze-icon-theme" [17]="xcursor-themes"
        [18]="" [19]="fonts-noto fonts-noto-color-emoji" [20]="fonts-liberation"
        [21]="fonts-cantarell" [22]="fonts-dejavu"
        [23]="" [24]="lxappearance" [25]="qt5ct" [26]="qt5-style-kvantum"
    )
    TEM_VOID=(
        [0]="" [1]="gnome-themes-extra" [2]="arc-theme"
        [3]="materia-gtk-theme" [4]="" [5]=""
        [6]="" [7]=""
        [8]="" [9]="papirus-icon-theme" [10]="numix-icon-theme"
        [11]="" [12]="" [13]=""
        [14]="" [15]="" [16]="breeze-icons" [17]="xcursor-themes"
        [18]="" [19]="noto-fonts" [20]="liberation-fonts-ttf"
        [21]="cantarell-fonts" [22]="dejavu-fonts-ttf"
        [23]="" [24]="lxappearance" [25]="qt5ct" [26]="kvantum"
    )

    multi_menu "Temi GTK, Icone, Cursori e Font" "${voci_label[@]}"
    [ ${#SELEZIONE[@]} -eq 0 ] && return 0

    for idx in "${SELEZIONE[@]}"; do
        local pkgs=""
        case "$DISTRO" in
            arch)   pkgs="${TEM_ARCH[$idx]}" ;;
            debian) pkgs="${TEM_DEB[$idx]}" ;;
            void)   pkgs="${TEM_VOID[$idx]}" ;;
        esac
        [ -z "$pkgs" ] && continue
        installa_pkgs $pkgs && ok "${voci_label[$idx]} installato."
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  6. BROWSER WEB
# ─────────────────────────────────────────────────────────────────────────────
installa_browser() {
    local voci_label=(
        "Firefox"
        "Firefox ESR"
        "Chromium"
        "Google Chrome (AUR/non-free)"
        "Brave Browser"
        "Vivaldi"
        "Librewolf (privacy-focused)"
        "Falkon (leggero Qt)"
        "Midori"
        "Lynx (terminale)"
        "w3m (terminale)"
    )

    declare -A BR_ARCH BR_DEB BR_VOID
    BR_ARCH=([0]="firefox" [1]="firefox-esr-bin" [2]="chromium"
             [3]="google-chrome" [4]="brave-bin" [5]="vivaldi"
             [6]="librewolf-bin" [7]="falkon" [8]="midori"
             [9]="lynx" [10]="w3m")
    BR_DEB=([0]="firefox-esr" [1]="firefox-esr" [2]="chromium"
            [3]="" [4]="" [5]=""
            [6]="" [7]="falkon" [8]="midori"
            [9]="lynx" [10]="w3m")
    BR_VOID=([0]="firefox" [1]="firefox" [2]="chromium"
             [3]="" [4]="" [5]=""
             [6]="" [7]="falkon" [8]="midori"
             [9]="lynx" [10]="w3m")

    multi_menu "Browser Web" "${voci_label[@]}"
    [ ${#SELEZIONE[@]} -eq 0 ] && return 0

    for idx in "${SELEZIONE[@]}"; do
        local pkgs=""
        case "$DISTRO" in
            arch)   pkgs="${BR_ARCH[$idx]}" ;;
            debian) pkgs="${BR_DEB[$idx]}" ;;
            void)   pkgs="${BR_VOID[$idx]}" ;;
        esac
        [ -z "$pkgs" ] && { warn "${voci_label[$idx]}: considera Flatpak o download diretto. Skip."; continue; }
        installa_pkgs $pkgs && ok "${voci_label[$idx]} installato."
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  7. SVILUPPO (editor, IDE, linguaggi, VCS, container…)
# ─────────────────────────────────────────────────────────────────────────────
installa_dev() {
    local voci_label=(
        "--- EDITOR / IDE ---"
        "Vim"
        "Neovim"
        "Nano (potenziato)"
        "Geany + plugin"
        "VSCodium (VSCode open)"
        "Visual Studio Code (AUR)"
        "Emacs"
        "Kate"
        "Mousepad"
        "--- BUILD / TOOLS ---"
        "git"
        "make / cmake / meson"
        "gcc / g++"
        "clang / llvm"
        "base-devel (arch) / build-essential (deb)"
        "--- LINGUAGGI ---"
        "Python3 + pip + venv"
        "Node.js + npm"
        "Rust (rustup)"
        "Go"
        "--- DATABASE ---"
        "SQLite3"
        "PostgreSQL client"
        "--- CONTAINER / VIRT ---"
        "Docker + docker-compose"
        "Podman"
        "VirtualBox"
        "--- RETE / DEBUG ---"
        "curl + wget"
        "net-tools + nmap"
        "Wireshark"
        "--- VERSIONING GRAFICO ---"
        "Gitg"
        "Meld (diff visivo)"
    )

    declare -A DEV_ARCH DEV_DEB DEV_VOID
    DEV_ARCH=(
        [0]="" [1]="vim" [2]="neovim" [3]="nano" [4]="geany geany-plugins"
        [5]="vscodium-bin" [6]="visual-studio-code-bin" [7]="emacs" [8]="kate" [9]="mousepad"
        [10]="" [11]="git" [12]="make cmake meson" [13]="gcc" [14]="clang llvm"
        [15]="base-devel"
        [16]="" [17]="python python-pip" [18]="nodejs npm" [19]="rustup" [20]="go"
        [21]="" [22]="sqlite" [23]="postgresql-libs"
        [24]="" [25]="docker docker-compose" [26]="podman" [27]="virtualbox"
        [28]="" [29]="curl wget" [30]="net-tools nmap" [31]="wireshark-qt"
        [32]="" [33]="gitg" [34]="meld"
    )
    DEV_DEB=(
        [0]="" [1]="vim" [2]="neovim" [3]="nano" [4]="geany geany-plugins"
        [5]="" [6]="" [7]="emacs" [8]="kate" [9]="mousepad"
        [10]="" [11]="git" [12]="make cmake meson" [13]="gcc" [14]="clang llvm"
        [15]="build-essential"
        [16]="" [17]="python3 python3-pip python3-venv" [18]="nodejs npm" [19]="" [20]="golang"
        [21]="" [22]="sqlite3" [23]="postgresql-client"
        [24]="" [25]="docker.io docker-compose" [26]="podman" [27]="virtualbox"
        [28]="" [29]="curl wget" [30]="net-tools nmap" [31]="wireshark-qt"
        [32]="" [33]="gitg" [34]="meld"
    )
    DEV_VOID=(
        [0]="" [1]="vim" [2]="neovim" [3]="nano" [4]="geany geany-plugins"
        [5]="" [6]="" [7]="emacs" [8]="kate" [9]="mousepad"
        [10]="" [11]="git" [12]="make cmake meson" [13]="gcc" [14]="clang"
        [15]="base-devel"
        [16]="" [17]="python3 python3-pip" [18]="nodejs npm" [19]="rustup" [20]="go"
        [21]="" [22]="sqlite" [23]="postgresql-client"
        [24]="" [25]="docker docker-compose" [26]="podman" [27]=""
        [28]="" [29]="curl wget" [30]="nmap" [31]="wireshark"
        [32]="" [33]="gitg" [34]="meld"
    )

    multi_menu "Strumenti di Sviluppo" "${voci_label[@]}"
    [ ${#SELEZIONE[@]} -eq 0 ] && return 0

    for idx in "${SELEZIONE[@]}"; do
        local pkgs=""
        case "$DISTRO" in
            arch)   pkgs="${DEV_ARCH[$idx]}" ;;
            debian) pkgs="${DEV_DEB[$idx]}" ;;
            void)   pkgs="${DEV_VOID[$idx]}" ;;
        esac
        [ -z "$pkgs" ] && continue
        installa_pkgs $pkgs && ok "${voci_label[$idx]} installato."
    done

    # Rust: installazione via rustup (non via pkg manager)
    for idx in "${SELEZIONE[@]}"; do
        if [ "$idx" -eq 19 ]; then
            info "Installo Rust tramite rustup…"
            if ! command -v rustup &>/dev/null; then
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                # shellcheck source=/dev/null
                source "$HOME/.cargo/env"
            else
                rustup update
            fi
            ok "Rust aggiornato."
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  8. PERSONALIZZAZIONE TERMINALE
# ─────────────────────────────────────────────────────────────────────────────
personalizza_terminale() {
    sezione "Personalizzazione Terminale"
    echo -e "  Questa sezione configura emulatore, shell, tema colori e font.\n"

    # ── 8a. Emulatore di terminale ────────────────────────────────────────────
    local term_label=("Alacritty" "Kitty" "Wezterm" "XFCE4-terminal" "URxvt" "ST (suckless)" "Tilix" "Terminator")
    declare -A TERM_ARCH TERM_DEB TERM_VOID
    TERM_ARCH=([0]="alacritty" [1]="kitty" [2]="wezterm" [3]="xfce4-terminal" [4]="rxvt-unicode" [5]="st" [6]="tilix" [7]="terminator")
    TERM_DEB=([0]="alacritty" [1]="kitty" [2]="" [3]="xfce4-terminal" [4]="rxvt-unicode" [5]="" [6]="tilix" [7]="terminator")
    TERM_VOID=([0]="alacritty" [1]="kitty" [2]="" [3]="xfce4-terminal" [4]="rxvt-unicode" [5]="st" [6]="" [7]="terminator")

    menu_singolo "Scegli l'emulatore di terminale" "${term_label[@]}"
    local term_idx=0
    for i in "${!term_label[@]}"; do
        [ "${term_label[$i]}" = "$SCELTA_SINGOLA" ] && term_idx=$i
    done
    if [ -n "$SCELTA_SINGOLA" ]; then
        local pkgs=""
        case "$DISTRO" in
            arch)   pkgs="${TERM_ARCH[$term_idx]}" ;;
            debian) pkgs="${TERM_DEB[$term_idx]}" ;;
            void)   pkgs="${TERM_VOID[$term_idx]}" ;;
        esac
        [ -n "$pkgs" ] && installa_pkgs $pkgs && ok "$SCELTA_SINGOLA installato."
    fi

    # ── 8b. Shell ─────────────────────────────────────────────────────────────
    menu_singolo "Scegli la shell" "Bash (default)" "Zsh" "Fish"
    case "$SCELTA_SINGOLA" in
        "Zsh")
            case "$DISTRO" in
                arch)   installa_pkgs zsh zsh-completions ;;
                debian) installa_pkgs zsh ;;
                void)   installa_pkgs zsh ;;
            esac
            chsh -s "$(which zsh)"
            ok "Zsh impostato come shell predefinita."

            # Oh-My-Zsh
            echo -ne "\n  Installare ${BOLD}Oh-My-Zsh${RESET}? [s/N] "
            read -r r
            if [[ "$r" =~ ^[sS]$ ]]; then
                RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
                ok "Oh-My-Zsh installato."

                # Powerlevel10k
                echo -ne "  Installare tema ${BOLD}Powerlevel10k${RESET}? [s/N] "
                read -r r2
                if [[ "$r2" =~ ^[sS]$ ]]; then
                    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
                        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
                    sed -i 's/ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
                    ok "Powerlevel10k configurato."
                fi

                # zsh-syntax-highlighting
                git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
                    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 2>/dev/null || true
                # zsh-autosuggestions
                git clone https://github.com/zsh-users/zsh-autosuggestions.git \
                    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 2>/dev/null || true
                info "Plugin syntax-highlighting e autosuggestions clonati."
                info "Aggiungili manualmente in ~/.zshrc: plugins=(git zsh-syntax-highlighting zsh-autosuggestions)"
            fi
            ;;
        "Fish")
            case "$DISTRO" in
                arch)   installa_pkgs fish ;;
                debian) installa_pkgs fish ;;
                void)   installa_pkgs fish ;;
            esac
            chsh -s "$(which fish)"
            ok "Fish impostato come shell predefinita."
            echo -ne "  Installare ${BOLD}Fisher${RESET} (plugin manager per Fish)? [s/N] "
            read -r r3
            [[ "$r3" =~ ^[sS]$ ]] && fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
            ;;
        *) info "Shell Bash mantenuta." ;;
    esac

    # ── 8c. Starship prompt (cross-shell) ────────────────────────────────────
    echo -ne "\n  Installare ${BOLD}Starship${RESET} (prompt moderno cross-shell)? [s/N] "
    read -r rs
    if [[ "$rs" =~ ^[sS]$ ]]; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        # Aggiungi eval in .bashrc e .zshrc se presenti
        for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish"; do
            if [ -f "$rc" ]; then
                grep -q "starship init" "$rc" || echo 'eval "$(starship init bash)"' >> "$rc"
            fi
        done
        ok "Starship installato."
    fi

    # ── 8d. Tema colori per Alacritty / Kitty ────────────────────────────────
    local temi_colori=("Dracula" "Nord" "Catppuccin Mocha" "Gruvbox Dark" "One Dark" "Tokyo Night" "Solarized Dark" "Nessuno")
    menu_singolo "Tema colori per il terminale (Alacritty/Kitty)" "${temi_colori[@]}"
    local tema_scelto="$SCELTA_SINGOLA"
    if [ -n "$tema_scelto" ] && [ "$tema_scelto" != "Nessuno" ]; then
        _applica_tema_terminale "$tema_scelto"
    fi
}

# Funzione helper: scrive un file di tema per Alacritty
_applica_tema_terminale() {
    local tema="$1"
    local dir_alacritty="$HOME/.config/alacritty"
    mkdir -p "$dir_alacritty"

    info "Applico tema: $tema"
    case "$tema" in
        "Dracula")
            cat > "$dir_alacritty/colors.toml" <<'EOF'
[colors.primary]
background = "#282a36"
foreground = "#f8f8f2"

[colors.normal]
black   = "#000000"
red     = "#ff5555"
green   = "#50fa7b"
yellow  = "#f1fa8c"
blue    = "#caa9fa"
magenta = "#ff79c6"
cyan    = "#8be9fd"
white   = "#bfbfbf"

[colors.bright]
black   = "#4d4d4d"
red     = "#ff6e67"
green   = "#5af78e"
yellow  = "#f4f99d"
blue    = "#caa9fa"
magenta = "#ff92d0"
cyan    = "#9aedfe"
white   = "#e6e6e6"
EOF
            ;;
        "Nord")
            cat > "$dir_alacritty/colors.toml" <<'EOF'
[colors.primary]
background = "#2e3440"
foreground = "#d8dee9"

[colors.normal]
black   = "#3b4252"
red     = "#bf616a"
green   = "#a3be8c"
yellow  = "#ebcb8b"
blue    = "#81a1c1"
magenta = "#b48ead"
cyan    = "#88c0d0"
white   = "#e5e9f0"

[colors.bright]
black   = "#4c566a"
red     = "#bf616a"
green   = "#a3be8c"
yellow  = "#ebcb8b"
blue    = "#81a1c1"
magenta = "#b48ead"
cyan    = "#8fbcbb"
white   = "#eceff4"
EOF
            ;;
        "Gruvbox Dark")
            cat > "$dir_alacritty/colors.toml" <<'EOF'
[colors.primary]
background = "#282828"
foreground = "#ebdbb2"

[colors.normal]
black   = "#282828"
red     = "#cc241d"
green   = "#98971a"
yellow  = "#d79921"
blue    = "#458588"
magenta = "#b16286"
cyan    = "#689d6a"
white   = "#a89984"

[colors.bright]
black   = "#928374"
red     = "#fb4934"
green   = "#b8bb26"
yellow  = "#fabd2f"
blue    = "#83a598"
magenta = "#d3869b"
cyan    = "#8ec07c"
white   = "#ebdbb2"
EOF
            ;;
        *)
            warn "Tema $tema: scrivi le opzioni colore manualmente in ~/.config/alacritty/colors.toml"
            ;;
    esac
    ok "Tema $tema applicato in $dir_alacritty/colors.toml"
    info "Per applicarlo aggiungere in alacritty.toml: import = [\"~/.config/alacritty/colors.toml\"]"
}

# ─────────────────────────────────────────────────────────────────────────────
#  9. NERD FONTS
# ─────────────────────────────────────────────────────────────────────────────
installa_nerd_fonts() {
    sezione "Nerd Fonts"

    local NERD_VERSION
    info "Recupero versione più recente di Nerd Fonts da GitHub…"
    NERD_VERSION=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
                   | grep '"tag_name"' | cut -d'"' -f4)
    [ -z "$NERD_VERSION" ] && NERD_VERSION="v3.2.1" && warn "Impossibile contattare GitHub, uso versione $NERD_VERSION"
    info "Versione Nerd Fonts: $NERD_VERSION"

    local font_label=(
        "JetBrainsMono"
        "FiraCode"
        "Hack"
        "SourceCodePro"
        "Meslo"
        "Iosevka"
        "CascadiaCode"
        "RobotoMono"
        "UbuntuMono"
        "Mononoki"
        "DejaVuSansMono"
        "NerdFontsSymbolsOnly"
    )

    multi_menu "Nerd Fonts da installare" "${font_label[@]}"
    [ ${#SELEZIONE[@]} -eq 0 ] && return 0

    local FONT_DIR="$HOME/.local/share/fonts/NerdFonts"
    mkdir -p "$FONT_DIR"

    local BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_VERSION}"

    for idx in "${SELEZIONE[@]}"; do
        local font="${font_label[$idx]}"
        local zip="${font}.zip"
        local url="${BASE_URL}/${zip}"

        info "Download: $font ($NERD_VERSION)…"
        if curl -fLo "/tmp/${zip}" "$url"; then
            unzip -oq "/tmp/${zip}" -d "${FONT_DIR}/${font}/"
            rm -f "/tmp/${zip}"
            ok "$font installato in $FONT_DIR/$font/"
        else
            errore "Impossibile scaricare $font. Controlla la connessione."
        fi
    done

    info "Aggiorno la cache dei font…"
    fc-cache -fv "$FONT_DIR" 2>/dev/null && ok "Cache font aggiornata."
    info "Per verificare: fc-list | grep NerdFont"
}

# ─────────────────────────────────────────────────────────────────────────────
#  10. VERIFICA SOFTWARE INSTALLATO
# ─────────────────────────────────────────────────────────────────────────────
verifica_software() {
    sezione "Verifica Software Installato"

    # Lista di comandi/binari da controllare, con etichetta
    declare -A CHECK_LIST
    CHECK_LIST=(
        # Desktop / WM
        ["openbox"]="Openbox WM"
        ["xfce4-session"]="XFCE4"
        ["i3"]="i3 WM"
        ["bspwm"]="bspwm"
        ["qtile"]="Qtile"
        # Grafica
        ["gimp"]="GIMP"
        ["inkscape"]="Inkscape"
        ["krita"]="Krita"
        ["darktable"]="Darktable"
        ["vlc"]="VLC"
        ["mpv"]="MPV"
        ["blender"]="Blender"
        # Office
        ["libreoffice"]="LibreOffice"
        ["evince"]="Evince"
        ["okular"]="Okular"
        ["calibre"]="Calibre"
        ["thunderbird"]="Thunderbird"
        # Sistema
        ["gparted"]="GParted"
        ["thunar"]="Thunar"
        ["htop"]="htop"
        ["btop"]="btop"
        ["neofetch"]="neofetch"
        ["rsync"]="rsync"
        ["flatpak"]="Flatpak"
        # Browser
        ["firefox"]="Firefox"
        ["chromium"]="Chromium"
        # Dev
        ["vim"]="Vim"
        ["nvim"]="Neovim"
        ["nano"]="Nano"
        ["geany"]="Geany"
        ["code"]="VSCode/Codium"
        ["git"]="Git"
        ["gcc"]="GCC"
        ["python3"]="Python3"
        ["node"]="Node.js"
        ["rustc"]="Rust"
        ["go"]="Go"
        ["docker"]="Docker"
        # Terminale
        ["alacritty"]="Alacritty"
        ["kitty"]="Kitty"
        ["zsh"]="Zsh"
        ["fish"]="Fish"
        ["starship"]="Starship"
    )

    local installati=0
    local mancanti=0

    echo -e "  ${BOLD}Stato dei software:${RESET}\n"
    printf "  %-20s %-12s\n" "Software" "Stato"
    sep

    for cmd in $(echo "${!CHECK_LIST[@]}" | tr ' ' '\n' | sort); do
        local label="${CHECK_LIST[$cmd]}"
        if command -v "$cmd" &>/dev/null; then
            local ver
            ver=$(command "$cmd" --version 2>/dev/null | head -1 | awk '{print $NF}' | tr -d '()')
            printf "  ${GREEN}%-20s${RESET} ${GREEN}✔ installato${RESET}  ${DIM}%s${RESET}\n" "$label" "$ver"
            ((installati++))
        else
            printf "  ${RED}%-20s${RESET} ${RED}✘ mancante${RESET}\n" "$label"
            ((mancanti++))
        fi
    done

    sep
    echo -e "\n  ${GREEN}${BOLD}Installati: $installati${RESET}   ${RED}${BOLD}Mancanti: $mancanti${RESET}\n"
}

# ─────────────────────────────────────────────────────────────────────────────
#  EXTRA: Flatpak — configurazione repository
# ─────────────────────────────────────────────────────────────────────────────
configura_flatpak() {
    if command -v flatpak &>/dev/null; then
        sezione "Configurazione Flatpak"
        if ! flatpak remotes | grep -q flathub; then
            flatpak remote-add --if-not-exists flathub \
                https://dl.flathub.org/repo/flathub.flatpakrepo
            ok "Repository Flathub aggiunto."
        else
            ok "Flathub già configurato."
        fi
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
#  MENU PRINCIPALE
# ─────────────────────────────────────────────────────────────────────────────
menu_principale() {
    while true; do
        clear
        echo -e "${BG_BLUE}${WHITE}${BOLD}"
        echo "  ╔══════════════════════════════════════════════════════════╗"
        echo "  ║         POST-INSTALL MANAGER — ilnanny / Cristian       ║"
        echo "  ║              Distro: $(printf '%-32s' "${DISTRO^^}")         ║"
        echo "  ╚══════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"

        echo -e "  ${BOLD}Seleziona una sezione:${RESET}\n"
        echo -e "   ${CYAN}1${RESET}. 🖥️  Ambienti Grafici / Window Manager"
        echo -e "   ${CYAN}2${RESET}. 🎨  Applicazioni Grafiche e Multimediali"
        echo -e "   ${CYAN}3${RESET}. 📄  Suite Office e Documenti"
        echo -e "   ${CYAN}4${RESET}. ⚙️  Strumenti di Sistema"
        echo -e "   ${CYAN}5${RESET}. 🎨  Temi GTK, Icone, Cursori, Font di Sistema"
        echo -e "   ${CYAN}6${RESET}. 🌐  Browser Web"
        echo -e "   ${CYAN}7${RESET}. 💻  Strumenti di Sviluppo"
        echo -e "   ${CYAN}8${RESET}. 🖤  Personalizzazione Terminale"
        echo -e "   ${CYAN}9${RESET}. 🔤  Nerd Fonts"
        echo -e "   ${CYAN}a${RESET}. ⬆️  Aggiorna il sistema"
        echo -e "   ${CYAN}v${RESET}. ✅  Verifica software installato"
        echo -e "   ${CYAN}t${RESET}. 🔄  Esegui TUTTO in sequenza"
        echo -e "   ${CYAN}q${RESET}. 🚪  Esci"
        sep
        echo -ne "  ${BOLD}Scelta: ${RESET}"
        read -r scelta

        case "$scelta" in
            1) installa_desktop       ; pausa ;;
            2) installa_grafica       ; pausa ;;
            3) installa_office        ; pausa ;;
            4) installa_sistema       ; pausa ;;
            5) installa_temi          ; pausa ;;
            6) installa_browser       ; pausa ;;
            7) installa_dev           ; pausa ;;
            8) personalizza_terminale ; pausa ;;
            9) installa_nerd_fonts    ; pausa ;;
            a|A) aggiorna_sistema     ; pausa ;;
            v|V) verifica_software    ; pausa ;;
            t|T)
                aggiorna_sistema
                installa_desktop
                installa_grafica
                installa_office
                installa_sistema
                installa_temi
                installa_browser
                installa_dev
                personalizza_terminale
                installa_nerd_fonts
                configura_flatpak
                verifica_software
                pausa
                ;;
            q|Q)
                echo -e "\n  ${GREEN}${BOLD}Arrivederci!${RESET}  Log salvato in: ${CYAN}$LOG_FILE${RESET}\n"
                exit 0
                ;;
            *)
                warn "Opzione non valida."
                sleep 1
                ;;
        esac
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────
main() {
    clear
    titolo "POST-INSTALL MANAGER — ilnanny v2.0"
    rileva_distro
    sleep 1
    menu_principale
}

main "$@"
