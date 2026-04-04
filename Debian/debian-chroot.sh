#!/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Nota: DEBIAN MASTER INSTALLER 2026. Script interattivo per la 
# preparazione del sistema: gestione partizioni, installazione base, 
# driver hardware automatici e strumenti web essenziali.
# Target: SSD Esterno Crucial (/dev/sda)
# Host Supportati: Arch Linux, Debian/MX, Void Linux
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

# --- COLORI ---
V="\e[32m"; R="\e[31m"; G="\e[33m"; C="\e[36m"; B="\e[1m"; RESET="\e[0m"

# 1. CONTROLLO PRIVILEGI
if [[ $EUID -ne 0 ]]; then
    echo -e "${G}Richiesti privilegi di ROOT.${RESET}"
    if command -v sudo &> /dev/null; then
        exec sudo "$0" "$@"
    else
        echo "Inserisci password di root:"
        exec su -c "$0" "$@"
    fi
    exit
fi

# 2. RACCOLTA DATI INTERATTIVA
clear
echo -e "${B}${C}--- CONFIGURAZIONE DEBIAN PRO (Smart Hardware Detection) ---${RESET}"
read -p "Nome Utente: " NEW_USER
read -s -p "Password Utente: " USER_PASS; echo
read -s -p "Password ROOT: " ROOT_PASS; echo
echo -e "------------------------------------------------------"
echo -e "Ambiente Grafico:"
echo -e "1) XFCE (Completo + Thunar Plugins + GVFS)"
echo -e "2) GNOME (Standard Debian)"
read -p "Scelta (1-2): " DE_CHOICE

# 3. ANALISI HARDWARE (Host Side)
IS_MATEBOOK=false
if cat /sys/class/dmi/id/sys_vendor 2>/dev/null | grep -iq "HUAWEI"; then
    IS_MATEBOOK=true
    echo -e "${V}Rilevato Hardware Huawei Matebook! Applicherò i fix audio ES8336.${RESET}"
fi

# 4. GESTIONE DISCHI
echo -e "\n${B}Analisi Dischi:${RESET}"
lsblk -o NAME,SIZE,FSTYPE,LABEL,MODEL | grep -v "loop"
echo "------------------------------------------------------"
read -p "Partizione ROOT (es. sda2): " RAW_ROOT
TARGET_ROOT="/dev/${RAW_ROOT#/dev/}"
read -p "Partizione EFI (es. sda1): " RAW_EFI
TARGET_EFI="/dev/${RAW_EFI#/dev/}"

# 5. PREPARAZIONE E DEBOOTSTRAP
echo -e "${V}Formattazione e installazione base in corso...${RESET}"
umount -l "$TARGET_ROOT" 2>/dev/null || true
mkfs.ext4 -F -L "Debian_Pro" "$TARGET_ROOT"

MOUNT_DIR="/mnt/debian_pro"
mkdir -p "$MOUNT_DIR"
mount "$TARGET_ROOT" "$MOUNT_DIR"
mkdir -p "$MOUNT_DIR/boot/efi"
mount "$TARGET_EFI" "$MOUNT_DIR/boot/efi"

# Installazione dipendenze e KEYRING sull'host per evitare Warning GPG
if command -v pacman &> /dev/null; then
    pacman -Sy --noconfirm debootstrap arch-install-scripts debian-archive-keyring
elif command -v apt &> /dev/null; then
    apt update && apt install -y debootstrap arch-install-scripts debian-archive-keyring
fi

debootstrap --arch amd64 bookworm "$MOUNT_DIR" http://deb.debian.org/debian/

# 6. SCRIPT INTERNO (Configurazione Sistema e Driver)
cat <<EOF > "$MOUNT_DIR/setup.sh"
#!/bin/bash
cat > /etc/apt/sources.list <<EOM
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOM

apt update
apt install -y linux-image-amd64 firmware-linux firmware-linux-nonfree \\
               firmware-sof-signed firmware-iwlwifi firmware-realtek \\
               alsa-utils pipewire wireplumber blueman network-manager \\
               grub-efi-amd64 efibootmgr os-prober sudo git curl wget micro

