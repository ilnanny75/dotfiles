#!/usr/bin/env bash
#==========================================================
#   ILNANNY MASTER-SCRIPT 2026 - MODULAR SYMLINKER
#==========================================================

# Colori
CYAN='\033[0;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Rilevamento OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS=$(uname -s)
fi

header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "║      ILNANNY MASTER DEPLOYER - OS: ${YELLOW}${OS^^}${CYAN}        ║"
    echo -e "╚════════════════════════════════════════════════════╝${NC}"
}

deploy_bash() {
    echo -e "\n${YELLOW}>> Configurazione Bash & Alias...${NC}"
    DOT_BASH="$HOME/dotfiles/bash/etc_bash"
    BASH_D="$DOT_BASH/bashrc.d"

    # 1. Link del Master Bashrc
    echo -e "Collego Master Bashrc..."
    ln -sf "$DOT_BASH/bashrc" "$HOME/.bashrc"
    ln -sf "$DOT_BASH/bash_logout" "$HOME/.bash_logout"

    # 2. Gestione Alias Specifici per OS
    # Cancelliamo eventuali vecchi link specifici per non fare caos
    rm -f "$BASH_D/alias_specifico.sh"

    case $OS in
        void)
            # Punta al file alias_void (che creeremo/sposteremo in bashrc.d)
            ln -sf "$HOME/dotfiles/Void/etc/bash/bashrc.d/alias_void" "$BASH_D/alias_specifico.sh"
            echo -e "${GREEN}Linkato: Alias VOID (xbps)${NC}"
            ;;
        debian|mx)
            ln -sf "$BASH_D/alias_debian" "$BASH_D/alias_specifico.sh"
            echo -e "${GREEN}Linkato: Alias DEBIAN (apt)${NC}"
            ;;
        arch)
            # Se hai un file alias_arch in futuro
            ln -sf "$BASH_D/alias_arch" "$BASH_D/alias_specifico.sh"
            echo -e "${GREEN}Linkato: Alias ARCH (pacman)${NC}"
            ;;
    esac

    echo -e "${CYAN}Ricarico la shell...${NC}"
    source "$HOME/.bashrc"
}

fix_bin_links() {
    echo -e "\n${YELLOW}>> Riparazione link in ~/bin...${NC}"
    mkdir -p "$HOME/bin"
    find "$HOME/bin" -xtype l -delete
    # Collega i 5 super script
    for f in "$HOME/dotfiles/scripts/bin/"*.sh; do
        ln -sf "$f" "$HOME/bin/$(basename "$f" .sh)"
    done
    echo -e "${GREEN}Link in ~/bin ripristinati.${NC}"
}

# --- MENU ---
header
echo -e "1) ${CYAN}DEPLOY COMPLETO${NC} (Bash + ~/bin + Config)"
echo -e "q) Esci"
read -p "Scegli: " opt

if [ "$opt" == "1" ]; then
    deploy_bash
    fix_bin_links
    # Aggiungi qui il link a .config (Geany, ecc) se vuoi
    echo -e "\n${GREEN}OPERAZIONE COMPLETATA!${NC}"
fi
