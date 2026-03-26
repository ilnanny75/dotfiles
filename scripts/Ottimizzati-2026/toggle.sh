#!/usr/bin/env bash
#================================================
#   O.S.      : Gnu Linux                       =
#   Author    : Cristian Pozzessere   = ilnanny =
#   Github    : https://github.com/ilnanny75    =
#================================================
#   Progetto  : Toggle servizi (polybar,        =
#               compton, redshift, caffeine)     =
#================================================

NOME=$(basename "$0")
VER="1.0"

# Colori
STD='\033[0m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LCYAN='\033[1;36m'
RED='\033[0;31m'

uso() {
    cat <<- EOF

 ${LCYAN}USO:${STD}  $NOME [OPZIONE [AGGIUNTIVA]]

 ${YELLOW}OPZIONI:${STD}

     -h, --help         Mostra questo messaggio
     -v, --version      Mostra la versione dello script
     -p, --polybar      Attiva/disattiva la sessione polybar configurata
     -c, --compton      Attiva/disattiva compton (o icona di monitoraggio)
     -r, --redshift     Attiva/disattiva redshift (o icona di monitoraggio)
     -f, --caffeine     Attiva/disattiva caffeine (o icona di monitoraggio)

 ${YELLOW}AGGIUNTIVA:${STD}

     -t, --toggle       Commuta il programma on/off (senza questo flag
                        viene avviato un processo di monitoraggio)

EOF
}

# Controlla se un processo è in esecuzione (usa pgrep, più portabile di pidof)
is_running() {
    pgrep -x "$1" > /dev/null 2>&1
}

toggle_polybar() {
    if is_running polybar; then
        echo -e "${YELLOW} Fermo polybar...${STD}"
        pkill polybar
        echo -e "${RED} ● polybar fermato${STD}"
    else
        echo -e "${YELLOW} Avvio polybar...${STD}"
        al-polybar-session
        echo -e "${GREEN} ● polybar avviato${STD}"
    fi
}

toggle_compton() {
    # Modalità toggle diretta (con -t)
    if (( opt == 1 )); then
        if is_running compton; then
            echo -e "${YELLOW} Fermo compton...${STD}"
            al-compositor --stop
            echo -e "${RED} ● compton fermato${STD}"
        else
            echo -e "${YELLOW} Avvio compton...${STD}"
            al-compositor --start
            echo -e "${GREEN} ● compton avviato${STD}"
        fi
        exit 0
    fi
    # Modalità monitoraggio (output per polybar/lemonbar)
    icona_on=""
    icona_off=""
    while true; do
        if is_running compton; then
            echo "$icona_on"
        else
            echo "%{F#888888}${icona_off}"
        fi
        sleep 2
    done
}

toggle_redshift() {
    # Modalità toggle diretta (con -t)
    if (( opt == 1 )); then
        if is_running redshift; then
            echo -e "${YELLOW} Fermo redshift...${STD}"
            pkill redshift
            echo -e "${RED} ● redshift fermato${STD}"
        else
            echo -e "${YELLOW} Avvio redshift...${STD}"
            redshift &
            echo -e "${GREEN} ● redshift avviato${STD}"
        fi
        exit 0
    fi
    # Modalità monitoraggio (output colorato per barre di stato)
    icona=""
    while true; do
        if is_running redshift; then
            # Leggi la temperatura corrente di redshift
            temp=$(redshift -p 2>/dev/null | grep -o '[0-9]\+K' | tr -d 'K')
        else
            temp=""
        fi

        if [[ -z "$temp" ]]; then
            echo " $icona "                  # Grigio (non in esecuzione)
        elif [[ $temp -ge 5000 ]]; then
            echo "%{F#8039A0} $icona "       # Blu   (luce fredda)
        elif [[ $temp -ge 4000 ]]; then
            echo "%{F#F2B300} $icona "       # Giallo (luce neutra)
        else
            echo "%{F#FF5B6C} $icona "       # Arancio (luce calda)
        fi
        sleep 2
    done
}

toggle_caffeine() {
    # Modalità toggle diretta (con -t)
    if (( opt == 1 )); then
        if is_running caffeine; then
            echo -e "${YELLOW} Fermo caffeine...${STD}"
            killall caffeine
            echo -e "${RED} ● caffeine fermato${STD}"
        else
            echo -e "${YELLOW} Avvio caffeine...${STD}"
            caffeine &
            echo -e "${GREEN} ● caffeine avviato${STD}"
        fi
        exit 0
    fi
    # Modalità monitoraggio
    icona_on=""
    icona_off=""
    while true; do
        if is_running caffeine; then
            echo "%{F#0099FF}${icona_on}"   # Blu = attivo
        else
            echo "%{F#FF4444}${icona_off}"  # Rosso = inattivo
        fi
        sleep 2
    done
}

# Nessun argomento: mostra l'uso
if [[ $# -eq 0 ]]; then
    uso
    exit 0
fi

# Gestione opzioni da riga di comando
opt=0
case $1 in
    -h|--help)
        uso ;;
    -v|--version)
        echo -e "${LCYAN}${NOME} — versione ${VER}${STD}" ;;
    -p|--polybar)
        toggle_polybar ;;
    -c|--compton)
        [[ "${2-}" =~ ^(-t|--toggle)$ ]] && opt=1
        toggle_compton ;;
    -r|--redshift)
        [[ "${2-}" =~ ^(-t|--toggle)$ ]] && opt=1
        toggle_redshift ;;
    -f|--caffeine)
        [[ "${2-}" =~ ^(-t|--toggle)$ ]] && opt=1
        toggle_caffeine ;;
    *)
        echo -e "${RED} Opzione non riconosciuta: $1${STD}"
        uso
        exit 1 ;;
esac
