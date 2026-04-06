#!/usr/bin/env python3
"""
================================================================================
PROGETTO: Gemini Terminal Tool Linux
VERSIONE: 3.2 (Auto-Update Model)
DESCRIZIONE: Assistente interattivo basato su AI per terminale Linux.
             Supporta Arch, Debian e Void.
AUTORE: Cristian Pozzessere (ilnanny) 
GitHub: https://github.com/ilnanny75
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
    colors = {"info": "\033[94m[*]\033[0m", "ok": "\033[92m[V]\033[0m", "error": "\033[91m[X]\033[0m", "wait": "\033[93m[...]\033[0m"}
    print(f"{colors.get(status, '[*]')} {message}")

def check_distro():
    if os.path.exists("/etc/arch-release"): return "arch"
    if os.path.exists("/etc/debian_version"): return "debian"
    if os.path.exists("/etc/void-release"): return "void"
    return "linux-generic"

def install_dependencies():
    distro = check_distro()
    try:
        import google.generativeai
        import rich
    except ImportError:
        log(f"Sistema {distro.upper()} rilevato. Configurazione ambiente...", "wait")
        if not shutil.which("pip"):
            if distro == "arch": subprocess.run(["sudo", "pacman", "-S", "--noconfirm", "python-pip"])
            elif distro == "debian": subprocess.run(["sudo", "apt", "update"]); subprocess.run(["sudo", "apt", "install", "-y", "python3-pip"])
            elif distro == "void": subprocess.run(["sudo", "xbps-install", "-Sy", "python3-pip"])
        subprocess.run([sys.executable, "-m", "pip", "install", "--user", "google-generativeai", "rich", "--break-system-packages"])
        os.execv(sys.executable, ['python3'] + sys.argv)

def mostra_help(console):
    from rich.table import Table
    from rich.panel import Panel
    table = Table(title="🛠️ GUIDA COMANDI GEMINI-CLI", show_header=True, header_style="bold magenta")
    table.add_column("Comando", style="cyan"); table.add_column("Descrizione", style="white")
    table.add_row("help", "Mostra questa guida."); table.add_row("salva", "Esporta chat in JSON."); table.add_row("clear", "Pulisce lo schermo."); table.add_row("esci", "Chiude lo script.")
    console.print(table)
    geany_tips = "[bold yellow]INTEGRAZIONE GEANY:[/bold yellow]\n1. Strumenti -> Invia selezione a -> Comandi personalizzati.\n2. Aggiungi: [italic]xfce4-terminal -e \"python3 " + os.path.abspath(__file__) + "\"[/italic]"
    console.print(Panel(geany_tips, title="Suggerimento Geany", border_style="green"))

def salva_sessione(history):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filepath = os.path.join(SAVE_DIR, f"chat_{timestamp}.json")
    serializable = [{"role": msg.role, "parts": [msg.parts[0].text]} for msg in history]
    with open(filepath, "w") as f: json.dump(serializable, f, indent=4)
    return filepath

def carica_sessione():
    files = sorted([f for f in os.listdir(SAVE_DIR) if f.endswith('.json')], reverse=True)
    if not files: return []
    print("\nUltime sessioni:"); [print(f"[{i}] {f}") for i, f in enumerate(files[:5])]
    scelta = input("\nNumero sessione (o Invio per nuova): ")
    if scelta.isdigit() and int(scelta) < len(files):
        with open(os.path.join(SAVE_DIR, files[int(scelta)]), "r") as f: return json.load(f)
    return []

def start_chat(api_key):
    import google.generativeai as genai
    from rich.console import Console
    from rich.markdown import Markdown
    console = Console()
    genai.configure(api_key=api_key)
    
    # : IL MODELLO SI AGGIORNA DA SOLO 
    model = genai.GenerativeModel('gemini-flash-latest')
    
    console.print("\n[bold cyan]1.[/bold cyan] Nuova Sessione | [bold cyan]2.[/bold cyan] Carica Sessione")
    scelta = input("Scegli: ")
    history = carica_sessione() if scelta == "2" else []
    chat = model.start_chat(history=history)
    os.system('clear')
    console.print(f"[bold blue]🤖 Gemini CLI Pronto (Modello: Flash-Latest)[/bold blue]\n")

    while True:
        try:
            user_input = console.input("[bold green]Tu ❯ [/bold green]").strip()
            if not user_input: continue
            if user_input.lower() in ["esci", "exit", "quit"]: break
            if user_input.lower() == "help": mostra_help(console); continue
            if user_input.lower() == "salva": console.print(f"✔ Salvato in: {salva_sessione(chat.history)}"); continue
            if user_input.lower() == "clear": os.system('clear'); continue
            with console.status("[bold yellow]Gemini sta elaborando..."):
                response = chat.send_message(user_input)
            console.print(Markdown("---")); console.print(Markdown(response.text)); console.print(Markdown("---"))
        except Exception as e: console.print(f"[bold red]Errore:[/bold red] {e}")

if __name__ == "__main__":
    install_dependencies()
    key = os.getenv("GEMINI_API_KEY")
    if not key: key = input("Incolla API Key: ").strip()
    if key: start_chat(key)
