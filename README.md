<h1>🛠️ ilnanny Lab - Dotfiles 2026</h1>

<p align="left">
  <a href="https://github.com/ilnanny75"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" /></a>
  <a href="http://ilnanny.deviantart.com"><img src="https://img.shields.io/badge/DeviantArt-181717?style=for-the-badge&logo=deviantart&logoColor=white" /></a>
  <a href="https://www.gnome-look.org/u/ilnanny75/products"><img src="https://img.shields.io/badge/Gnome--Look-181717?style=for-the-badge&logo=gnome&logoColor=white" /></a>
  <a href="https://openclipart.org/artist/ilnanny"><img src="https://img.shields.io/badge/OpenClipart-181717?style=for-the-badge&logo=inkscape&logoColor=white" /></a>
</p>

<hr>

<p><strong>Laboratorio personale di icone, script e configurazioni Linux (Debian, Void, Arch).</strong></p>

<hr>

<h3>🚀 Setup Istantaneo</h3>
<p>Se hai appena scaricato i dotfiles o sei su un nuovo sistema, usa il Master Manager per collegare tutto in modo automatico:</p>

<pre><code>
cd ~/dotfiles && chmod +x ilnanny-OS-manager.sh && ./ilnanny-OS-manager.sh
</code></pre>

<hr>

<h3>📂 Struttura Modulare</h3>
<p>Il laboratorio è intelligente e riconosce automaticamente l'OS:</p>
<ul>
  <li><strong>bash/etc_bash/bashrc.d</strong>: Moduli Bash Universali (Alias comuni, PS1, Utility).</li>
  <li><strong>Debian / Void / Arch</strong>: Configurazioni specifiche caricate in base alla distro.</li>
  <li><strong>scripts/bin</strong>: Il cuore degli script (Icone, Git Manager, Fix Hardware).</li>
  <li><strong>config</strong>: Sincronizzazione automatica per Geany, Openbox, Thunar e XFCE.</li>
</ul>

<hr>

<h3>📔 MEMO Rapido</h3>
<ul>
  <li><strong>pigia</strong>: Il comando definitivo per Git. Gestisce commit e push in un colpo solo.</li>
  <li><strong>multigit</strong>: Il tuo nuovo "coltellino svizzero" per pulire la cache e bonificare i repo.</li>
  <li><strong>up</strong>: Sincronizza il repository locale con quello online (git pull).</li>
  <li><strong>install</strong>: Installa pacchetti usando il gestore corretto della tua distro.</li>
  <li><strong>update</strong>: Aggiorna l'intero sistema (core e pacchetti).</li>
  <li><strong>treed</strong>: Visualizza la struttura delle cartelle senza lag di immagini.</li>
  <li><strong>vedi</strong>: Esplora i file saltando i binari pesanti (immagini/PDF).</li>
</ul>

<hr>

<h3>🛠️ Manutenzione e Bonifica</h3>
<p>Se riscontri problemi con i vecchi riferimenti (email di terzi o vecchi nomi utente), lancia il comando:</p>
<p><strong>multigit</strong> e seleziona l'opzione <strong>9 (BONIFICA LAB)</strong>.</p>
<p>Questo imposterà automaticamente l'utente <strong>ilnanny75</strong>, l'email <strong>ilnannyhack@gmail.com</strong> e convertirà i branch da <i>master</i> a <i>main</i>.</p>
