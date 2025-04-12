#!/bin/bash
set -e

deb_file(){
# Configurar los repositorios para testing

cat <<EOF >/etc/apt/sources.list
deb http://deb.debian.org/debian testing main contrib non-free
deb-src http://deb.debian.org/debian testing main contrib non-free

deb http://deb.debian.org/debian/ stable main contrib non-free-firmware
deb-src http://deb.debian.org/debian/ stable main contrib non-free-firmware

deb http://security.debian.org/debian-security stable-security main non-free-firmware
deb-src http://security.debian.org/debian-security stable-security main non-free-firmware
EOF
}

### VARIABLES ###

	TAB='$\t'
	TAB_SIZE='\t'
	DISTRO=""

	deb_paquetes=(
		xwayland
		network-manager
		curl
		sway
		swaybg
		swayidle
		swaylock
		wofi
		brightnessctl
		pipewire
		playerctl
		zip
		unzip
		grim
	)
	arch_paquetes=(
		sway
		swaybg
		swayidle
		swaylock
		swaync
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
	fedora_paquetes=(
		sway
		swaybg
		swayidle
		swaylock
		wofi
		brightnessctl
		pipewire
		playerctl
	)

### FUNCIONES ###

### Verificar

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

	ver_distro(){
		if [ -f /etc/arch-release ]; then
			DISTRO="Arch"
		elif [ -f /etc/debian_version ]; then
			DISTRO="Debian"
		elif [ -f /etc/fedora-release ]; then
			DISTRO="Fedora"
		else
			draw_error "No se pudo determinar la distro"
			exit 1
		fi
	}

### Dibujar 

	draw_spinner() {
		local pid=$1
		local delay=0.1
		local spinstr='|/-\'
		while kill -0 "$pid" 2>/dev/null; do
			for ((i=0; i<${#spinstr}; i++)); do
				printf "\033[F"							#Vuelve a linea anterior y limpia \033[2K
				printf "\r║ %.43s %$(( ${#2} < 43 ? 43 - ${#2} : 1))s [%s] ║\n" "$2" "" "${spinstr:i:1}"
				draw_footer
				sleep "$delay"
			done
		done
		printf "\033[F"
		printf "║ %.37s %$((37 > ${#2} ? 37 - ${#2} : 1))s %s ║\n\n" "$2" "" "Listo [✔]"
	}

	draw_header(){
		clear
		ancho=30
		largoTitulo=0

		if [[ ${#1}%2 == 0 ]]; then
			largoTitulo=${#1}
		else
			largoTitulo=${#1}+1
		fi

		borde=$(( ($ancho - $largoTitulo) / 2 ))

		centro=""
		for i in $(seq 1 $borde); do
			centro+=" "
		done

		centro+="$1"
		for i in $(seq 1 $borde); do
			centro+=" "
		done

		printf "╔" && printf "═%.0s" {1..10} && printf "%.30s" "$centro" && printf "═%.0s" {1..10} && printf "╗\n"
		printf "║" && printf "%50s" && printf "║\n"
	}

	draw_footer(){
		printf "╚" && printf "═%.0s" {1..34} && printf "leoleguizamon97═╝"
	}

	draw_error(){
		printf "\033[F"
		printf "║ %.37s %$((37 > ${#1} ? 37 - ${#1} : 1))s %s ║\n\n" "$1" "" "Error [x]"
		sleep 1 &
		draw_spinner $! "Saliendo..."
		exit 1
	}

	draw_separator(){
			printf "\033[F"
			printf "╠══════════════════════════════════════════════════╣\n"
			printf "║                                                  ║\n"
	}

### Sistema

	sys_exit(){
		printf "║                                                  ║\n"
		sleep 1 &
		draw_spinner $! "Adios!"
		exit 0
	}

	sys_reboot(){
		printf "\n"
		for i in {5..1}; do
			printf "\033[F║      Reiniciando el sistema en: $i!               ║\n"
			draw_footer
			sleep 1
		done
		sleep 2 &
		draw_spinner $! "Adios!"
		reboot now
	}

	sys_invalid(){
		printf "║    Opcion no valida                              ║\n"
		draw_footer
	}

	sys_mkDir(){
		# Crear directorios como usuario regular
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/.config/ > /dev/null
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Downloads > /dev/null
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Desktop > /dev/null
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Documents > /dev/null
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Music > /dev/null
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Pictures > /dev/null
		sudo -u "$SUDO_USER" mkdir -p /home/"$SUDO_USER"/Videos > /dev/null

		# Crear el directorio de fuentes
		mkdir -p /usr/local/share/fonts
	}

### Update

	update_debian() {
		printf "║                ${1}                                    ║\n"
		if [ $1 -eq 1 ] ; then

			printf "║    Este script migrara tu sistema Debian a       ║\n"
			printf "║    a version 'testing'                           ║\n"
			printf "║                                                  ║\n"
			printf "║    NO RECOMENDADO SI YA REALIZO LA INSTALACION   ║\n"
			printf "║    DE SWAY.                                      ║\n"
			printf "║                                                  ║\n"
			printf "║    De ser asi mantengase en la version STABLE    ║\n"
			printf "║                                                  ║\n"
			printf "║                                                  ║\n"

			draw_footer
			printf "\033[F"
			read -p "║    ¿Deseas continuar? (s/n): " respuesta
			if [[ "$respuesta" != "s" && "$respuesta" != "S" ]]; then
				printf "\033[F║    Operación cancelada                           ║\n"
				draw_footer
				return
			fi
		fi

		# Hacer un respaldo del archivo sources.list
		cp /etc/apt/sources.list /etc/apt/sources.list.bak > /dev/null 2>&1 &
		draw_spinner $! "Haciendo respaldo de sources.list"

		# Configurar los repositorios para testing
		deb_file > /dev/null 2>&1 &
		draw_spinner $! "Configurando los repositorios"

		# Actualizar lista de paquetes
		apt update -y > /dev/null 2>&1 &
		draw_spinner $! "Actualizando la lista de paquetes"

		# Fix broken packages
		apt --fix-broken install -y > /dev/null 2>&1 &
		draw_spinner $! "Fixing broken packages"

		# Actualizar el sistema a testing
		apt full-upgrade -y > /dev/null 2>&1 &
		draw_spinner $! "Actualizando el sistema"

		# Limpiar paquetes obsoletos
		apt autoremove -y > /dev/null 2>&1 &
		draw_spinner $! "Eliminando paquetes obsoletos"

		# Completado
		printf "\033[F"
		printf "║                                                  ║\n"
		printf "║    Migración a Debian 'testing' completada       ║\n"
		printf "║    Reinicia tu sistema para aplicar los cambios  ║\n"
		printf "║                                                  ║\n"

		draw_footer
	}

### Install

	install_fonts(){
		printf "║                                                  ║\n"
		# Verificar zip
		if [ "$DISTRO" == "Debian" ]; then
			apt install -y zip > /dev/null 2>&1 &
			pid=$!
		elif [ "$DISTRO" == "Arch" ]; then
			pacman -S zip > /dev/null 2>&1 &
			pid=$!
		elif [ "$DISTRO" == "Fedora" ]; then
			dnf install -y zip > /dev/null 2>&1 &
			pid=$!
		fi
		draw_spinner "$pid" "Instalando zip"
		
		# Descargar y descomprimir la fuente Nerd Font Hasklig
		cd /home/"$SUDO_USER"/Downloads
		if [ -f "/home/"$SUDO_USER"/Downloads/Hasklig.zip" ]; then
			sleep 1 &
			draw_spinner $! "Fuentes ya descargadas!"
		else
			sudo -u "$SUDO_USER" wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hasklig.zip > /dev/null 2>&1 &
				draw_spinner $! "Descargando Nerdfont Hasklig"
		fi
		
		sudo unzip Hasklig.zip -d /usr/local/share/fonts/Hasklig > /dev/null 2>&1 &
		draw_spinner $! "Descomprimiendo Nerdfont Hasklig"
		
		fc-cache -fv > /dev/null 2>&1 &
		draw_spinner $! "Actualizando caché de fuentes"
		
		chmod -R 755 /usr/local/share/fonts > /dev/null
	}

	install_sway(){
		if [ "$DISTRO" == "Debian" ]; then
			install_sway_deb
		elif [ "$DISTRO" == "Arch" ]; then
			install_sway_arch
		elif [ "$DISTRO" == "Fedora" ]; then
			install_sway_fedora
		fi
	}

### FUNCIONES PENDIENTES ###

	install_sway_deb(){

		# Función para verificar si un paquete está disponible en los repositorios
		check_and_install() {
			if apt-cache policy "$1" | grep -q "Candidate:"; then
				apt install -y "$1" > /dev/null 2>&1 &
				draw_spinner $! "Instalando $1"
			else
				sleep 1 &
				draw_spinner $! "No disponible $1"
			fi
		}

		# Actualizar repositorios
		printf "║                                                  ║\n"
		apt update > /dev/null 2>&1 &
		draw_spinner $! "Actualizando lista de paquetes"
		
		# Verificar e instalar los paquetes disponibles
		draw_separator
		for paquete in "${deb_paquetes[@]}"; do
			check_and_install "$paquete"
		done

		# Descargar configuración de sway
		draw_separator
		sudo -u "$SUDO_USER" git clone https://github.com/leoleguizamon97/sway.git /home/"$SUDO_USER"/.config/sway > /dev/null 2>&1 &
		draw_spinner $! "Descargando configuración de Sway"

		# Aviso
		draw_separator
		sleep 5 &
		draw_spinner $! "¡Se recomienda reiniciar el sistema!"
	}

	install_sway_arch(){
		printf "║    Instalando sway y sus dependencias            ║\n"
		sleep 5 & 
		draw_spinner $! "Not yet implemented"
	}
	
	install_sway_fedora(){
		printf "║    Instalando sway y sus dependencias            ║\n"
		sleep 5 & 
		draw_spinner $! "Not yet implemented"
	}

	install_vscode(){
		printf "║                                                  ║\n"
		apt install -y wget gpg apt-transport-https > /dev/null 2>&1 &
		#draw_spinner $! "Instalando dependencias"
		
		wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg 
		install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &
		draw_spinner $! "Descargando clave"
		
		echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null 2>&1 &
		draw_spinner $! "Agregando repositorio"
		
		rm -f packages.microsoft.gpg &
		draw_spinner $! "Limpiando"

		apt update > /dev/null 2>&1 &
		draw_spinner $! "Actualizando"

		draw_separator
		apt install -y code > /dev/null 2>&1 &
		draw_spinner $! "Instalando"

		draw_separator
		sleep 2 &
		draw_spinner $! "¡Listo!"
	}

	install_dotfiles(){
		printf "║    Instalando dotfiles                           ║\n"
		sleep 5 & 
		draw_spinner $! "Not yet implemented"
	}

	install_browser(){
		printf "║    Instalando Browser                            ║\n"
		sleep 5 & 
		draw_spinner $! "Not yet implemented"
	}

	update(){
		if [ "$DISTRO" == "Debian" ]; then
			update_debian 1
		elif [ "$DISTRO" == "Arch" ]; then
			update_arch 1
		elif [ "$DISTRO" == "Fedora" ]; then
			update_fedora 1
		fi
	}

### Main menu

	main(){
		while [ true ]; do
			draw_header "Instalador de SWAY"
			printf "║      Selecciona una opcion:                      ║\n"
			printf "║                                                  ║\n"
			printf "║     ╔═════════════════════════════════════╗      ║\n"
			printf "║     ║ 1. Configurar Sway/Apps             ║      ║\n"
			printf "║     ║ 2. Configurar dotfiles              ║      ║\n"
			printf "║     ║ 3. Configurar nuevos repositorios   ║      ║\n"
			printf "║     ╠═════════════════════════════════════╣      ║\n"
			printf "║     ║ 4. ??????                           ║      ║\n"
			printf "║     ║ 5. ??????                           ║      ║\n"
			printf "║     ║ 6. Instalar VS Code                 ║      ║\n"	
			printf "║     ║ 7. Instalar Navegador               ║      ║\n"
			printf "║     ║ 8. Instalar NerdFont Hasklig        ║      ║\n"
			printf "║     ╠═════════════════════════════════════╣      ║\n"
			printf "║     ║ 9. Reiniciar el sistema             ║      ║\n"
			printf "║     ║ 0. Salir                            ║      ║\n"
			printf "║     ╚═════════════════════════════════════╝      ║\n"
			printf "║                                                  ║\n"
			printf "║     %.40s %*s ║\n" "$DISTRO" $(( ${#DISTRO} < 43 ? 43 - ${#DISTRO} : 3  )) ""
			printf "║                                                  ║\n"
			printf "║                                                  ║\n"
			draw_footer
			printf "\033[F\033[F"
			read -p "║     Selecciona opcion: " opcion
			if [ "$opcion" == "1" ]; then
				draw_header "Instalando Escritorio Sway"
				install_sway
			elif [ "$opcion" == "2" ]; then
				draw_header "Descargar dotfiles"
				install_dotfiles
			elif [ "$opcion" == "3" ]; then
				draw_header "Actualizando Repos $DISTRO"
				update
			elif [ "$opcion" == "4" ]; then
				draw_header "???"
				draw_footer
			elif [ "$opcion" == "5" ]; then
				draw_header "???"
				draw_footer
			elif [ "$opcion" == "6" ]; then
				draw_header "Instalando VSCode"
				install_vscode
			elif [ "$opcion" == "7" ]; then
				draw_header "Instalando Navegador"
				install_browser
			elif [ "$opcion" == "8" ]; then
				draw_header "Instalando NerdFont Hasklig"
				install_fonts
			elif [ "$opcion" == "9" ]; then
				draw_header "Reiniciando el sistema"
				sys_reboot
			elif [ "$opcion" == "0" ]; then
				draw_header "Saliendo..."
				sys_exit
			else
				draw_header "Opcion no valida"
				sys_invalid
			fi
			sleep 2
		done
	}

### MAIN ###

draw_header "Verificando..."
printf "║                                                  ║\n"

sleep 0.2 &
draw_spinner $! "Verificando permisos de sudo..."
ver_sudo

sleep 0.2 &
draw_spinner $! "Verificando distribución..."
ver_distro

sleep 0.2 &
draw_spinner $! "Creando carpetas de usuario..."
sys_mkDir

sleep 1
main