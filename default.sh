#!/bin/bash

# Verificar si se ejecuta con sudo
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, ejecuta este script con sudo."
    exit 1
fi

echo "Elige el modo de instalación: "
echo -e "|\t _____________________________________ "
echo -e "|\t|                                     |"
echo -e "|\t| 1. Instalación completa DEBIAN      |"
echo -e "|\t| 2. Instalación completa ARCH        |"
echo -e "|\t| ------------------------------------|"
echo -e "|\t| 3. Actualizar Debian a 'testing'    |"
echo -e "|\t| 4. Actualizar configuracion de Sway |"
echo -e "|\t| 5. Salir                            |"
echo -e "|\t|_____________________________________|"

read -p "Opción: " opcion








echo "Este script migrará tu sistema Debian a la versión 'testing'."

# Confirmación del usuario
read -p "¿Estás seguro de que deseas continuar? (s/n): " respuesta
if [[ "$respuesta" != "s" && "$respuesta" != "S" ]]; then
    echo "Operación cancelada."
    exit 0
fi

# Hacer un respaldo del archivo sources.list
echo "Haciendo respaldo de /etc/apt/sources.list..."
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Configurar los repositorios para testing
echo "Configurando los repositorios para 'testing'..."
cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian testing main contrib non-free
deb-src http://deb.debian.org/debian testing main contrib non-free

deb http://security.debian.org/debian-security testing-security main contrib non-free
deb-src http://security.debian.org/debian-security testing-security main contrib non-free

deb http://deb.debian.org/debian testing-updates main contrib non-free
deb-src http://deb.debian.org/debian testing-updates main contrib non-free
EOF

sleep 5

# Actualizar lista de paquetes
echo "Actualizando la lista de paquetes..."
apt update

sleep 5

# Actualizar el sistema a testing
echo "Actualizando el sistema a 'testing'..."
apt full-upgrade -y

# Limpiar paquetes obsoletos
echo "Eliminando paquetes obsoletos..."
apt autoremove -y

echo "Migración a Debian 'testing' completada."
echo "Reinicia tu sistema para aplicar los cambios."

# Crear directorios como usuario regular
sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/.config/sway
sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Downloads

# Crear el directorio de fuentes
mkdir -p /usr/local/share/fonts

# Instalación de paquetes necesarios

# Lista de paquetes a verificar
paquetes=(
    sway swaybg swayidle swaylock wofi brightnessctl pipewire playerctl 
	firefox firefox-esr p7zip-full 
    #yazi ffmpeg p7zip jq poppler fd ripgrep fzf zoxide imagemagick
)

# Función para verificar si un paquete está disponible en los repositorios
check_and_install() {
    if apt-cache policy "$1" | grep -q "Candidate:"; then
        echo "El paquete '$1' está disponible. Instalando..."
		echo ""
		sleep 2
        apt install -y "$1"
    else
        echo "El paquete '$1' NO está disponible en los repositorios."
		sleep 5
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
sudo 7z x Hasklig.zip -o/usr/local/share/fonts
fc-cache -fv

# Descargar configuración de sway
sudo -u "$SUDO_USER" git clone https://github.com/leoleguizamon97/sway.git /home/"$SUDO_USER"/.config/sway
chmod -R 755 /usr/local/share/fonts

echo "Instalación completada correctamente."
echo "Reiniciando el sistema..."
for i in {5..1}; do
	echo -n "$i "
	sleep 1
done
reboot now