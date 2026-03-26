     1	#!/bin/bash
     2	#==========================================================
     3	#  ILNANNY HARDWARE MANAGER - 2026
     4	#  Monitor, Network, Sound & Recording
     5	#==========================================================
     6	
     7	VERDE='\033[0;32m'
     8	GIALLO='\033[1;33m'
     9	CYAN='\033[0;36m'
    10	NC='\033[0m'
    11	
    12	# --- 🖥️ DISPLAY (Ex Schermo) ---
    13	manage_display() {
    14	    echo -e "1) Solo Laptop  2) Solo Esterno (HDMI)  3) Duplica"
    15	    read -p "Opzione: " DSP
    16	    case $DSP in
    17	        1) xrandr --output eDP-1 --auto --output HDMI-1 --off ;;
    18	        2) xrandr --output eDP-1 --off --output HDMI-1 --auto ;;
    19	        3) xrandr --output eDP-1 --auto --output HDMI-1 --auto --same-as eDP-1 ;;
    20	    esac
    21	}
    22	
    23	# --- 🎥 SCREENCAST (Ex Screencast) ---
    24	manage_record() {
    25	    FILE="scast_$(date +%Y%m%d_%H%M%S).mp4"
    26	    echo -e "${GIALLO}Registrazione avviata... Premi 'q' nel terminale per fermare.${NC}"
    27	    ffmpeg -f x11grab -video_size 1920x1080 -i :0.0 -c:v libx264 -preset ultrafast "$HOME/Video/$FILE"
    28	}
    29	
    30	# --- 🔊 AUDIO TEST (Ex Speaker-test & Volume) ---
    31	manage_audio() {
    32	    echo -e "1) Test Speaker (L/R)  2) Reset Alsa/Pulse"
    33	    read -p "Opzione: " AUD
    34	    case $AUD in
    35	        1) speaker-test -t wav -c 2 ;;
    36	        2) pulseaudio -k && alsa force-reload ;;
    37	    esac
    38	}
    39	
    40	# --- 🌐 NETWORK (Ex wlan0) ---
    41	manage_net() {
    42	    echo -e "${CYAN}--- Stato Interfacce ---${NC}"
    43	    ip -brief link
    44	    echo -e "\n${GIALLO}Riavvio Wi-Fi...${NC}"
    45	    nmcli networking off && nmcli networking on
    46	}
    47	
    48	# --- MENU ---
    49	clear
    50	echo -e "${CYAN}=============================================="
    51	echo -e "      ILNANNY HARDWARE CENTER 2026           "
    52	echo -e "==============================================${NC}"
    53	echo "1) [DISPLAY] Gestione Monitor (xrandr)"
    54	echo "2) [RECORD]  Registra Schermo (ffmpeg)"
    55	echo "3) [AUDIO]   Test & Reset Audio"
    56	echo "4) [WIFI]    Stato & Reset Rete"
    57	echo "5) Esci"
    58	read -p "Scegli un'opzione: " OPT
    59	
    60	case $OPT in
    61	    1) manage_display ;;
    62	    2) manage_record ;;
    63	    3) manage_audio ;;
    64	    4) manage_net ;;
    65	    5) exit 0 ;;
    66	esac
