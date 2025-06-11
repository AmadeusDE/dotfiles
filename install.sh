#!/bin/sh

#intentional splitting
# shellcheck disable=SC2046
sudo pacman -Syu $(tr "\n" " " < packages)
shellcheck "$(realpath "$0")"
sudo chown root "$(realpath doas.conf)"
sudo ln -sf "$(realpath doas.conf)" /etc/doas.conf
yay -Syu $(tr "\n" " " < aurpackages)
flatpak install $(tr "\n" " " < flats)
doas pacman -Rns $(tr "\n" " " < rmpackages)
doas pacman -Syu doas-sudo-shim
doas usermod --shell /bin/zsh "$USER"
doas systemctl enable sddm.service
echo "After this you'll be asked what version to downgrade bluez too, if you want bluetooth to work use 5.68, press any key to continue"
#intentional dummy and -r doesn't matter because the var is never used
# shellcheck disable=SC2034,SC2162
read dummy
doas downgrade bluez bluez-libs
mkdir -p "$HOME"/.dotfiles/
ln -sf "$(realpath wallpaper.sh)" "$HOME"/.dotfiles/wallpaper.sh
ln -sf "$(realpath autostart.conf)" "$HOME"/.dotfiles/autostart.conf
ln -sf "$(realpath hypridle.conf)" "$HOME"/.dotfiles/hypridle.conf
ln -sf "$(realpath vars.conf)" "$HOME"/.dotfiles/vars.conf
mkdir -p "$HOME"/.config/hypr
ln -sf "$(realpath hyprland.conf)" "$HOME"/.config/hypr/hyprland.conf
ln -sf "$(realpath hyprlock.conf)" "$HOME"/.config/hypr/hyprlock.conf
mkdir -p "$HOME"/.config/kitty
ln -sf "$(realpath kitty.conf)" "$HOME"/.config/kitty/kitty.conf
mkdir -p "$HOME"/.config/conky
ln -sf "$(realpath conky.conf)" "$HOME"/.config/conky/conky.conf
mkdir -p "$HOME"/.config/btio
ln -sf "$(realpath btop.conf)" "$HOME"/.config/btop/btop.conf
mkdir -p "$HOME"/.config/fastfetch
ln -sf "$(realpath fastfetch.jsonc)" "$HOME"/.config/fastfetch/config.jsonc
mkdir -p "$HOME"/.config/lf
ln -sf "$(realpath lf/lfrc)" "$HOME"/.config/lf/lfrc
ln -sf "$(realpath lf/kitty_clean)" "$HOME"/.config/lf/kitty_clean
ln -sf "$(realpath lf/kitty_preview)" "$HOME"/.config/lf/kitty_preview
cp -r "$(realpath kitty-pistol-previewer/vidthumb)" "$HOME"/.config/lf/vidthumb
doas mkdir -p /usr/share/sddm/themes/simplicity
doas cp -r "$(realpath simplicity-sddm-theme/simplicity)" /usr/share/sddm/themes/simplicity
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
