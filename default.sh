#!/bin/bash
set -e

deb_file(){
# Configurar los repositorios para testing
echo -e "Configurando los repositorios para 'testing'..."

cat <<EOF >/etc/apt/sources.list
deb http://deb.debian.org/debian testing main contrib non-free
deb-src http://deb.debian.org/debian testing main contrib non-free

deb http://security.debian.org/debian-security testing-security main contrib non-free
deb-src http://security.debian.org/debian-security testing-security main contrib non-free

deb http://deb.debian.org/debian testing-updates main contrib non-free
deb-src http://deb.debian.org/debian testing-updates main contrib non-free
EOF
}

### VARIABLES ###

	TAB='$\t'
	TAB_SIZE='\t'
	TITLE="Instalador de Sway"
	MSG=" ¡Hola mundo! "
	DISTRO=""
	# Lista de paquetes a verificar
	deb_paquetes=(
		 sway
		swaybg
		swayidle
		swaylock
		wofi
		brightnessctl
		pipewire
		playerctl
		firefox-esr
		p7zip-full
		thunar
	)
	arch_paquetes=(
		sway
		swaybg
		swayidle
		swaylock
		wofi
		brightnessctl
		pipewire
		playerctl
		firefox
		p7zip
		yazi
		ffmpeg
		p7zip
		jq
		poppler
		fd
		ripgrep
		fzf
		zoxide
		imagemagick
	)
