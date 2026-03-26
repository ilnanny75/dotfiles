     1	#!/bin/bash
     2	#==========================================================
     3	#  ILNANNY ADMIN & DEV TOOL - 2026
     4	#  Gestione Avanzata: Boot, Dev, Multimedia & Utils
     5	#==========================================================
     6	
     7	VERDE='\033[0;32m'
     8	GIALLO='\033[1;33m'
     9	CYAN='\033[0;36m'
    10	NC='\033[0m'
    11	
    12	check_root() {
    13	    if [ "$EUID" -ne 0 ]; then
    14	        echo -e "${GIALLO}Richiesti privilegi di root...${NC}"
    15	        exec sudo "$0" "$@"
    16	    fi
    17	}
    18	
    19	# --- 🖥️ GESTIONE BOOT (Ex Grub-Master) ---
    20	manage_boot() {
    21	    check_root
    22	    echo -e "${CYAN}--- Ripristino/Aggiornamento GRUB ---${NC}"
    23	    update-grub || grub-mkconfig -o /boot/grub/grub.cfg
    24	    echo -e "${VERDE}Configurazione GRUB rigenerata.${NC}"
    25	}
    26	
    27	# --- 🛠️ DEVELOPMENT (Ex Compile & GTK-Version) ---
    28	manage_dev() {
    29	    echo -e "1) Controlla Versioni GTK  2) Compila sorgente locale"
    30	    read -p "Scelta: " DEV_OPT
    31	    case $DEV_OPT in
    32	        1)
    33	            for v in 2 3 4; do
    34	                if pkg-config --exists "gtk+-$v.0" 2>/dev/null; then
    35	                    echo -e "${VERDE}GTK $v:${NC} $(pkg-config --modversion "gtk+-$v.0")"
    36	                fi
    37	            done
    38	            ;;
    39	        2)
    40	            read -p "Inserisci nome file (senza estensione): " FILE
    41	            gcc -Wall "$FILE".c -o "$FILE" $(pkg-config --cflags --libs gtk+-3.0)
    42	            ;;
    43	    esac
    44	}
    45	
    46	# --- 🎬 MULTIMEDIA (Ex DVD-Convert) ---
    47	manage_media() {
    48	    echo -e "${CYAN}--- Conversione Video FFmpeg ---${NC}"
    49	    read -p "File sorgente (ISO o MKV): " IN
    50	    read -p "Nome file output: " OUT
    51	    ffmpeg -i "$IN" -c:v libx264 -crf 20 -c:a aac -b:a 192k "$OUT"
    52	}
    53	
    54	# --- 📅 UTILS (Ex Giorno-Corrente) ---
    55	manage_utils() {
    56	    read -p "Inserisci data (AAAA-MM-GG): " DATA
    57	    date -d "$DATA" +"Il giorno era un: %A"
    58	}
    59	
    60	# --- MENU ---
    61	clear
    62	echo -e "${CYAN}=============================================="
    63	echo -e "       ILNANNY ADMIN TOOLBOX 2026            "
    64	echo -e "==============================================${NC}"
    65	echo "1) [BOOT]   Rigenera GRUB"
    66	echo "2) [DEV]    GTK Check & Compile"
    67	echo "3) [MEDIA]  Converti Video (FFmpeg)"
    68	echo "4) [DATE]   Calcola giorno della settimana"
    69	echo "5) [FILE]   Apri Dotfiles in File Manager"
    70	echo "6) Esci"
    71	read -p "Scegli un'opzione: " OPT
    72	
    73	case $OPT in
    74	    1) manage_boot ;;
    75	    2) manage_dev ;;
    76	    3) manage_media ;;
    77	    4) manage_utils ;;
    78	    5) pcmanfm ~/dotfiles/scripts/bin/ & ;;
    79	    6) exit 0 ;;
    80	esac
