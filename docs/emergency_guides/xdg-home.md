# Guida configurazione xdg & icone thunar

1. Modifica percorsi (user-dirs.dirs)
File: ~/.config/user-dirs.dirs

Aggiungi in fondo:
XDG_BIN_DIR="$HOME/bin"
XDG_DOTFILES_DIR="$HOME/dotfiles"

2. Assegnazione icone (metadati gio)

gio set ~/bin metadata::custom-icon-name folder-script
gio set ~/dotfiles metadata::custom-icon-name folder-git

3. Refresh sistema e thunar

sudo gtk-update-icon-cache /usr/share/icons/Lila_HD_Blue/
thunar -q

4. Barra laterale thunar
Trascina le cartelle bin e dotfiles nella colonna sinistra di Thunar 
