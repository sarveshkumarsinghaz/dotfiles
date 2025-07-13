#!/bin/bash

set -e

echo "Starting Hyprland and dotfiles installation..."

# Check if yay is already installed
if ! command -v yay &>/dev/null; then
  echo "yay not found, installing yay (AUR helper)..."
  git clone https://aur.archlinux.org/yay ~yay
  cd ~/yay
  # Check if cloning was successful
  if [ ! -d "yay" ]; then
    echo "Error: 'yay' directory not found after cloning. Exiting."
    exit 1
  fi
  cd yay
  echo "Building and installing yay..."
  makepkg -si --noconfirm # --noconfirm to bypass prompts
  rm -rf ~/yay
else
  echo "yay is already installed, skipping installation."
fi

# --- Install Hyprland and other packages ---
echo "Installing Hyprland and other dependencies via yay..."
yay -S --needed --noconfirm \
  ttf-jetbrains-mono-nerd \
  hyprland \
  hyprlock \
  hypridle \
  neovim \
  papirus-icon-theme \
  bibata-cursor-theme \
  stow \
  fzf \
  kitty \
  fish \
  mako \
  tmux \
  yazi \
  wofi \
  wiremix \
  bluetui \
  calcure \
  waybar


cd ~/hyprdots
echo "applying dotfiles..."

stow wofi/
stow waybar/
stow gtk-4.0/
stow gtk-3.0/
stow yazi/
stow mako/
stow background/
stow nvim/
stow hypr/
stow icons/
stow fish/
stow kitty/

echo "setting cursor and icon-theme......"
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface cursor-size 24
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'
gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-d %s'
echo "Installation complete! You may need to reboot or log out and back in for changes to take effect."
