#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  git-multitool.sh — Coltellino svizzero per Git (Lab 2026)
#  Autore: ilnanny75
#  Funzioni: Pulizia, Bonifica Email/User, Switch Master->Main
# ═══════════════════════════════════════════════════════════════

# ── Colori per i messaggi a schermo ──
VERDE="\e[32m"
ROSSO="\e[31m"
GIALLO="\e[33m"
CIANO="\e[36m"
GRASSETTO="\e[1m"
RESET="\e[0m"

# ── Funzioni di output (Le tue icone preferite) ──
info()    { echo -e "${CIANO}ℹ️  $*${RESET}"; }
ok()      { echo -e "${VERDE}✅ $*${RESET}"; }
warn()    { echo -e "${GIALLO}⚠️  $*${RESET}"; }
errore()  { echo -e "${ROSSO}❌ $*${RESET}"; }
titolo()  { echo -e "\n${GRASSETTO}${CIANO}🚀 $*${RESET}\n"; }
linea()   { echo -e "${CIANO}────────────────────────────────────────${RESET}"; }

# ── Controllo che siamo dentro un repo git ──
controlla_repo() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        errore "Questa cartella NON è un repo git."
        errore "Spostati dentro la cartella del progetto e riprova."
        exit 1
    fi
}

# ── Opzione 1: Stato del Repo ──
stato_repo() {
    titolo "STATO DEL REPOSITORY"
    git status -sb
    linea
    info "Contatti remoti:"
    git remote -v
}

# ── Opzione 2: Svuota Cache ──
svuota_cache() {
    titolo "PULIZIA CACHE GIT"
    warn "Questa operazione rimuove l'indice ma NON i tuoi file fisici."
    git rm -r --cached .
    ok "Cache svuotata. Ora puoi rifare il commit per aggiornare l'indice."
}

# ── Opzione 3: Commit Rapido ──
commit_rapido() {
    titolo "COMMIT RAPIDO"
    read -rp "Inserisci il messaggio del commit: " MSG
    if [ -z "$MSG" ]; then
        MSG="Aggiornamento automatico Lab 2026"
    fi
    git add .
    git commit -m "$MSG"
    ok "Commit effettuato: $MSG"
}

# ── Opzione 9: BONIFICA TOTALE LAB 2026 (Quella che cercavi!) ──
bonifica_lab() {
    titolo "🧹 BONIFICA TOTALE LABORATORIO 2026"
    warn "Sto per uniformare User, Email e Branch..."
    echo ""

    # 1. Switch Master -> Main
    CURRENT_BRANCH=$(git branch --show-current)
    if [ "$CURRENT_BRANCH" == "master" ]; then
        info "Rilevato branch 'master'. Conversione in 'main'..."
        git branch -m master main
        ok "Branch rinominato in 'main' locale."
    else
        info "Branch corrente è già '$CURRENT_BRANCH'. Nessun cambio necessario."
    fi

    # 2. Correzione Utente e Email locale
    info "Configurazione identità: ilnanny75 <ilnannyhack@gmail.com>"
    git config user.name "ilnanny75"
    git config user.email "ilnannyhack@gmail.com"
    ok "Identità Git aggiornata per questo repo."

    # 3. Pulizia Email negli script (Bonifica Erik Dubois / Vecchi residui)
    info "Scansione file per rimozione vecchie email..."
    # Questo comando cerca qualsiasi stringa formato email e la sostituisce con la tua corretta
    # Evita di toccare la cartella .git per non rompere il database di git
    find . -type f -not -path '*/.*' -exec sed -i 's/[a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\{2,4\}/ilnannyhack@gmail.com/g' {} +

    ok "Bonifica completata! Tutti i file ora puntano a ilnannyhack@gmail.com"
}

# ── Altre Funzioni Standard ──
push_normale()  { titolo "PUSH AL REMOTO"; git push; }
pull_remoto()   { titolo "PULL DAL REMOTO"; git pull; }
force_push()    { titolo "FORCE PUSH"; warn "ATTENZIONE: Sovrascrivo il remoto!"; git push -f; }
mostra_log()    { titolo "ULTIMI COMMIT"; git log --oneline -n 10 --graph; }
force_rebuild() { titolo "REBUILD GITHUB PAGES"; git commit --allow-empty -m "Forcing rebuild" && git push; }

# ── MENU INTERATTIVO ──
main_menu() {
    controlla_repo
    while true; do
        echo -e "\n${GRASSETTO}${CIANO}🛠️  GIT MULTITOOL — Lab 2026${RESET}"
        echo -e "  📁 Cartella: ${GIALLO}$(pwd)${RESET}"
        BRANCH=$(git branch --show-current 2>/dev/null)
        echo -e "  🌿 Branch:   ${VERDE}${BRANCH}${RESET}"
        linea
        echo "  1) 📋  Stato repo (Check veloce)"
        echo "  2) 🧹  Svuota cache git"
        echo "  3) 📝  Commit rapido"
        echo "  4) 🚀  Push al remoto"
        echo "  5) ⬇️   Pull dal remoto"
        echo "  6) 💪  Force push (Usa con cautela!)"
        echo "  7) 📜  Mostra ultimi 10 commit"
        echo "  8) 🔄  Forza rebuild GitHub Pages"
        echo -e "  ${ROSSO}9) ☣️   BONIFICA LAB (Master->Main, User, Email)${RESET}"
        echo "  0) 🚪  Esci"
        echo ""
        read -rp "  Scegli un'opzione: " SCELTA
        echo ""

        case "$SCELTA" in
            1) stato_repo ;;
            2) svuota_cache ;;
            3) commit_rapido ;;
            4) push_normale ;;
            5) pull_remoto ;;
            6) force_push ;;
            7) mostra_log ;;
            8) force_rebuild ;;
            9) bonifica_lab ;;
            0) echo -e "\n  ${VERDE}Arrivederci ilnanny! 👋${RESET}\n"; exit 0 ;;
            *) warn "Opzione non valida, riprova..." ;;
        esac
        echo -e "\n${CIANO}Premi INVIO per tornare al menu...${RESET}"
        read -r
        clear
    done
}

# Lancio del menu
clear
main_menu

