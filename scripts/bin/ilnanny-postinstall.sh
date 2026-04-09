#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
#  ilnanny POST-INSTALL MANAGER  v3.0
#  Script master di post-installazione per Arch, Debian/MX e Void Linux
#
#  Autore : ilnanny <ilnannyhack@gmail.com>
#  GitHub : https://github.com/ilnanny75
#  Licenza: GPL v3
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
#  COLORI E STILE
# ─────────────────────────────────────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
ITALIC="\033[3m"
UL="\033[4m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[97m"
BG_BLUE="\033[44m"
BG_CYAN="\033[46m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"

# ─────────────────────────────────────────────────────────────────────────────
#  VARIABILI GLOBALI
# ─────────────────────────────────────────────────────────────────────────────
DISTRO=""
PKG_MGR=""
LOG_FILE="$HOME/postinstall-$(date +%Y%m%d-%H%M%S).log"
VERSION="3.0"

# ─────────────────────────────────────────────────────────────────────────────
#  FUNZIONI DI OUTPUT
# ─────────────────────────────────────────────────────────────────────────────
titolo() {
    local larghezza=70
    local testo=" $1 "
    local riempimento=$(( (larghezza - ${#testo}) / 2 ))
    echo ""
    echo -e "${BLUE}${BOLD}$(printf '═%.0s' $(seq 1 $larghezza))${RESET}"
    echo -e "${BLUE}${BOLD}$(printf '═%.0s' $(seq 1 $riempimento))${RESET}${WHITE}${BOLD}${testo}${RESET}${BLUE}${BOLD}$(printf '═%.0s' $(seq 1 $riempimento))${RESET}"
    echo -e "${BLUE}${BOLD}$(printf '═%.0s' $(seq 1 $larghezza))${RESET}"
    echo ""
}

sottotitolo() {
    echo -e "\n${CYAN}${BOLD}▸ $1${RESET}"
    echo -e "${DIM}$(printf '─%.0s' $(seq 1 60))${RESET}"
}

info()    { echo -e "${GREEN}  ✔${RESET}  $1" | tee -a "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}  ⚠${RESET}  $1" | tee -a "$LOG_FILE"; }
error()   { echo -e "${RED}  ✘${RESET}  $1" | tee -a "$LOG_FILE"; }
nota()    { echo -e "${CYAN}  ℹ${RESET}  ${DIM}$1${RESET}"; }
ok()      { echo -e "${BG_GREEN}${BOLD}  OK  ${RESET}  ${GREEN}$1${RESET}"; }
skip()    { echo -e "${DIM}  ↷  Saltato: $1${RESET}"; }

pausa() {
    echo -e "\n${DIM}  Premi un tasto per continuare...${RESET}"
    read -n 1 -s -r
}

chiedi() {
    echo -en "\n${CYAN}  ▶ Installare ${BOLD}$1${RESET}${CYAN}? (s/n): ${RESET}"
    read -r risposta
    [[ "$risposta" =~ ^[Ss]$ ]]
}

conferma() {
    echo -en "\n${YELLOW}  ⚠ ${BOLD}$1${RESET}${YELLOW} — Confermi? (s/n): ${RESET}"
    read -r risposta
    [[ "$risposta" =~ ^[Ss]$ ]]
}

spinner() {
    local pid=$1
    local msg="${2:-Attendere...}"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        echo -en "\r  ${CYAN}${frames[$i]}${RESET}  ${DIM}$msg${RESET}  "
        i=$(( (i+1) % ${#frames[@]} ))
        sleep 0.1
    done
    echo -en "\r\033[K"
}

# ─────────────────────────────────────────────────────────────────────────────
#  RILEVAMENTO DISTRO
# ─────────────────────────────────────────────────────────────────────────────
rileva_distro() {
    if [ ! -f /etc/os-release ]; then
        error "Impossibile rilevare la distribuzione."
        exit 1
    fi
    . /etc/os-release
    case "${ID:-}" in
        arch)
            DISTRO="arch"
            PKG_MGR="pacman"
            ;;
        debian|ubuntu|linuxmint|mx)
            DISTRO="debian"
            PKG_MGR="apt"
            ;;
        void)
            DISTRO="void"
            PKG_MGR="xbps"
            ;;
        *)
            error "Distribuzione non supportata: ${ID:-sconosciuta}"
            exit 1
            ;;
    esac
    info "Distribuzione: ${BOLD}${PRETTY_NAME:-$ID}${RESET}"
    info "Gestore pacchetti: ${BOLD}$PKG_MGR${RESET}"
    info "Log sessione: ${BOLD}$LOG_FILE${RESET}"
}

# ─────────────────────────────────────────────────────────────────────────────
#  FUNZIONI CORE DI INSTALLAZIONE
# ─────────────────────────────────────────────────────────────────────────────

# Installa un pacchetto passando il nome per ogni distro
# Uso: installa_pkg "nome_arch" "nome_debian" "nome_void" "descrizione"
installa_pkg() {
    local p_arch="${1:-}"
    local p_deb="${2:-}"
    local p_void="${3:-}"
    local desc="${4:-pacchetto}"
    local pkg=""

    case $DISTRO in
        arch)   pkg="$p_arch" ;;
        debian) pkg="$p_deb"  ;;
        void)   pkg="$p_void" ;;
    esac

    if [ -z "$pkg" ]; then
        warn "$desc non disponibile nei repo ufficiali per $DISTRO"
        return 1
    fi

    echo -e "  ${DIM}→ Installazione: ${BOLD}$pkg${RESET}"
    case $DISTRO in
        arch)   sudo pacman -S --noconfirm --needed $pkg >> "$LOG_FILE" 2>&1 ;;
        debian) sudo apt install -y $pkg >> "$LOG_FILE" 2>&1 ;;
        void)   sudo xbps-install -Sy $pkg >> "$LOG_FILE" 2>&1 ;;
    esac && info "$desc installato." || error "Errore installazione $pkg"
}

# Verifica se un pacchetto è già installato
pkg_installato() {
    local pkg="$1"
    case $DISTRO in
        arch)   pacman -Qi "$pkg" &>/dev/null ;;
        debian) dpkg -l "$pkg" 2>/dev/null | grep -q "^ii" ;;
        void)   xbps-query "$pkg" &>/dev/null ;;
    esac
}

# Mostra stato [INSTALLATO] o [NON INSTALLATO] per un pacchetto
stato_pkg() {
    local pkg_arch="${1:-}" pkg_deb="${2:-}" pkg_void="${3:-}" desc="${4:-$1}"
    local pkg=""
    case $DISTRO in
        arch)   pkg="$pkg_arch" ;;
        debian) pkg="$pkg_deb"  ;;
        void)   pkg="$pkg_void" ;;
    esac
    if [ -n "$pkg" ] && pkg_installato "$pkg"; then
        echo -e "    ${GREEN}[✔ INSTALLATO]${RESET}  $desc ${DIM}($pkg)${RESET}"
    elif [ -z "$pkg" ]; then
        echo -e "    ${DIM}[  N/D      ]${RESET}  $desc ${DIM}(non disponibile su $DISTRO)${RESET}"
    else
        echo -e "    ${DIM}[  ----     ]${RESET}  $desc ${DIM}($pkg)${RESET}"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
#  RICERCA INTELLIGENTE PACCHETTI
# ─────────────────────────────────────────────────────────────────────────────

