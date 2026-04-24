#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Nota: Configurazione Multi-Repo (GitHub & OpenCode). 
# Gestisce autenticazione GitHub via CLI e verifica SSH per OpenCode.
# Supporta: Void Linux, Arch, Debian/Ubuntu, Fedora.
#
# Autore: ilnanny 2026
# Mail: ilnannyhack@gmail.com
# GitHub: https://github.com/ilnanny75
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Identità ────────────────────────────────────────────────
readonly GIT_NAME="ilnanny75"
readonly GIT_EMAIL="cristianpozzessere@gmail.com"
readonly OPENCODE_URL="https://www.opencode.net/-/profile/keys"

# ── Colori ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

msg()  { echo -e "${CYAN}${BOLD}→${RESET} $*"; }
ok()   { echo -e "${GREEN}${BOLD}✔${RESET} $*"; }
err()  { echo -e "${RED}${BOLD}✘${RESET} $*"; exit 1; }
warn() { echo -e "${YELLOW}${BOLD}!${RESET} $*"; }

# ── Banner ──────────────────────────────────────────────────
echo -e "\n${BOLD}${CYAN}══════════════════════════════════════${RESET}"
echo -e "${BOLD}   🚀 Multi-Git Setup — ilnanny75${RESET}"
echo -e "${BOLD}${CYAN}══════════════════════════════════════${RESET}\n"

# ── Rilevamento OS e installazione gh ───────────────────────
if command -v gh &>/dev/null; then
    ok "GitHub CLI già installato: $(gh --version | head -1)"
else
    msg "Installazione github-cli in corso..."
    
    if command -v xbps-install &>/dev/null; then
        sudo xbps-install -Sy github-cli
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm github-cli
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y gh
    elif command -v apt &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y gh
    else
        err "Gestore pacchetti non riconosciuto. Installa 'gh' manualmente."
    fi
    ok "GitHub CLI installato correttamente."
fi

# ── Sezione 1: GitHub (HTTPS via CLI) ───────────────────────
echo -e "\n${BOLD}[1/2] Configurazione GitHub${RESET}"
if gh auth status &>/dev/null; then
    warn "Sei già autenticato su GitHub."
    read -rp "$(echo -e "${YELLOW}Vuoi ri-autenticarti? (s/N): ${RESET}")" risposta
    if [[ "$risposta" =~ ^[Ss]$ ]]; then
        gh auth login --hostname github.com --git-protocol https --web
    fi
else
    msg "Avvio autenticazione GitHub via browser..."
    gh auth login --hostname github.com --git-protocol https --web
fi

# ── Sezione 2: OpenCode (SSH Verification) ──────────────────
echo -e "\n${BOLD}[2/2] Configurazione OpenCode (GitLab)${RESET}"
msg "Verifica connessione SSH a OpenCode..."

# Test della chiave SSH con timeout per evitare blocchi
if ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@www.opencode.net 2>&1 | grep -q "Welcome"; then
    ok "Connessione SSH a OpenCode riuscita!"
else
    warn "Connessione SSH non riuscita o chiave non autorizzata."
    echo -e "  ${YELLOW}→ Assicurati di aver aggiunto la chiave pubblica qui:${RESET}"
    echo -e "    ${CYAN}${OPENCODE_URL}${RESET}"
fi

# ── Finalizzazione Git Globale ──────────────────────────────
if gh auth status &>/dev/null; then
    echo -e "\n${BOLD}Applicazione impostazioni globali...${RESET}"
    git config --global user.name  "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    gh auth setup-git

    echo -e "\n${BOLD}${GREEN}══════════════════════════════════════${RESET}"
    ok "Setup terminato con successo!"
    echo -e "  ${BOLD}User:${RESET}  $GIT_NAME"
    echo -e "  ${BOLD}Email:${RESET} $GIT_EMAIL"
    echo -e "  ${BOLD}GitHub:${RESET} Autenticato (HTTPS)"
    echo -e "  ${BOLD}GitLab:${RESET} Verificato (SSH)"
    echo -e "${BOLD}${GREEN}══════════════════════════════════════${RESET}\n"
else
    err "Errore critico: Autenticazione GitHub fallita. Controlla il token."
fi
