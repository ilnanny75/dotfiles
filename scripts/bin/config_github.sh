#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  ilnanny75 Github Configurazione
# ═══════════════════════════════════════════════════════════

#!/bin/bash

# --- CONFIGURAZIONE IDENTITÀ ---
EMAIL="cristianpozzessere@gmail.com"
USERNAME="ilnanny75"

echo "-------------------------------------------------------"
echo "   🚀 GitHub Setup via CLI per Cristian (ilnanny75)   "
echo "-------------------------------------------------------"

# 1. Rilevamento e Installazione di github-cli (gh)
if command -v xbps-install &>/dev/null; then
    OS="Void Linux"
    INSTALL_CMD="sudo xbps-install -S github-cli"
elif command -v pacman &>/dev/null; then
    OS="Arch Linux"
    INSTALL_CMD="sudo pacman -S --noconfirm github-cli"
elif command -v apt &>/dev/null; then
    OS="Debian/Ubuntu"
    INSTALL_CMD="sudo apt update && sudo apt install -y gh"
else
    echo "❌ Sistema non riconosciuto. Installa 'gh' manualmente prima di continuare."
    exit 1
fi

echo "📦 Sistema rilevato: $OS"

read -p "Vuoi installare/aggiornare github-cli e autenticarti? (s/n): " scelta
if [[ ! "$scelta" =~ ^[Ss]$ ]]; then
    echo "Operazione annullata."
    exit 0
fi

# Esecuzione installazione
$INSTALL_CMD

if [ $? -ne 0 ]; then
    echo "❌ Errore durante l'installazione. Controlla i permessi sudo."
    exit 1
fi

echo ""
echo "-------------------------------------------------------"
echo "🔐 AVVIO AUTENTICAZIONE (Segui le istruzioni)"
echo "1. Scegli 'GitHub.com'"
echo "2. Scegli 'HTTPS'"
echo "3. Scegli 'Yes' per configurare Git con le tue credenziali"
echo "4. Scegli 'Login with a web browser'"
echo "5. COPIA il codice che apparirà qui sotto"
echo "6. Incollalo nel browser e conferma con l'APP (2FA)"
echo "-------------------------------------------------------"
read -p "Premi [INVIO] per generare il codice di accesso..."

# Avvio login interattivo
gh auth login

# Se il login ha successo, configura Git in modo che usi 'gh' come gestore credenziali
if gh auth status &>/dev/null; then
    echo "⚙️ Configurazione Git in corso..."
    git config --global user.name "$USERNAME"
    git config --global user.email "$EMAIL"
    
    # Questo comando è fondamentale: dice a Git di usare il token di 'gh' per HTTPS
    gh auth setup-git
    
    echo ""
    echo "-------------------------------------------------------"
    echo "✅ OPERAZIONE CONCLUSA CON SUCCESSO!"
    echo "👤 Utente: $USERNAME"
    echo "🚀 Ora puoi fare push/pull via HTTPS senza password."
    echo "-------------------------------------------------------"
else
    echo "❌ L'autenticazione non è stata completata."
fi
