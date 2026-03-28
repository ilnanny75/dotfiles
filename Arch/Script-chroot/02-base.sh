#!/usr/bin/env bash
# =============================================================================
# 02-base.sh — pacstrap, fstab, locale, hostname, utente, X11, sudo
# Arch Linux su Huawei Matebook D | Intel i5-10210U | GPU Intel UHD 620
# Utente: ilnanny | Shell: bash | Dotfiles: github.com/ilnanny75/dotfiles
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()  { echo -e "${CYAN}[INFO]${RESET} $*"; }
ok()    { echo -e "${GREEN}[OK]${RESET}   $*"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error() { echo -e "${RED}[ERR]${RESET}  $*" >&2; exit 1; }

[[ $EUID -ne 0 ]] && error "Esegui come root: sudo bash 02-base.sh"

# ─── Importa variabili da script 01 ──────────────────────────────────────────
VARS_FILE="/tmp/arch-install-vars.env"
if [[ -f "${VARS_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${VARS_FILE}"
else
    warn "File variabili non trovato, uso valori predefiniti."
    MOUNTPOINT="/mnt/arch"
fi

# ─── Variabili configurazione ─────────────────────────────────────────────────
USERNAME="ilnanny"
HOSTNAME="matebook-arch"
LOCALE_IT="it_IT.UTF-8"
LOCALE_EN="en_US.UTF-8"
TIMEZONE="Europe/Rome"
DOTFILES_REPO="https://github.com/ilnanny75/dotfiles.git"

# ─── Banner ──────────────────────────────────────────────────────────────────
echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║        ARCH LINUX INSTALL — 02 BASE SYSTEM              ║"
echo "║   pacstrap | locale | utente ilnanny | X11 | sudo       ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Verifica mount
mountpoint -q "${MOUNTPOINT}" || error "${MOUNTPOINT} non montato. Esegui prima 01-partizioni.sh"

# ─── 1. pacstrap ─────────────────────────────────────────────────────────────
info "Installazione sistema base con pacstrap..."
pacstrap -K "${MOUNTPOINT}" \
    base base-devel linux linux-firmware \
    intel-ucode \
    linux-headers \
    networkmanager \
    grub efibootmgr \
    git bash bash-completion \
    vim nano \
    man-db man-pages \
    wget curl \
    zsh \
    htop \
    zip unzip p7zip \
    openssh \
    reflector \
    pacman-contrib \
    os-prober \
    ntfs-3g
ok "pacstrap completato."

# ─── 2. fstab ────────────────────────────────────────────────────────────────
info "Generazione fstab..."
genfstab -U "${MOUNTPOINT}" >> "${MOUNTPOINT}/etc/fstab"
echo ""
info "Contenuto fstab generato:"
cat "${MOUNTPOINT}/etc/fstab"
echo ""
ok "fstab generato."

# ─── 3. Configurazione in chroot ─────────────────────────────────────────────
info "Entrata in chroot per configurazione sistema..."

arch-chroot "${MOUNTPOINT}" /bin/bash <<CHROOT_EOF
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
info()  { echo -e "\${CYAN}[INFO]\${RESET} \$*"; }
ok()    { echo -e "\${GREEN}[OK]\${RESET}   \$*"; }

# Timezone
info "Impostazione timezone ${TIMEZONE}..."
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc
ok "Timezone impostata."

# Locale
info "Configurazione locale..."
sed -i 's/^#${LOCALE_IT}/${LOCALE_IT}/' /etc/locale.gen
sed -i 's/^#${LOCALE_EN}/${LOCALE_EN}/' /etc/locale.gen
locale-gen
echo "LANG=${LOCALE_IT}" > /etc/locale.conf
echo "LC_TIME=${LOCALE_IT}" >> /etc/locale.conf
echo "LC_ALL=${LOCALE_IT}" >> /etc/locale.conf
ok "Locale configurata: ${LOCALE_IT}"

# Tastiera
info "Configurazione tastiera italiana..."
echo "KEYMAP=it" > /etc/vconsole.conf
echo "FONT=Lat2-Terminus16" >> /etc/vconsole.conf
ok "Tastiera: it"

# Hostname
info "Impostazione hostname..."
echo "${HOSTNAME}" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain  ${HOSTNAME}
EOF
ok "Hostname: ${HOSTNAME}"

# Initramfs (aggiunge moduli Intel per early KMS)
info "Configurazione mkinitcpio per Intel UHD 620..."
sed -i 's/^MODULES=()/MODULES=(i915)/' /etc/mkinitcpio.conf
mkinitcpio -P
ok "Initramfs rigenerato con modulo i915."

# GRUB
info "Installazione GRUB EFI..."
pacman -S --noconfirm grub efibootmgr os-prober

# Configura /etc/default/grub PRIMA di grub-mkconfig
info "Configurazione /etc/default/grub (os-prober + timeout)..."
# Abilita os-prober per rilevare MX Linux, Void, Windows
sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
# Se la riga non esisteva la aggiunge in fondo
grep -q 'GRUB_DISABLE_OS_PROBER' /etc/default/grub || \
    echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
# Timeout 10 secondi (abbastanza per scegliere)
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=10/' /etc/default/grub
# Menu sempre visibile (non hidden)
sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub
# Risoluzione grafica
sed -i 's/^#GRUB_GFXMODE=.*/GRUB_GFXMODE=auto/' /etc/default/grub
ok "Parametri GRUB impostati."

grub-install --target=x86_64-efi \
             --efi-directory=/boot/efi \
             --bootloader-id="Arch Linux" \
             --recheck

# os-prober ha bisogno che le altre partizioni siano montate per rilevarle.
# Monta temporaneamente sda2 (MX) e sda4 (Void) se non già montate.
info "Mount temporaneo sda2/sda4 per os-prober..."
mkdir -p /mnt/probe_mx /mnt/probe_void
mount /dev/sda2 /mnt/probe_mx  2>/dev/null || true
mount /dev/sda4 /mnt/probe_void 2>/dev/null || true

info "Generazione grub.cfg (os-prober rileva MX, Void, eventuale Windows)..."
grub-mkconfig -o /boot/grub/grub.cfg

# Smonta i probe mount
umount /mnt/probe_mx  2>/dev/null || true
umount /mnt/probe_void 2>/dev/null || true
rmdir  /mnt/probe_mx /mnt/probe_void 2>/dev/null || true

ok "GRUB installato — MX Linux, Void e Windows rilevati da os-prober."

# NetworkManager
info "Abilitazione NetworkManager..."
systemctl enable NetworkManager
ok "NetworkManager abilitato."

# SSH (opzionale, disabilitato di default)
systemctl disable sshd 2>/dev/null || true

# Password root
info "Impostazione password root..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
passwd root
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "Password root impostata."

# Utente ilnanny
info "Creazione utente ${USERNAME}..."
if id "${USERNAME}" &>/dev/null; then
    echo -e "\${YELLOW}[WARN]\${RESET} Utente ${USERNAME} già esistente."
else
    useradd -m -G wheel,audio,video,optical,storage,network,input \
            -s /bin/bash \
            -c "ilnanny" \
            "${USERNAME}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
passwd "${USERNAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "Utente ${USERNAME} creato con shell bash."

# sudo
info "Configurazione sudo per gruppo wheel..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
ok "sudo abilitato per gruppo wheel."

# ─── X11 + driver Intel ──────────────────────────────────────────────────────
info "Installazione X11 e driver Intel UHD 620..."
pacman -S --noconfirm \
    xorg-server \
    xorg-xinit \
    xorg-xrandr \
    xorg-xdpyinfo \
    xorg-xset \
    xterm \
    mesa \
    libva-intel-driver \
    intel-media-driver \
    vulkan-intel \
    xf86-video-intel \
    xf86-input-libinput
ok "X11 e driver Intel installati."

# Configurazione X11 per Intel (TearFree, SNA)
mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/20-intel.conf <<EOF
Section "Device"
    Identifier  "Intel Graphics"
    Driver      "intel"
    Option      "TearFree"    "true"
    Option      "AccelMethod" "sna"
    Option      "DRI"         "3"
EndSection
EOF
ok "Configurazione Intel TearFree applicata."

# Touchpad libinput
cat > /etc/X11/xorg.conf.d/40-libinput.conf <<EOF
Section "InputClass"
    Identifier "libinput touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lrm"
    Option "NaturalScrolling" "true"
    Option "DisableWhileTyping" "true"
EndSection
EOF
ok "Touchpad libinput configurato."

# ─── yay (AUR helper) ────────────────────────────────────────────────────────
info "Installazione yay (AUR helper)..."
pacman -S --noconfirm git
cd /tmp
git clone https://aur.archlinux.org/yay.git
chown -R ${USERNAME}:${USERNAME} /tmp/yay
cd /tmp/yay
sudo -u ${USERNAME} makepkg -si --noconfirm
cd /
rm -rf /tmp/yay
ok "yay installato."

# ─── Dotfiles ────────────────────────────────────────────────────────────────
info "Clone dotfiles da ${DOTFILES_REPO}..."
sudo -u ${USERNAME} git clone ${DOTFILES_REPO} /home/${USERNAME}/.dotfiles || \
    echo -e "\${YELLOW}[WARN]\${RESET} Clone dotfiles fallito (verifica dopo il reboot)."
ok "Dotfiles clonati in /home/${USERNAME}/.dotfiles"

echo ""
echo -e "\${GREEN}\${BOLD}✔ Configurazione base chroot completata.\${RESET}"
CHROOT_EOF

echo ""
echo -e "${GREEN}${BOLD}✔ Script 02 completato. Prosegui con: sudo bash 03-desktop.sh${RESET}"
