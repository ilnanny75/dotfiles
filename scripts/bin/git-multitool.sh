#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  git-multitool.sh — Coltellino svizzero Git per ilnanny75
#  Gestione automatica conflitti, fix SSH→HTTPS, diagnostica
# ═══════════════════════════════════════════════════════════════

set -uo pipefail

# ── Colori ──────────────────────────────────────────────────────
VERDE="\e[32m"; ROSSO="\e[31m"; GIALLO="\e[33m"
CIANO="\e[36m"; GRASSETTO="\e[1m"; RESET="\e[0m"
BLU="\e[34m"; MAGENTA="\e[35m"

# ── Messaggistica ───────────────────────────────────────────────
info()    { echo -e "${CIANO}  ℹ  $*${RESET}"; }
ok()      { echo -e "${VERDE}  ✔  $*${RESET}"; }
warn()    { echo -e "${GIALLO}  ⚠  $*${RESET}"; }
errore()  { echo -e "${ROSSO}  ✘  $*${RESET}"; }
titolo()  { echo -e "\n${GRASSETTO}${CIANO}  ══  $*  ══${RESET}\n"; }
passo()   { echo -e "${BLU}  →  $*${RESET}"; }
linea()   { echo -e "${CIANO}  ────────────────────────────────────────${RESET}"; }
pausa()   { echo ""; read -rp "  Premi [INVIO] per continuare..." _; }

# ── Branch corrente (helper) ─────────────────────────────────────
branch_corrente() { git branch --show-current 2>/dev/null || echo "main"; }

# ── Controllo: siamo in un repo git? ────────────────────────────
controlla_repo() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        errore "Questa cartella NON è un repository git."
        errore "Spostati nella cartella giusta prima di usare questo tool."
        exit 1
    fi
}