# Database alias: nomi "comuni/errati" → nome corretto per distro
# Formato: "termine_ricerca:arch_pkg:debian_pkg:void_pkg:descrizione"
ALIAS_DB=(
    "networkmanager:networkmanager:network-manager:NetworkManager:Network Manager"
    "network manager:networkmanager:network-manager:NetworkManager:Network Manager"
    "network-manager:networkmanager:network-manager:NetworkManager:Network Manager"
    "nm-applet:network-manager-applet:network-manager-gnome:network-manager-applet:NM Applet"
    "vscode:code:code:vscode:Visual Studio Code"
    "vs code:code:code:vscode:Visual Studio Code"
    "visual studio code:code:code:vscode:Visual Studio Code"
    "virtualbox:virtualbox:virtualbox:virtualbox:VirtualBox"
    "virtual box:virtualbox:virtualbox:virtualbox:VirtualBox"
    "libreoffice:libreoffice-fresh:libreoffice:libreoffice:LibreOffice"
    "libre office:libreoffice-fresh:libreoffice:libreoffice:LibreOffice"
    "vlc media player:vlc:vlc:vlc:VLC"
    "vlcplayer:vlc:vlc:vlc:VLC"
    "nerd fonts:ttf-jetbrains-mono-nerd:fonts-jetbrains-mono:jetbrains-mono-nerd:Nerd Fonts JetBrains"
    "jetbrains:ttf-jetbrains-mono-nerd:fonts-jetbrains-mono:jetbrains-mono-nerd:JetBrains Mono Nerd"
    "neovim:neovim:neovim:neovim:Neovim"
    "nvim:neovim:neovim:neovim:Neovim"
    "docker desktop:docker:docker.io:docker:Docker"
    "nodejs:nodejs:nodejs:nodejs:Node.js"
    "node js:nodejs:nodejs:nodejs:Node.js"
    "node.js:nodejs:nodejs:nodejs:Node.js"
    "python3:python:python3:python3:Python 3"
    "python 3:python:python3:python3:Python 3"
    "thunar:thunar:thunar:Thunar:Thunar File Manager"
    "file manager:thunar:nautilus:Thunar:File Manager"
    "terminal:xfce4-terminal:xfce4-terminal:xfce4-terminal:XFCE Terminal"
    "xfce terminal:xfce4-terminal:xfce4-terminal:xfce4-terminal:XFCE Terminal"
    "openssh:openssh:openssh-server:openssh:OpenSSH Server"
    "ssh:openssh:openssh-client:openssh:OpenSSH Client"
    "bluetooth:bluez:bluez:bluez:Bluetooth (bluez)"
    "blueman:blueman:blueman:blueman:Blueman BT Manager"
    "pulseaudio:pulseaudio:pulseaudio:pulseaudio:PulseAudio"
    "pipewire:pipewire:pipewire:pipewire:PipeWire"
    "nvidia:nvidia:nvidia-driver:nvidia:Driver NVIDIA"
    "amd:mesa:mesa:mesa:Driver Mesa AMD/Intel"
    "wine:wine:wine:wine:Wine (Windows compat)"
    "steam:steam:steam:steam:Steam"
    "obs:obs-studio:obs-studio:obs:OBS Studio"
    "obs studio:obs-studio:obs-studio:obs:OBS Studio"
    "kdenlive:kdenlive:kdenlive:kdenlive:Kdenlive"
    "handbrake:handbrake:handbrake:handbrake:HandBrake"
    "audacity:audacity:audacity:audacity:Audacity"
    "gparted:gparted:gparted:gparted:GParted"
    "htop:htop:htop:htop:htop"
    "btop:btop:btop:btop:btop"
    "neofetch:neofetch:neofetch:neofetch:Neofetch"
    "fastfetch:fastfetch:fastfetch:fastfetch:Fastfetch"
    "timeshift:timeshift:timeshift:timeshift:Timeshift (backup)"
    "rsync:rsync:rsync:rsync:rsync"
    "midnight commander:mc:mc:mc:Midnight Commander"
    "mc:mc:mc:mc:Midnight Commander"
    "ranger:ranger:ranger:ranger:Ranger (file manager TUI)"
    "nnn:nnn:nnn:nnn:nnn (file manager TUI)"
    "zsh:zsh:zsh:zsh:Zsh"
    "fish:fish:fish:fish:Fish Shell"
    "tmux:tmux:tmux:tmux:tmux"
    "screen:screen:screen:screen:GNU Screen"
    "fzf:fzf:fzf:fzf:fzf (fuzzy finder)"
    "ripgrep:ripgrep:ripgrep:ripgrep:ripgrep (rg)"
    "bat:bat:bat:bat:bat (cat con sintassi)"
    "eza:eza:eza:eza:eza (ls moderno)"
    "fd:fd:fd-find:fd:fd (find moderno)"
    "flatpak:flatpak:flatpak:flatpak:Flatpak"
    "snap:snapd:snapd:snapd:Snap"
    "chromium:chromium:chromium:chromium:Chromium"
    "firefox:firefox:firefox-esr:firefox:Firefox"
    "gimp:gimp:gimp:gimp:GIMP"
    "inkscape:inkscape:inkscape:inkscape:Inkscape"
    "krita:krita:krita:krita:Krita"
    "darktable:darktable:darktable:darktable:Darktable"
    "rawtherapee:rawtherapee:rawtherapee:rawtherapee:RawTherapee"
    "blender:blender:blender:blender:Blender"
    "geany:geany:geany:geany:Geany"
    "kate:kate:kate:kate:Kate Editor"
    "micro:micro:micro:micro:Micro Editor"
    "vim:vim:vim:vim:Vim"
    "emacs:emacs:emacs:emacs:GNU Emacs"
    "git:git:git:git:Git"
    "gh:github-cli:gh:github-cli:GitHub CLI"
    "github cli:github-cli:gh:github-cli:GitHub CLI"
    "curl:curl:curl:curl:curl"
    "wget:wget:wget:wget:wget"
    "aria2:aria2:aria2:aria2:aria2 (download)"
    "ufw:ufw:ufw:ufw:UFW Firewall"
    "iptables:iptables:iptables:iptables:iptables"
    "fail2ban:fail2ban:fail2ban:fail2ban:Fail2Ban"
    "clamav:clamav:clamav:clamav:ClamAV Antivirus"
    "cups:cups:cups:cups:CUPS (stampa)"
    "samba:samba:samba:samba:Samba"
    "nfs:nfs-utils:nfs-kernel-server:nfs-utils:NFS Server"
    "transmission:transmission-gtk:transmission-gtk:transmission-gtk:Transmission"
    "qbittorrent:qbittorrent:qbittorrent:qbittorrent:qBittorrent"
    "keepass:keepassxc:keepassxc:keepassxc:KeePassXC"
    "keepassxc:keepassxc:keepassxc:keepassxc:KeePassXC"
    "bitwarden:bitwarden:bitwarden:bitwarden:Bitwarden"
    "signal:signal-desktop:signal-desktop:signal-desktop:Signal"
    "telegram:telegram-desktop:telegram-desktop:telegram-desktop:Telegram"
    "discord:discord:discord:discord:Discord"
    "thunderbird:thunderbird:thunderbird:thunderbird:Thunderbird"
    "evolution:evolution:evolution:evolution:Evolution Mail"
    "calibre:calibre:calibre:calibre:Calibre (eBook)"
    "okular:okular:okular:okular:Okular (PDF)"
    "evince:evince:evince:evince:Evince (PDF)"
    "zathura:zathura:zathura:zathura:Zathura (PDF)"
    "atril:atril:atril:atril:Atril (PDF)"
    "ffmpeg:ffmpeg:ffmpeg:ffmpeg:FFmpeg"
    "mpv:mpv:mpv:mpv:MPV Player"
    "celluloid:celluloid:celluloid:celluloid:Celluloid (MPV GUI)"
    "shotwell:shotwell:shotwell:shotwell:Shotwell"
    "nomacs:nomacs:nomacs:nomacs:nomacs (Image Viewer)"
    "feh:feh:feh:feh:feh (Image Viewer)"
    "sxiv:sxiv:sxiv:sxiv:sxiv (Image Viewer)"
    "variety:variety:variety:variety:Variety Wallpaper"
    "nitrogen:nitrogen:nitrogen:nitrogen:Nitrogen Wallpaper"
    "xfce4:xfce4:xfce4:xfce4:XFCE4 Desktop"
    "xfce:xfce4:xfce4:xfce4:XFCE Desktop"
    "gnome:gnome:gnome:gnome:GNOME Desktop"
    "kde:plasma-meta:kde-plasma-desktop:kde5:KDE Plasma"
    "plasma:plasma-meta:kde-plasma-desktop:kde5:KDE Plasma"
    "lxde:lxde:lxde:lxde:LXDE Desktop"
    "lxqt:lxqt:lxqt:lxqt:LXQt Desktop"
    "mate:mate:mate-desktop-environment:mate:MATE Desktop"
    "i3:i3:i3:i3:i3 WM"
    "i3wm:i3:i3:i3:i3 Window Manager"
    "openbox:openbox:openbox:openbox:Openbox WM"
    "bspwm:bspwm:bspwm:bspwm:bspwm WM"
    "sway:sway:sway:sway:Sway WM (Wayland)"
    "picom:picom:picom:picom:Picom Compositor"
    "compton:picom:compton:picom:Compositor (picom)"
    "rofi:rofi:rofi:rofi:Rofi Launcher"
    "dmenu:dmenu:dmenu:dmenu:dmenu"
    "polybar:polybar:polybar:polybar:Polybar"
    "xmobar:xmobar:xmobar:xmobar:xmobar"
    "conky:conky:conky:conky:Conky"
    "dunst:dunst:dunst:dunst:Dunst (notify)"
    "libnotify:libnotify:libnotify-bin:libnotify:libnotify"
    "pavucontrol:pavucontrol:pavucontrol:pavucontrol:PavuControl"
    "alsamixer:alsa-utils:alsa-utils:alsa-utils:AlsaMixer"
    "pulseeffects:easyeffects:easyeffects:easyeffects:EasyEffects"
    "easyeffects:easyeffects:easyeffects:easyeffects:EasyEffects"
    "xrandr:xorg-xrandr:x11-xserver-utils:xrandr:xrandr"
    "arandr:arandr:arandr:arandr:ARandR"
    "lm-sensors:lm_sensors:lm-sensors:lm_sensors:LM Sensors"
    "sensors:lm_sensors:lm-sensors:lm_sensors:LM Sensors"
    "stress:stress:stress:stress:stress"
    "cpupower:cpupower:linux-cpupower:cpupower:CPU Power"
    "tlp:tlp:tlp:tlp:TLP (risparmio energia)"
    "powertop:powertop:powertop:powertop:PowerTop"
    "auto-cpufreq:auto-cpufreq:auto-cpufreq:auto-cpufreq:auto-cpufreq"
    "glow:glow:glow:glow:Glow (Markdown)"
    "pandoc:pandoc:pandoc:pandoc:Pandoc"
    "latex:texlive-core:texlive-base:texlive-core:LaTeX (texlive)"
    "texlive:texlive-core:texlive-base:texlive-core:TeXLive"
    "java:jdk-openjdk:default-jdk:openjdk:Java (OpenJDK)"
    "openjdk:jdk-openjdk:default-jdk:openjdk:OpenJDK"
    "go:go:golang:go:Go Language"
    "golang:go:golang:go:Go Language"
    "rust:rust:rustc:rust:Rust Language"
    "rustc:rust:rustc:rust:Rust (rustc)"
    "cargo:rust:cargo:cargo:Cargo (Rust)"
    "gcc:gcc:gcc:gcc:GCC"
    "g++:gcc:g++:gcc:G++"
    "make:make:make:make:GNU Make"
    "cmake:cmake:cmake:cmake:CMake"
    "pip:python-pip:python3-pip:python3-pip:pip (Python)"
    "pip3:python-pip:python3-pip:python3-pip:pip3"
    "virtualenv:python-virtualenv:python3-virtualenv:python3-virtualenv:virtualenv"
    "php:php:php:php:PHP"
    "composer:php-composer:composer:composer:Composer (PHP)"
    "ruby:ruby:ruby:ruby:Ruby"
    "gem:ruby:ruby:ruby:RubyGems"
    "perl:perl:perl:perl:Perl"
    "lua:lua:lua5.4:lua54:Lua"
    "sqlite:sqlite:sqlite3:sqlite:SQLite"
    "postgresql:postgresql:postgresql:postgresql:PostgreSQL"
    "mariadb:mariadb:mariadb-server:mariadb:MariaDB"
    "mysql:mariadb:mariadb-server:mariadb:MySQL/MariaDB"
    "redis:redis:redis:redis:Redis"
    "nginx:nginx:nginx:nginx:Nginx"
    "apache:apache:apache2:apache:Apache"
    "certbot:certbot:certbot:certbot:Certbot (SSL)"
)

