# 🐧 WIKI LINUX - COMANDI ESSENZIALI (ilnanny 2026)

### 📂 Gestione File e Cartelle
- `ls -lhS` : Elenca file, dimensione leggibile (Kb/Mb), ordinati dal più grande.
- `du -sh .` : Peso totale della cartella in cui ti trovi.
- `cp -rv fonte destinazione` : Copia file/cartelle mostrando cosa sta facendo.
- `mv vecchio_nome nuovo_nome` : Sposta o rinomina.
- `rm -rf nome` : Cancella DEFINITIVAMENTE (attenzione!).

### ⚡ Potere Root (Amministrazione)
- `sudo !!` : Esegue l'ultimo comando digitato ma con i privilegi di root.
- `pkexec thunar` : Apre Thunar come root (metodo moderno su Debian/MX).
- `sudo chown -R $USER:$USER cartella/` : Ti riprendi i permessi di una cartella.

### 📜 Lettura e Testo
- `cat file.txt` : Stampa tutto il file a video.
- `less file.txt` : Leggi il file (usa frecce per scorrere, `q` per uscire).
- `grep "parola" file.sh` : Cerca una parola specifica dentro un file.

### ⌨️ VIM (Sopravvivenza)
1. Apri: `vim nomefile`
2. Scrivi: Premi `i` (modalità Insert).
3. Esci e Salva: Premi `Esc` poi scrivi `:wq` e premi Invio.
4. Esci senza salvare: Premi `Esc` poi scrivi `:q!` e premi Invio.

### 🌐 Rete Rapida
- `ip a` : Mostra il tuo indirizzo IP locale.
- `ping -c 4 google.com` : Controlla se internet risponde.