# ════════════════════════════════════════════════════════════════
#  DIAGNOSTICA — controlla e spiega tutto ciò che non va
# ════════════════════════════════════════════════════════════════
diagnostica() {
    titolo "DIAGNOSTICA COMPLETA"
    local problemi=0

    # 1. Git installato?
    passo "Controllo git..."
    if command -v git &>/dev/null; then
        ok "git trovato: $(git --version)"
    else
        errore "git NON installato! Installalo prima."
        ((problemi++))
    fi

    # 2. gh (GitHub CLI) installato e autenticato?
    passo "Controllo github-cli (gh)..."
    if command -v gh &>/dev/null; then
        ok "gh trovato: $(gh --version | head -1)"
        if gh auth status &>/dev/null; then
            ok "Autenticato su GitHub come: $(gh api user --jq .login 2>/dev/null || echo '?')"
        else
            warn "gh installato ma NON autenticato."
            warn "Esegui: gh auth login --web"
            ((problemi++))
        fi
    else
        warn "github-cli (gh) non trovato. Alcune funzioni potrebbero non funzionare."
        ((problemi++))
    fi

    # 3. Identità Git configurata?
    passo "Controllo identità git..."
    local nome email
    nome=$(git config --global user.name  2>/dev/null || true)
    email=$(git config --global user.email 2>/dev/null || true)
    if [[ -n "$nome" && -n "$email" ]]; then
        ok "Identità: $nome <$email>"
    else
        warn "Identità git non configurata."
        warn "Esegui: git config --global user.name 'ilnanny75'"
        warn "         git config --global user.email 'tua@email.com'"
        ((problemi++))
    fi

    # 4. Remote del repo corrente
    passo "Controllo remote origin..."
    if git remote get-url origin &>/dev/null; then
        local remote_url
        remote_url=$(git remote get-url origin)
        if [[ "$remote_url" == git@* ]]; then
            warn "Il remote usa SSH: $remote_url"
            warn "Con gh auth (HTTPS) questo causa 'Permission denied (publickey)'"
            warn "Soluzione: opzione 8 del menu → Fix SSH→HTTPS"
            ((problemi++))
        elif [[ "$remote_url" == https://* ]]; then
            ok "Remote HTTPS corretto: $remote_url"
        else
            warn "Remote non standard: $remote_url"
            ((problemi++))
        fi
    else
        warn "Nessun remote 'origin' configurato."
        ((problemi++))
    fi

    # 5. Stato del repo
    passo "Stato del repository..."
    local modificati staged
    modificati=$(git diff --name-only 2>/dev/null | wc -l)
    staged=$(git diff --cached --name-only 2>/dev/null | wc -l)
    local untracked
    untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)
    info "File modificati (non in stage): $modificati"
    info "File pronti per commit (staged): $staged"
    info "File non tracciati:              $untracked"

    # 6. Commit in sospeso?
    passo "Commit locali non inviati..."
    local ahead
    ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    if [[ "$ahead" -gt 0 ]]; then
        warn "Hai $ahead commit locali NON ancora inviati a GitHub."
    else
        ok "Sei in sincronizzazione con GitHub."
    fi

    linea
    if [[ $problemi -eq 0 ]]; then
        ok "Nessun problema rilevato. Tutto OK!"
    else
        warn "Trovati $problemi problema/i. Usa le opzioni del menu per risolverli."
    fi
    pausa
}

# ════════════════════════════════════════════════════════════════
#  FIX SSH → HTTPS  (il bug di oggi!)
# ════════════════════════════════════════════════════════════════
fix_ssh_https() {
    titolo "FIX: SSH → HTTPS"
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null || true)

    if [[ -z "$remote_url" ]]; then
        errore "Nessun remote 'origin' trovato in questo repo."
        pausa; return
    fi

    info "Remote attuale: $remote_url"

    if [[ "$remote_url" == https://* ]]; then
        ok "Il remote è già HTTPS. Nessuna modifica necessaria."
        pausa; return
    fi

    if [[ "$remote_url" == git@github.com:* ]]; then
        # Converte git@github.com:utente/repo.git → https://github.com/utente/repo.git
        local nuovo_url
        nuovo_url=$(echo "$remote_url" | sed 's|git@github.com:|https://github.com/|')
        passo "Nuovo URL: $nuovo_url"
        read -rp "  Confermi la modifica? (s/N): " ok_risposta
        if [[ "$ok_risposta" =~ ^[Ss]$ ]]; then
            git remote set-url origin "$nuovo_url"
            ok "Remote aggiornato a HTTPS!"
            info "Da ora push e pull funzioneranno con il token gh."
        else
            info "Operazione annullata."
        fi
    else
        warn "Remote non riconosciuto come SSH standard: $remote_url"
        read -rp "  Inserisci il nuovo URL HTTPS manualmente: " nuovo_url
        if [[ -n "$nuovo_url" ]]; then
            git remote set-url origin "$nuovo_url"
            ok "Remote aggiornato."
        fi
    fi
    pausa
}

# ════════════════════════════════════════════════════════════════
#  STATO REPO
# ════════════════════════════════════════════════════════════════
stato_repo() {
    titolo "STATO REPOSITORY"
    info "Directory: $(pwd)"
    info "Branch:    $(branch_corrente)"
    info "Remote:    $(git remote get-url origin 2>/dev/null || echo 'non configurato')"
    linea
    git status -s
    linea
    local ahead behind
    ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "?")
    behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "?")
    info "Commit locali da inviare: $ahead | Commit remoti da scaricare: $behind"
    pausa
}