# Cerca nel database alias una corrispondenza fuzzy
cerca_alias() {
    local query="${1,,}"  # lowercase
    local trovati=()
    for entry in "${ALIAS_DB[@]}"; do
        local termine="${entry%%:*}"
        if [[ "$termine" == *"$query"* ]] || [[ "$query" == *"$termine"* ]]; then
            trovati+=("$entry")
        fi
    done
    echo "${trovati[@]:-}"
}

# Ricerca live nei repo della distro
cerca_repo() {
    local query="$1"
    local risultati=""
    case $DISTRO in
        arch)
            risultati=$(pacman -Ss "$query" 2>/dev/null | grep -E "^[a-z]" | head -20 | \
                awk '{print $1, $2}' || true)
            ;;
        debian)
            risultati=$(apt-cache search "$query" 2>/dev/null | head -20 || true)
            ;;
        void)
            risultati=$(xbps-query -Rs "$query" 2>/dev/null | head -20 || true)
            ;;
    esac
    echo "$risultati"
}

# Funzione principale di ricerca
ricerca_pacchetto() {
    titolo "Ricerca Pacchetto"
    
    while true; do
        echo -en "\n${CYAN}  Inserisci il nome da cercare ${DIM}(invio per uscire)${RESET}${CYAN}: ${RESET}"
        read -r query
        [ -z "$query" ] && break

        local query_lower="${query,,}"
        local trovato_alias=false

        # 1. Cerca nel database alias
        sottotitolo "Corrispondenze nel database alias"
        local alias_trovati
        alias_trovati=$(cerca_alias "$query_lower")
        
        if [ -n "$alias_trovati" ]; then
            trovato_alias=true
            echo ""
            local n=1
            declare -A alias_map
            while IFS= read -r entry; do
                [ -z "$entry" ] && continue
                IFS=':' read -ra campi <<< "$entry"
                local termine="${campi[0]}"
                local p_arch="${campi[1]}"
                local p_deb="${campi[2]}"
                local p_void="${campi[3]}"
                local desc="${campi[4]}"
                local pkg_corrente=""
                case $DISTRO in
                    arch)   pkg_corrente="$p_arch" ;;
                    debian) pkg_corrente="$p_deb"  ;;
                    void)   pkg_corrente="$p_void" ;;
                esac
                
                if pkg_installato "$pkg_corrente" 2>/dev/null; then
                    echo -e "    ${GREEN}[$n]${RESET} ${BOLD}$desc${RESET} ${DIM}→ $pkg_corrente${RESET} ${GREEN}[già installato]${RESET}"
                else
                    echo -e "    ${CYAN}[$n]${RESET} ${BOLD}$desc${RESET} ${DIM}→ $pkg_corrente${RESET}"
                fi
                
                # Se hai cercato "networkmanager" e il pkg si chiama "network-manager" avvisa
                if [ "$query_lower" != "$termine" ] && [ "$query_lower" != "${pkg_corrente,,}" ]; then
                    echo -e "         ${YELLOW}↳ Intendevi: ${BOLD}$pkg_corrente${RESET}${YELLOW}?${RESET}"
                fi
                
                alias_map[$n]="$entry"
                ((n++))
            done <<< "$(echo "$alias_trovati" | tr ' ' '\n')"
            
            echo ""
            echo -en "  ${CYAN}Installa numero (o invio per cercare nei repo): ${RESET}"
            read -r scelta
            
            if [[ "$scelta" =~ ^[0-9]+$ ]] && [ -n "${alias_map[$scelta]:-}" ]; then
                IFS=':' read -ra campi <<< "${alias_map[$scelta]}"
                installa_pkg "${campi[1]}" "${campi[2]}" "${campi[3]}" "${campi[4]}"
                pausa
                continue
            fi
        else
            nota "Nessuna corrispondenza nel database alias."
        fi

        # 2. Cerca live nei repo
        sottotitolo "Ricerca live nei repository ($DISTRO)"
        echo -e "  ${DIM}Ricerca in corso...${RESET}"
        
        local repo_results
        repo_results=$(cerca_repo "$query")
        
        if [ -z "$repo_results" ]; then
            warn "Nessun risultato nei repository per: '$query'"
            nota "Suggerimenti:"
            echo -e "    • Prova con un termine più generico"
            echo -e "    • Usa la sezione Flatpak per pacchetti extra"
            echo -e "    • Verifica il nome esatto su pkgs.org"
        else
            echo ""
            echo "$repo_results" | head -15 | nl -w3 -s') '
            echo ""
            echo -en "  ${CYAN}Inserisci il nome esatto da installare (o invio per annullare): ${RESET}"
            read -r pkg_da_installare
            if [ -n "$pkg_da_installare" ]; then
                if conferma "Installare '$pkg_da_installare'"; then
                    case $DISTRO in
                        arch)   sudo pacman -S --noconfirm "$pkg_da_installare" ;;
                        debian) sudo apt install -y "$pkg_da_installare" ;;
                        void)   sudo xbps-install -Sy "$pkg_da_installare" ;;
                    esac && info "Installazione completata." || error "Errore installazione."
                fi
            fi
        fi
        
        echo ""
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  SEZIONI INSTALLAZIONE CATEGORIZZATE
# ─────────────────────────────────────────────────────────────────────────────

