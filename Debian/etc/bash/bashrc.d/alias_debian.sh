#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Lab Alias Manager. Collezione di scorciatoie per APT, 
# navigazione rapida nelle cartelle del Lab e comandi master 
# per la sincronizzazione GitHub (pigia/up).
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

# --- Gestione Pacchetti (APT) ----------------------------
alias update='sudo apt update && sudo apt upgrade'       # Aggiorna tutto il magazzino Debian 
alias instally='sudo apt install -y'                     # Installa a colpo sicuro (senza chiedere conferma) 
alias purge='sudo apt purge && sudo apt autoremove'      # Pulizia totale e profonda 
alias search='apt search'                                # Cerca tra migliaia di pacchetti 
alias show='apt show'                                    # Fammi leggere la carta d'identità del pacchetto 

# NUOVO: Pulizia sistema (Cache, Temp e Cestino)
alias clean='sudo apt clean && sudo apt autoremove -y && rm -rf /tmp/* && rm -rf ~/.local/share/Trash/*'

# --- 📂 Navigazione Lab (I nuovi percorsi 2026) ----------
alias dots='cd ~/dotfiles'                              # Vola nella cartella principale dei dotfiles [cite: 2, 3]
alias gbin='cd ~/dotfiles/scripts/bin'                  # Entra nel cuore degli script [cite: 3]
alias cdd='cd ~/dotfiles/bash/etc_bash/bashrc.d/'       # Vai dove nascono gli alias [cite: 3]
alias docs='cd ~/dotfiles/docs_lab'                     # Leggi i manuali del Lab [cite: 3]

# --- 🚀 Master Commands (I tuoi nuovi muscoli) ----------
# Il manager universale per caricare tutto su GitHub
alias pigia='~/dotfiles/scripts/bin/ilnanny-git-manager.sh' # [cite: 3, 4]
# Sincronizza il laboratorio locale con quello online
alias up='~/dotfiles/scripts/bin/ilnanny-git-manager.sh --pull' # 
# Lancia il re del Lab (il manager del sistema)
alias manager='~/dotfiles/ilnanny-OS-manager.sh' # 

# --- 📔 Utility e Visualizzazione ------------------------
alias memo='cat ~/dotfiles/MEMORANDUM.md'               # Leggi i tuoi appunti al volo 
alias vedi='ls -sh --color=auto -I "*.png" -I "*.jpg" -I "*.pdf"' # Guarda i file senza il "rumore" dei binari 
alias treed='tree -h --du -a -C -I "*.png|*.jpg|*.pdf"'  # Albero delle cartelle pulito e veloce
