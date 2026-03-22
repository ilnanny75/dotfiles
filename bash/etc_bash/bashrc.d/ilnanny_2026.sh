#!/bin/bash
#==========================================================
#  TOOLBOX ILNANNY 2026 - Modulo Nuove Funzioni
#==========================================================

# Funzione per convertire SVG in PNG (Migliorata)
svg2png() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Utilizzo: svg2png nomefile.svg dimensione"
        return 1
    fi
    convert -background none -size "$2"x"$2" "$1" "${1%.*}-$2.png"
    echo "Fatto! Creato: ${1%.*}-$2.png"
}

# Funzione per mostrare il branch git nel prompt
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# --- Alias per il Repository Dotfiles ---
alias dots='cd ~/dotfiles'
alias gbin='cd ~/dotfiles/scripts/bin'
alias pigia='cd ~/dotfiles && git add . && read -p "Messaggio Commit: " msg && git commit -m "$msg" && git push origin main && cd -'

# --- Alias per i tuoi nuovi Script ilnanny ---
alias crea-tema='~/dotfiles/scripts/bin/crea-tema-icone.sh'
alias trova-icona='~/dotfiles/scripts/bin/trova-icona.sh'
alias mx-pulizia='~/dotfiles/scripts/bin/mx-clean.sh'
alias crea-link='~/dotfiles/scripts/bin/ilnanny-links.sh'
alias crea-template='~/dotfiles/scripts/bin/ilnanny-templates.sh'
alias ottimizza-svg='~/dotfiles/scripts/bin/ilnanny-optimize.sh'
alias controlla-tema='~/dotfiles/scripts/bin/ilnanny-check.sh'
alias impacchetta='~/dotfiles/scripts/bin/ilnanny-pack.sh'