# ════════════════════════════════════════════════════════════════
#  SUPER PUSH: add + commit + push
# ════════════════════════════════════════════════════════════════
super_push() {
    titolo "COMMIT & PUSH"
    local branch
    branch=$(branch_corrente)

    # Mostra cosa verrà committato
    passo "File che verranno aggiunti:"
    git status -s
    linea

    read -rp "  Messaggio del commit (INVIO = data/ora auto): " msg
    [[ -z "$msg" ]] && msg="Update $(date +'%Y-%m-%d %H:%M')"

    git add .

    # Niente da committare?
    if git diff --cached --quiet; then
        warn "Nessuna modifica da committare."
        # Ma forse ci sono commit locali non pushati?
        local ahead
        ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
        if [[ "$ahead" -gt 0 ]]; then
            info "Hai $ahead commit già pronti. Provo direttamente il push..."
        else
            info "Niente da fare. Repository già aggiornato."
            pausa; return
        fi
    else
        git commit -m "$msg"
        ok "Commit creato: '$msg'"
    fi

    passo "Invio a GitHub (branch: $branch)..."
    if git push origin "$branch" 2>&1; then
        ok "Push completato con successo!"
    else
        errore "Push rifiutato da GitHub."
        linea
        warn "Possibili cause e soluzioni:"
        info "1. GitHub ha commit che tu non hai → usa opzione 4 (Pull)"
        info "2. Il remote usa SSH invece di HTTPS → usa opzione 8 (Fix SSH)"
        info "3. Token gh scaduto → esegui: gh auth login --web"
        info "4. Vuoi forzare il push → usa opzione 5 (Force Push)"
    fi
    pausa
}

# ════════════════════════════════════════════════════════════════
#  PULL INTELLIGENTE con gestione conflitti
# ════════════════════════════════════════════════════════════════
pull_intelligente() {
    titolo "PULL & SINCRONIZZAZIONE"
    local branch
    branch=$(branch_corrente)

    passo "Scarico aggiornamenti da GitHub (branch: $branch)..."

    if git pull origin "$branch" --rebase 2>&1; then
        ok "Sincronizzazione completata con successo."
    else
        linea
        warn "Rilevato conflitto o divergenza tra locale e GitHub!"
        echo ""
        echo -e "  ${GRASSETTO}Come vuoi risolvere?${RESET}"
        echo "  1) Tieni i MIEI file locali  (GitHub verrà sovrascritto)"
        echo "  2) Tieni i file di GITHUB    (le tue modifiche locali vengono perse)"
        echo "  3) Annulla — risolvo a mano"
        echo ""
        read -rp "  Scelta: " opt
        git rebase --abort 2>/dev/null || true
        case $opt in
            1)
                passo "Forzo i miei file locali..."
                git pull origin "$branch" -X ours
                ok "Usati i tuoi file locali."
                ;;
            2)
                passo "Forzo i file di GitHub..."
                git pull origin "$branch" -X theirs
                ok "Usati i file di GitHub."
                ;;
            *)
                info "Operazione annullata. Risolvi i conflitti a mano con:"
                info "  git status        → vedi i file in conflitto"
                info "  git mergetool     → apri un editor visivo"
                info "  git rebase --abort → annulla tutto e torna al punto di partenza"
                ;;
        esac
    fi
    pausa
}

# ════════════════════════════════════════════════════════════════
#  FORCE PUSH — sovrascrive GitHub con i file locali
# ════════════════════════════════════════════════════════════════
force_push() {
    titolo "FORCE PUSH ⚠"
    local branch
    branch=$(branch_corrente)

    warn "Stai per sovrascrivere GitHub con i tuoi file locali."
    warn "Tutto ciò che c'è su GitHub e NON hai in locale verrà PERSO."
    echo ""
    read -rp "  Sei sicuro? Scrivi 'forza' per confermare: " confirm
    if [[ "$confirm" == "forza" ]]; then
        git add .
        if ! git diff --cached --quiet; then
            read -rp "  Messaggio commit (INVIO = 'Force update'): " msg
            [[ -z "$msg" ]] && msg="Force update $(date +'%Y-%m-%d %H:%M')"
            git commit -m "$msg"
        fi
        passo "Force push in corso..."
        if git push origin "$branch" --force 2>&1; then
            ok "GitHub aggiornato forzatamente con la tua versione."
        else
            errore "Force push fallito."
            info "Controlla il remote con l'opzione 8 (Fix SSH→HTTPS)"
        fi
    else
        info "Operazione annullata."
    fi
    pausa
}

# ════════════════════════════════════════════════════════════════
#  LOG — ultimi commit
# ════════════════════════════════════════════════════════════════
mostra_log() {
    titolo "ULTIMI 10 COMMIT"
    git log -n 10 --oneline --graph --decorate
    linea
    pausa
}

