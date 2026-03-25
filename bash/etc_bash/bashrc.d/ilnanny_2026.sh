#!/bin/bash
#==========================================================
#  TOOLBOX ILNANNY 2026 - Modulo Nuove Funzioni
#==========================================================

# Funzione per convertire SVG in PNG (Migliorata con controllo dipendenze)
svg2png() {
    if ! command -v convert &> /dev/null; then
        echo "Errore: ImageMagick (convert) non è installato."
        return 1
    fi
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Utilizzo: svg2png nomefile.svg dimensione"
        echo "Esempio: svg2png logo.svg 512"
        return 1
    fi
    # -background none mantiene la trasparenza
    convert -background none -size "$2"x"$2" "$1" "${1%.*}-$2.png"
    echo "✅ Fatto! Creato: ${1%.*}-$2.png"
}

# Funzione per mostrare il branch git nel prompt (Veloce e pulita)
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# --- 📂 Alias per il Repository Dotfiles ---
alias dots='cd ~/dotfiles'
alias gbin='cd ~/dotfiles/scripts/bin'

# Pigia migliorato: ora torna nella cartella precedente solo se il push ha successo
alias pigia='cd ~/dotfiles && git add . && read -p "Messaggio Commit: " msg && git commit -m "$msg" && git push origin main && cd -'

# --- 🛠️ Alias per i tuoi nuovi Script ilnanny ---
# Nota: ho aggiunto il controllo se il file esiste prima di lanciarlo per evitare errori "file not found"
alias crea-tema='[ -f ~/dotfiles/scripts/bin/crea-tema-icone.sh ] && ~/dotfiles/scripts/bin/crea-tema-icone.sh'
alias trova-icona='~/dotfiles/scripts/bin/trova-icona.sh'
alias mx-pulizia='~/dotfiles/scripts/bin/mx-clean.sh'
alias crea-link='~/dotfiles/scripts/bin/ilnanny-links.sh'
alias crea-template='~/dotfiles/scripts/bin/ilnanny-templates.sh'
alias ottimizza-svg='~/dotfiles/scripts/bin/ilnanny-optimize.sh'
alias controlla-tema='~/dotfiles/scripts/bin/ilnanny-check.sh'
alias impacchetta='~/dotfiles/scripts/bin/ilnanny-pack.sh'
