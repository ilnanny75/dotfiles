# 🏁 Guida Rapida Installazione Dotfiles (ilnanny 2026)

Quando arrivi su un nuovo computer o una nuova distro, segui questi 3 passi:

### 1. Scarica i tuoi Dotfiles
Apri il terminale e scrivi:
`git clone https://github.com/ilnanny75/dotfiles.git ~/dotfiles`

### 2. Rendi eseguibile il Bootstrap
`chmod +x ~/dotfiles/scripts/bin/ilnanny-bootstrap.sh`

### 3. Avvia l'automazione
`~/dotfiles/scripts/bin/ilnanny-bootstrap.sh`

---
### 📦 Cosa fa questo script:
- Rileva se sei su **Debian** o **Arch**.
- Installa tutti i programmi necessari per le tue **Azioni Personalizzate di Thunar** (Zenity, Inkscape, ecc.).
- Collega il tuo **Master Bashrc** così hai subito tutti i tuoi alias.
- Installa gli strumenti per l'ottimizzazione delle icone.
