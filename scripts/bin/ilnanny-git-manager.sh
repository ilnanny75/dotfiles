     1	#!/bin/bash
     2	#==========================================================
     3	#  ILNANNY GIT MANAGER - 2026
     4	#  Sincronizzazione, Configurazione e Manutenzione Repo
     5	#==========================================================
     6	
     7	VERDE='\033[0;32m'
     8	GIALLO='\033[1;33m'
     9	CYAN='\033[0;36m'
    10	NC='\033[0m'
    11	
    12	# --- 🆔 CONFIGURAZIONE IDENTITÀ ---
    13	git_setup() {
    14	    echo -e "${CYAN}--- Configurazione Identità Git ---${NC}"
    15	    read -p "Inserisci Nome Utente (es. ilnanny75): " USR
    16	    read -p "Inserisci Email (es. ilnannyhack@gmail.com): " MAIL
    17	    
    18	    git config --global user.name "$USR"
    19	    git config --global user.email "$MAIL"
    20	    git config --global core.editor "geany"
    21	    git config --global init.defaultBranch main
    22	    
    23	    echo -e "${VERDE}Configurazione salvata per $USR ($MAIL)${NC}"
    24	}
    25	
    26	# --- 🚀 PUSH INTERATTIVO (Upload) ---
    27	git_upload() {
    28	    echo -e "${CYAN}--- Preparazione Upload su GitHub ---${NC}"
    29	    
    30	    # 1. Pull preventivo per evitare conflitti
    31	    echo -e "${GIALLO}Sincronizzazione con il server...${NC}"
    32	    git pull origin main --rebase
    33	
    34	    # 2. Pulizia file temporanei
    35	    echo -e "${GIALLO}Pulizia refusi (Geany/Inkscape)...${NC}"
    36	    find . -name "*~" -delete -o -name "*.swp" -delete
    37	
    38	    # 3. Add e Commit
    39	    git add .
    40	    echo -e "${CYAN}Stato attuale:${NC}"
    41	    git status -s
    42	    
    43	    read -p "Messaggio del commit (Enter per default): " MSG
    44	    MSG=${MSG:-"Update $(date +'%d-%m-%Y %H:%M')"}
    45	    
    46	    git commit -m "$MSG"
    47	    
    48	    # 4. Push
    49	    echo -e "${VERDE}Invio dati a GitHub...${NC}"
    50	    git push origin main
    51	}
    52	
    53	# --- 🔍 STATUS & INFO ---
    54	git_info() {
    55	    echo -e "${CYAN}--- Info Repository ---${NC}"
    56	    echo -e "${GIALLO}Utente attivo:${NC} $(git config user.name) ($(git config user.email))"
    57	    echo -e "${GIALLO}Remote URL:${NC} $(git remote -v | head -n 1)"
    58	    echo -e "${GIALLO}Stato file:${NC}"
    59	    git status
    60	}
    61	
    62	# --- MENU ---
    63	clear
    64	echo -e "${CYAN}=============================================="
    65	echo -e "      ILNANNY GIT MANAGER 2026               "
    66	echo -e "==============================================${NC}"
    67	echo "1) [SETUP]  Imposta Nome ed Email (Global)"
    68	echo "2) [UPLOAD] Pulisci, Sincronizza e Fai Push"
    69	echo "3) [STATUS] Controlla stato e identità attuale"
    70	echo "4) Esci"
    71	echo -e "${CYAN}----------------------------------------------${NC}"
    72	read -p "Scegli un'opzione: " OPT
    73	
    74	case $OPT in
    75	    1) git_setup ;;
    76	    2) git_upload ;;
    77	    3) git_info ;;
    78	    4) exit 0 ;;
    79	    *) echo "Scelta non valida." ;;
    80	esac
