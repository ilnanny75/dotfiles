#==========================================================
#  O.S.      : Gnu Linux (MX 2026)
#  Author    : Cristian Pozzessere (ilnanny)
#  File      : Master Bash Config - ILNANNY DOTFILES 2026
#==========================================================

# 1. Controllo Shell Interattiva
case $- in
    *i*) ;;
    *) return;;
esac

# 2. Caricamento Profili di Sistema
for SH in /etc/profile.d/*.sh; do
    [ -r "$SH" ] && . "$SH"
done

# 3. IL CUORE DEI DOTFILES
MY_BASH_DIR="$HOME/dotfiles/bash/etc_bash/bashrc.d"
if [ -d "$MY_BASH_DIR" ]; then
    for file in "$MY_BASH_DIR"/*; do
        [ -r "$file" ] && . "$file"
    done
fi

# 4. PATH e Editor
export PATH="$HOME/dotfiles/scripts/bin:$HOME/bin:$PATH"
export EDITOR='geany'
export VISUAL='geany'

# Alias Universale (Sostituisce quello vecchio nei moduli)
alias pigia='read -p "Messaggio Commit: " msg && git add . && git commit -m "$msg" && git push origin main'
