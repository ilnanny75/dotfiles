#!/bin/bash
#==========================================================
#  O.S.      : Gnu Linux
#  Author    : Cristian Pozzessere (ilnanny)
#  D.A.Page  : http://ilnanny.deviantart.com
#  Github    : https://github.com/ilnanny75
#==========================================================

echo "1) Nuovo Repo  2) Commit/Push  3) Solo Status  4) Esci"
read -p "Scegli opzione: " OPT

case $OPT in
    1)
        read -p "Nome del Repo: " REPO
        git init
        git remote add origin "git@github.com:ilnanny75/$REPO.git"
        echo "Pronto per il primo push!"
        ;;
    2)
        git status
        read -p "Commento del Commit: " MSG
        git add .
        git commit -m "$MSG"
        git push origin main
        echo "Fatto! Ricordati di caricare anche su OpenDesktop/Pling!"
        ;;
    3) git status ;;
    *) exit ;;
esac
