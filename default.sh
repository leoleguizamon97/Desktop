#!/bin/bash

# Instalación de paquetes necesarios
sudo apt install -y sway swaybg swayidle swaylock wofi brightnessctl pipewire playerctl firefox
# sudo apt install -y yazi ffmpeg p7zip jq poppler fd ripgrep fzf zoxide imagemagick

# Descargar y descomprimir la fuente Nerd Font Hasklig
cd ~/Downloads || exit
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hasklig.zip
sudo unzip -o Hasklig.zip -d /usr/local/share/fonts
fc-cache -fv

# Descargar configuración de sway
git clone https://github.com/leoleguizamon97/sway.git ~/.config/sway
