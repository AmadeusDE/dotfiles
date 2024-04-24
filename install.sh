#!/bin/sh

sudo pacman -Syu $(cat packages | tr "\n" " ")
sudo chown root "$(pwd)"/doas.conf
sudo ln -sf "$(pwd)"/doas.conf /etc/doas.conf
doas pacman -Rns sudo
doas pacman -Syu doas-sudo-shim
ln -sf "$(pwd)"/wallpaper.sh "$HOME"/.dotfiles/wallpaper.sh
ln -sf "$(pwd)"/autostart.conf "$HOME"/.dotfiles/autostart.conf
ln -sf "$(pwd)"/hypridle.conf "$HOME"/.dotfiles/hypridle.conf
ln -sf "$(pwd)"/vars.conf "$HOME"/.dotfiles/vars.conf
ln -sf "$(pwd)"/hyprland.conf "$HOME"/.config/hypr/hyprland.conf
ln -sf "$(pwd)"/hyprlock.conf "$HOME"/.config/hypr/hyprlock.conf
ln -sf "$(pwd)"/kitty.conf "$HOME"/.config/kitty/kitty.conf
ln -sf "$(pwd)"/conky.conf "$HOME"/.config/conky/conky.conf
doas ln -sf "$(pwd)"/sddm.conf /etc/sddm.conf