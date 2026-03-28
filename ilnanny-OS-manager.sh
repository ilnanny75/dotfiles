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
# - se è una directory reale, la lascia stare e avvisa
safe_link() {
    local src="$1"
    local dst="$2"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -d "$dst" ]; then
        warn "SKIP: $dst è una cartella reale (non symlink) — non la tocco."
        return
    fi
    ln -sf "$src" "$dst"
    ok "Link: $dst → $src"
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
    # 5. Configurazione Grafica — logica per cartella
    #
    # REGOLA:
    #   - Cartelle "sicure" (geany, gtk-3.0, openbox, Thunar):
    #     link diretto ~/.config/NOME → dotfiles/config/NOME
    #     perché il repo contiene TUTTA la config di quella app.
    #
    #   - xfce4: NON si linka la cartella intera perché XFCE ci
    #     scrive dentro file vivi (panel/, terminal/, desktop/, ecc.)
    #     che non sono nel repo. Si linkano solo le sottocartelle
    #     gestite, lasciando il resto intatto.
    # ─────────────────────────────────────────────────────────────────

    info "Link cartelle config dirette (geany, gtk-3.0, openbox, Thunar)..."
    for folder in geany gtk-3.0 openbox Thunar; do
        if [ -d "$DOTFILES/config/$folder" ]; then
            safe_link "$DOTFILES/config/$folder" ~/.config/"$folder"
        fi
    done

    # gtk-2.0 (file singolo, non cartella)
    if [ -f "$DOTFILES/config/.gtkrc-2.0" ]; then
        safe_link "$DOTFILES/config/.gtkrc-2.0" ~/.gtkrc-2.0
    fi

    # ── xfce4: link granulare ──────────────────────────────────────
    info "Link granulare xfce4 (solo xfconf/xfce-perchannel-xml)..."
    mkdir -p ~/.config/xfce4/xfconf

    XFCONF_SRC="$DOTFILES/config/xfce4/xfconf/xfce-perchannel-xml"
    XFCONF_DST=~/.config/xfce4/xfconf/xfce-perchannel-xml

    if [ -d "$XFCONF_SRC" ]; then
        # Rimuovi il link se già esiste, poi ricrea
        if [ -L "$XFCONF_DST" ]; then
            rm "$XFCONF_DST"
        elif [ -d "$XFCONF_DST" ]; then
            warn "xfce-perchannel-xml esiste come cartella reale — faccio backup e rimpiazzo."
            mv "$XFCONF_DST" "${XFCONF_DST}.bak_$(date +%Y%m%d_%H%M%S)"
        fi
        ln -sf "$XFCONF_SRC" "$XFCONF_DST"
        ok "Link: ~/.config/xfce4/xfconf/xfce-perchannel-xml → repo"
    else
        warn "xfce-perchannel-xml non trovato nel repo, skip."
    fi

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
