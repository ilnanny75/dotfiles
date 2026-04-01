#!/bin/bash

# Identificativi della partizione
UUID_DATI="40175288-0055-44da-9612-c080122d04c8"
MOUNT_POINT="$HOME/Dati"

echo "--- Configurazione Partizione Dati Condivisa ---"

# 1. Creazione cartella di mount
if [ ! -d "$MOUNT_POINT" ]; then
    echo "[*] Creazione cartella $MOUNT_POINT..."
    mkdir -p "$MOUNT_POINT"
else
    echo "[!] La cartella $MOUNT_POINT esiste già."
fi

# 2. Backup di fstab
echo "[*] Creazione backup di /etc/fstab in /etc/fstab.bak"
sudo cp /etc/fstab /etc/fstab.bak

# 3. Controllo se l'UUID è già presente in fstab
if grep -q "$UUID_DATI" /etc/fstab; then
    echo "[!] Errore: L'UUID $UUID_DATI è già presente in /etc/fstab. Operazione annullata."
else
    # 4. Scrittura in fstab
    echo "[*] Aggiunta della partizione a /etc/fstab..."
    LINEA_FSTAB="UUID=$UUID_DATI  $MOUNT_POINT  ext4  defaults,noatime,user  0  2"
    echo "$LINEA_FSTAB" | sudo tee -a /etc/fstab > /dev/null
    
    echo "[*] Montaggio della partizione..."
    sudo mount -a
    
    # 5. Fix dei permessi (UID 1000 è lo standard per il primo utente)
    echo "[*] Impostazione permessi per l'utente corrente..."
    sudo chown -R $(id -u):$(id -g) "$MOUNT_POINT"
    
    echo "--- Configurazione completata con successo! ---"
    echo "La partizione è ora montata in: $MOUNT_POINT"
fi
