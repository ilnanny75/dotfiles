#!/bin/bash
# Esempio di integrazione nello script
info "Installazione Tema Arc-Dark HiDPI..."
mkdir -p ~/.themes
curl -L https://github.com/loichu/arc-theme-xfwm4-hidpi/archive/refs/heads/master.tar.gz | tar xz -C ~/.themes/
echo "Tema HiDPI pronto in ~/.themes"
exit 0