aggiorna_sistema() {
    titolo "Aggiornamento Sistema"
    conferma "Aggiornare tutto il sistema" || return 0
    case $DISTRO in
        arch)   sudo pacman -Syu --noconfirm ;;
        debian) sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y ;;
        void)   sudo xbps-install -Syu ;;
    esac | tee -a "$LOG_FILE"
    ok "Sistema aggiornato."
}

# ────────────────────────────────────────
sezione_sistema() {
    titolo "Strumenti di Sistema"

    sottotitolo "Stato corrente"
    stato_pkg "git" "git" "git" "Git"
    stato_pkg "curl" "curl" "curl" "curl"
    stato_pkg "wget" "wget" "wget" "wget"
    stato_pkg "rsync" "rsync" "rsync" "rsync"
    stato_pkg "htop" "htop" "htop" "htop"
    stato_pkg "btop" "btop" "btop" "btop"
    stato_pkg "mc" "mc" "mc" "Midnight Commander"
    stato_pkg "ranger" "ranger" "ranger" "Ranger"
    stato_pkg "ufw" "ufw" "ufw" "UFW Firewall"
    stato_pkg "openssh" "openssh-client" "openssh" "OpenSSH"
    stato_pkg "tmux" "tmux" "tmux" "tmux"
    stato_pkg "fzf" "fzf" "fzf" "fzf"
    stato_pkg "ripgrep" "ripgrep" "ripgrep" "ripgrep"
    stato_pkg "bat" "bat" "bat" "bat"
    stato_pkg "eza" "eza" "eza" "eza"

    sottotitolo "Selezione da installare"
    chiedi "Git + Curl + Wget"    && installa_pkg "git curl wget" "git curl wget" "git curl wget" "Git + Curl + Wget"
    chiedi "rsync"                && installa_pkg "rsync" "rsync" "rsync" "rsync"
    chiedi "htop"                 && installa_pkg "htop" "htop" "htop" "htop"
    chiedi "btop"                 && installa_pkg "btop" "btop" "btop" "btop"
    chiedi "Midnight Commander"   && installa_pkg "mc" "mc" "mc" "Midnight Commander"
    chiedi "Ranger (TUI)"         && installa_pkg "ranger" "ranger" "ranger" "Ranger"
    chiedi "nnn (TUI)"            && installa_pkg "nnn" "nnn" "nnn" "nnn"
    chiedi "UFW Firewall"         && installa_pkg "ufw" "ufw" "ufw" "UFW"
    chiedi "OpenSSH"              && installa_pkg "openssh" "openssh-client openssh-server" "openssh" "OpenSSH"
    chiedi "tmux"                 && installa_pkg "tmux" "tmux" "tmux" "tmux"
    chiedi "Screen"               && installa_pkg "screen" "screen" "screen" "GNU Screen"
    chiedi "fzf (fuzzy finder)"   && installa_pkg "fzf" "fzf" "fzf" "fzf"
    chiedi "ripgrep (rg)"         && installa_pkg "ripgrep" "ripgrep" "ripgrep" "ripgrep"
    chiedi "bat (cat migliorato)" && installa_pkg "bat" "bat" "bat" "bat"
    chiedi "eza (ls moderno)"     && installa_pkg "eza" "eza" "eza" "eza"
    chiedi "fd (find moderno)"    && installa_pkg "fd" "fd-find" "fd" "fd"
    chiedi "unzip + p7zip"        && installa_pkg "unzip p7zip" "unzip p7zip-full" "unzip p7zip" "Archivi"
    chiedi "aria2 (download)"     && installa_pkg "aria2" "aria2" "aria2" "aria2"
    chiedi "lm-sensors"           && installa_pkg "lm_sensors" "lm-sensors" "lm_sensors" "LM Sensors"
    chiedi "TLP (laptop risparmio energia)" && installa_pkg "tlp tlp-rdw" "tlp" "tlp" "TLP"
    chiedi "Neofetch"             && installa_pkg "neofetch" "neofetch" "neofetch" "Neofetch"
    chiedi "Fastfetch"            && installa_pkg "fastfetch" "fastfetch" "fastfetch" "Fastfetch"
    chiedi "Glow (Markdown TUI)"  && installa_pkg "glow" "glow" "glow" "Glow"
}

