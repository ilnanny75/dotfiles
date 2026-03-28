#!/usr/bin/env bash
# =============================================================================
# 03-desktop.sh — DE/WM, audio (PipeWire), wifi, bluetooth, LightDM + slick-greeter
# Arch Linux su Huawei Matebook D | XFCE | Tema: Adwaita-dark
# Utente: ilnanny | Greeter: lightdm-slick-greeter
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()  { echo -e "${CYAN}[INFO]${RESET} $*"; }
ok()    { echo -e "${GREEN}[OK]${RESET}   $*"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error() { echo -e "${RED}[ERR]${RESET}  $*" >&2; exit 1; }

[[ $EUID -ne 0 ]] && error "Esegui come root: sudo bash 03-desktop.sh"

VARS_FILE="/tmp/arch-install-vars.env"
[[ -f "${VARS_FILE}" ]] && source "${VARS_FILE}" || MOUNTPOINT="/mnt/arch"

USERNAME="ilnanny"

mountpoint -q "${MOUNTPOINT}" || error "${MOUNTPOINT} non montato."

# ─── Banner ──────────────────────────────────────────────────────────────────
echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║        ARCH LINUX INSTALL — 03 DESKTOP                  ║"
echo "║   XFCE | PipeWire | WiFi | Bluetooth | LightDM          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# ─── Selezione DE/WM interattiva ─────────────────────────────────────────────
echo -e "${BOLD}Scegli il Desktop Environment / Window Manager:${RESET}"
echo "  1) XFCE          (consigliato — già configurato)"
echo "  2) i3wm          (tiling, minimale)"
echo "  3) Openbox       (floating, leggero)"
echo "  4) GNOME         (completo, moderno)"
echo "  5) KDE Plasma    (completo, personalizzabile)"
echo "  6) Solo WM base  (nessun DE — solo Openbox + tint2)"
echo ""
read -rp "Scelta [1-6, default=1]: " DE_CHOICE
DE_CHOICE="${DE_CHOICE:-1}"

case "${DE_CHOICE}" in
    1) DE_NAME="XFCE";        DE_PKGS="xfce4 xfce4-goodies" ;;
    2) DE_NAME="i3wm";        DE_PKGS="i3-wm i3status i3blocks dmenu rofi feh picom" ;;
    3) DE_NAME="Openbox";     DE_PKGS="openbox obconf lxappearance tint2 pcmanfm rofi" ;;
    4) DE_NAME="GNOME";       DE_PKGS="gnome gnome-extra" ;;
    5) DE_NAME="KDE Plasma";  DE_PKGS="plasma kde-applications" ;;
    6) DE_NAME="Minimal WM";  DE_PKGS="openbox tint2 feh picom" ;;
    *) DE_NAME="XFCE";        DE_PKGS="xfce4 xfce4-goodies" ;;
esac

info "DE selezionato: ${DE_NAME}"

# ─── Configurazione in chroot ─────────────────────────────────────────────────
arch-chroot "${MOUNTPOINT}" /bin/bash <<CHROOT_EOF
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
info()  { echo -e "\${CYAN}[INFO]\${RESET} \$*"; }
ok()    { echo -e "\${GREEN}[OK]\${RESET}   \$*"; }
warn()  { echo -e "\${YELLOW}[WARN]\${RESET} \$*"; }

USERNAME="${USERNAME}"
DE_PKGS="${DE_PKGS}"
DE_NAME="${DE_NAME}"

# ─── 1. Desktop Environment ───────────────────────────────────────────────────
info "Installazione \${DE_NAME} (\${DE_PKGS})..."
pacman -S --noconfirm \${DE_PKGS}
ok "\${DE_NAME} installato."

# ─── 2. Font e temi ──────────────────────────────────────────────────────────
info "Installazione font e temi..."
pacman -S --noconfirm \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-cjk \
    ttf-hack \
    adwaita-icon-theme \
    gnome-themes-extra \
    gtk-engine-murrine
ok "Font e temi installati (include Adwaita-dark)."

# ─── 3. LightDM + slick-greeter ──────────────────────────────────────────────
info "Installazione LightDM e lightdm-slick-greeter..."
pacman -S --noconfirm lightdm

# slick-greeter è su AUR
sudo -u \${USERNAME} yay -S --noconfirm lightdm-slick-greeter

# Configurazione LightDM
info "Configurazione LightDM per slick-greeter..."
sed -i 's/^#greeter-session=.*/greeter-session=lightdm-slick-greeter/' \
    /etc/lightdm/lightdm.conf
sed -i "s/^#user-session=.*/user-session=xfce/" \
    /etc/lightdm/lightdm.conf

# Configurazione slick-greeter (tema Adwaita-dark)
cat > /etc/lightdm/slick-greeter.conf <<EOF
[Greeter]
theme-name=Adwaita-dark
icon-theme-name=Adwaita
background=/usr/share/backgrounds/archlinux/simple.png
draw-user-backgrounds=true
show-hostname=true
clock-format=%H:%M — %A %d %B
EOF
ok "LightDM configurato con slick-greeter + Adwaita-dark."

# Abilita LightDM
systemctl enable lightdm
ok "LightDM abilitato all'avvio."

