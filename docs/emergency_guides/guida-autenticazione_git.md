# 📔 Lab Documentazione: Configurazione Git Multi-Piattaforma
**Target:** GitHub (HTTPS + CLI + 2FA) & OpenCode.net (SSH)

---

## 1. SSH KEY (OpenCode.net / GitLab)
La chiave SSH permette l'accesso sicuro senza password.

1. Generazione: ssh-keygen -t ed25519 -C "tua_email@esempio.com"
2. Copia pubblica: cat ~/.ssh/id_ed25519.pub
3. Configurazione Web: Incolla su [https://www.opencode.net/-/profile/keys](https://www.opencode.net/-/profile/keys)

---

## 2. GITHUB CLI (2FA)
Gestione GitHub con autenticazione a due fattori.

1. Login: gh auth login --hostname github.com --git-protocol https --web
2. Procedura: Inserisci il codice di 8 cifre nel browser e conferma con l'app 2FA.

---

## 3. CONFIGURAZIONE NUOVO PROGETTO (Double Push)
Eseguire nella cartella del progetto per collegare entrambi i server.

export REPO="NOME_TUO_PROGETTO"
export USER="TUO_USERNAME"

git remote set-url origin [https://github.com/$USER/$REPO.git](https://github.com/$USER/$REPO.git)
git remote set-url --add --push origin git@www.opencode.net:$USER/$REPO.git
git remote set-url --add --push origin [https://github.com/$USER/$REPO.git](https://github.com/$USER/$REPO.git)

---

## 4. SCRIPT: git-manager.sh (Comando 'pigia')
Automatizza add, commit e push intelligente.

#!/usr/bin/env bash
set -uo pipefail
V="\e[32m"; C="\e[36m"; R="\e[31m"; GI="\e[33m"; RESET="\e[0m"

git_setup() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo -e "${R}Errore: Non sei in un repository Git.${RESET}"; exit 1
    fi
    git config core.fileMode false
    git add .
    read -rp "Messaggio commit: " msg
    [[ -z "$msg" ]] && msg="Update $(date +'%Y-%m-%d %H:%M')"
    git commit -m "$msg"
    local branch=$(git branch --show-current)
    if git remote -v | grep -q "opencode"; then
        echo -e "\n${GI}Destinazioni multiple rilevate!${RESET}"
        echo "1) Solo GitHub | 2) Entrambi (GitHub + OpenCode)"
        read -rp "Scelta: " scelta
        if [[ "$scelta" == "2" ]]; then
            git push origin "$branch"
        else
            local gh_url=$(git remote -v | grep "github.com" | head -n1 | awk '{print $2}')
            git push "$gh_url" "$branch"
        fi
    else
        git push origin "$branch"
    fi
}
git_setup

---

## 5. DIAGNOSTICA
Comandi per verificare la configurazione:

- Verifica Remoti: git remote -v
- Test SSH OpenCode: ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@www.opencode.net
- Stato GitHub: gh auth status
