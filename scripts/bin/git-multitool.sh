#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  git-multitool-v2.sh — Coltellino svizzero potenziato (Lab 2026)
#  Potenziato per la gestione automatica dei conflitti e push forzati.
# ═══════════════════════════════════════════════════════════════

# ── Colori e Stile ──
VERDE="\e[32m"; ROSSO="\e[31m"; GIALLO="\e[33m"; CIANO="\e[36m"; GRASSETTO="\e[1m"; RESET="\e[0m"

# ── Funzioni di Messaggistica ──
info()    { echo -e "${CIANO}ℹ️  $*${RESET}"; }
ok()      { echo -e "${VERDE}✅ $*${RESET}"; }
warn()    { echo -e "${GIALLO}⚠️  $*${RESET}"; }
errore()  { echo -e "${ROSSO}❌ $*${RESET}"; }
titolo()  { echo -e "\n${GRASSETTO}${CIANO}🚀 $*${RESET}\n"; }
linea()   { echo -e "${CIANO}────────────────────────────────────────${RESET}"; }

# ── Controllo Ambiente ──
controlla_repo() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        errore "Questa cartella NON è un repo git."
        exit 1
    fi
}

# ── Funzioni Core Potenziate ──

# 1. Stato approfondito
stato_repo() {
    titolo "STATO REPOSITORY"
    git status -s
    linea
    info "Branch remoto:"
    git remote -v
}

# 2. Sincronizzazione con gestione conflitti (Novità!)
pull_intelligente() {
    titolo "PULL & REPAIR"
    info "Tentativo di sincronizzazione con Rebase..."
    if ! git pull origin $(git branch --show-current) --rebase; then
        warn "Rilevato conflitto o divergenza!"
        echo "1) Forza i MIEI file (Ignora GitHub)"
        echo "2) Forza i file di GITHUB (Ignora i miei)"
        echo "3) Annulla e risolvi a mano"
        read -rp "Scegli opzione: " opt
        case $opt in
            1) git rebase --abort; git pull origin $(git branch --show-current) -X ours ;;
            2) git rebase --abort; git pull origin $(git branch --show-current) -X theirs ;;
            *) git rebase --abort; info "Operazione annullata." ;;
        esac
    else
        ok "Sincronizzazione completata con successo."
    fi
}

# 3. Commit e Push in un colpo solo
super_push() {
    titolo "COMMIT & PUSH VELOCE"
    read -rp "Messaggio del commit: " msg
    if [ -z "$msg" ]; then msg="Update $(date +'%Y-%m-%d %H:%M')"; fi

    git add .
    git commit -m "$msg"

    info "Invio dati..."
    if git push origin $(git branch --show-current); then
        ok "Caricato correttamente!"
    else
        errore "Push rifiutato! GitHub ha modifiche che non hai."
        warn "Consiglio: Usa l'opzione 5 (Pull) prima di riprovare."
    fi
}

# 4. Forza Bruta (Il comando che abbiamo usato oggi)
force_push_atomico() {
    warn "ATTENZIONE: Sovrascriverai GitHub con i tuoi file locali!"
    read -rp "Sei sicuro? (s/n): " confirm
    if [[ $confirm == [sS] ]]; then
        git add .
        git commit -m "Force Update 2026 🚀"
        git push origin $(git branch --show-current) --force
        ok "GitHub è stato piallato e aggiornato con la tua versione."
    fi
}

# ── MENU INTERATTIVO ──
main_menu() {
    controlla_repo
    while true; do
        echo -e "\n${GRASSETTO}${CIANO}🛠️  GIT MULTITOOL POWER — 2026${RESET}"
        echo -e "  📁 Dir:    ${GIALLO}$(pwd)${RESET}"
        echo -e "  🌿 Branch: ${VERDE}$(git branch --show-current)${RESET}"
        linea
        echo "  1) 📋 Stato rapido"
        echo "  2) 📝 Super Push (Add + Commit + Push)"
        echo "  3) ⬇️  Sincronizza e Ripara (Pull + Conflict Solver)"
        echo "  4) 💪 FORCE PUSH (Usa se GitHub ti rifiuta)"
        echo "  5) 📜 Log ultimi 5 commit"
        echo "  6) 🧹 Pulizia Cache Git"
        echo "  0) 🚪 Esci"
        echo ""
        read -rp "  Scegli un'opzione: " SCELTA

        case "$SCELTA" in
            1) stato_repo ;;
            2) super_push ;;
            3) pull_intelligente ;;
            4) force_push_atomico ;;
            5) git log -n 5 --oneline ; linea ;;
            6) git rm -r --cached . && git add . && ok "Cache pulita. Fai un commit ora." ;;
            0) ok "Alla prossima!"; exit 0 ;;
            *) errore "Opzione non valida." ;;
        esac
    done
}

main_menu
