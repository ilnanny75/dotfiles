#!/bin/bash
# Installa i temi presenti nel repo nelle cartelle di sistema

[[ $(whoami) == 'root' ]] || exec sudo su -c "$0" root

echo "--- Installazione Temi ilnanny 2026 ---"

# Cerca cartelle GTK e Icone nel percorso del repo
REPO_THEMES="$HOME/dotfiles/themes/gtk"
REPO_ICONS="$HOME/dotfiles/themes/icons"

if [ -d "$REPO_THEMES" ]; then
    cp -rv "$REPO_THEMES"/* /usr/share/themes/
fi

if [ -d "$REPO_ICONS" ]; then
    cp -rv "$REPO_ICONS"/* /usr/share/icons/
    # Aggiorna automaticamente le cache
    for theme in /usr/share/icons/*; do
        if [ -f "$theme/index.theme" ]; then
            gtk-update-icon-cache -f -t "$theme"
        fi
    done
fi

echo "Installazione completata!"
