#!/bin/bash
#==========================================================
# TOOLBOX ILNANNY 2026 - Modulo Nuove Funzioni
#==========================================================

# --- 🖼️ Manipolazione Immagini ---------------------------
svg2png() {                                                    # Convertitore SVG
    if ! command -v convert &> /dev/null; then
        echo "Errore: ImageMagick non trovato."                # Controllo dipendenza
        return 1
    fi
    convert -background none -size "$2"x"$2" "$1" "${1%.*}-$2.png" # Esegue conversione
}

# --- 🛠️ Alias Automazione Script ------------------------
alias crea-tema='[ -f ~/dotfiles/scripts/bin/crea-tema-icone.sh ] && ~/dotfiles/scripts/bin/crea-tema-icone.sh'                       # Crea Tema
alias mx-pulizia='~/dotfiles/scripts/bin/mx-clean.sh'            # Script pulizia MX
alias crea-link='~/dotfiles/scripts/bin/ilnanny-links.sh'        # Crea Symlinks
alias ottimizza-svg='~/dotfiles/scripts/bin/ilnanny-optimize.sh' # Ottimizza icone

# --- 🌿 Git Avanzato -------------------------------------
# Torna nella cartella precedente solo se il push ha successo
alias pigia='cd ~/dotfiles && git add . && read -p "Commit: " msg && git commit -m "$msg" && git push origin main && cd -'
