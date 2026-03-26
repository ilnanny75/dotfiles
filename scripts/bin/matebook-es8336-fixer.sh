     1	#!/bin/bash
     2	#==========================================================
     3	#  ILNANNY MATEBOOK & SYSTEM MANAGER - 2026
     4	#  Target: Huawei MateBook (Audio ES8336) & System Maintenance
     5	#==========================================================
     6	
     7	# Colori
     8	VERDE='\033[0;32m'
     9	ROSSO='\033[0;31m'
    10	GIALLO='\033[1;33m'
    11	CYAN='\033[0;36m'
    12	NC='\033[0m'
    13	
    14	# Funzione per i privilegi di root
    15	check_root() {
    16	    if [ "$EUID" -ne 0 ]; then
    17	        echo -e "${GIALLO}Richiesti privilegi di root...${NC}"
    18	        exec sudo "$0" "$@"
    19	    fi
    20	}
    21	
    22	# --- 🔊 FIX AUDIO MATEBOOK (ES8336) ---
    23	fix_audio() {
    24	    check_root
    25	    echo -e "${CYAN}--- Configurazione Audio MateBook (ES8336) ---${NC}"
    26	    
    27	    # Rilevamento Distro per firmware
    28	    if [ -f /etc/debian_version ]; then
    29	        INSTALL_CMD="apt install -y"
    30	        PKGS="firmware-sof-signed alsa-ucm-conf"
    31	    elif [ -f /etc/arch-release ]; then
    32	        INSTALL_CMD="pacman -S --noconfirm"
    33	        PKGS="sof-firmware alsa-ucm-conf"
    34	    else
    35	        echo -e "${ROSSO}Distribuzione non supportata automaticamente.${NC}"
    36	        return
    37	    fi
    38	
    39	    echo -e "${GIALLO}Installazione pacchetti necessari...${NC}"
    40	    $INSTALL_CMD $PKGS
    41	
    42	    # Modifica GRUB se non già presente
    43	    if ! grep -q "snd_intel_dspcfg.dsp_driver=1" /etc/default/grub; then
    44	        echo -e "${GIALLO}Aggiunta parametro driver al GRUB...${NC}"
    45	        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="snd_intel_dspcfg.dsp_driver=1 /' /etc/default/grub
    46	        update-grub || grub-mkconfig -o /boot/grub/grub.cfg
    47	    fi
    48	    
    49	    # Caricamento forzato modulo (vecchio script audio)
    50	    if ! lsmod | grep -q snd_hda_intel; then
    51	        modprobe snd_hda_intel
    52	    fi
    53	
    54	    echo -e "${VERDE}Fix Audio completato! Riavvia per applicare le modifiche.${NC}"
    55	}
    56	
    57	# --- 🧹 PULIZIA SISTEMA ---
    58	clean_all() {
    59	    check_root
    60	    echo -e "${CYAN}--- Manutenzione Disco e RAM ---${NC}"
    61	    # Pulizia cache utente
    62	    rm -rf ~/.cache/*
    63	    # Svuota Cestino
    64	    rm -rf ~/.local/share/Trash/files/*
    65	    # Svuota RAM Cache
    66	    sync && echo 3 > /proc/sys/vm/drop_caches
    67	    echo -e "${VERDE}Sistema ottimizzato e RAM svuotata.${NC}"
    68	}
    69	
    70	# --- 💀 KILL WINDOW ---
    71	kill_win() {
    72	    echo -e "${GIALLO}Clicca sulla finestra da terminare (o Esc per annullare)...${NC}"
    73	    xkill || echo "Errore: xorg-xkill non trovato."
    74	}
    75	
    76	# --- 🔍 LISTA DRIVER ---
    77	list_drivers() {
    78	    echo -e "${CYAN}--- Drivers in uso ---${NC}"
    79	    if command -v lshw &> /dev/null; then
    80	        lshw -short | grep -i "driver"
    81	    else
    82	        lsmod
    83	    fi
    84	}
    85	
    86	# --- MENU ---
    87	clear
    88	echo -e "${CYAN}=============================================="
    89	echo -e "      ILNANNY MATEBOOK TOOLKIT 2026          "
    90	echo -e "==============================================${NC}"
    91	echo "1) [HARDWARE] Fix Audio ES8336 (MateBook)"
    92	echo "2) [SISTEMA]  Pulizia Cache e RAM"
    93	echo "3) [UTILITY]  Kill Window (X-Kill)"
    94	echo "4) [INFO]     Elenca Driver in uso"
    95	echo "5) Esci"
    96	echo -e "${CYAN}----------------------------------------------${NC}"
    97	read -p "Scegli un'opzione: " OPT
    98	
    99	case $OPT in
   100	    1) fix_audio ;;
   101	    2) clean_all ;;
   102	    3) kill_win ;;
   103	    4) list_drivers ;;
   104	    5) exit 0 ;;
   105	    *) echo "Scelta non valida." ;;
   106	esac