# ────────────────────────────────────────
sezione_sviluppo() {
    titolo "Sviluppo ed Editor"

    sottotitolo "Stato corrente"
    stato_pkg "git" "git" "git" "Git"
    stato_pkg "gcc" "gcc" "gcc" "GCC"
    stato_pkg "make" "make" "make" "GNU Make"
    stato_pkg "cmake" "cmake" "cmake" "CMake"
    stato_pkg "python" "python3" "python3" "Python 3"
    stato_pkg "nodejs" "nodejs" "nodejs" "Node.js"
    stato_pkg "go" "golang" "go" "Go Language"
    stato_pkg "rust" "rustc" "rust" "Rust"
    stato_pkg "geany" "geany" "geany" "Geany"
    stato_pkg "code" "code" "vscode" "VSCode"
    stato_pkg "neovim" "neovim" "neovim" "Neovim"

    sottotitolo "Editor e IDE"
    chiedi "Geany + Plugin"   && installa_pkg "geany geany-plugins" "geany geany-plugins" "geany geany-plugins" "Geany"
    chiedi "Neovim"           && installa_pkg "neovim" "neovim" "neovim" "Neovim"
    chiedi "Micro Editor"     && installa_pkg "micro" "micro" "micro" "Micro"
    chiedi "Kate"             && installa_pkg "kate" "kate" "kate" "Kate"
    chiedi "Vim"              && installa_pkg "vim" "vim" "vim" "Vim"

    chiedi "Visual Studio Code" && {
        case $DISTRO in
            arch)
                installa_pkg "code" "" "" "VSCode"
                ;;
            debian)
                nota "VSCode richiede il repository Microsoft."
                if conferma "Aggiungere il repository Microsoft e installare VSCode"; then
                    sudo apt install -y curl gpg apt-transport-https
                    curl -sSL https://packages.microsoft.com/keys/microsoft.asc \
                        | sudo gpg --dearmor -o /usr/share/keyrings/ms-vscode.gpg
                    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ms-vscode.gpg] \
https://packages.microsoft.com/repos/code stable main" \
                        | sudo tee /etc/apt/sources.list.d/vscode.list
                    sudo apt update && sudo apt install -y code
                    info "VSCode installato (repo Microsoft)."
                fi
                ;;
            void)
                installa_pkg "" "" "vscode" "VSCode"
                ;;
        esac
    }

    sottotitolo "Linguaggi e Runtime"
    chiedi "Python 3 + pip"  && installa_pkg "python python-pip" "python3 python3-pip" "python3 python3-pip" "Python 3"
    chiedi "Node.js + npm"   && installa_pkg "nodejs npm" "nodejs npm" "nodejs npm" "Node.js"
    chiedi "Go"              && installa_pkg "go" "golang" "go" "Go"
    chiedi "Rust + Cargo"    && installa_pkg "rust cargo" "rustc cargo" "rust cargo" "Rust"
    chiedi "GCC + Make"      && installa_pkg "gcc make" "gcc make" "gcc make" "GCC + Make"
    chiedi "CMake"           && installa_pkg "cmake" "cmake" "cmake" "CMake"
    chiedi "Java (OpenJDK)"  && installa_pkg "jdk-openjdk" "default-jdk" "openjdk" "Java"
    chiedi "PHP + Composer"  && installa_pkg "php composer" "php composer" "php composer" "PHP"
    chiedi "Ruby"            && installa_pkg "ruby" "ruby" "ruby" "Ruby"
    chiedi "SQLite"          && installa_pkg "sqlite" "sqlite3" "sqlite" "SQLite"

    sottotitolo "Strumenti Git e CLI"
    chiedi "GitHub CLI (gh)" && installa_pkg "github-cli" "gh" "github-cli" "GitHub CLI"
    chiedi "git-delta (diff)" && installa_pkg "git-delta" "git-delta" "git-delta" "git-delta"
    chiedi "lazygit"         && installa_pkg "lazygit" "lazygit" "lazygit" "lazygit"

    sottotitolo "Container e Virtualizzazione"
    chiedi "Docker" && {
        case $DISTRO in
            arch)
                installa_pkg "docker docker-compose" "" "" "Docker"
                sudo systemctl enable --now docker
                sudo usermod -aG docker "$USER"
                warn "Riavvia la sessione per usare Docker senza sudo."
                ;;
            debian)
                nota "Docker richiede il repository ufficiale Docker."
                if conferma "Aggiungere il repository Docker e installare"; then
                    sudo apt install -y ca-certificates curl gnupg
                    sudo install -m 0755 -d /etc/apt/keyrings
                    curl -fsSL https://download.docker.com/linux/debian/gpg \
                        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
                        | sudo tee /etc/apt/sources.list.d/docker.list
                    sudo apt update
                    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
                    sudo usermod -aG docker "$USER"
                    info "Docker installato (repo ufficiale)."
                fi
                ;;
            void)
                installa_pkg "" "" "docker docker-compose" "Docker"
                sudo ln -sf /etc/sv/docker /var/service/
                sudo usermod -aG docker "$USER"
                ;;
        esac
    }
    chiedi "VirtualBox" && installa_pkg "virtualbox virtualbox-host-modules-arch" "virtualbox" "virtualbox" "VirtualBox"
}

# ────────────────────────────────────────
sezione_grafica() {
    titolo "Grafica, Video e Multimedia"

    sottotitolo "Stato corrente"
    stato_pkg "gimp" "gimp" "gimp" "GIMP"
    stato_pkg "inkscape" "inkscape" "inkscape" "Inkscape"
    stato_pkg "krita" "krita" "krita" "Krita"
    stato_pkg "vlc" "vlc" "vlc" "VLC"
    stato_pkg "mpv" "mpv" "mpv" "MPV"
    stato_pkg "obs-studio" "obs-studio" "obs" "OBS Studio"
    stato_pkg "ffmpeg" "ffmpeg" "ffmpeg" "FFmpeg"
    stato_pkg "audacity" "audacity" "audacity" "Audacity"

    sottotitolo "Editor Immagini"
    chiedi "GIMP"            && installa_pkg "gimp" "gimp" "gimp" "GIMP"
    chiedi "Inkscape"        && installa_pkg "inkscape" "inkscape" "inkscape" "Inkscape"
    chiedi "Krita"           && installa_pkg "krita" "krita" "krita" "Krita"
    chiedi "Darktable"       && installa_pkg "darktable" "darktable" "darktable" "Darktable"
    chiedi "RawTherapee"     && installa_pkg "rawtherapee" "rawtherapee" "rawtherapee" "RawTherapee"
    chiedi "Blender"         && installa_pkg "blender" "blender" "blender" "Blender"
    chiedi "nomacs (viewer)" && installa_pkg "nomacs" "nomacs" "nomacs" "nomacs"
    chiedi "feh (viewer)"    && installa_pkg "feh" "feh" "feh" "feh"

    sottotitolo "Video e Streaming"
    chiedi "VLC"             && installa_pkg "vlc" "vlc" "vlc" "VLC"
    chiedi "MPV"             && installa_pkg "mpv" "mpv" "mpv" "MPV"
    chiedi "Celluloid (MPV)" && installa_pkg "celluloid" "celluloid" "celluloid" "Celluloid"
    chiedi "OBS Studio"      && installa_pkg "obs-studio" "obs-studio" "obs" "OBS Studio"
    chiedi "Kdenlive"        && installa_pkg "kdenlive" "kdenlive" "kdenlive" "Kdenlive"
    chiedi "HandBrake"       && installa_pkg "handbrake" "handbrake" "handbrake" "HandBrake"
    chiedi "FFmpeg"          && installa_pkg "ffmpeg" "ffmpeg" "ffmpeg" "FFmpeg"

    sottotitolo "Audio"
    chiedi "Audacity"        && installa_pkg "audacity" "audacity" "audacity" "Audacity"
    chiedi "PavuControl"     && installa_pkg "pavucontrol" "pavucontrol" "pavucontrol" "PavuControl"
    chiedi "EasyEffects"     && installa_pkg "easyeffects" "easyeffects" "easyeffects" "EasyEffects"
    chiedi "alsa-utils"      && installa_pkg "alsa-utils" "alsa-utils" "alsa-utils" "ALSA Utils"

    sottotitolo "Screenshot e Screencast"
    chiedi "Flameshot"       && installa_pkg "flameshot" "flameshot" "flameshot" "Flameshot"
    chiedi "Scrot"           && installa_pkg "scrot" "scrot" "scrot" "Scrot"
    chiedi "Peek (GIF)"      && installa_pkg "peek" "peek" "peek" "Peek"
}

