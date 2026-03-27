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

Se sei su un nuovo sistema, usa il Master Manager per collegare tutto in modo automatico:

cd ~/dotfiles && chmod +x ilnanny-OS-manager.sh && ./ilnanny-OS-manager.sh
📂 Struttura Modulare 2026

Il laboratorio ora riconosce automaticamente l'OS su cui ti trovi:

    bash/etc_bash/bashrc.d: Moduli Bash Universali (Alias comuni, PS1, Utility).

    Debian / Void / Arch: Configurazioni specifiche caricate in base alla distro.

    scripts/bin: Il cuore degli script (Icone, Git Manager, Fix Hardware).

    config: Sincronizzazione per Geany, Openbox, Thunar e XFCE.

📔 MEMO Rapido (I tuoi nuovi muscoli)

Ecco i comandi principali che abbiamo configurato nei tuoi alias:

    pigia: Salva tutto e spinge le modifiche su GitHub.

    up: Sincronizza il repository locale con quello online.

    instally: Installa pacchetti (rileva apt, xbps o pacman in automatico).

    update: Aggiorna l'intero sistema.

    treed: Visualizza l'albero delle cartelle senza lag.

    vedi: Esplora i file saltando i binari pesanti (immagini/PDF).

🛠️ Manutenzione

Per ricaricare le modifiche agli alias dopo aver modificato i file in bashrc.d:

source ~/.bashrc

"Il codice è come il caffè: deve essere pulito, forte e senza errori."
