#!/bin/bash

# Identificativi della partizione
UUID_DATI="40175288-0055-44da-9612-c080122d04c8"
# Mount point di sistema (standard per dischi interni)
MOUNT_POINT="/mnt/Dati"

echo "--- Configurazione Partizione Dati (Sistema) ---"

# 1. Creazione cartella di mount in /mnt
if [ ! -d "$MOUNT_POINT" ]; then
    echo "[*] Creazione cartella $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
else
    echo "[!] La cartella $MOUNT_POINT esiste già."
fi

# 2. Backup di fstab
echo "[*] Creazione backup di /etc/fstab..."
sudo cp /etc/fstab /etc/fstab.bak

# 3. Controllo se l'UUID è già presente in fstab
if grep -q "$UUID_DATI" /etc/fstab; then
    echo "[!] L'UUID è già presente. Rimuovo la vecchia riga per aggiornarla..."
    sudo sed -i "/$UUID_DATI/d" /etc/fstab
fi

# 4. Scrittura in fstab
# Usiamo 'defaults' che include 'exec', e 'noatime' per le prestazioni.
# Rimosso 'user' per evitare il blocco noexec automatico.
echo "[*] Aggiunta della partizione a /etc/fstab..."
LINEA_FSTAB="UUID=$UUID_DATI  $MOUNT_POINT  ext4  defaults,noatime  0  2"
echo "$LINEA_FSTAB" | sudo tee -a /etc/fstab > /dev/null

# 5. Montaggio
echo "[*] Montaggio della partizione..."
sudo mount -a

# 6. Fix dei permessi
# Dato che è ext4, dobbiamo dire al file system che tu sei il proprietario
echo "[*] Impostazione permessi per l'utente $(whoami)..."
sudo chown -R $(id -u):$(id -g) "$MOUNT_POINT"

echo "--- Configurazione completata! ---"
echo "La partizione è montata in: $MOUNT_POINT"
echo "Puoi creare un collegamento veloce nella tua home con:"
echo "ln -s $MOUNT_POINT ~/Dati"
