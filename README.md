<p align="left">
  <a href="https://github.com/ilnanny75">
    <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" />
  </a>
  <a href="http://ilnanny.deviantart.com">
    <img src="https://img.shields.io/badge/DeviantArt-05CC47?style=for-the-badge&logo=deviantart&logoColor=white" />
  </a>
  <a href="https://www.gnome-look.org/u/ilnanny75/products">
    <img src="https://img.shields.io/badge/Gnome--Look-303133?style=for-the-badge&logo=gnome&logoColor=white" />
  </a>
  <a href="https://openclipart.org/artist/ilnanny">
    <img src="https://img.shields.io/badge/OpenClipart-2F2F2F?style=for-the-badge&logo=inkscape&logoColor=white" />
  </a>
</p>

🛠️ ilnanny Lab - Dotfiles 2026

Laboratorio personale di icone, script e configurazioni Linux (Debian, Void, Arch).
🚀 Setup Istantaneo

Se hai appena scaricato i dotfiles o sei su un nuovo sistema, usa il Master Manager per collegare tutto in modo automatico. Lo script rileverà la tua distribuzione e configurerà i link simbolici corretti:

cd ~/dotfiles && chmod +x ilnanny-OS-manager.sh && ./ilnanny-OS-manager.sh
📂 Struttura Modulare 2026

Il laboratorio è stato riorganizzato per essere intelligente e pulito:

    bash/etc_bash/bashrc.d: Qui risiedono i moduli Bash universali. Vengono caricati automaticamente su ogni sistema per darti sempre i tuoi alias e le tue funzioni preferite.

    Debian / Void / Arch: Cartelle dedicate alle configurazioni specifiche. Contengono alias per i gestori pacchetti (apt, xbps, pacman) e ottimizzazioni per il sistema operativo in uso.

    scripts/bin: Il cuore pulsante dell'automazione. Include script per la gestione delle icone, il backup su GitHub, la pulizia del sistema e il fix dell'hardware.

    config: Sincronizzazione automatica delle configurazioni per Geany, Openbox, Thunar e l'ambiente XFCE.

📔 MEMO Rapido (I tuoi nuovi muscoli)

Grazie agli alias intelligenti, puoi gestire tutto con pochi tasti:

    pigia: Il comando definitivo per Git. Aggiunge i file, crea il commit e spinge tutto sul tuo GitHub (ilnanny75).

    up: Sincronizza il repository locale scaricando le novità dal server e pulisce i file temporanei.

    instally: Non importa su quale distro sei; questo comando userà il gestore pacchetti corretto per installare quello che ti serve.

    update: Aggiorna l'intero sistema (core e pacchetti) con un solo comando.

    treed: Visualizza la struttura delle cartelle in modo grafico ma leggero, saltando i file binari pesanti.

    vedi: Esplora velocemente il contenuto delle cartelle ignorando immagini e PDF per non rallentare il terminale.

🛠️ Manutenzione

Se modifichi i file dentro bashrc.d o aggiungi nuovi alias, non serve riavviare il terminale. Basta dare il comando:

source ~/.bashrc

"Il codice è come il caffè: deve essere pulito, forte e senza errori."
