#!/bin/bash

set -e
cd /ros2-humble-pkgbuild
AUR_USER=ab
chown -R ${AUR_USER}:${AUR_USER} .

sudo pacman -Syyu --noconfirm --noprogressbar

# Temporary fix (https://github.com/m2-farzan/ros2-galactic-PKGBUILD/issues/9)
pacman -S wget python-pip python-pyqt5 --noconfirm --noprogressbar
pip3 install pyqt5==5.15.5

cat .SRCINFO | grep -oP "depends\ \=\ \K.+" | xargs sudo -u ${AUR_USER} yay -S --noconfirm --noprogressbar --needed

sudo -u ${AUR_USER} makepkg
