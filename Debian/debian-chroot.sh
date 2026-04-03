#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Nota: DEBIAN MASTER INSTALLER 2026. Script interattivo per la 
# preparazione del sistema: gestione partizioni, installazione base, 
# driver hardware automatici e strumenti web essenziali.
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

# --- COLORI ---
V="\e[32m"; R="\e[31m"; G="\e[33m"; C="\e[36m"; B="\e[1m"; RESET="\e[0m"

[[ $EUID -ne 0 ]] && { echo -e "${R}Lancia lo script come root!${RESET}"; exit 1; }

clear
echo -e "${C}${B}Analisi Dischi (Il disco interno nvme0n1 NON si tocca!)${RESET}"
lsblk -o NAME,SIZE,FSTYPE,MODEL,LABEL | grep -v "loop"
echo "------------------------------------------------------"

# 1. SCELTA TARGET (SSD ESTERNO)
read -p "Inserisci la partizione ROOT dell'SSD ESTERNO (es. /dev/sda3): " TARGET_PART
[[ "$TARGET_PART" == *"nvme"* ]] && { echo -e "${R}ALT! Questo è il disco interno! Esco per sicurezza.${RESET}"; exit 1; }

read -p "Vuoi formattare $TARGET_PART in EXT4? (s/N): " FMT
[[ "$FMT" =~ ^[Ss]$ ]] && mkfs.ext4 -F -L "Debian_Root" "$TARGET_PART"

MOUNT_DIR="/mnt/debian_lab"
mkdir -p "$MOUNT_DIR"
mount "$TARGET_PART" "$MOUNT_DIR"

# 2. EFI (Sempre del SSD Esterno)
read -p "Inserisci la partizione EFI del SSD ESTERNO (es. /dev/sda1): " EFI_PART
mkdir -p "$MOUNT_DIR/boot/efi"
mount "$EFI_PART" "$MOUNT_DIR/boot/efi"

# 3. DEBOOTSTRAP
echo -e "${V}Installazione base in corso...${RESET}"
apt update && apt install -y debootstrap arch-install-scripts
debootstrap --arch amd64 bookworm "$MOUNT_DIR" http://deb.debian.org/debian/

# 4. CONFIGURAZIONE CHROOT (Il "cuore" del sistema)
cat <<EOF > "$MOUNT_DIR/setup.sh"
#!/bin/bash
# Repo con firmware per il Matebook
cat > /etc/apt/sources.list <<EOM
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOM

apt update
# Kernel, Driver Intel/Matebook e OS-PROBER per vedere Arch/Void/MX
apt install -y linux-image-amd64 linux-headers-amd64 firmware-sof-signed \\
               firmware-iwlwifi os-prober grub-efi-amd64 efibootmgr \\
               network-manager sudo git curl gh

# ABILITA OS-PROBER (Fondamentale per vedere gli altri Linux sull'SSD)
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub

# INSTALLA GRUB IN MODALITÀ REMOVIBILE (Non tocca le variabili EFI del PC)
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=DEBIAN_LAB --removable
grub-mkconfig -o /boot/grub/grub.cfg

# UTENTE
useradd -m -G sudo -s /bin/bash ilnanny
echo "ilnanny:ilnanny" | chpasswd
systemctl enable NetworkManager
exit
EOF

# MOUNT & CHROOT
chmod +x "$MOUNT_DIR/setup.sh"
for dir in /dev /dev/pts /proc /sys /run; do mount --bind $dir "$MOUNT_DIR$dir"; done
chroot "$MOUNT_DIR" /bin/bash ./setup.sh

# GENERAZIONE FSTAB (Usa gli UUID per non sbagliare mai mount)
genfstab -U "$MOUNT_DIR" >> "$MOUNT_DIR/etc/fstab"

# CLEANUP
umount -R "$MOUNT_DIR"
echo -e "${V}${B}INSTALLAZIONE COMPLETATA! Moglie salva, Lab operativo.${RESET}"
