#!/usr/bin/env python3
"""
================================================================================
PROGETTO: Gemini Terminal Tool Linux
VERSIONE: 3.0
DESCRIZIONE: Assistente interattivo basato su AI per terminale Linux.
             Supporta Arch, Debian e Void. Gestisce dipendenze, sessioni
             e integrazione con Geany.
AUTORE: Cristian Pozzessere (ilnanny) 
URL GITHUB: https://github.com/ilnanny75
LICENZA: MIT
DIPENDENZE: google-generativeai
================================================================================
"""

import os
import json
import subprocess
import sys
import shutil
from datetime import datetime

# --- CONFIGURAZIONE PERCORSI ---
SAVE_DIR = os.path.expanduser("~/.gemini_chats")
if not os.path.exists(SAVE_DIR):
    os.makedirs(SAVE_DIR)

def log(message, status="info"):
    """Stampa messaggi di log colorati per l'utente."""
    colors = {
        "info": "\033[94m[*]\033[0m", 
        "ok": "\033[92m[V]\033[0m", 
        "error": "\033[91m[X]\033[0m", 
        "wait": "\033[93m[...]\033[0m"
    }
    print(f"{colors.get(status, '[*]')} {message}")

def check_distro():
    """Rileva la distribuzione Linux in uso."""
    if os.path.exists("/etc/arch-release"): return "arch"
    if os.path.exists("/etc/debian_version"): return "debian"
    if os.path.exists("/etc/void-release"): return "void"
    return "linux-generic"

def install_dependencies():
    """Verifica e installa automaticamente le librerie mancanti."""
    distro = check_distro()
    try:
        import google.generativeai
        import rich
    except ImportError:
        log(f"Sistema {distro.upper()} rilevato. Configurazione ambiente...", "wait")
        
        # Installazione PIP se manca tramite gestore pacchetti di sistema
        if not shutil.which("pip"):
            log("Installazione di pip in corso...", "wait")
            if distro == "arch": 
                subprocess.run(["sudo", "pacman", "-S", "--noconfirm", "python-pip"])
            elif distro == "debian": 
                subprocess.run(["sudo", "apt", "update"])
                subprocess.run(["sudo", "apt", "install", "-y", "python3-pip"])
            elif distro == "void": 
                subprocess.run(["sudo", "xbps-install", "-Sy", "python3-pip"])

        # Installazione librerie Python necessarie (bypassando PEP 668)
        subprocess.run([sys.executable, "-m", "pip", "install", "--user", "google-generativeai", "rich", "--break-system-packages"])
        log("Librerie installate con successo. Riavvio dello script...", "ok")
        os.execv(sys.executable, ['python3'] + sys.argv)

def mostra_help(console):
    """Mostra la guida ai comandi e i suggerimenti per Geany."""
    from rich.table import Table
    from rich.panel import Panel

    table = Table(title="🛠️ GUIDA COMANDI GEMINI-CLI", show_header=True, header_style="bold magenta")
    table.add_column("Comando", style="cyan")
    table.add_column("Descrizione", style="white")

    table.add_row("help", "Mostra questa tabella con i comandi disponibili.")
    table.add_row("salva", "Esporta la conversazione in ~/.gemini_chats/ (JSON).")
    table.add_row("clear", "Pulisce lo schermo del terminale (comando 'clear' di Linux).")
    table.add_row("esci", "Termina la sessione e chiude lo script.")
    
    console.print(table)
    
    geany_tips = (
        "[bold yellow]INTEGRAZIONE GEANY:[/bold yellow]\n"
        "1. Apri Geany -> Strumenti -> Invia selezione a -> Imposta comandi personalizzati.\n"
        "2. Clicca 'Aggiungi' e inserisci questo comando:\n"
        "   [italic]xfce4-terminal -e \"python3 " + os.path.abspath(__file__) + "\"[/italic]\n"
        "3. Seleziona il codice in Geany e usa il comando per passarlo a Gemini!"
    )
    console.print(Panel(geany_tips, title="Suggerimento Geany IDE", border_style="green"))

def salva_sessione(history):
    """Salva la cronologia della chat in un file JSON."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filepath = os.path.join(SAVE_DIR, f"chat_{timestamp}.json")
    
    serializable = []
    for msg in history:
        serializable.append({"role": msg.role, "parts": [msg.parts[0].text]})
    
    with open(filepath, "w") as f:
        json.dump(serializable, f, indent=4)
    return filepath

def carica_sessione():
    """Carica una sessione precedente dall'elenco dei file salvati."""
    files = sorted([f for f in os.listdir(SAVE_DIR) if f.endswith('.json')], reverse=True)
    if not files:
        print("Nessun salvataggio trovato nella cartella ~/.gemini_chats/")
        return []
    
    print("\nUltime sessioni salvate:")
    for i, f in enumerate(files[:5]):
        print(f"[{i}] {f}")
    
    scelta = input("\nInserisci il numero (o Invio per nuova chat): ")
    if scelta.isdigit() and int(scelta) < len(files):
        with open(os.path.join(SAVE_DIR, files[int(scelta)]), "r") as f:
            log(f"Caricamento sessione: {files[int(scelta)]}", "ok")
            return json.load(f)
    return []

def start_chat(api_key):
    """Avvia il ciclo principale della chat interattiva."""
    import google.generativeai as genai
    from rich.console import Console
    from rich.markdown import Markdown

    console = Console()
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('gemini-1.5-flash')
    
    console.print("\n[bold cyan]1.[/bold cyan] Nuova Sessione | [bold cyan]2.[/bold cyan] Carica Sessione")
    scelta = input("Scegli un'opzione: ")
    
    history = carica_sessione() if scelta == "2" else []
    chat = model.start_chat(history=history)

    os.system('clear')
    console.print(f"[bold blue]🤖 Gemini CLI - Sistema {check_distro().upper()} Pronto[/bold blue]")
    console.print("[dim]Digita 'help' per la guida o 'esci' per terminare[/dim]\n")

    while True:
        try:
            user_input = console.input("[bold green]Tu ❯ [/bold green]").strip()
            
            if not user_input: continue
            if user_input.lower() in ["esci", "exit", "quit"]: break
            if user_input.lower() == "help":
                mostra_help(console)
                continue
            if user_input.lower() == "salva":
                path = salva_sessione(chat.history)
                console.print(f"[bold green]✔ Chat salvata correttamente in:[/bold green]\n{path}")
                continue
            if user_input.lower() == "clear":
                os.system('clear')
                continue

            with console.status("[bold yellow]Gemini sta elaborando..."):
                response = chat.send_message(user_input)
            
            console.print(Markdown("---"))
            console.print(Markdown(response.text))
            console.print(Markdown("---"))

        except Exception as e:
            console.print(f"[bold red]Errore durante la comunicazione:[/bold red] {e}")

if __name__ == "__main__":
    # 1. Verifica e installa dipendenze
    install_dependencies()
    
    # 2. Gestione Chiave API (Ambiente o Input)
    key = os.getenv("GEMINI_API_KEY")
    if not key:
        log("Variabile d'ambiente GEMINI_API_KEY non trovata.", "info")
        key = input("Incolla qui la tua API Key: ").strip()
    
    # 3. Avvio
    if key:
        start_chat(key)
    else:
        log("Impossibile procedere senza API Key. Uscita.", "error")