# Logica Driver Audio Matebook
if [ "$IS_MATEBOOK" = true ]; then
    echo "Configurazione Audio Huawei Matebook..."
    echo "options snd-intel-dspcfg dsp_driver=3" > /etc/modprobe.d/matebook.conf
    echo "options snd-sof-pci tplg_filename=sof-tgl-es8336-ssp0.tplg" >> /etc/modprobe.d/matebook.conf
    
    cat <<EOM > /usr/local/bin/unlock-audio
#!/bin/bash
amixer -c 0 sset 'Master' 100% unmute 2>/dev/null
amixer -c 0 sset 'Speaker' 100% unmute 2>/dev/null
amixer -c 0 sset 'Headphone' 100% unmute 2>/dev/null
EOM
    chmod +x /usr/local/bin/unlock-audio
fi

# Rilevamento Video
lspci | grep -iq nvidia && apt install -y nvidia-driver-detect nvidia-kernel-dkms

# Desktop Environment
if [ "$DE_CHOICE" == "1" ]; then
    apt install -y xfce4 xfce4-goodies lightdm gvfs gvfs-backends thunar-archive-plugin thunar-volman
else
    apt install -y gnome-core gdm3
fi

# Creazione Utente e Gruppi
useradd -m -G sudo,audio,video,bluetooth,lp,scanner -s /bin/bash $NEW_USER
echo "$NEW_USER:$USER_PASS" | chpasswd
echo "root:$ROOT_PASS" | chpasswd

# Forza il salvataggio degli utenti sul disco
sync

# Configurazione GRUB
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable --recheck
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable bluetooth 2>/dev/null || true
exit
EOF

# 7. ESECUZIONE CHROOT (Sincronizzazione corretta dei volumi)
chmod +x "$MOUNT_DIR/setup.sh"
for d in dev dev/pts proc sys run; do 
    mkdir -p "$MOUNT_DIR/$d"
    mount --bind "/$d" "$MOUNT_DIR/$d" 
done
chroot "$MOUNT_DIR" /bin/bash -c "export IS_MATEBOOK=$IS_MATEBOOK; /setup.sh"

# 8. INTEGRAZIONE DOTFILES
clear
echo -e "${B}${G}--- SISTEMA BASE PRONTO ---${RESET}"
read -p "Vuoi integrare i tuoi dotfiles (github.com/ilnanny75/dotfiles) adesso? (s/n): " DOT_ANS
if [[ "$DOT_ANS" =~ ^[Ss]$ ]]; then
    echo -e "${V}Clonazione dotfiles per l'utente $NEW_USER...${RESET}"
    # Clonazione come root e cambio proprietario per evitare errori "unknown user"
    chroot "$MOUNT_DIR" /bin/bash -c "cd /home/$NEW_USER && git clone https://github.com/ilnanny75/dotfiles dotfiles && chown -R $NEW_USER:$NEW_USER dotfiles"
    if [ -f "$MOUNT_DIR/home/$NEW_USER/dotfiles/install.sh" ]; then
        chroot "$MOUNT_DIR" /bin/bash -c "cd /home/$NEW_USER/dotfiles && chmod +x install.sh && sudo -u $NEW_USER ./install.sh"
    fi
fi

# 9. PULIZIA E SMONTAGGIO
echo -e "${V}Generazione FSTAB e smontaggio...${RESET}"
if command -v genfstab &> /dev/null; then
    genfstab -U "$MOUNT_DIR" >> "$MOUNT_DIR/etc/fstab"
fi
rm "$MOUNT_DIR/setup.sh"
umount -R "$MOUNT_DIR"

# 10. FINE
echo -e "\n${B}${V}INSTALLAZIONE COMPLETATA CON SUCCESSO!${RESET}"
read -p "Vuoi riavviare il PC ora? (s/n): " REBOOT_NOW
if [[ "$REBOOT_NOW" =~ ^[Ss]$ ]]; then
    reboot
else
    echo -e "${G}Uscita.${RESET}"
fi