### Funciones TERMINADAS ###
	ver_sudo() {
		if [ "$EUID" -ne 0 ]; then
			clear
			printf "\t\n"
			printf "\t╔═══════════════════════════════════════════╗\n"
			printf "\t║                                           ║\n"
			printf "\t║ Por favor, ejecuta este script con $ sudo ║\n"
			printf "\t║                                           ║\n"
			printf "\t╚═══════════════════════════════════════════╝\n"
			printf "\t\n"
			exit 1
		fi
	}

	spinner() {
		local pid=$1
		local delay=0.1
		local spinstr='|/-\'
		printf "\n"
		while kill -0 "$pid" 2>/dev/null; do
			for ((i=0; i<${#spinstr}; i++)); do
				printf "\033[F\033[2K"							#Vuelve a linea anterior y limpia
				printf "\r║ %.30s %$((48 > ${#2} ? 43 - ${#2} : 3))s [%s] ║\n" "$2" "" "${spinstr:i:1}"
				draw_footer
				sleep "$delay"
			done
		done
		printf "\033[F\033[2K"
		printf "║ %50s ║\n\n" " [✔] Listo"
	}

	draw_footer(){
		printf "╚" && printf "═%.0s" {1..34} && printf "leoleguizamon97═╝"
	}


### FUNCIONES ###


	reiniciar(){
		MSG="Reinicio"
		printf "║      Reiniciando el sistema en: "
		for i in {5..1}; do
			printf " $i! "
			sleep 1
		done
		printf "\n Bye! \n\n"
		sleep 2
		reboot now
	}

	actualizar_debian() {

		printf "║      Este script migrará tu sistema Debian a la versión 'testing'."
		read -p "║$TAB ¿Estás seguro de que deseas continuar? (s/n): " respuesta
		
		if [[ "$respuesta" != "s" && "$respuesta" != "S" ]]; then
			echo -e "║      Operación cancelada."
			return 1
		fi

		# Hacer un respaldo del archivo sources.list
		echo -e "║      Haciendo respaldo de /etc/apt/sources.list..."
		cp /etc/apt/sources.list /etc/apt/sources.list.bak > /dev/null

		deb_file

		echo -e "║      Repositorios configurados correctamente."
		
		# Actualizar lista de paquetes
		echo -e "║      Actualizando la lista de paquetes..."
		apt update & > /dev/null
		pid=$!
		clear
		spinner "$pid"

		# Actualizar lista de paquetes
		echo -e "║      Actualizando la lista de paquetes..."
		apt update > /dev/null

		# Actualizar el sistema a testing
		echo -e "║      Actualizando el sistema a 'testing'..."
		apt full-upgrade -y

		# Limpiar paquetes obsoletos
		echo -e "║      Eliminando paquetes obsoletos..."
		apt autoremove -y

		echo -e "║      Migración a Debian 'testing' completada."
		echo -e "║      Reinicia tu sistema para aplicar los cambios."

	}

	mk_directorios(){
		# Crear directorios como usuario regular
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/.config/sway > /dev/null
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Downloads > /dev/null
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Desktop > /dev/null
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Documents > /dev/null
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Music > /dev/null
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Pictures > /dev/null
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Videos > /dev/null

		# Crear el directorio de fuentes
		mkdir -p /usr/local/share/fonts
	}

	sway_deb_install(){
		# Función para verificar si un paquete está disponible en los repositorios
		check_and_install() {
			if apt-cache policy "$1" | grep -q "Candidate:"; then
				echo -e "║      El paquete '$1' está disponible. Instalando..."
				echo -e "║      "
				sleep 2
				apt install -y "$1" > /dev/null
			else
				echo -e "║      El paquete '$1' NO está disponible en los repositorios."
				sleep 5
			fi
		}

		# Actualizar repositorios
		echo -e "║      Actualizando lista de paquetes..."
		apt update

		# Verificar e instalar los paquetes disponibles
		for paquete in "${deb_paquetes[@]}"; do
			check_and_install "$paquete"
		done

		# Descargar configuración de sway
		echo -e "║      Descargando configuración de Sway..."
		sudo -u "$SUDO_USER" git clone https://github.com/leoleguizamon97/sway.git /home/"$SUDO_USER"/.config/sway > /dev/null
		echo -e "║      Instalación completada correctamente."

		sleep 5

	}

	#sway_arch_install(){}
	
	#swat_ubunt_install(){}

	fonts_install(){
		# Verificar 7z
		if [ "$DISTRO" == "debian" ]; then
			echo -e "║      Instalando p7zip-full en Debian..."
			apt install -y p7zip-full > /dev/null 2>&1 &
			pid=$!
			spinner "$pid" "Instalando p7zip-full"

		elif [ "$DISTRO" == "arch" ]; then
			echo -e "║      Instalando p7zip en Arch..."
			pacman -S p7zip > /dev/null 2>&1 &
			pid=$!
			spinner "$pid" "Instalando p7zip-full"

		elif [ "$DISTRO" == "ubuntu" ]; then
			echo -e "║      Instalando p7zip-full en Ubuntu..."
			apt install -y p7zip-full > /dev/null 2>&1 &
			pid=$!
			spinner "$pid" "Instalando p7zip-full"
		fi
		# Descargar y descomprimir la fuente Nerd Font Hasklig
		cd /home/"$SUDO_USER"/Downloads
		sudo -u "$SUDO_USER" wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hasklig.zip > /dev/null 2>&1 &
			pid=$!
			spinner "$pid" "Descargando Nerdfont Hasklig"
		sudo 7z x Hasklig.zip -o/usr/local/share/fonts > /dev/null 2>&1 &
			pid=$!
			spinner "$pid" "Descomprimiendo Nerdfont Hasklig"
		fc-cache -fv > /dev/null 2>&1 &
			# Spinner
			pid=$!
			spinner "$pid" "Actualizando caché de fuentes"
		chmod -R 755 /usr/local/share/fonts > /dev/null
		MSG="Fuentes instaladas correctamente."
		sleep 30
	}

	ver_distro(){
		if [ -f /etc/debian_version ]; then
			DISTRO="debian"
		elif [ -f /etc/arch-release ]; then
			DISTRO="arch"
		# ubuntu
		elif [ -f /etc/lsb-release ]; then
			DISTRO="ubuntu"
		else
			echo -e "║      No se pudo determinar la distribución."
			return 1
		fi
		echo -e "║      Distribución detectada: $DISTRO"
		return 0
		sleep 2
	}



	draw_header(){
		clear
		ancho=30
		largoTitulo=0
		
		if [[ ${#TITLE}%2 == 0 ]]; then
			largoTitulo=${#TITLE}
		else
			largoTitulo=${#TITLE}+1
		fi

		borde=$(( ($ancho - $largoTitulo) / 2 ))
		
		centro=""
		for i in $(seq 1 $borde); do
			centro+=" "
		done
		centro+="$TITLE"
		for i in $(seq 1 $borde); do
			centro+=" "
		done

		printf "╔" && printf "═%.0s" {1..10} && printf "%.30s" "$centro" && printf "═%.0s" {1..10} && printf "╗\n"
		printf "║" && printf "%50s" && printf "║\n"
		
		
	}

	# Ciclo principal
	main(){
		draw_header
		while [ true ]; do
			echo -e "║      Elige el modo de instalación: "
			echo -e "║" 
			echo -e "║     ╔═════════════════════════════════════╗"
			echo -e "║     ║                                     ║"
			echo -e "║     ║ 1. Instalación completa             ║"
			echo -e "║     ║ ------------------------------------║"
			echo -e "║     ║ 2. Actualizar configuracion de Sway ║"
			echo -e "║     ║ 3. Instalación de fuentes           ║"
			echo -e "║     ║ 8. Actualizar Debian a 'testing'    ║"
			echo -e "║     ║ 9. Reiniciar el sistema             ║"
			echo -e "║     ║ 0. Salir                            ║"
			echo -e "║     ║                                     ║"
			echo -e "║     ╚═════════════════════════════════════╝"
			echo -e "║     "
			echo -e "║      Sisema detectado: $DISTRO"
			echo -e "║     "
			read -p "║     Selecciona opcion: " opcion 
			draw_footer

			if [ "$opcion" == "1" ]; then
				clear
				MSG="Instalación completa DEBIAN"
				sleep 3
				actualizar_debian
			elif [ "$opcion" == "2" ]; then
				clear
				MSG="Instalación completa ARCH"
				sleep 3
				sway_arch_install
			elif [ "$opcion" == "3" ]; then
				clear
				MSG="Instalación de fuentes"
				fonts_install
				sleep 5
			elif [ "$opcion" == "4" ]; then
				MSG="Actualizar configuracion de Sway"
				sleep 5
			elif [ "$opcion" == "4" ]; then
				clear 
				MSG="Actualizar Debian a 'testing'"
				sleep 5
			elif [ "$opcion" == "9" ]; then
				clear

				MSG="Reiniciar el sistema"
				reiniciar
			elif [ "$opcion" == "0" ]; then
				clear
				draw_header
				MSG="123456789|123456789|123456789|123456789"
				sleep 3 &
				printf "\r                                         "
				spinner "$!" "Adios!"
				exit 0
			else
				clear
				MSG="║      Opción no válida."
			fi

		done
	}

leo="leoleguizamon97"
echo ${#leo}

### MAIN ###
ver_sudo
draw_header

ver_distro
mk_directorios
main