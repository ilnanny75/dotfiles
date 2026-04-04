# ═══════════════════════════════════════════════════════════════════
#Nota : Alias per git
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════
# Funzione per clonare ed entrare automaticamente nella cartella
gclone_cd() {
    # Clona il repository
    git clone "$1"
    
    # Se il clone ha avuto successo (exit code 0)
    if [ $? -eq 0 ]; then
        # Estrai il nome della cartella dall'URL (rimuovendo il path e l'estensione .git)
        local dir_name=$(basename "$1" .git)
        cd "$dir_name"
    fi
}

# Definisce l'alias gc
alias gc='gclone_cd'
