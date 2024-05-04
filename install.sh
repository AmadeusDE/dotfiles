#!/bin/sh

#intentional splitting
# shellcheck disable=SC2046
sudo pacman -Syu $(tr "\n" " " < packages)
shellcheck "$(realpath "$0")"
sudo chown root "$(realpath doas.conf)"
sudo ln -sf "$(realpath doas.conf)" /etc/doas.conf
yay -Syu $(tr "\n" " " < aurpackages)
flatpak install $(tr "\n" " " < flats)
doas pacman -Rns sudo
doas pacman -Syu doas-sudo-shim
doas usermod --shell /bin/zsh "$USER"
echo "After this you'll be asked what version to downgrade bluez too, if you want bluetooth to work use 5.68, press any key to continue"
#intentional dummy and -r doesn't matter because the var is never used
# shellcheck disable=SC2034,SC2162
read dummy
doas downgrade bluez bluez-libs
ln -sf "$(realpath wallpaper.sh)" "$HOME"/.dotfiles/wallpaper.sh
ln -sf "$(realpath autostart.conf)" "$HOME"/.dotfiles/autostart.conf
ln -sf "$(realpath hypridle.conf)" "$HOME"/.dotfiles/hypridle.conf
ln -sf "$(realpath vars.conf)" "$HOME"/.dotfiles/vars.conf
ln -sf "$(realpath hyprland.conf)" "$HOME"/.config/hypr/hyprland.conf
ln -sf "$(realpath hyprlock.conf)" "$HOME"/.config/hypr/hyprlock.conf
ln -sf "$(realpath kitty.conf)" "$HOME"/.config/kitty/kitty.conf
ln -sf "$(realpath conky.conf)" "$HOME"/.config/conky/conky.conf
ln -sf "$(realpath .zshrc)" "$HOME"/.zshrc
ln -sf "$(realpath btop.conf)" "$HOME"/.config/btop/btop.conf
ln -sf "$(realpath fastfetch.jsonc)" "$HOME"/.config/fastfetch/config.jsonc
doas cp -r "$(realpath simplicity-sddm-theme/simplicity)" /usr/share/sddm/themes/simplicity
doas cp "$(realpath sddm-theme.conf)" /usr/share/sddm/themes/simplicity/theme.conf.user
doas ln -sf "$(pwd)"/sddm.conf /etc/sddm.conf
cp /usr/share/pipewire/pipewire.conf .config/pipewire/pipewire.conf
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl https://raw.githubusercontent.com/sbugzu/gruvbox-zsh/ed9693db2f8ab064b70eb8932d067c1e0bab4a85/gruvbox.zsh-theme > ~/.oh-my-zsh/custom/themes/gruvbox.zsh-theme
# you can't double quote these
# shellcheck disable=SC2086
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# shellcheck disable=SC2086
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# shellcheck disable=SC2086
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete