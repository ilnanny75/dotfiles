# 📔 Lab Documentazione: Configurazione Git Multi-Piattaforma
**Autore:** ilnanny75
**Target:** GitHub (HTTPS + CLI + 2FA) & OpenCode.net (SSH)

## 1. SSH KEY (OpenCode.net)
1. Genera: ssh-keygen -t ed25519 -C "cristianpozzessere@gmail.com"
2. Copia: cat ~/.ssh/id_ed25519.pub
3. Incolla su: https://www.opencode.net/-/profile/keys

## 2. GITHUB CLI (2FA)
1. Installa:
   - Void: sudo xbps-install -Sy github-cli
   - Fedora: sudo dnf install gh
   - Arch: sudo pacman -S github-cli
2. Login: gh auth login --hostname github.com --git-protocol https --web

## 3. DOUBLE PUSH CONFIG
Esegui nella cartella del progetto:
git remote set-url origin https://github.com/ilnanny75/Lila-HD-Icon-Theme-Official.git
git remote set-url --add --push origin git@www.opencode.net:ilnanny75/Lila-HD-Icon-Theme-Official.git
git remote set-url --add --push origin https://github.com/ilnanny75/Lila-HD-Icon-Theme-Official.git

## 4. SCRIPT UNIVERSALE (gitconf.sh)
#!/bin/bash
set -euo pipefail
GIT_NAME="ilnanny75"
GIT_EMAIL="cristianpozzessere@gmail.com"
echo "--- Verifica GitHub ---"
gh auth status || gh auth login --web
echo "--- Verifica OpenCode SSH ---"
ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@www.opencode.net 2>&1 | grep -q "Welcome" && echo "OK" || echo "ERRORE"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
gh auth setup-git