# ════════════════════════════════════════════════════════════════
#  PULIZIA CACHE GIT (.gitignore non applicato a file già tracciati)
# ════════════════════════════════════════════════════════════════
pulizia_cache() {
    titolo "PULIZIA CACHE GIT"
    info "Utile quando hai aggiunto file a .gitignore ma git li traccia ancora."
    warn "Dopo la pulizia dovrai fare un commit."
    echo ""
    read -rp "  Procedo con la pulizia? (s/N): " ok_pulizia
    if [[ "$ok_pulizia" =~ ^[Ss]$ ]]; then
        git rm -r --cached . &>/dev/null
        git add .
        ok "Cache pulita. Ora fai un commit con l'opzione 2."
    else
        info "Operazione annullata."
    fi
    pausa
}

# ════════════════════════════════════════════════════════════════
#  UNDO — annulla l'ultimo commit (mantiene i file)
# ════════════════════════════════════════════════════════════════
undo_ultimo_commit() {
    titolo "ANNULLA ULTIMO COMMIT"
    info "Annulla l'ultimo commit mantenendo i tuoi file modificati."
    warn "Funziona solo su commit NON ancora pushati su GitHub."
    echo ""
    local ultimo
    ultimo=$(git log -1 --oneline)
    info "Ultimo commit: $ultimo"
    echo ""
    read -rp "  Annullo questo commit? (s/N): " ok_undo
    if [[ "$ok_undo" =~ ^[Ss]$ ]]; then
        git reset --soft HEAD~1
        ok "Commit annullato. I tuoi file sono ancora lì, pronti per un nuovo commit."
    else
        info "Operazione annullata."
    fi
    pausa
}

# ════════════════════════════════════════════════════════════════
#  MENU PRINCIPALE
# ════════════════════════════════════════════════════════════════
main_menu() {
    controlla_repo
    while true; do
        clear
        echo -e "\n${GRASSETTO}${CIANO}  🛠  GIT MULTITOOL — ilnanny75${RESET}"
        echo -e "  ${BLU}Dir:    ${GIALLO}$(pwd)${RESET}"
        echo -e "  ${BLU}Branch: ${VERDE}$(branch_corrente)${RESET}"
        echo -e "  ${BLU}Remote: ${RESET}$(git remote get-url origin 2>/dev/null || echo 'non configurato')"
        linea
        echo -e "  ${GRASSETTO}OPERAZIONI QUOTIDIANE${RESET}"
        echo "   1)  📋  Stato repo"
        echo "   2)  🚀  Commit & Push (add + commit + push)"
        echo "   3)  📜  Log ultimi 10 commit"
        linea
        echo -e "  ${GRASSETTO}SINCRONIZZAZIONE${RESET}"
        echo "   4)  ⬇   Pull intelligente (con gestione conflitti)"
        echo "   5)  💪  Force Push (sovrascrive GitHub)"
        linea
        echo -e "  ${GRASSETTO}MANUTENZIONE & FIX${RESET}"
        echo "   6)  🔍  Diagnostica completa"
        echo "   7)  ↩   Annulla ultimo commit"
        echo "   8)  🔧  Fix SSH → HTTPS (risolve 'Permission denied')"
        echo "   9)  🧹  Pulizia cache git"
        linea
        echo "   0)  🚪  Esci"
        echo ""
        read -rp "  Scegli un'opzione: " SCELTA
        echo ""

        case "$SCELTA" in
            1) stato_repo ;;
            2) super_push ;;
            3) mostra_log ;;
            4) pull_intelligente ;;
            5) force_push ;;
            6) diagnostica ;;
            7) undo_ultimo_commit ;;
            8) fix_ssh_https ;;
            9) pulizia_cache ;;
            0) ok "Alla prossima, Cristian!"; echo ""; exit 0 ;;
            *) errore "Opzione '$SCELTA' non valida."; sleep 1 ;;
        esac
    done
}

main_menu
