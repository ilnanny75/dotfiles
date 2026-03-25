# --- NAVIGAZIONE E STRUTTURA ---
alias ls='ls --group-directories-first --dereference-command-line-symlink-to-dir --color=auto'
alias l='ls -la'
alias ll='ls -lh'
alias vedi='ls -sh --color=auto'
alias treed='tree -h --du -a -C'
alias df='df -hT'
alias free='free -h'
alias lsbk='lsblk -o +fstype,label,uuid,partuuid'

# --- GESTIONE PACCHETTI (APT / GENTOO) ---
alias apt='sudo apt'
alias instally='sudo apt install -y'
alias search='apt search'
alias show='apt show'
alias update='sudo apt update && sudo apt upgrade'
alias dist-upgrade='sudo apt dist-upgrade'
alias purge='sudo apt purge && sudo apt autoremove'
alias ipk='sudo dpkg -i'
alias rpk='sudo dpkg -r'
alias eix='eix -F'
alias emerge='emerge --color=y'

# --- MANUTENZIONE E SISTEMA ---
alias adb='sudo adb'
alias blkid='sudo blkid -c /dev/null -o list'
alias fc='sudo fc-cache -fv'
alias htop='xfce4-terminal -e htop' # Terminale XFCE invece di xterm
alias hw='hwinfo --short'
alias inxi='sudo inxi -xrmFA'
alias upgrub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias upx='xrdb ~/.Xresources'
alias myip='curl -s https://ifconfig.me'
alias meteo='curl wttr.in/Taranto'
alias microcode='grep . /sys/devices/system/cpu/vulnerabilities/*'
alias ps='ps auxf'
alias pgrep='pgrep -l'
alias gruppi='cut -d: -f1 /etc/group'
alias utenti='cut -d: -f1 /etc/passwd'

# --- SICUREZZA E FILE ---
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias ln='ln -v'
alias chgrp='chgrp --preserve-root'
alias chown='chown --preserve-root'
alias ncat='cat -n'

# --- EDITOR E PERCORSI ---
alias gy='geany'
alias lp='leafpad'    # Sudo rimosso
alias mp='mousepad'   # Sudo rimosso
alias nn='nano'       # Sudo rimosso
alias bashome='geany ~/.bashrc' # Sudo rimosso
alias fstab='sudo geany /etc/fstab' # Qui sudo serve (file di sistema)
alias sourcelist='sudo geany /etc/apt/sources.list'
alias dots='cd ~/dotfiles'
alias gbin='cd ~/dotfiles/scripts/bin'

# --- MULTIMEDIA E CONVERSIONI ---
alias 300dpi='for i in *; do inkscape -d=300 -C --export-filename="${i%.*}.png" "$i"; done'
alias eps2svg='for i in *.eps; do inkscape "$i" --export-plain-svg="${i%.eps}.svg"; done'
alias fixpng='find . -type f -name "*.png" -exec convert {} -strip {} \;'
alias 7zip='7za a -t7z -mx=9 -mfb=256 -md=256m -ms=on'
alias youtube-mp3='yt-dlp -x --audio-format mp3 --audio-quality 0'
alias youtube-video='yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"'

# --- GIT E AUTOMAZIONE ---
alias gc='git clone'
alias pigia='read -p "Messaggio Commit: " msg && git add . && git commit -m "$msg" && git push origin main'
alias gitup='sh ~/bin/gitup'

# --- SCORCIATOIE FILE MANAGER (THUNAR) ---
alias goapp='sudo thunar /usr/share/applications/'
alias gobash='sudo thunar /etc/bash'
alias godotfiles='thunar ~/dotfiles/' # Puntato correttamente alla home
alias goicon='sudo thunar /usr/share/icons/'
alias gotheme='sudo thunar /usr/share/themes/'
alias gowall='sudo thunar /usr/share/backgrounds/'

# --- SPEGNIMENTO E RIAVVIO ---
alias reboot='sudo reboot'
alias riavvia='sudo reboot'
alias spegni='sudo shutdown -h now'
