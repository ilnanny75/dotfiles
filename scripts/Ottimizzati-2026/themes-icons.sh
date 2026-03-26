#!/bin/bash
#================================================
#   O.S.      : Gnu Linux                       =
#   Author    : Cristian Pozzessere   = ilnanny =
#   Github    : https://github.com/ilnanny75    =
#================================================
#   Progetto  : Installazione temi GTK e icone  =
#================================================

# Colori
RED='\033[0;41;30m'
STD='\033[0;0;39m'
GREEN='\033[1;32;3m'
LCYAN="\e[1;36m"
YELLOW="\e[1;33m"
PURPLE="\e[1;35m"
ATTENZIONE="\e[0;31m"

# Controlla i privilegi di root
if [[ $EUID -ne 0 ]]; then
    echo -e "${ATTENZIONE} Questo script richiede i permessi di root.${STD}"
    exec sudo bash "$0" "$@"
    exit 1
fi

clear
echo -e "${LCYAN}"
echo " ╔══════════════════════════════════════════╗"
echo " ║   INSTALLAZIONE TEMI GTK, ICONE E CURSOR ║"
echo " ╚══════════════════════════════════════════╝"
echo -e "${STD}"

# --- CARTELLA SORGENTE ---
echo -e "${YELLOW} Inserisci la cartella base dove si trovano i tuoi temi e icone.${STD}"
echo -e "${LCYAN} (era: /media/Dati — es. /mnt/Dati, ~/risorse, /home/utente/temi)${STD}"
echo
read -r -p " Cartella base sorgente: " BASE_DIR

# Rimuovi eventuale slash finale
BASE_DIR="${BASE_DIR%/}"

# Verifica che la cartella esista
if [[ ! -d "$BASE_DIR" ]]; then
    echo -e "${RED} Cartella '$BASE_DIR' non trovata!${STD}"
    exit 1
fi

echo
echo -e "${YELLOW} Sottocartella dei temi GTK (relativa alla base).${STD}"
echo -e "${LCYAN} (era: XThemes/GTK-themes — premi Invio per confermare)${STD}"
read -r -p " Sottocartella temi GTK [XThemes/GTK-themes]: " SUBDIR_TEMI
SUBDIR_TEMI="${SUBDIR_TEMI:-XThemes/GTK-themes}"
DIR_TEMI="${BASE_DIR}/${SUBDIR_TEMI}"

echo
echo -e "${YELLOW} Sottocartella delle icone Blender (relativa alla base).${STD}"
echo -e "${LCYAN} (era: Blender-icon-theme — premi Invio per confermare)${STD}"
read -r -p " Sottocartella icone [Blender-icon-theme]: " SUBDIR_ICONE
SUBDIR_ICONE="${SUBDIR_ICONE:-Blender-icon-theme}"
DIR_ICONE="${BASE_DIR}/${SUBDIR_ICONE}"

# Verifica le sottocartelle
errore=0
[[ ! -d "$DIR_TEMI" ]]  && echo -e "${RED} Cartella temi non trovata: $DIR_TEMI${STD}"  && errore=1
[[ ! -d "$DIR_ICONE" ]] && echo -e "${RED} Cartella icone non trovata: $DIR_ICONE${STD}" && errore=1
[[ $errore -eq 1 ]] && exit 1

# Riepilogo
echo
echo -e "${PURPLE} ╔══════════════════════════════════════════╗"
echo -e "${PURPLE} ║            RIEPILOGO                     ║"
echo -e "${PURPLE} ╠══════════════════════════════════════════╣"
printf  "${PURPLE} ║  %-10s: %-29s║\n${STD}" "Temi GTK"  "$DIR_TEMI"
printf  "${PURPLE} ║  %-10s: %-29s║\n${STD}" "Icone"     "$DIR_ICONE"
printf  "${PURPLE} ║  %-10s: %-29s║\n${STD}" "Dest temi" "/usr/share/themes"
printf  "${PURPLE} ║  %-10s: %-29s║\n${STD}" "Dest icone" "/usr/share/icons"
echo -e "${PURPLE} ╚══════════════════════════════════════════╝${STD}"
echo
read -r -p " Confermi l'installazione? [s/N]: " conferma
if [[ ! "$conferma" =~ ^[sS]$ ]]; then
    echo -e "${RED} Operazione annullata.${STD}"; exit 0
