
# --- Alias per il Design ---
# Per convertire velocemente un PNG in un'icona (es: ico 48x48)
alias img-info='identify -format "%w x %h %b\n"'
# Pulizia veloce del sistema MX
alias pulisci='sudo apt autoremove && sudo apt autoclean'
# Scorciatoia per tornare al laboratorio icone
alias icone='cd ~/dotfiles/graphics/icons'


# --- Funzione ilnanny Designer ---
# Converte SVG in PNG alla dimensione scelta
# Utilizzo: svg2png file.svg 128 (creerà file-128.png)
svg2png() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Utilizzo: svg2png nomefile.svg dimensione"
        return 1
    fi
    convert -background none -size "$2"x"$2" "$1" "${1%.*}-$2.png"
    echo "Convertito: ${1%.*}-$2.png"
}

