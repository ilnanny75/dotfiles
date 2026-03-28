#!/usr/bin/env bash
# =============================================================================
#  install-arch-chroot.sh
#  Installa Arch Linux su /dev/sda3 (Arch-root) in chroot da MX Linux
#  Autore: ilnanny75 | GPU: Intel UHD (i5-10210U) | DE: XFCE | Shell: bash
#  EFI condivisa: /dev/sda1 | GRUB master: MX Linux (\EFI\MX\grubx64.efi)
# =============================================================================

set -euo pipefail

# ── Colori ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
BLU='\033[1;34m'; CYN='\033[0;36m'; RST='\033[0m'; BLD='\033[1m'

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${BLU}[INFO]${RST} $*"; }
ok()      { echo -e "${GRN}[  OK]${RST} $*"; }
warn()    { echo -e "${YLW}[WARN]${RST} $*"; }
err()     { echo -e "${RED}[ERR ]${RST} $*"; exit 1; }
section() { echo -e "\n${BLD}${CYN}══════════════════════════════════════${RST}"; \
            echo -e "${BLD}${CYN}  $*${RST}"; \
            echo -e "${BLD}${CYN}══════════════════════════════════════${RST}"; }
ask()     { echo -en "${YLW}[?]${RST} $* "; }
pause()   { echo -e "${YLW}[PAUSA]${RST} Premi INVIO per continuare..."; read -r; }

# ── Variabili configurazione ──────────────────────────────────────────────────
ARCH_PART="/dev/sda3"
EFI_PART="/dev/sda1"
MOUNT="/mnt/arch-install"
EFI_UUID="5FCE-81A1"
ARCH_UUID="932fc410-ffaa-4853-b188-4a104473c145"
HOSTNAME="archlinux"
LOCALE_LANG="it_IT.UTF-8"
LOCALE_GEN="it_IT.UTF-8 UTF-8\nen_US.UTF-8 UTF-8"
KEYMAP="it"
TIMEZONE="Europe/Rome"
DOTFILES_REPO="https://github.com/ilnanny75/dotfiles"
GRUB_ID="Arch"

# ── Controllo root ────────────────────────────────────────────────────────────
[[ $EUID -ne 0 ]] && err "Esegui lo script come root: sudo bash $0"

# =============================================================================
section "BENVENUTO — Installazione Arch Linux in chroot"
# =============================================================================
echo ""
echo -e "  Disco target  : ${BLD}${ARCH_PART}${RST} (Arch-root)"
echo -e "  EFI           : ${BLD}${EFI_PART}${RST} (condivisa con MX/Void)"
echo -e "  Mount point   : ${BLD}${MOUNT}${RST}"
echo -e "  Hostname      : ${BLD}${HOSTNAME}${RST}"
echo -e "  DE            : ${BLD}XFCE${RST}"
echo -e "  Shell         : ${BLD}bash${RST}"
echo -e "  Dotfiles      : ${BLD}${DOTFILES_REPO}${RST}"
echo ""
ask "Tutto corretto? Procedere? [s/N]"
read -r CONFIRM
[[ "${CONFIRM,,}" != "s" ]] && echo "Annullato." && exit 0

# =============================================================================
section "FASE 1 — Installazione arch-install-scripts"
# =============================================================================
info "Verifico se pacstrap è disponibile..."
if ! command -v pacstrap &>/dev/null; then
    info "pacstrap non trovato. Installo arch-install-scripts..."
    apt-get update -qq
    apt-get install -y arch-install-scripts || \
        err "Impossibile installare arch-install-scripts. Installa manualmente e riprova."
    ok "arch-install-scripts installato."
else
    ok "pacstrap già disponibile."
fi

if ! command -v arch-chroot &>/dev/null; then
    err "arch-chroot non trovato. Verifica l'installazione di arch-install-scripts."
fi

# =============================================================================
section "FASE 2 — Montaggio partizioni"
# =============================================================================
info "Creo punto di mount ${MOUNT}..."
mkdir -p "${MOUNT}"

info "Monto ${ARCH_PART} su ${MOUNT}..."
if mountpoint -q "${MOUNT}"; then
    warn "${MOUNT} già montato, smonto prima..."
    umount -R "${MOUNT}"
fi
mount "${ARCH_PART}" "${MOUNT}"
ok "${ARCH_PART} montato su ${MOUNT}"

info "Monto EFI ${EFI_PART} su ${MOUNT}/boot/efi..."
mkdir -p "${MOUNT}/boot/efi"
mount "${EFI_PART}" "${MOUNT}/boot/efi"
ok "EFI montata su ${MOUNT}/boot/efi"

# =============================================================================
section "FASE 3 — Installazione sistema base (pacstrap)"
# =============================================================================
info "Configurazione mirror Arch (usando rankmirrors o mirror IT)..."

# Crea pacman.conf temporaneo con mirror IT
mkdir -p /tmp/arch-mirrors
cat > /tmp/pacman-arch.conf <<'EOF'
[options]
HoldPkg     = pacman glibc
Architecture = auto
CheckSpace
ParallelDownloads = 5

