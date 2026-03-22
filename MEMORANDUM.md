# 📓 ILNANNY LAB 2026 - DIARIO DI BORDO

## ⚡ ALIAS DI SISTEMA (Scorciatoie veloci)
| Alias | Comando Reale | Cosa fa? |
| :--- | :--- | :--- |
| **dots** | `cd ~/dotfiles` | Salta istantaneamente nel tuo archivio Git |
| **gbin** | `cd ~/dotfiles/scripts/bin` | Vai dove tieni tutti i tuoi script attivi |
| **gy** | `geany` | Apre l'editor grafico Geany (es: `gy file.txt`) |
| **pigia** | `git add + commit + push` | **Il Re degli alias.** Salva tutto su GitHub in un colpo solo |

---

## 🎨 TOOLBOX DESIGNER (Gestione Icone e Temi)
| Comando | Utilizzo | Descrizione |
| :--- | :--- | :--- |
| **colorchange** | `colorchange #HEX1 #HEX2` | Cambia un colore a tutti gli SVG nella cartella |
| **crea-link** | `crea-link` | Genera i symlink per le icone (da finire di restaurare) |
| **crea-tema** | `crea-tema` | Crea la struttura cartelle standard Freedesktop |
| **optimize-svg**| `optimize-svg` | Pulisce il codice degli SVG e riduce il peso |
| **svg2png** | `svg2png file.svg 48` | Converte un SVG in PNG alla dimensione scelta |

---

## 🔍 UTILITY & DIAGNOSTICA
| Comando | Descrizione |
| :--- | :--- |
| **gtk-version** | Ti dice se il sistema usa GTK 2, 3 o 4 (fondamentale per i temi) |
| **mx-pulizia** | Aggiorna i repository e pulisce i pacchetti inutili |
| **searchscripts**| Cerca una parola o riga di codice dentro tutti i tuoi script |
| **usblist** | Elenca i dischi. Usa `sudo usblist usb` per vedere solo le pendrive |

---

## 🛠️ MANUTENZIONE LAB
* Per aggiungere un nuovo script: copialo in `~/dotfiles/scripts/bin/` e dai `chmod +x`.
* Per aggiungere un alias: modifica `/etc/bash/bashrc.d/ilnanny_2026.sh`.
* Dopo ogni modifica importante: **PIGIA!**
