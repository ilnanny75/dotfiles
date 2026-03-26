#!/bin/bash
#================================================
#   O.S.      : Gnu Linux                       =
#   Author    : Cristian Pozzessere   = ilnanny =
#   Github    : https://github.com/ilnanny75    =
#================================================

# --- Configurazione Colori ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

clear
echo -e "${GREEN}=================================================="
echo -e "       GENERATORE ISO INTERATTIVO (BIOS/DATA)     "
echo -e "==================================================${NC}\n"

# 1. Controllo dipendenze
# Verifico se esiste genisoimage o mkisofs
if command -v genisoimage &> /dev/null; then
    ISO_CMD="genisoimage"
elif command -v mkisofs &> /dev/null; then
    ISO_CMD="mkisofs"
else
    echo -e "${RED}Errore: 'genisoimage' o 'mkisofs' non installati.${NC}"
    echo "Installa con: sudo apt install genisoimage"
    exit 1
fi

# 2. Scelta della sorgente
echo -e "${YELLOW}Passo 1: Cartella sorgente${NC}"
read -e -p "Trascina qui la cartella da masterizzare (es. ./CD): " SOURCE_DIR

if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Errore: La cartella '$SOURCE_DIR' non esiste.${NC}"
    exit 1
fi

# 3. Nome del file e Etichetta
echo -e "\n${YELLOW}Passo 2: Metadati${NC}"
read -p "Inserisci il nome del file finale (es. backup.iso): " ISONAME
read -p "Inserisci l'etichetta del volume (Nome che appare quando monti l'ISO): " CDLABEL

# Impostazione default se vuoti
ISONAME=${ISONAME:-"output_image.iso"}
CDLABEL=${CDLABEL:-"BOOTCD"}

# 4. Opzione Boot (Opzionale)
echo -e "\n${YELLOW}Passo 3: Opzioni di Boot${NC}"
read -p "Vuoi rendere l'ISO avviabile? (s/N): " is_bootable

BOOT_OPTS=""
if [[ "$is_bootable" =~ ^[Ss]$ ]]; then
    read -e -p "Inserisci il percorso del file di boot (es. boot.img): " BOOT_IMG
    if [ -f "$SOURCE_DIR/$BOOT_IMG" ]; then
        # Parametri standard per boot BIOS
        BOOT_OPTS="-no-emul-boot -boot-info-table -boot-load-size 4 -b $BOOT_IMG"
        echo -e "${GREEN}Configurazione boot aggiunta.${NC}"
    else
        echo -e "${RED}Attenzione: File $BOOT_IMG non trovato in $SOURCE_DIR. Procedo senza boot.${NC}"
    fi
fi

# 5. Esecuzione
echo -e "\n${GREEN}Generazione in corso...${NC}"

# Spiegazione flag:
# -o : file di output
# -v : verbose (mostra progresso)
# -J : Joliet (estensione per Windows)
# -R : Rock Ridge (estensione per permessi Linux)
# -D : Non usare il deep directory relocation
# -A : ID Applicazione
# -V : Etichetta Volume

$ISO_CMD -o "$ISONAME" \
    -v -J -R -D \
    -A "Creato da ilnanny" \
    -V "$CDLABEL" \
    $BOOT_OPTS \
    "$SOURCE_DIR"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}Fatto! Il file '$ISONAME' è pronto.${NC}"
else
    echo -e "\n${RED}Si è verificato un errore durante la creazione.${NC}"
fi

exit 0