[core]
Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch

[extra]
Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch
EOF

info "Avvio pacstrap — questo richiede qualche minuto..."
pacstrap -C /tmp/pacman-arch.conf "${MOUNT}" \
    base base-devel linux linux-firmware intel-ucode \
    networkmanager grub efibootmgr os-prober \
    bash bash-completion \
    vim nano git curl wget \
    \
    mesa vulkan-intel intel-media-driver libva-intel-driver \
    xf86-video-intel libva-utils vdpauinfo \
    \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack \
    wireplumber \
    gst-plugin-pipewire gstreamer-vaapi \
    ffmpeg pavucontrol \
    \
    bluez bluez-utils blueberry \
    \
    xorg xorg-xinit xorg-xrandr \
    xfce4 xfce4-goodies \
    network-manager-applet nm-connection-editor \
    lightdm lightdm-slick-greeter \
    \
    firefox \
    \
    ttf-dejavu ttf-liberation noto-fonts \
    noto-fonts-emoji ttf-font-awesome \
    \
    sudo

ok "Sistema base installato."

# =============================================================================
section "FASE 4 — Generazione fstab"
# =============================================================================
info "Genero /etc/fstab con UUID..."
genfstab -U "${MOUNT}" >> "${MOUNT}/etc/fstab"
ok "fstab generato:"
cat "${MOUNT}/etc/fstab"
pause

# =============================================================================
section "FASE 5 — Configurazione in chroot"
# =============================================================================

# Chiedo il nome utente
ask "Nome utente per Arch Linux [default: ilnanny]:"
read -r USERNAME
USERNAME="${USERNAME:-ilnanny}"

# Creo lo script da eseguire dentro il chroot
cat > "${MOUNT}/root/arch-setup.sh" <<CHROOT_EOF
#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
BLU='\033[1;34m'; CYN='\033[0;36m'; RST='\033[0m'; BLD='\033[1m'
info()    { echo -e "\${BLU}[INFO]\${RST} \$*"; }
ok()      { echo -e "\${GRN}[  OK]\${RST} \$*"; }
section() { echo -e "\n\${BLD}\${CYN}══ \$* ══\${RST}"; }

USERNAME="${USERNAME}"
HOSTNAME="${HOSTNAME}"
LOCALE_LANG="${LOCALE_LANG}"
KEYMAP="${KEYMAP}"
TIMEZONE="${TIMEZONE}"
DOTFILES_REPO="${DOTFILES_REPO}"

# ── 5.1 Timezone ──────────────────────────────────────────────────────────────
section "5.1 Timezone"
ln -sf /usr/share/zoneinfo/\${TIMEZONE} /etc/localtime
hwclock --systohc
ok "Timezone: \${TIMEZONE}"

# ── 5.2 Locale ────────────────────────────────────────────────────────────────
section "5.2 Locale"
echo "it_IT.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=\${LOCALE_LANG}" > /etc/locale.conf
echo "KEYMAP=\${KEYMAP}" > /etc/vconsole.conf
ok "Locale: \${LOCALE_LANG} | Keymap: \${KEYMAP}"

# ── 5.3 Hostname ──────────────────────────────────────────────────────────────
section "5.3 Hostname"
echo "\${HOSTNAME}" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   \${HOSTNAME}.localdomain \${HOSTNAME}
EOF
ok "Hostname: \${HOSTNAME}"

# ── 5.4 Password root ─────────────────────────────────────────────────────────
section "5.4 Password root"
echo "Imposta la password per root:"
passwd

# ── 5.5 Utente ────────────────────────────────────────────────────────────────
section "5.5 Creazione utente \${USERNAME}"
useradd -m -G wheel,audio,video,network,storage,optical,bluetooth -s /bin/bash "\${USERNAME}"
echo "Imposta la password per \${USERNAME}:"
passwd "\${USERNAME}"

# Abilita sudo per gruppo wheel
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
ok "Utente \${USERNAME} creato con sudo."

# ── 5.6 Initramfs ─────────────────────────────────────────────────────────────
section "5.6 mkinitcpio"
mkinitcpio -P
ok "initramfs generato."

# ── 5.7 LightDM ───────────────────────────────────────────────────────────────
section "5.7 Servizi"
# ── Configura slick-greeter ───────────────────────────────────────────────────
mkdir -p /etc/lightdm
cat > /etc/lightdm/slick-greeter.conf <<EOF
[Greeter]
background=#1a1a1a
theme-name=Adwaita-dark
icon-theme-name=Adwaita
font-name=Sans 11
show-hostname=true
show-power=true
show-a11y=false
show-keyboard=false
EOF

# Imposta slick-greeter come greeter attivo
sed -i 's/#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf

# ── Tema GTK scuro per l'utente ───────────────────────────────────────────────
mkdir -p /home/\${USERNAME}/.config/gtk-3.0
cat > /home/\${USERNAME}/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
gtk-font-name=Sans 11
gtk-cursor-theme-name=Adwaita
gtk-application-prefer-dark-theme=1
EOF

