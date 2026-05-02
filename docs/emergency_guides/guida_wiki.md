# Setup Wiki Personale con Geany e Markdown

### 1. Installazione Requisiti
Installare Geany e il pacchetto plugin dedicato per la gestione dei progetti e del rendering Markdown.

* **Fedora:** `sudo dnf install geany geany-plugins-markdown geany-plugins-projectorganizer`
* **Debian:** `sudo apt install geany geany-plugin-markdown geany-plugin-projectorganizer`

### 2. Attivazione Plugin
1. Aprire Geany.
2. Navigare in **Strumenti** > **Gestore Plugin**.
3. Abilitare le seguenti voci:
    * **Markdown**: Per l'anteprima in tempo reale.
    * **Project Organizer**: Per la gestione della struttura a cartelle.

### 3. Creazione della Struttura Wiki
1. Andare su **Progetto** > **Nuovo**.
2. **Nome Progetto**: Inserire "Wiki".
3. **Nome file**: Selezionare la cartella principale dove risiederanno i file `.md`.
4. Nella barra laterale sinistra, selezionare la scheda **Progetti** per visualizzare l'albero dei file.

### 4. Gestione Contenuti e Anteprima
* **Creazione**: Salvare i nuovi file con estensione `.md` (es: `guida_bash.md`).
* **Visualizzazione**: Nel pannello inferiore (messaggi), cliccare sulla scheda **Markdown** per vedere il rendering del testo.
* **Sintassi Base**:
    * `# Titolo`
    * `## Sottotitolo`
    * `**Grassetto**`
    * `* Lista`
    * `` `codice` ``

### 5. Navigazione Rapida
* **Apertura file sotto cursore**: Per saltare da una guida all'altra citata nel testo, posizionare il cursore sul nome del file o sul percorso e premere `Ctrl + Shift + o`.
* **Ricerca Globale**: Premere `Ctrl + Shift + f` per cercare una stringa in tutta la cartella della Wiki.
* **Simboli**: Usare la scheda **Simboli** nella barra laterale per saltare rapidamente tra i vari titoli (`#`, `##`) del file aperto.

### 6. Ottimizzazione XFCE/Openbox
Per mantenere l'ambiente leggero:
* Disabilitare la barra degli strumenti (**Visualizza** > **Mostra Barra degli strumenti**).
* Utilizzare il terminale integrato (**Visualizza** > **Mostra Messaggi**) per testare gli script Bash senza uscire dall'editor.