# ─── 4. Audio: PipeWire ──────────────────────────────────────────────────────
info "Installazione PipeWire (audio moderno)..."
pacman -S --noconfirm \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    pipewire-jack \
    wireplumber \
    pavucontrol \
    alsa-utils

# Abilita PipeWire per l'utente
sudo -u \${USERNAME} systemctl --user enable pipewire pipewire-pulse wireplumber 2>/dev/null || \
    info "PipeWire si abiliterà al primo login dell'utente."
ok "PipeWire installato."

# ─── 5. WiFi ─────────────────────────────────────────────────────────────────
info "Installazione strumenti WiFi..."
pacman -S --noconfirm \
    iw \
    iwd \
    wireless_tools \
    wpa_supplicant \
    nm-connection-editor \
    network-manager-applet

# Huawei Matebook D — Intel AX WiFi (già supportato dal kernel)
info "Verifica firmware Intel WiFi (iwlwifi)..."
if [[ -d /lib/firmware/iwlwifi* ]] 2>/dev/null || ls /lib/firmware/iwlwifi* &>/dev/null; then
    ok "Firmware iwlwifi presente."
else
    pacman -S --noconfirm linux-firmware
    ok "linux-firmware installato."
fi

systemctl enable NetworkManager
ok "WiFi configurato tramite NetworkManager."

# ─── 6. Bluetooth ────────────────────────────────────────────────────────────
info "Installazione Bluetooth..."
pacman -S --noconfirm \
    bluez \
    bluez-utils \
    blueman

systemctl enable bluetooth
ok "Bluetooth abilitato (bluez + blueman)."

# ─── 7. Gestione energia (Huawei Matebook) ───────────────────────────────────
info "Installazione gestione energia..."
pacman -S --noconfirm \
    tlp \
    tlp-rdw \
    powertop \
    acpi \
    acpid

systemctl enable tlp
systemctl enable acpid
ok "TLP e acpid abilitati per risparmio energetico."

# ─── 8. Applicazioni base XFCE ───────────────────────────────────────────────
info "Applicazioni di base per XFCE + Thunar con supporto volumi completo..."
pacman -S --noconfirm \
    thunar \
    thunar-archive-plugin \
    thunar-volman \
    thunar-media-tags-plugin \
    file-roller \
    mousepad \
    ristretto \
    xarchiver \
    ntfs-3g \
    gvfs \
    gvfs-mtp \
    gvfs-smb \
    gvfs-nfs \
    gvfs-goa \
    gvfs-afc \
    gvfs-gphoto2 \
    udisks2 \
    udiskie \
    xdg-user-dirs \
    xdg-utils \
    xfce4-terminal \
    xfce4-notifyd \
    xfce4-screenshooter \
    xfce4-taskmanager \
    xfce4-power-manager

# udiskie: automount in background per tutti i volumi (NTFS, FAT, ext4, MTP)
# Lo avviamo all'avvio della sessione XFCE
USER_HOME="/home/${USERNAME}"
mkdir -p "${USER_HOME}/.config/autostart"
cat > "${USER_HOME}/.config/autostart/udiskie.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=udiskie
Exec=udiskie --tray --automount --notify
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Comment=Automount removable media
EOF
chown ${USERNAME}:${USERNAME} "${USER_HOME}/.config/autostart/udiskie.desktop"
ok "Thunar + NTFS (ntfs-3g) + gvfs completo + udiskie automount installati."

# ─── 9. Stampanti (CUPS) ─────────────────────────────────────────────────────
info "Installazione CUPS (stampanti)..."
pacman -S --noconfirm cups system-config-printer
systemctl enable cups
ok "CUPS abilitato."

# ─── 10. Tema GTK Adwaita-dark per ilnanny ───────────────────────────────────
info "Configurazione tema Adwaita-dark per l'utente \${USERNAME}..."
USER_HOME="/home/\${USERNAME}"

mkdir -p "\${USER_HOME}/.config/gtk-3.0"
cat > "\${USER_HOME}/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
gtk-font-name=Noto Sans 10
gtk-cursor-theme-name=Adwaita
gtk-application-prefer-dark-theme=1
EOF

mkdir -p "\${USER_HOME}/.config/gtk-4.0"
cp "\${USER_HOME}/.config/gtk-3.0/settings.ini" "\${USER_HOME}/.config/gtk-4.0/settings.ini"

# GTK2
cat > "\${USER_HOME}/.gtkrc-2.0" <<EOF
gtk-theme-name="Adwaita-dark"
gtk-icon-theme-name="Adwaita"
gtk-font-name="Noto Sans 10"
EOF

chown -R \${USERNAME}:\${USERNAME} "\${USER_HOME}/.config" "\${USER_HOME}/.gtkrc-2.0"
ok "Tema Adwaita-dark configurato per \${USERNAME}."

# xdg-user-dirs
sudo -u \${USERNAME} xdg-user-dirs-update 2>/dev/null || true

echo ""
echo -e "\${GREEN}\${BOLD}✔ Script 03 desktop completato.\${RESET}"
CHROOT_EOF

echo ""
echo -e "${GREEN}${BOLD}✔ Script 03 completato. Prosegui con: sudo bash 04-postinstall.sh${RESET}"