fi

# --- INSTALLAZIONE TEMI GTK ---
echo
echo -e "${YELLOW} Installo i temi GTK in /usr/share/themes ...${STD}"

temi_ok=0
temi_err=0
# Lista dei temi da installare
TEMI=(
    Noktomix Celedark Classico Crynge Grigio
    Larry-Dark Larrycow Lila-Gtk Mybrown Newclear
    Nocciola Stonex Teiera
)

for tema in "${TEMI[@]}"; do
    src="${DIR_TEMI}/${tema}"
    if [[ -d "$src" ]]; then
        if cp -a -r "$src" /usr/share/themes/ 2>/dev/null; then
            echo -e "  ${GREEN}✔ ${tema}${STD}"
            (( temi_ok++ ))
        else
            echo -e "  ${RED}✘ Errore: ${tema}${STD}"
            (( temi_err++ ))
        fi
    else
        echo -e "  ${ATTENZIONE}⚠ Non trovato: ${tema}${STD}"
        (( temi_err++ ))
    fi
done

# --- INSTALLAZIONE ICONE ---
echo
echo -e "${YELLOW} Installo le icone in /usr/share/icons ...${STD}"

icone_ok=0
icone_err=0
# Lista dei pack di icone da installare
ICONE=(
    Blender blender-blue blender-cyan blender-dark
    blender-dkblue blender-kaki blender-red Lila_HD-cursor
)

for icona in "${ICONE[@]}"; do
    src="${DIR_ICONE}/${icona}"
    if [[ -d "$src" ]]; then
        if cp -a -r "$src" /usr/share/icons/ 2>/dev/null; then
            echo -e "  ${GREEN}✔ ${icona}${STD}"
            (( icone_ok++ ))
        else
            echo -e "  ${RED}✘ Errore: ${icona}${STD}"
            (( icone_err++ ))
        fi
    else
        echo -e "  ${ATTENZIONE}⚠ Non trovato: ${icona}${STD}"
        (( icone_err++ ))
    fi
done

# --- RIGENERA CACHE ICONE ---
CACHE_SCRIPT="/usr/share/icons/Blender/icon-cache-maker.sh"
if [[ -x "$CACHE_SCRIPT" ]]; then
    echo
    echo -e "${YELLOW} Rigenero la cache delle icone...${STD}"
    bash "$CACHE_SCRIPT" && echo -e "${GREEN} ✔ Cache icone aggiornata.${STD}" \
                         || echo -e "${ATTENZIONE} ⚠ Errore nella rigenerazione della cache.${STD}"
else
    # Tentativo con gtk-update-icon-cache (presente su quasi tutti i sistemi)
    if command -v gtk-update-icon-cache &>/dev/null; then
        echo
        echo -e "${YELLOW} Rigenero la cache icone con gtk-update-icon-cache...${STD}"
        gtk-update-icon-cache -f -t /usr/share/icons/ 2>/dev/null \
            && echo -e "${GREEN} ✔ Cache icone aggiornata.${STD}" \
            || echo -e "${ATTENZIONE} ⚠ Impossibile aggiornare la cache.${STD}"
    fi
fi

# --- RIEPILOGO FINALE ---
echo
echo -e "${PURPLE} ╔══════════════════════════════════════════╗"
echo -e "${PURPLE} ║             RIEPILOGO FINALE             ║"
echo -e "${PURPLE} ╠══════════════════════════════════════════╣"
printf  "${PURPLE} ║  Temi GTK  : %-6s OK  %-6s errori    ║\n${STD}" "$temi_ok"  "$temi_err"
printf  "${PURPLE} ║  Icone     : %-6s OK  %-6s errori    ║\n${STD}" "$icone_ok" "$icone_err"
echo -e "${PURPLE} ╚══════════════════════════════════════════╝${STD}"
echo
echo -e "${GREEN} ✔ Installazione completata. Puoi chiudere il terminale.${STD}"
echo

exit 0
