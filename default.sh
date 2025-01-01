#!/bin/bash

# Verificar si se ejecuta con sudo
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, ejecuta este script con sudo."
    exit 1
fi

# Crear directorios como usuario regular
sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/.config/sway
sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Downloads

# Crear el directorio de fuentes
mkdir -p /usr/local/share/fonts

# Instalación de paquetes necesarios

# Lista de paquetes a verificar
paquetes=(
    sway swaybg swayidle swaylock wofi brightnessctl pipewire playerctl firefox git
    #yazi ffmpeg p7zip jq poppler fd ripgrep fzf zoxide imagemagick
)
apt install -y sway swaybg swayidle swaylock wofi brightnessctl pipewire playerctl firefox git

# Función para verificar si un paquete está disponible en los repositorios
check_and_install() {
    if apt-cache policy "$1" | grep -q "Candidate:"; then
        echo "El paquete '$1' está disponible. Instalando..."
        apt install -y "$1"
    else
        echo "El paquete '$1' NO está disponible en los repositorios."
    fi
}

# Actualizar repositorios
echo "Actualizando lista de paquetes..."
apt update

# Verificar e instalar los paquetes disponibles
for paquete in "${paquetes[@]}"; do
    check_and_install "$paquete"
done


# Descargar y descomprimir la fuente Nerd Font Hasklig
cd /home/"$SUDO_USER"/Downloads || exit
sudo -u "$SUDO_USER" wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hasklig.zip
sudo unzip -o Hasklig.zip -d /usr/local/share/fonts
fc-cache -fv

# Descargar configuración de sway
sudo -u "$SUDO_USER" git clone https://github.com/leoleguizamon97/sway.git /home/"$SUDO_USER"/.config/sway
chmod -R 755 /usr/local/share/fonts

echo "Instalación completada correctamente."