# ────────────────────────────────────────
sezione_browser_rete() {
    titolo "Browser Web e Rete"

    sottotitolo "Stato corrente"
    stato_pkg "firefox" "firefox-esr" "firefox" "Firefox"
    stato_pkg "chromium" "chromium" "chromium" "Chromium"
    stato_pkg "networkmanager" "network-manager" "NetworkManager" "Network Manager"

    sottotitolo "Browser"
    chiedi "Firefox" && {
        if [ "$DISTRO" == "debian" ]; then
            installa_pkg "" "firefox-esr" "" "Firefox ESR"
        else
            installa_pkg "firefox" "" "firefox" "Firefox"
        fi
    }
    chiedi "Chromium"        && installa_pkg "chromium" "chromium" "chromium" "Chromium"
    chiedi "qutebrowser"     && installa_pkg "qutebrowser" "qutebrowser" "qutebrowser" "qutebrowser"
    chiedi "Lynx (TUI)"      && installa_pkg "lynx" "lynx" "lynx" "Lynx"
    chiedi "w3m  (TUI)"      && installa_pkg "w3m" "w3m" "w3m" "w3m"

    sottotitolo "Rete e VPN"
    chiedi "NetworkManager + nmtui" && {
        installa_pkg "networkmanager" "network-manager network-manager-gnome" "NetworkManager" "NetworkManager"
        case $DISTRO in
            arch) sudo systemctl enable --now NetworkManager ;;
            debian) sudo systemctl enable --now NetworkManager ;;
            void) sudo ln -sf /etc/sv/NetworkManager /var/service/ 2>/dev/null || true ;;
        esac
    }
    chiedi "nmap"            && installa_pkg "nmap" "nmap" "nmap" "nmap"
    chiedi "Wireshark"       && installa_pkg "wireshark-qt" "wireshark" "wireshark" "Wireshark"
    chiedi "OpenVPN"         && installa_pkg "openvpn" "openvpn" "openvpn" "OpenVPN"
    chiedi "WireGuard"       && installa_pkg "wireguard-tools" "wireguard" "wireguard-tools" "WireGuard"

    sottotitolo "Download e File Sharing"
    chiedi "Transmission"    && installa_pkg "transmission-gtk" "transmission-gtk" "transmission-gtk" "Transmission"
    chiedi "qBittorrent"     && installa_pkg "qbittorrent" "qbittorrent" "qbittorrent" "qBittorrent"
    chiedi "aria2"           && installa_pkg "aria2" "aria2" "aria2" "aria2"
    chiedi "lftp"            && installa_pkg "lftp" "lftp" "lftp" "lftp"
    chiedi "Filezilla"       && installa_pkg "filezilla" "filezilla" "filezilla" "FileZilla"
}

# ────────────────────────────────────────
sezione_temi() {
    titolo "Temi, Icone e Personalizzazione"

    mkdir -p ~/.icons ~/.themes ~/.local/share/fonts

    sottotitolo "Wallpaper e GTK"
    chiedi "Nitrogen (wallpaper)"  && installa_pkg "nitrogen" "nitrogen" "nitrogen" "Nitrogen"
    chiedi "Variety (wallpaper)"   && installa_pkg "variety" "variety" "variety" "Variety"
    chiedi "lxappearance (GTK)"    && installa_pkg "lxappearance" "lxappearance" "lxappearance" "LXAppearance"
    chiedi "qt5ct (Qt temi)"       && installa_pkg "qt5ct" "qt5ct" "qt5ct" "qt5ct"

    sottotitolo "Icon Theme Lila-HD (GitHub — ilnanny75)"
    if chiedi "Lila-HD Icon Theme"; then
        warn "Questo tema viene scaricato da GitHub (ilnanny75/Lila-HD-Icon-Theme-Official)."
        if conferma "Procedere con il download da GitHub"; then
            local TMP; TMP=$(mktemp -d)
            git clone --depth 1 https://github.com/ilnanny75/Lila-HD-Icon-Theme-Official "$TMP/Lila-HD"
            cp -r "$TMP/Lila-HD" ~/.icons/
            rm -rf "$TMP"
            info "Lila-HD installato in ~/.icons/"
        fi
    fi

    sottotitolo "Tema GTK Nordic (GitHub — EliverLara)"
    if chiedi "Nordic GTK Theme"; then
        warn "Questo tema viene scaricato da GitHub (EliverLara/Nordic)."
        if conferma "Procedere con il download da GitHub"; then
            local TMP; TMP=$(mktemp -d)
            git clone --depth 1 https://github.com/EliverLara/Nordic "$TMP/Nordic"
            cp -r "$TMP/Nordic" ~/.themes/
            rm -rf "$TMP"
            info "Nordic installato in ~/.themes/"
        fi
    fi

    sottotitolo "Tema GTK Adwaita-dark (repo ufficiali)"
    chiedi "Adwaita-dark + gnome-themes" && \
        installa_pkg "gnome-themes-extra" "gnome-themes-extra" "gnome-themes-extra" "Adwaita-dark"

    sottotitolo "Nerd Fonts"
    if chiedi "JetBrainsMono Nerd Font (GitHub — ryanoasis)"; then
        warn "Il font viene scaricato da GitHub Releases (ryanoasis/nerd-fonts)."
        if conferma "Procedere con il download"; then
            local FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerd"
            mkdir -p "$FONT_DIR"
            local TMP; TMP=$(mktemp -d)
            wget -q --show-progress -P "$TMP" \
                https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
            tar -xf "$TMP/JetBrainsMono.tar.xz" -C "$TMP"
            find "$TMP" -name "*Retina*" -exec cp {} "$FONT_DIR/" \;
            find "$TMP" -name "*Regular*" -exec cp {} "$FONT_DIR/" \;
            fc-cache -f -v > /dev/null
            rm -rf "$TMP"
            ok "JetBrainsMono Nerd Font installato."
        fi
    fi

    if chiedi "Hack Nerd Font (GitHub — ryanoasis)"; then
        warn "Il font viene scaricato da GitHub Releases."
        if conferma "Procedere con il download"; then
            local FONT_DIR="$HOME/.local/share/fonts/HackNerd"
            mkdir -p "$FONT_DIR"
            local TMP; TMP=$(mktemp -d)
            wget -q --show-progress -P "$TMP" \
                https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.tar.xz
            tar -xf "$TMP/Hack.tar.xz" -C "$FONT_DIR"
            fc-cache -f -v > /dev/null
            rm -rf "$TMP"
            ok "Hack Nerd Font installato."
        fi
    fi
}

