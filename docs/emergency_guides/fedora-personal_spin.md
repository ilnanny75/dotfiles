#  Guida Fedora spin ilNanny-Rescue

Questa guida riassume i passaggi per generare la ISO Live personalizzata su Fedora,
evitando i blocchi comuni riscontrati durante lo sviluppo .

---

## 1. Prerequisiti di sistema Sull'Host
Assicurarsi che il sistema che compila abbia i seguenti pacchetti:

COMANDO: sudo dnf install lorax livemedia-creator xorriso grub2-pc-modules grub2-pc

---

## 2. Configurazione kickstart .ks
Il file "ilnanny-fedora.ks" deve contenere queste righe nella sezione %packages.
Onde evitare Errore xorriso status 5.

Lista pacchetti obbligatori:
%packages
grub2-pc
grub2-pc-modules
grub2-efi-x64-cdboot
shim-x64
@core
%end

---

##  3. Il comando da lanciare in ~/CreaSpin
Copia ed esegui questo blocco per pulire i vecchi tentativi e avviare la build:

# Pulizia profonda Mount, Loop e Temp
sudo umount -l ./lmc-temp/* 2>/dev/null
sudo losetup -D
sudo rm -rf ./iso-output ./lmc-temp /tmp/lmc-* && mkdir -p ./lmc-temp

# Avvio creazione ISO
sudo systemd-inhibit --why="Building ISO" --who="ilnanny" --mode=block \
livemedia-creator --make-iso \
  --ks ilnanny-fedora.ks \
  --no-virt \
  --project "ilNanny-Rescue" \
  --releasever 43 \
  --volid ilNanny-Rescue-v2.6 \
  --resultdir ./iso-output \
  --tmp ./lmc-temp \
  --location https://mirror.garr.it/fedora/linux/releases/43/Everything/x86_64/os/ \
  --live-rootfs-size 8

---

## 4. Monitorare log live
Mentre il comando sopra gira, apri un altro terminale e usa questi:

A) Vedere cosa sta facendo Lorax ESATTAMENTE:
   tail -f ~/CreaSpin/livemedia.log

B) Vedere se il file SquashFS sta crescendo (se i MB aumentano, sta lavorando):
   watch -n 10 "du -sh ./lmc-temp"

---

##  5. Note tecniche e errori comuni
- Ventole calde: Normale, sta comprimendo lo SquashFS.
- Terminale "appeso": Se i log (punto 4A) si fermano e non ci sono ventole, è crashato.
- Disco Esterno: Molto lento in scrittura, abbi pazienza nella fase finale.

---

##  6. Aggiornamento a Fedora 44 (E future)
Quando uscirà Fedora 44, modifica solo due parametri nel comando di lancio:
1. Cambia --releasever 43 in --releasever 44
2. Cambia l'URL della --location sostituendo il numero 43 con 44.

---

##  7.  ISO Finale
A fine processo quando torna il prompt dei comandi, la ISO sarà qui:
~/CreaSpin/iso-output/images/boot.iso
