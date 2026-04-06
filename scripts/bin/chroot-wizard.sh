#!/usr/bin/env bash
# Wizard Interattivo per Chroot - ilnanny 2026

echo "--- 🛠 WIZARD CHROOT INTERATTIVO ---"

# 1. Scelta Partizione Root
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
echo ""
read -p "Inserisci il device della ROOT (es. sda2): " ROOT_DEV
mount /dev/$ROOT_DEV /mnt

# 2. Controllo EFI
read -p "Hai una partizione EFI separata? (s/n): " HAS_EFI
if [[ $HAS_EFI == "s" ]]; then
    read -p "Inserisci il device EFI (es. sda1): " EFI_DEV
    mkdir -p /mnt/boot/efi
    mount /dev/$EFI_DEV /mnt/boot/efi
fi

# 3. Montaggio Bind automatico
echo "Montaggio dei sistemi virtuali (dev, proc, sys, run)..."
for i in /dev /dev/pts /proc /sys /run; do
    mount -B $i /mnt$i
done

# 4. Copia DNS (fondamentale per scaricare pacchetti in chroot)
cp /etc/resolv.conf /mnt/etc/resolv.conf

# 5. Smontaggio al ritorno con controllo errori
echo "Smontaggio in corso..."
if ! umount -R /mnt 2>/dev/null; then
    echo -e "${R}⚠️ Errore: Il mountpoint è occupato!${RESET}"
    read -p "Vuoi forzare la chiusura dei processi con fuser? (s/n): " FORZA
    if [[ $FORZA == "s" ]]; then
        echo "Esecuzione: fuser -kvm /mnt ..."
        fuser -kvm /mnt
        sleep 1
        umount -R /mnt && echo "✅ Smontaggio forzato riuscito."
    else
        echo "Ok, smontaggio non eseguito. Fallo manualmente con 'umount -l /mnt'."
    fi
else
    echo "✅ Sistema pulito correttamente."
fi
echo "--------------------------------------------------------"
echo "✅ Ambiente pronto! Digita 'exit' per uscire e smontare."
echo "--------------------------------------------------------"

# 5. Entrata in Chroot
chroot /mnt /bin/bash

# 6. Smontaggio al ritorno
echo "Smontaggio in corso..."
umount -R /mnt
echo "Fatto. Sistema pulito."