# ────────────────────────────────────────
sezione_desktop() {
    titolo "Ambienti Desktop e WM"

    sottotitolo "Desktop Environments"
    chiedi "XFCE4 completo"   && installa_pkg "xfce4 xfce4-goodies" "xfce4 xfce4-goodies" "xfce4 xfce4-goodies" "XFCE4"
    chiedi "MATE Desktop"     && installa_pkg "mate mate-extra" "mate-desktop-environment" "mate" "MATE"
    chiedi "LXQt"             && installa_pkg "lxqt" "lxqt" "lxqt" "LXQt"

    sottotitolo "Window Manager"
    chiedi "i3 WM"            && installa_pkg "i3" "i3" "i3" "i3"
    chiedi "Openbox"          && installa_pkg "openbox" "openbox" "openbox" "Openbox"
    chiedi "bspwm + sxhkd"   && installa_pkg "bspwm sxhkd" "bspwm sxhkd" "bspwm sxhkd" "bspwm"
    chiedi "Sway (Wayland)"   && installa_pkg "sway" "sway" "sway" "Sway"
    chiedi "Herbstluftwm"     && installa_pkg "herbstluftwm" "herbstluftwm" "herbstluftwm" "herbstluftwm"

    sottotitolo "Compositing e UI"
    chiedi "Picom (compositor)" && installa_pkg "picom" "picom" "picom" "Picom"
    chiedi "Rofi (launcher)"    && installa_pkg "rofi" "rofi" "rofi" "Rofi"
    chiedi "Dunst (notify)"     && installa_pkg "dunst" "dunst" "dunst" "Dunst"
    chiedi "Polybar"            && installa_pkg "polybar" "polybar" "polybar" "Polybar"
    chiedi "Conky"              && installa_pkg "conky" "conky" "conky" "Conky"
    chiedi "ARandR (monitor)"   && installa_pkg "arandr" "arandr" "arandr" "ARandR"

    sottotitolo "Login Manager"
    chiedi "LightDM + greeter" && installa_pkg "lightdm lightdm-gtk-greeter" "lightdm lightdm-gtk-greeter" "lightdm lightdm-gtk-greeter" "LightDM"
    chiedi "SDDM"              && installa_pkg "sddm" "sddm" "sddm" "SDDM"
}

# ────────────────────────────────────────
sezione_ufficio() {
    titolo "Ufficio e Produttività"

    sottotitolo "Stato corrente"
    stato_pkg "libreoffice-fresh" "libreoffice" "libreoffice" "LibreOffice"
    stato_pkg "thunderbird" "thunderbird" "thunderbird" "Thunderbird"

    chiedi "LibreOffice"        && installa_pkg "libreoffice-fresh libreoffice-fresh-it" "libreoffice libreoffice-l10n-it" "libreoffice" "LibreOffice"
    chiedi "Thunderbird"        && installa_pkg "thunderbird thunderbird-i18n-it" "thunderbird" "thunderbird" "Thunderbird"
    chiedi "Evolution Mail"     && installa_pkg "evolution" "evolution" "evolution" "Evolution"
    chiedi "Okular (PDF)"       && installa_pkg "okular" "okular" "okular" "Okular"
    chiedi "Evince (PDF)"       && installa_pkg "evince" "evince" "evince" "Evince"
    chiedi "Atril (PDF)"        && installa_pkg "atril" "atril" "atril" "Atril"
    chiedi "Zathura (PDF TUI)"  && installa_pkg "zathura zathura-pdf-mupdf" "zathura" "zathura" "Zathura"
    chiedi "Calibre (eBook)"    && installa_pkg "calibre" "calibre" "calibre" "Calibre"
    chiedi "Pandoc"             && installa_pkg "pandoc" "pandoc" "pandoc" "Pandoc"
    chiedi "KeePassXC"          && installa_pkg "keepassxc" "keepassxc" "keepassxc" "KeePassXC"

    sottotitolo "Comunicazione"
    chiedi "Telegram"           && installa_pkg "telegram-desktop" "telegram-desktop" "telegram-desktop" "Telegram"
    chiedi "Signal"             && {
        case $DISTRO in
            arch) installa_pkg "signal-desktop" "" "" "Signal" ;;
            debian)
                warn "Signal richiede il repository ufficiale Signal."
                if conferma "Aggiungere repo Signal e installare"; then
                    curl -fsSL https://updates.signal.org/desktop/apt/keys.asc | \
                        sudo gpg --dearmor -o /usr/share/keyrings/signal-desktop-keyring.gpg
                    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] \
https://updates.signal.org/desktop/apt xenial main' | \
                        sudo tee /etc/apt/sources.list.d/signal-xenial.list
                    sudo apt update && sudo apt install -y signal-desktop
                    info "Signal installato (repo ufficiale)."
                fi
                ;;
            void) installa_pkg "" "" "signal-desktop" "Signal" ;;
        esac
    }
    chiedi "Discord"            && installa_pkg "discord" "discord" "discord" "Discord"
}

# ────────────────────────────────────────
sezione_gaming() {
    titolo "Gaming e Compatibilità Windows"

    chiedi "Steam" && {
        case $DISTRO in
            arch)
                nota "Assicurati di avere multilib abilitato in /etc/pacman.conf"
                installa_pkg "steam" "" "" "Steam"
                ;;
            debian)
                installa_pkg "" "steam" "" "Steam"
                ;;
            void)
                installa_pkg "" "" "steam" "Steam"
                ;;
        esac
    }
    chiedi "Wine"               && installa_pkg "wine" "wine" "wine" "Wine"
    chiedi "Lutris"             && installa_pkg "lutris" "lutris" "lutris" "Lutris"
    chiedi "MangoHud"           && installa_pkg "mangohud" "mangohud" "mangohud" "MangoHud"
    chiedi "GameMode"           && installa_pkg "gamemode" "gamemode" "gamemode" "GameMode"
    chiedi "Heroic Launcher"    && installa_pkg "heroic-games-launcher" "heroic-games-launcher" "" "Heroic"
}

# ────────────────────────────────────────
sezione_flatpak() {
    titolo "Flatpak e Flathub"

    if ! command -v flatpak &>/dev/null; then
        warn "Flatpak non è installato."
        if chiedi "Installare Flatpak + Flathub"; then
            installa_pkg "flatpak" "flatpak" "flatpak" "Flatpak"
            sudo flatpak remote-add --if-not-exists flathub \
                https://flathub.org/repo/flathub.flatpakrepo
            ok "Flatpak configurato con Flathub."
        fi
    else
        info "Flatpak già installato."
        flatpak remote-list
    fi

    sottotitolo "Ricerca su Flathub"
    echo -en "\n${CYAN}  Cerca un'app su Flathub ${DIM}(invio per saltare)${RESET}${CYAN}: ${RESET}"
    read -r query_flat
    if [ -n "$query_flat" ]; then
        flatpak search "$query_flat" | head -15
        echo ""
        echo -en "  ${CYAN}ID da installare (es. org.videolan.VLC) o invio per annullare: ${RESET}"
        read -r flat_id
        if [ -n "$flat_id" ]; then
            warn "Installazione da Flathub: $flat_id"
            if conferma "Procedere con flatpak install $flat_id"; then
                flatpak install flathub "$flat_id" -y && ok "$flat_id installato."
            fi
        fi
    fi
}

# ────────────────────────────────────────
sezione_sicurezza() {
    titolo "Sicurezza e Backup"

    chiedi "UFW Firewall"       && {
        installa_pkg "ufw" "ufw" "ufw" "UFW"
        sudo ufw enable
        info "UFW attivato con regole di default."
    }
    chiedi "Fail2Ban"           && installa_pkg "fail2ban" "fail2ban" "fail2ban" "Fail2Ban"
    chiedi "ClamAV"             && installa_pkg "clamav" "clamav" "clamav" "ClamAV"
    chiedi "Timeshift (backup)" && installa_pkg "timeshift" "timeshift" "timeshift" "Timeshift"
    chiedi "rsync"              && installa_pkg "rsync" "rsync" "rsync" "rsync"
    chiedi "Borgbackup"         && installa_pkg "borg" "borgbackup" "borgbackup" "Borg Backup"
    chiedi "rclone"             && installa_pkg "rclone" "rclone" "rclone" "rclone"
    chiedi "GnuPG"              && installa_pkg "gnupg" "gnupg" "gnupg" "GnuPG"
}

