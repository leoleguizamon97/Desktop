#!/bin/bash
set -e

deb_file(){
# Configurar los repositorios para testing

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
		while kill -0 "$pid" 2>/dev/null; do
			for ((i=0; i<${#spinstr}; i++)); do
				printf "\033[F"							#Vuelve a linea anterior y limpia \033[2K
				printf "\r║ %.42s %$((50 > ${#2} ? 43 - ${#2} : 1))s [%s] ║\n" "$2" "" "${spinstr:i:1}"
				sleep "$delay"
				draw_footer
			done
		done
		printf "\033[F"
		printf "║ %.34s %$((50 > ${#2} ? 37 - ${#2} : 1))s %s ║\n\n" "$2" "" "Listo [✔]"
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

	draw_footer(){
		printf "╚" && printf "═%.0s" {1..34} && printf "leoleguizamon97═╝"
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

	ver_distro(){
		if [ -f /etc/arch-release ]; then
			DISTRO="Arch"
		elif [ -f /etc/lsb-release ]; then
			DISTRO="Ubuntu"
		elif [ -f /etc/debian_version ]; then
			DISTRO="Debian"
		else
			draw_header
			printf "║                                                  ║\n"
			printf "║    No se pudo determinar la distribución         ║\n"
			draw_footer
			exit
			return 1
		fi
		return 0
		sleep 2
	}

	salir(){
		printf "║                                                  ║\n"
		sleep 1 &
		spinner "$!" "Adios!"
		exit 0
	}

	reiniciar(){
		printf "\n"
		for i in {5..1}; do
			printf "\033[F║      Reiniciando el sistema en: $i!               ║\n"
			draw_footer
			sleep 1
		done
		printf "\n Bye! \n\n"
		sleep 2
		reboot now
	}

	actualizar_debian() {

		# Configurar los repositorios para testing
		printf "║    Este script migrará tu sistema Debian a       ║\n"
		printf "║    a versión 'testing'                           ║\n"
		printf "║                                                  ║\n"
		printf "║                                                  ║\n"
		printf "║                                                  ║\n"
		draw_footer
		printf "\033[F\033[F"
		read -p "║    ¿Deseas continuar? (s/n): " respuesta
		
		if [[ "$respuesta" != "s" && "$respuesta" != "S" ]]; then
			printf "\033[F║    Operación cancelada                           ║\n"
			printf "║                                                  ║\n"
			draw_footer
			return
		fi

		# Hacer un respaldo del archivo sources.list
		cp /etc/apt/sources.list /etc/apt/sources.list.bak > /dev/null 2>&1
		spinner $! "Haciendo respaldo de /etc/apt/sources.list"
		
		# Configurar los repositorios para testing
		deb_file > /dev/null 2>&1
		spinner $! "Configurando los repositorios para testing"
		
		# Actualizar lista de paquetes
		apt update & > /dev/null 2>&1
		spinner "$!" "Actualizando la lista de paquetes"

		# Actualizar el sistema a testing
		apt full-upgrade -y > /dev/null 2>&1
		spinner $! "Actualizando el sistema a 'testing'"

		# Limpiar paquetes obsoletos
		apt autoremove -y > /dev/null 2>&1
		spinner $! "Eliminando paquetes obsoletos"

		printf "║                                                  ║\n"
		printf "║    Migración a Debian 'testing' completada       ║\n"
		printf "║    Reinicia tu sistema para aplicar los cambios  ║\n"
		printf "║                                                  ║\n"
		draw_footer
	}

	fonts_install(){
		printf "\n"
		# Verificar 7z
		if [ "$DISTRO" == "Debian" ]; then
			apt install -y p7zip-full > /dev/null 2>&1 &
			pid=$!
			spinner "$pid" "Instalando p7zip-full"
		elif [ "$DISTRO" == "Arch" ]; then
			pacman -S p7zip > /dev/null 2>&1 &
			pid=$!
			spinner "$pid" "Instalando p7zip-full"
		elif [ "$DISTRO" == "Ubuntu" ]; then
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
	}

### FUNCIONES PENDIENTES ###

	sway_deb_install(){
		# Función para verificar si un paquete está disponible en los repositorios
		check_and_install() {
			if apt-cache policy "$1" | grep -q "Candidate:"; then
				printf "║    El paquete '$1' está disponible               ║\n"
				apt install -y "$1" > /dev/null 2>&1
				spinner $! "Instalando $1"
			else
				printf "║                                                  ║\n"
				printf "║    El paquete '$1' NO está disponible        [x] ║\n"
				sleep 1
			fi
		}

		# Actualizar repositorios
		apt update > /dev/null 2>&1
		spinner $! "Actualizando lista de paquetes"

		# Verificar e instalar los paquetes disponibles
		for paquete in "${deb_paquetes[@]}"; do
			check_and_install "$paquete"
		done

		# Descargar configuración de sway
		sudo -u "$SUDO_USER" git clone https://github.com/leoleguizamon97/sway.git /home/"$SUDO_USER"/.config/sway > /dev/null 2>&1
		spinner $! "Descargando configuración de Sway"
		sleep 5

	}

	#sway_arch_install(){}
	
	#swat_ubunt_install(){}

	# Ciclo principal
	main(){
		while [ true ]; do
			draw_header
			printf "║      Elige el modo de instalación:               ║\n"
			printf "║                                                  ║\n"
			printf "║     ╔═════════════════════════════════════╗      ║\n"
			printf "║     ║                                     ║      ║\n"
			printf "║     ║ 1. Instalación completa             ║      ║\n"
			printf "║     ║ ------------------------------------║      ║\n"
			printf "║     ║ 2. Actualizar configuracion de Sway ║      ║\n"
			printf "║     ║ 3. Instalación de fuentes           ║      ║\n"
			printf "║     ║ 8. Actualizar Debian a 'testing'    ║      ║\n"
			printf "║     ║ 9. Reiniciar el sistema             ║      ║\n"
			printf "║     ║ 0. Salir                            ║      ║\n"
			printf "║     ║                                     ║      ║\n"
			printf "║     ╚═════════════════════════════════════╝      ║\n"
			printf "║                                                  ║\n"
			printf "║     Sistema detectado: %.20s %*s ║\n" "$DISTRO" $((24 - ${#DISTRO})) ""
			printf "║                                                  ║\n"
			printf "║                                                  ║\n"
			printf "║                                                  ║\n"
			draw_footer
			printf "\033[F\033[F"
			read -p "║     Selecciona opcion: " opcion 

			if [ "$opcion" == "1" ]; then
				draw_header
				actualizar_debian
				sleep 5
			elif [ "$opcion" == "2" ]; then
				draw_header
				sleep 3
				#sway_arch_install
			elif [ "$opcion" == "3" ]; then
				draw_header
				fonts_install
				sleep 5
			elif [ "$opcion" == "4" ]; then
				sleep 5
			elif [ "$opcion" == "4" ]; then
				draw_header
				sleep 5
			elif [ "$opcion" == "9" ]; then
				draw_header
				reiniciar
			elif [ "$opcion" == "0" ]; then
				draw_header
				salir
			else
				draw_header
				printf "║  Opcion no Valida                                ║\n"
				printf "║                                                  ║\n"
				draw_footer
				sleep 1
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