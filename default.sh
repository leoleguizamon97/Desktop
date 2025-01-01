#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Por favor, ejecuta este script con sudo."
    exit 1
fi

sudo -u "$SUDO_USER" mkdir -p /home/$SUDO_USER/.config/sway
sudo -u "$SUDO_USER" mkdir -p /home/$SUDO_USER/Downloads
sudo -u "$SUDO_USER" mkdir -p /usr/local/share/fonts
# Instalación de paquetes necesarios
sudo -u "$SUDO_USER" apt install -y sway swaybg swayidle swaylock wofi brightnessctl pipewire playerctl firefox git
# sudo apt install -y yazi ffmpeg p7zip jq poppler fd ripgrep fzf zoxide imagemagick

# Descargar y descomprimir la fuente Nerd Font Hasklig
sudo -u "$SUDO_USER" cd /home/$USER_DIR/Downloads || exit
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hasklig.zip
sudo -u "$SUDO_USER" unzip -o Hasklig.zip -d /usr/local/share/fonts
fc-cache -fv

# Descargar configuración de sway
git clone https://github.com/leoleguizamon97/sway.git ~/.config/sway
