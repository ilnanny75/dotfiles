#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Setup interattivo della partizione Dati (sda5).
# Allineato con la configurazione fstab per Void, Arch e Debian.
# ═══════════════════════════════════════════════════════════════════

# --- CONFIGURAZIONE ---
UUID_DATI="40175288-0055-44da-9612-c080122d04c8"
MOUNT_POINT="/media/ilnanny/dati-linux"

clear
echo "===================================================="
echo "   CONFIGURAZIONE SINCRONIZZATA PARTIZIONE DATI"
echo "===================================================="

# 1. Verifica se il disco è connesso
echo "[*] Verifica presenza disco con UUID: $UUID_DATI..."
if ! lsblk -no UUID | grep -q "$UUID_DATI"; then
    echo " [!] ERRORE: Disco non trovato!"
    echo "     L'UUID $UUID_DATI non risulta collegato."
   exit 1
fi
echo " [OK] Disco trovato correttamente."

# 2. Gestione Punto di Mount
if [ ! -d "$MOUNT_POINT" ]; then
    echo "[*] Il punto di mount $MOUNT_POINT non esiste. Lo creo?"
    read -p "    Procedere? (s/n): " confirm
    if [[ $confirm == [sS] ]]; then
        sudo mkdir -p "$MOUNT_POINT"
        echo " [OK] Cartella creata."
    else
        echo " [!] Operazione annullata."
        exit 1
    fi
fi

# 3. Backup di fstab
echo "[*] Creazione backup di /etc/fstab..."
sudo cp /etc/fstab /etc/fstab.bak

# 4. Scrittura in fstab (Pulizia e Nuova riga con NOFAIL)
echo "[*] Aggiornamento /etc/fstab..."
# Rimuove vecchie righe dello script o dell'UUID per evitare conflitti
sudo sed -i "\| $MOUNT_POINT |d" /etc/fstab
sudo sed -i "/$UUID_DATI/d" /etc/fstab

# RIGA DEFINITIVA: Aggiunto 'nofail' per sicurezza al boot
LINEA_FSTAB="UUID=$UUID_DATI  $MOUNT_POINT  ext4  noatime,rw,nofail,x-gvfs-show  0  2"

echo "$LINEA_FSTAB" | sudo tee -a /etc/fstab > /dev/null
echo " [OK] Configurazione fstab aggiornata."

# 5. Ricaricamento Systemd (se presente) e Montaggio
if command -v systemctl >/dev/null; then
    sudo systemctl daemon-reload
fi

echo "[*] Tentativo di montaggio..."
sudo umount "$MOUNT_POINT" 2>/dev/null
if sudo mount -a; then
    echo " [OK] Partizione montata con successo in $MOUNT_POINT"
else
    echo " [!] Errore nel montaggio. Controlla /etc/fstab."
    exit 1
fi

# 6. Fix Permessi Ricorsivo
echo "[*] Vuoi impostare $USER come proprietario di $MOUNT_POINT?"
read -p "    Procedere? (s/n): " confirm_perm
if [[ $confirm_perm == [sS] ]]; then
    sudo chown -R $(id -u):$(id -g) "$MOUNT_POINT"
    echo " [OK] Permessi impostati."
fi

echo "===================================================="
echo "   SISTEMA ALLINEATO E SICURO!"
echo "===================================================="
