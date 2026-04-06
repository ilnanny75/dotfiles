# 🛠 CHROOT UNIVERSALE (Debian, Void, Arch)

Se il sistema non parte, identifica la partizione ROOT con `lsblk`.

## 1. Montaggio Base
`mount /dev/sdX2 /mnt`          # La tua ROOT (Sia ext4, xfs o btrfs)
`mount /dev/sdX1 /mnt/boot/efi` # La partizione EFI (Sempre!)

## 2. Bind dei sistemi (Il "Ponte")
# Questo comando funziona su tutte le distro:
for i in /dev /dev/pts /proc /sys /run; do mount -B $i /mnt$i; done

## 3. Entrare nel sistema
# Se sei su Debian/Arch:
`chroot /mnt /bin/bash`

# Se sei su VOID (Importante!):
`XBPS_ARCH=$(uname -m) chroot /mnt /bin/bash`

## 4. Comandi di Ripristino rapidi
- **Debian**: `update-grub` && `grub-install /dev/sdX`
- **Arch**: `grub-mkconfig -o /boot/grub/grub.cfg`
- **Void**: `xbps-reconfigure -f linux6.x` (per rigenerare initramfs)

## 5. Uscita Pulita
`exit`
`umount -R /mnt`

## 🛑 EMERGENZA: SMONTAGGIO FORZATO
Se `umount -R /mnt` fallisce con "Target is busy":

1. **Trova e uccidi i processi attivi sul mount:**
   `sudo fuser -kvm /mnt` 
   *(k=kill, v=verbose, m=mountpoint)*

2. **Smontaggio "Pigro" (Lazy):**
   `sudo umount -l /mnt`
   *(Lo smonta non appena il processo finisce, liberando il terminale)*

3. **Verifica residui:**
   `cat /proc/mounts | grep /mnt`
