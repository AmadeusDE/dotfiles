#!/bin/sh

#fixes shellcheck thinking i want to disable SC2046 for the entire file
echo
#intentional splitting
# shellcheck disable=SC2046
sudo pacman -Syu $(tr "\n" " " < packages)
shellcheck "$(realpath "$0")"
sudo chown root "$(realpath doas.conf)"
sudo ln -sf "$(realpath doas.conf)" /etc/doas.conf
# shellcheck disable=SC2046
yay -Syu $(tr "\n" " " < aurpackages)
# shellcheck disable=SC2046
flatpak install $(tr "\n" " " < flats)
# shellcheck disable=SC2046
doas pacman -Rns $(tr "\n" " " < rmpackages)
doas pacman -Syu doas-sudo-shim
doas usermod --shell /bin/zsh "$USER"
systemctl --use  enable pipewire pipewire-pulse wireplumber
doas systemctl enable sddm bluetooth
echo "After this you'll be asked what version to downgrade bluez too, if you want bluetooth to work use 5.68, press any key to continue"
#intentional dummy and -r doesn't matter because the var is never used
# shellcheck disable=SC2034,SC2162
read dummy
doas downgrade bluez bluez-libs
# shellcheck disable=SC2046
while [ $(pacman -Qtdg) ]; do pacman -Qtdq | xargs doas pacman -Rns --noconfirm; done
doas pacman -Scc
mkdir -p "$HOME"/.dotfiles/
ln -sf "$(realpath wallpaper.sh)" "$HOME"/.dotfiles/wallpaper.sh
go build screenshot.go util.go
ln -sf "$(realpath screenshot)" "$HOME"/.dotfiles/screenshot
go build help.go util.go gemini.go
ln -sf "$(realpath help)" "$HOME"/.dotfiles/help
touch tokens.json
ln -sf "$(realpath tokens.json)" "$HOME"/.dotfiles/tokens.json
ln -sf "$(realpath autostart.conf)" "$HOME"/.dotfiles/autostart.conf
ln -sf "$(realpath hypridle.conf)" "$HOME"/.dotfiles/hypridle.conf
ln -sf "$(realpath vars.conf)" "$HOME"/.dotfiles/vars.conf
ln -sf "$(realpath .Xresources)" "$HOME"/.Xresources
mkdir -p "$HOME"/.config/hypr
ln -sf "$(realpath hyprland.conf)" "$HOME"/.config/hypr/hyprland.conf
ln -sf "$(realpath hyprlock.conf)" "$HOME"/.config/hypr/hyprlock.conf
mkdir -p "$HOME"/.config/kitty
ln -sf "$(realpath kitty.conf)" "$HOME"/.config/kitty/kitty.conf
mkdir -p "$HOME"/.config/conky
ln -sf "$(realpath conky.conf)" "$HOME"/.config/conky/conky.conf
mkdir -p "$HOME"/.config/swappy
ln -sf "$(realpath swappy.conf)" "$HOME"/.config/swappy/config
mkdir -p "$HOME"/.config/btop
ln -sf "$(realpath btop.conf)" "$HOME"/.config/btop/btop.conf
mkdir -p "$HOME"/.config/fastfetch
ln -sf "$(realpath fastfetch.jsonc)" "$HOME"/.config/fastfetch/config.jsonc
mkdir -p "$HOME"/.config/lf
ln -sf "$(realpath lf/lfrc)" "$HOME"/.config/lf/lfrc
ln -sf "$(realpath lf/kitty_clean)" "$HOME"/.config/lf/kitty_clean
ln -sf "$(realpath lf/kitty_preview)" "$HOME"/.config/lf/kitty_preview
cp -r "$(realpath kitty-pistol-previewer/vidthumb)" "$HOME"/.config/lf/vidthumb
doas mkdir -p /usr/share/sddm/themes/simplicity
doas cp -r "$(realpath simplicity-sddm-theme/simplicity)" /usr/share/sddm/themes/
doas cp "$(realpath sddm-theme.conf)" /usr/share/sddm/themes/simplicity/theme.conf
curl https://i.redd.it/u4ke5ih893x61.png > lock.png
doas cp "$(realpath lock.png)" /usr/share/sddm/themes/simplicity/lock.png
rm lock.png
doas ln -sf "$(pwd)"/sddm.conf /etc/sddm.conf
mkdir -p "$HOME"/.config/pipewire
cp /usr/share/pipewire/pipewire.conf "$HOME"/.config/pipewire/pipewire.conf
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ln -sf "$(realpath .zshrc)" "$HOME"/.zshrc
curl https://raw.githubusercontent.com/sbugzu/gruvbox-zsh/ed9693db2f8ab064b70eb8932d067c1e0bab4a85/gruvbox.zsh-theme > ~/.oh-my-zsh/custom/themes/gruvbox.zsh-theme
# you can't double quote these
# shellcheck disable=SC2086
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# shellcheck disable=SC2086
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# shellcheck disable=SC2086
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
echo "Install complete, you should run"
echo "\"doas pacman -Syu lib32-vulkan-intel vulkan-intel\", for intel"
echo "\"doas pacman -Syu lib32-vulkan-radeon vulkan-radeon\", for amd"
echo "\"doas pacman -Syu lib32-nvidia-utils nvidia-utils\", for nvidia"
echo "press any key to continue"
#intentional dummy and -r doesn't matter because the var is never used
# shellcheck disable=SC2034,SC2162
read dummy
