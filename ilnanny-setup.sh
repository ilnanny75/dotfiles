#!/bin/bash
#==========================================================
# ILNANNY DOTFILES INSTALLER - 2026
#==========================================================

yellow='\e[01;33m'
blue='\e[01;34m'
nc='\e[0m'

clear
echo -e "${blue}====================================================${nc}"
echo -e "${yellow}      ILNANNY LAB - INSTALLATORE AUTOMATICO        ${nc}"
echo -e "${blue}====================================================${nc}"

# 1. Controllo Dipendenze
echo -e "\n${blue}[1/3] Controllo software necessario...${nc}"
for pkg in inkscape imagemagick scour git curl geany; do
    if ! command -v $pkg &> /dev/null; then
        echo -e "  [!] Manca $pkg. Installazione in corso..."
        sudo apt update && sudo apt install $pkg -y
    else
        echo -e "  [✔] $pkg è già presente."
    fi
done

# 2. Backup e Link Bashrc
echo -e "\n${blue}[2/3] Configurazione Bash di sistema...${nc}"
if [ -L ~/.bashrc ]; then
    echo "  [i] .bashrc è già un link simbolico. Salto."
else
    echo "  [!] Backup di .bashrc in .bashrc.bk"
    mv ~/.bashrc ~/.bashrc.bk
    ln -s /etc/bash/bashrc ~/.bashrc
    echo "  [✔] Collegato .bashrc a /etc/bash/bashrc"
fi

# 3. Configurazione Editor (Nano e Vim)
echo -e "\n${blue}[3/3] Configurazione Editor...${nc}"
cp ~/dotfiles/editors/.nanorc ~/
cp ~/dotfiles/editors/.vimrc ~/
echo "  [✔] Nano e Vim configurati."

echo -e "\n${yellow}====================================================${nc}"
echo -e "${yellow}      INSTALLAZIONE COMPLETATA CON SUCCESSO!        ${nc}"
echo -e "${blue}      Ora chiudi e riapri il terminale.             ${nc}"
echo -e "${blue}====================================================${nc}"
