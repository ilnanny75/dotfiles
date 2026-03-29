#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  ilnanny-OS-manager.sh — MASTER SETUP 2026 (FULL VERSION)
# ═══════════════════════════════════════════════════════════════════

V="\e[32m"
R="\e[31m"
C="\e[36m"
G="\e[33m"
B="\e[1m"
RESET="\e[0m"

OS_ID=$(grep -w "ID" /etc/os-release | cut -d= -f2 | tr -d '"')

DOTFILES=~/dotfiles

header() {
    clear
    echo -e "${B}${C}󱓞  ilnanny LAB MANAGER — OS: ${OS_ID^^}${RESET}"
    echo -e "${C}─────────────────────────────────────────────────────${RESET}\n"
}

ok()     { echo -e "${V}✅ $*${RESET}"; }
info()   { echo -e "${C}ℹ️  $*${RESET}"; }
warn()   { echo -e "${G}⚠️  $*${RESET}"; }

bonifica_files() {
    info "Pulizia automatica dei file (rimozione numeri di riga)..."
    find "$DOTFILES" -type f \( -name "*.sh" -o -name "*.md" -o -name "bashrc" -o -name "alias*" \) \
        -not -path '*/.git/*' \
        -exec sed -i 's/^[[:space:]]*[0-9]\+[[:space:]]\+//' {} +
    ok "Tutti i file nel repository sono stati bonificati."
}

# Crea un symlink in modo sicuro:
# - se la destinazione è già un symlink, lo rimuove e lo ricrea
# - se è un file/cartella reale, lo rinomina in .bak_TIMESTAMP poi crea il link
safe_link() {
    local src="$1"
    local dst="$2"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        warn "Backup: $dst → ${dst}.bak_$(date +%Y%m%d_%H%M%S)"
        mv "$dst" "${dst}.bak_$(date +%Y%m%d_%H%M%S)"
    fi
    ln -sf "$src" "$dst"
    ok "Link: $dst → $src"
}

# Symlink dinamico di tutto $DOTFILES/config/ → ~/.config/
# Qualsiasi file/cartella aggiunta al repo viene linkata automaticamente.
# Le modifiche fatte in ~/.config/ finiscono direttamente nel repo.
# Se esiste già qualcosa in destinazione → backup .bak_TIMESTAMP
deploy_config() {
    local src_root="$DOTFILES/config"
    local dst_root="$HOME/.config"

    info "Symlink config: $src_root → $dst_root"

    for src in "$src_root"/*; do
        [ -e "$src" ] || continue
        local name
        name=$(basename "$src")
        safe_link "$src" "$dst_root/$name"
    done

    ok "Deploy config completato."
}

configura_lab() {
    header
    bonifica_files
    info "Sincronizzazione dotfiles per ${OS_ID^^}..."

    # 1. Cartelle base
    mkdir -p ~/.bashrc.d ~/.config ~/.local/share/fonts ~/bin
    # rm con glob non rimuove symlink rotti — find -delete li prende tutti
    find ~/.bashrc.d/ -maxdepth 1 \( -type f -o -type l \) -delete 2>/dev/null || true

    # 2. Link Moduli Universali bash
    ln -sf "$DOTFILES"/bash/etc_bash/bashrc.d/* ~/.bashrc.d/

    # 3. Logica Multi-OS
    case "$OS_ID" in
        arch)
            info "Attivazione moduli specifici ARCH..."
            [ -d "$DOTFILES/Arch/etc/bash/bashrc.d" ] && \
                ln -sf "$DOTFILES"/Arch/etc/bash/bashrc.d/* ~/.bashrc.d/ ;;
        debian|mx)
            info "Attivazione moduli specifici DEBIAN/MX..."
            [ -d "$DOTFILES/Debian/etc/bash/bashrc.d" ] && \
                ln -sf "$DOTFILES"/Debian/etc/bash/bashrc.d/* ~/.bashrc.d/ ;;
        void)
            info "Attivazione moduli specifici VOID..."
            [ -d "$DOTFILES/Void/etc/bash/bashrc.d" ] && \
                ln -sf "$DOTFILES"/Void/etc/bash/bashrc.d/* ~/.bashrc.d/ ;;
    esac

    # 4. Link Eseguibili e Bashrc
    ln -sf "$DOTFILES"/scripts/bin/* ~/bin/
    chmod +x "$DOTFILES"/scripts/bin/*
    safe_link "$DOTFILES/bash/etc_bash/bashrc" ~/.bashrc

    # ─────────────────────────────────────────────────────────────────
    # 5. Configurazione Grafica — symlink dinamico
    #
    # REGOLA:
    #   Tutto il primo livello di dotfiles/config/ viene linkato
    #   automaticamente in ~/.config/. Non serve più elencare le
    #   cartelle a mano: basta aggiungere una nuova cartella/file
    #   nel repo e al prossimo setup viene linkata.
    #   Le modifiche fatte localmente in ~/.config/ finiscono
    #   direttamente nel repo (dotfiles) — pronti per il push.
    #   Se esiste già qualcosa in destinazione → backup .bak_TIMESTAMP
    # ─────────────────────────────────────────────────────────────────
    deploy_config

    ok "LABORATORIO CONFIGURATO CON SUCCESSO!"
    echo -e "${G}Ricarica con: source ~/.bashrc${RESET}"
}

# --- MENU PRINCIPALE ---
while true; do
    header
    echo -e "  ${V}1)${RESET} 󰑭  SETUP TOTALE (Auto-Detect OS & Fix)"
    echo -e "  ${V}2)${RESET} 󰊢  GIT PIGIA (Upload rapido)"
    echo -e "  ${V}3)${RESET} 🛠️  GIT MULTITOOL (Gestione avanzata)"
    echo -e "  ${V}4)${RESET} 🧹  BONIFICA MANUALE (Fix numeri riga)"
    echo -e "  ${V}5)${RESET} 󰏫  EDIT README (Geany)"
    echo -e "  ${R}0)${RESET} 󰈆  ESCI"
    echo ""
    read -p "  Scegli opzione: " scelta

    case $scelta in
        1) configura_lab ;;
        2) bash "$DOTFILES"/scripts/bin/ilnanny-git-manager.sh ;;
        3) bash "$DOTFILES"/scripts/bin/git-multitool.sh ;;
        4) bonifica_files ;;
        5) geany "$DOTFILES"/README.md & ;;
        0) exit 0 ;;
        *) echo -e "${R}Opzione non valida!${RESET}" ;;
    esac
    echo -e "\n${G}Premi INVIO per tornare al menu...${RESET}"; read
done
