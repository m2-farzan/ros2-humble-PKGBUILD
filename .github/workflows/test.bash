#!/bin/bash

set -e
cd /ros2-humble-pkgbuild
AUR_USER=ab
chown -R ${AUR_USER}:${AUR_USER} .

cmp -s .SRCINFO <(makepkg --printsrcinfo) || echo "SRCINFO is out of sync"

sudo pacman -Syyu --noconfirm --noprogressbar

cat .SRCINFO | grep -oP "depends\ \=\ \K.+" | xargs sudo -u ${AUR_USER} yay -S --noconfirm --noprogressbar --needed

sudo -u ${AUR_USER} makepkg
