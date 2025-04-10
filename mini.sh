 #!/bin/bash
set -e

echo "Actualizando sistema..."
sudo dnf update -y

# 1. Eliminar paquetes
echo "Eliminando paquetes no deseados..."
sudo dnf remove -y vim-minimal nano

# 2. Instalar paquetes
echo "Instalando paquetes necesarios..."
sudo dnf install -y sway swaybg swaylock swayidle wofi brightnessctl pipewire micro btop p7zip

# 3. Clonar repositorios Git
echo "Clonando repositorios..."
git clone https://github.com/leoleguizamon97/Desktop"

mkdir -p ~/.config
git clone https://github.com/leoleguizamon97/sway ~/.config/"

# 4. Instalar fuentes
echo "Instalando fuentes Nerd Font (Hack)..."
mkdir -p ~/.local/share/fonts
curl -Lo /tmp/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip
unzip -o /tmp/Hack.zip -d ~/.local/share/fonts/
fc-cache -vf ~/.local/share/fonts/

# 5. Instalar VSCode
echo "Agregando repositorio e instalando VSCode..."

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

sudo dnf check-update
sudo dnf install -y code

echo "Listo!"