# GTK2 per compatibilità app legacy
cat > /home/\${USERNAME}/.gtkrc-2.0 <<EOF
gtk-theme-name="Adwaita-dark"
gtk-icon-theme-name="Adwaita"
gtk-font-name="Sans 11"
gtk-cursor-theme-name="Adwaita"
EOF

# Impostazioni XFCE (xfconf) tramite xfconf-query non disponibile in chroot,
# quindi le impostiamo via XML direttamente
mkdir -p /home/\${USERNAME}/.config/xfce4/xfconf/xfce-perchannel-xml
cat > /home/\${USERNAME}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Adwaita-dark"/>
    <property name="IconThemeName" type="string" value="Adwaita"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CursorThemeName" type="string" value="Adwaita"/>
    <property name="FontName" type="string" value="Sans 11"/>
    <property name="ApplicationPreferDarkTheme" type="bool" value="true"/>
  </property>
</channel>
EOF

chown -R \${USERNAME}:\${USERNAME} /home/\${USERNAME}/.config /home/\${USERNAME}/.gtkrc-2.0
ok "Tema Adwaita-dark applicato per \${USERNAME}."

systemctl enable lightdm
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable fstrim.timer
ok "LightDM, NetworkManager, Bluetooth, fstrim abilitati."

# Pipewire via systemd user (si abilita per utente, non system)
# Viene avviato automaticamente da XDG autostart in XFCE
# Aggiungo udev rule per bluetooth
sed -i 's/#AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf || true

# ── 5.8 GRUB EFI ──────────────────────────────────────────────────────────────
section "5.8 GRUB — installazione in \EFI\Arch"
# Abilita os-prober
sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub

grub-install --target=x86_64-efi \
    --efi-directory=/boot/efi \
    --bootloader-id=Arch \
    --recheck

grub-mkconfig -o /boot/grub/grub.cfg
ok "GRUB installato in \EFI\Arch\grubx64.efi"

# ── 5.9 yay — AUR helper ──────────────────────────────────────────────────────
section "5.9 Installazione yay (AUR helper)"
# makepkg non può girare come root, serve l'utente normale
# Diamo accesso temporaneo a sudo senza password per la compilazione
echo "\${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/yay-temp

su - "\${USERNAME}" -c "
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd /tmp
    rm -rf yay
"

# Rimuove la regola sudo temporanea
rm -f /etc/sudoers.d/yay-temp
ok "yay installato. Uso: yay -S <pacchetto-aur>"

# ── 5.10 Dotfiles ─────────────────────────────────────────────────────────────
section "5.10 Dotfiles da GitHub"
su - "\${USERNAME}" -c "
    git clone ${DOTFILES_REPO} ~/dotfiles
    cd ~/dotfiles
    if [ -f install.sh ]; then
        bash install.sh
    elif [ -f setup.sh ]; then
        bash setup.sh
    else
        echo 'Nessuno script install trovato. Link manuali:'
        ls ~/dotfiles/
    fi
"
ok "Dotfiles clonati in /home/\${USERNAME}/dotfiles"

echo ""
echo -e "\${GRN}\${BLD}══════════════════════════════════════\${RST}"
echo -e "\${GRN}\${BLD}  Configurazione chroot completata!  \${RST}"
echo -e "\${GRN}\${BLD}══════════════════════════════════════\${RST}"
echo ""
echo "Prossimi passi da MX Linux dopo il reboot:"
echo "  sudo update-grub   ← per rilevare Arch nel GRUB master MX"
echo ""
CHROOT_EOF

chmod +x "${MOUNT}/root/arch-setup.sh"

info "Entro in arch-chroot ed eseguo la configurazione..."
arch-chroot "${MOUNT}" /root/arch-setup.sh

# =============================================================================
section "FASE 6 — Pulizia e smontaggio"
# =============================================================================
info "Rimuovo script temporaneo dal chroot..."
rm -f "${MOUNT}/root/arch-setup.sh"

info "Smonto le partizioni..."
umount -R "${MOUNT}"
ok "Tutto smontato correttamente."

# =============================================================================
section "INSTALLAZIONE COMPLETATA"
# =============================================================================
echo ""
echo -e "  ${GRN}${BLD}Arch Linux installato con successo su ${ARCH_PART}${RST}"
echo ""
echo -e "  ${BLD}Cosa fare ora:${RST}"
echo -e "  1. Riavvia in MX Linux"
echo -e "  2. Esegui: ${CYN}sudo update-grub${RST}"
echo -e "     → rileverà Arch e lo aggiungerà al menu GRUB master"
echo -e "  3. Riavvia e scegli ${BLD}Arch Linux${RST} dal menu GRUB"
echo ""
echo -e "  ${YLW}EFI Arch:${RST} \\EFI\\Arch\\grubx64.efi"
echo -e "  ${YLW}Utente  :${RST} ${USERNAME}"
echo -e "  ${YLW}Hostname:${RST} ${HOSTNAME}"
echo -e "  ${YLW}DE      :${RST} XFCE + LightDM"
echo ""
