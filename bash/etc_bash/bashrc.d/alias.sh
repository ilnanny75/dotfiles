#!/bin/bash
#==========================================================
# ILNANNY ALIAS UNIFICATI - Lab 2026 (Anti-Lag Version)
#==========================================================

# --- 📂 Navigazione e Struttura --------------------------
alias blkid='lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL'
alias ls='ls --group-directories-first --color=auto'               # Directory per prime
alias l='ls -la'                                                   # Lista completa
alias ll='ls -lh'                                                  # Pesi file leggibili
alias vedi='ls -sh --color=auto -I "*.png" -I "*.jpg" -I "*.pdf"'  # Esclude binari che pesano
alias treed='tree -h --du -a -C -I "*.png|*.jpg|*.pdf|*.svg|.git"' # Albero pulito senza lag
alias ds='dust'                                                    # Analisi spazio con Dust
alias ds8='dust -d 1'                                              # Dust limitato al primo livello

# --- 🚀 Lab 2026 e Percorsi ------------------------------
alias dots='cd ~/dotfiles'                               # Cartella Repo
alias gbin='cd ~/dotfiles/scripts/bin'                   # Cartella Bin
alias cdd='cd ~/dotfiles/bash/etc_bash/bashrc.d/'        # Moduli Shell
alias lscripts='ls ~/dotfiles/scripts/bin/'              # Legge tutti gli scripts 

# --- 🛠️ Git & GitHub (I tuoi nuovi muscoli) --------------
# Il tuo comando storico aggiornato al nuovo manager
alias pigia='~/dotfiles/scripts/bin/ilnanny-git-manager.sh'

# 🔴 IL TUO NUOVO STRUMENTO (Salvataggio Cache e Fix)
alias multigit='bash ~/dotfiles/scripts/bin/git-multitool.sh'  # Multitools Github
alias up='git pull'                                            # Tira giù le modifiche

# --- 📝 Sistema (XFCE4-Terminal) -------------------------
alias gy='geany'                                         # Apri Geany
alias htop='xfce4-terminal -e htop'                      # Htop in Terminale
alias bashome='geany ~/.bashrc'                          # Modifica bashrc
alias fstab='sudo geany /etc/fstab'                      # Edit dischi
alias meteo='curl wttr.in/Taranto'                       # Meteo locale

# --- 🎬 Multimedia e conversioni -------------------------
alias 300dpi='for i in *; do inkscape -d=300 -C --export-filename="${i%.*}.png" "$i"; done'
alias youtube-mp3='yt-dlp -x --audio-format mp3'         # Solo audio da YT

# --- ⚡ Spegnimento --------------------------------------
alias reboot='sudo reboot'                               # Riavvio rapido
alias spegni='sudo shutdown -h now'                      # Spegnimento immediato
