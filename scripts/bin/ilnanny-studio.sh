     1	#!/bin/bash
     2	#==========================================================
     3	#  ILNANNY GRAPHIC STUDIO - 2026
     4	#  The Ultimate Icon & Theme Toolset
     5	#==========================================================
     6	
     7	VERDE='\033[0;32m'
     8	GIALLO='\033[1;33m'
     9	CYAN='\033[0;36m'
    10	ROSSO='\033[0;31m'
    11	NC='\033[0m'
    12	
    13	# --- 🎨 CREAZIONE & TEMPLATE ---
    14	studio_create() {
    15	    read -p "Nome nuovo tema: " NAME
    16	    NAME=${NAME:-"New-Theme"}
    17	    BASE="$HOME/dotfiles/graphics/icons/$NAME"
    18	    mkdir -p "$BASE"/{16x16,22x22,24x24,32x32,48x48,64x64,128x128,scalable}/{apps,places,status,devices}
    19	    echo "Struttura creata in $BASE"
    20	}
    21	
    22	# --- 🛠️ MODIFICA SVG (Colori e Spazi) ---
    23	studio_mod() {
    24	    echo -e "1) Cambia Colore HEX  2) Rimuovi Spazi dai nomi  3) Ottimizza (Scour)"
    25	    read -p "Scelta: " SUB
    26	    case $SUB in
    27	        1)
    28	            read -p "Vecchio HEX (es. 359bfa): " OLD
    29	            read -p "Nuovo HEX: " NEW
    30	            find . -type f -name "*.svg" -exec sed -i "s/#${OLD#\#}/#${NEW#\#}/gI" {} +
    31	            echo "Colori aggiornati."
    32	            ;;
    33	        2)
    34	            find . -type f -name "* *.svg" | while read -r file; do
    35	                mv -v "$file" "${file// /}"
    36	            done
    37	            ;;
    38	        3)
    39	            if command -v scour &> /dev/null; then
    40	                find . -name "*.svg" -exec scour -i {} -o {}.tmp --enable-viewboxing --indent=none --quiet \; -exec mv {}.tmp {} \;
    41	                echo "Ottimizzazione completata."
    42	            else
    43	                echo "Installa 'scour' prima."
    44	            fi
    45	            ;;
    46	    esac
    47	}
    48	
    49	# --- 🔗 SYMLINKER ---
    50	studio_links() {
    51	    echo -e "${GIALLO}Creazione link standard (folder -> inode-directory)...${NC}"
    52	    ln -sf folder.svg inode-directory.svg
    53	    ln -sf folder.svg gnome-fs-directory.svg
    54	    echo "Link creati nella cartella attuale."
    55	}
    56	
    57	# --- 📦 INSTALLATORE & CACHE ---
    58	studio_install() {
    59	    if [ "$EUID" -ne 0 ]; then sudo "$0" install_root; return; fi
    60	}
    61	
    62	install_root() {
    63	    echo "Aggiornamento cache icone in /usr/share/icons..."
    64	    for dir in /usr/share/icons/*; do
    65	        if [ -d "$dir" ] && [ -f "$dir/index.theme" ]; then
    66	            gtk-update-icon-cache -f -q "$dir"
    67	        fi
    68	    done
    69	    echo "Tutte le cache aggiornate."
    70	}
    71	
    72	# --- MENU ---
    73	if [ "$1" == "install_root" ]; then install_root; exit; fi
    74	
    75	clear
    76	echo -e "${CYAN}=============================================="
    77	echo -e "      ILNANNY GRAPHIC STUDIO 2026            "
    78	echo -e "==============================================${NC}"
    79	echo "1) [NEW]    Crea Struttura Nuovo Tema"
    80	echo "2) [EDIT]   Modifica (Colori, Spazi, Ottimizzazione)"
    81	echo "3) [LINK]   Genera Symlinks Standard"
    82	echo "4) [CACHE]  Aggiorna Cache Sistema (Root)"
    83	echo "5) Esci"
    84	echo -e "${CYAN}----------------------------------------------${NC}"
    85	read -p "Scegli un'opzione: " OPT
    86	
    87	case $OPT in
    88	    1) studio_create ;;
    89	    2) studio_mod ;;
    90	    3) studio_links ;;
    91	    4) studio_install ;;
    92	    5) exit 0 ;;
    93	esac