# ────────────────────────────────────────
sezione_shell() {
    titolo "Shell e Terminale"

    sottotitolo "Stato corrente"
    stato_pkg "zsh" "zsh" "zsh" "Zsh"
    stato_pkg "fish" "fish" "fish" "Fish"
    stato_pkg "tmux" "tmux" "tmux" "tmux"

    chiedi "Zsh"                && {
        installa_pkg "zsh" "zsh" "zsh" "Zsh"
        if chiedi "Impostare Zsh come shell di default"; then
            chsh -s "$(which zsh)"
            info "Shell di default impostata a Zsh."
        fi
    }
    chiedi "Fish Shell"         && installa_pkg "fish" "fish" "fish" "Fish"
    chiedi "Oh-My-Zsh (GitHub)" && {
        warn "Oh-My-Zsh viene scaricato da GitHub (ohmyzsh/ohmyzsh)."
        if conferma "Procedere"; then
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            ok "Oh-My-Zsh installato."
        fi
    }
    chiedi "Starship Prompt (GitHub)" && {
        warn "Starship viene scaricato da starship.rs"
        if conferma "Procedere"; then
            curl -sS https://starship.rs/install.sh | sh -s -- -y
            ok "Starship installato."
        fi
    }
    chiedi "XFCE Terminal"       && installa_pkg "xfce4-terminal" "xfce4-terminal" "xfce4-terminal" "XFCE Terminal"
    chiedi "Alacritty"           && installa_pkg "alacritty" "alacritty" "alacritty" "Alacritty"
    chiedi "Kitty"               && installa_pkg "kitty" "kitty" "kitty" "Kitty"
    chiedi "foot (Wayland)"      && installa_pkg "foot" "foot" "foot" "foot"
}

# ─────────────────────────────────────────────────────────────────────────────
#  RIEPILOGO SESSIONE
# ─────────────────────────────────────────────────────────────────────────────
riepilogo() {
    titolo "Riepilogo Sessione"
    if [ -f "$LOG_FILE" ]; then
        local inst err
        inst=$(grep -c "✔" "$LOG_FILE" 2>/dev/null || echo 0)
        err=$(grep  -c "✘" "$LOG_FILE" 2>/dev/null || echo 0)
        echo -e "  ${GREEN}✔ Installati con successo : ${BOLD}$inst${RESET}"
        echo -e "  ${RED}✘ Errori                  : ${BOLD}$err${RESET}"
        echo -e "  ${CYAN}ℹ Log completo            : ${BOLD}$LOG_FILE${RESET}"
    fi
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  MENU PRINCIPALE
# ─────────────────────────────────────────────────────────────────────────────
banner() {
    clear
    echo -e "${BLUE}${BOLD}"
    cat << 'EOF'
 ╔══════════════════════════════════════════════════════════════════╗
 ║   _ _                               ___  ____    __  __         ║
 ║  (_) |_ __   __ _ _ __  _ __  _   _/ _ \/ ___|  |  \/  | __ _  ║
 ║  | | | '_ \ / _` | '_ \| '_ \| | | | | \___ \  | |\/| |/ _` | ║
 ║  | | | | | | (_| | | | | | | | |_| | |_| |___) | | |  | | (_| | ║
 ║  |_|_|_| |_|\__,_|_| |_|_| |_|\__, |\___/|____/  |_|  |_|\__, | ║
 ║                                 |___/                       |___/ ║
 ║                  POST-INSTALL MANAGER  v3.0                      ║
 ╚══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
    echo -e "  ${DIM}Distro: ${BOLD}$DISTRO${RESET}${DIM}  |  Gestore: ${BOLD}$PKG_MGR${RESET}${DIM}  |  Log: $LOG_FILE${RESET}"
    echo ""
}

menu_principale() {
    while true; do
        banner
        echo -e "  ${CYAN}${BOLD}MENU PRINCIPALE${RESET}"
        echo -e "  ${DIM}$(printf '─%.0s' $(seq 1 50))${RESET}"
        echo -e "  ${YELLOW} 1)${RESET}  🔧  Strumenti di Sistema"
        echo -e "  ${YELLOW} 2)${RESET}  💻  Sviluppo ed Editor"
        echo -e "  ${YELLOW} 3)${RESET}  🎨  Grafica, Video e Multimedia"
        echo -e "  ${YELLOW} 4)${RESET}  🌐  Browser Web e Rete"
        echo -e "  ${YELLOW} 5)${RESET}  🖥️   Ambienti Desktop e WM"
        echo -e "  ${YELLOW} 6)${RESET}  📄  Ufficio e Produttività"
        echo -e "  ${YELLOW} 7)${RESET}  🎮  Gaming e Compatibilità"
        echo -e "  ${YELLOW} 8)${RESET}  🎭  Temi, Icone e Font"
        echo -e "  ${YELLOW} 9)${RESET}  🔒  Sicurezza e Backup"
        echo -e "  ${YELLOW}10)${RESET}  🐚  Shell e Terminale"
        echo -e "  ${YELLOW}11)${RESET}  📦  Flatpak / Flathub"
        echo -e "  ${DIM}$(printf '─%.0s' $(seq 1 50))${RESET}"
        echo -e "  ${GREEN} s)${RESET}  🔍  Ricerca Pacchetto (smart)"
        echo -e "  ${GREEN} a)${RESET}  ⬆️   Aggiorna Sistema"
        echo -e "  ${GREEN} r)${RESET}  📊  Riepilogo Sessione"
        echo -e "  ${RED}  q)${RESET}  ✖   Esci"
        echo ""
        echo -en "  ${CYAN}${BOLD}Scelta: ${RESET}"
        read -r opt

        case $opt in
            1)  sezione_sistema       ; pausa ;;
            2)  sezione_sviluppo      ; pausa ;;
            3)  sezione_grafica       ; pausa ;;
            4)  sezione_browser_rete  ; pausa ;;
            5)  sezione_desktop       ; pausa ;;
            6)  sezione_ufficio       ; pausa ;;
            7)  sezione_gaming        ; pausa ;;
            8)  sezione_temi          ; pausa ;;
            9)  sezione_sicurezza     ; pausa ;;
            10) sezione_shell         ; pausa ;;
            11) sezione_flatpak       ; pausa ;;
            s|S) ricerca_pacchetto   ; pausa ;;
            a|A) aggiorna_sistema    ; pausa ;;
            r|R) riepilogo           ; pausa ;;
            q|Q) riepilogo; echo -e "\n${GREEN}${BOLD}  Arrivederci!${RESET}\n"; exit 0 ;;
            *)  warn "Opzione non valida."; sleep 1 ;;
        esac
    done
}

# ─────────────────────────────────────────────────────────────────────────────
#  ENTRYPOINT
# ─────────────────────────────────────────────────────────────────────────────
main() {
    touch "$LOG_FILE"
    echo "=== ilnanny PostInstall v$VERSION — $(date) ===" >> "$LOG_FILE"
    
    rileva_distro
    
    # Controllo root parziale: non girare come root diretto
    if [ "$EUID" -eq 0 ]; then
        warn "Stai girando come root. Meglio usare un utente normale con sudo."
        conferma "Continuare comunque" || exit 1
    fi
    
    menu_principale
}

main "$@"
