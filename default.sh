#!/bin/bash
set -e

### Files ###

deb_file(){
# Configurar los repositorios para testing

cat <<EOF >/etc/apt/sources.list
deb http://deb.debian.org/debian/ bookworm main non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm main non-free-firmware

deb http://security.debian.org/debian-security bookworm-security main non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main non-free-firmware

deb http://deb.debian.org/debian/ bookworm-updates main non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm-updates main non-free-firmware

deb http://deb.debian.org/debian bookworm-backports main
EOF
}

### VARIABLES ###

	TAB='$\t'
	TAB_SIZE='\t'
	DISTRO=""

	deb_paquetes=(
		btop
		xwayland
		network-manager
		brightnessctl
		pipewire
		playerctl
		zip
		unzip
		curl
		sway
		swaybg
		swayidle
		swaylock
		wofi
		gedit
		nautilus
		nautilus-share
		gnome-disk-utility
		gnome-calculator
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
	}

	draw_space(){
		printf "\033[F"
		printf "║                                                  ║\n"
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

		draw_header "Opcion no valida / Cancelado"
		printf "║    La opcion no es valida o fue cancelada.       ║\n"
		printf "║                                                  ║\n"
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

	update(){
		if [ "$DISTRO" == "Debian" ]; then
			update_debian $1
		elif [ "$DISTRO" == "Arch" ]; then
			update_arch $1
		elif [ "$DISTRO" == "Fedora" ]; then
			update_fedora $1
		fi
	}

	update_debian() {
		if [ $1 -eq 1 ] ; then
			printf "║                                                  ║\n"
			printf "║    Se agregaran los repositorios BACKPORT        ║\n"
			printf "║    para la version estable de Debian             ║\n"
			printf "║                                                  ║\n"

			draw_footer
			printf "\033[F\033[F"
			read -p "║    ¿Deseas continuar? (s/n): " respuesta
			if [[ "$respuesta" != "s" && "$respuesta" != "S" ]]; then
				sys_invalid
				return
			fi
		fi
		printf "║    Agregando repositorios                        ║\n"
		printf "║                                                  ║\n"

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
		if [ $1 -eq 1 ] ; then
			printf "\033[F"
			printf "║                                                  ║\n"
			printf "║    Migración a Debian 'testing' completada       ║\n"
			printf "║    Reinicia tu sistema para aplicar los cambios  ║\n"
			printf "║                                                  ║\n"

			draw_footer
		fi
	}

### Install

	install_sway(){
		printf "║    Instalando Entorno Sway                       ║\n"
		printf "║                                                  ║\n"
		
		if [ "$DISTRO" == "Debian" ]; then
			install_sway_deb $1
		elif [ "$DISTRO" == "Arch" ]; then
			install_sway_arch $1
		elif [ "$DISTRO" == "Fedora" ]; then
			install_sway_fedora $1
		fi
	}

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
		apt update > /dev/null 2>&1 &
		draw_spinner $! "Actualizando lista de paquetes"
		
		# Verificar e instalar los paquetes disponibles
		draw_space

		for paquete in "${deb_paquetes[@]}"; do
			check_and_install "$paquete"
		done

		# Aviso
		if [ $1 -eq 1 ]; then
			draw_space
			sleep 5 &
			draw_spinner $! "¡Se recomienda reiniciar el sistema!"
		fi
	}

	install_browser(){
		printf "║    Instalando navegador                          ║\n"
		opcion=$1
		if [ $1 -eq 0 ]; then
			printf "║                                                  ║\n"
			printf "║    Selecciona un navegador:                      ║\n"
			printf "║                                                  ║\n"
			printf "║     ╔═════════════════════════════════════╗      ║\n"
			printf "║     ║ 1. Brave                            ║      ║\n"
			printf "║     ║ 2. Firefox                          ║      ║\n"
			printf "║     ╚═════════════════════════════════════╝      ║\n"
			printf "║                                                  ║\n"
			printf "║                                                  ║\n"
			printf "║                                                  ║\n"

			draw_footer
			printf "\033[F\033[F"
			read -p "║     Selecciona opcion: " opcion
			printf "\033[F"
			printf "║                                                  ║\n"
		fi
			printf "║                                                  ║\n"
		if [ "$opcion" -eq 1 ]; then
			curl -fsS https://dl.brave.com/install.sh | sh > /dev/null 2>&1 &
			draw_spinner $! "Instalando Brave"
		elif [ "$opcion" -eq 2 ]; then
			if [ "$DISTRO" == "Debian" ]; then
				apt install -y firefox-esr > /dev/null 2>&1 &
				pid=$!
			elif [ "$DISTRO" == "Arch" ]; then
				pacman -Sy firefox > /dev/null 2>&1 &
				pid=$!
			elif [ "$DISTRO" == "Fedora" ]; then
				dnf install -y firefox > /dev/null 2>&1 &
				pid=$!
			else
				draw_error "No se pudo determinar la distro"
				exit 1
			fi
			draw_spinner $pid "Instalando Firefox"
		else
			sys_invalid
		fi
	}

	install_vscode(){
		printf "║    Instalando VSCode                             ║\n"
		printf "║                                                  ║\n"

		if [ "$DISTRO" == "Debian" ]; then
			apt update > /dev/null 2>&1 &
			draw_spinner $! "Actualizando lista de paquetes"

			draw_space

			apt install -y wget > /dev/null 2>&1 &
			draw_spinner $! "Instalando... wget"
			apt install -y gpg > /dev/null 2>&1 &
			draw_spinner $! "Instalando... gpg"
			apt install -y apt-transport-https > /dev/null 2>&1 &
			draw_spinner $! "Instalando... apt-transport-https"
			
			wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg 
			install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &
			draw_spinner $! "Descargando clave"
			
			echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null 2>&1 &
			draw_spinner $! "Agregando repositorio"
			
			rm -f packages.microsoft.gpg &
			draw_spinner $! "Limpiando"

			apt update > /dev/null 2>&1 &
			draw_spinner $! "Actualizando"

			draw_space
			
			apt install -y code > /dev/null 2>&1 &
			draw_spinner $! "Instalando VSCode"

		elif [ "$DISTRO" == "Arch" ]; then
			sleep 1 & 
			draw_spinner $! "Not yet implemented"
		elif [ "$DISTRO" == "Fedora" ]; then
			sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc > /dev/null 2>&1 &
			draw_spinner $! "Importando clave"
			echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null 2>&1 &
			draw_spinner $! "Agregando repositorio"

			sudo dnf check-update > /dev/null 2>&1 &
			draw_spinner $! "Actualizando"
			sudo dnf install -y code > /dev/null 2>&1 &
			draw_spinner $! "Instalando VSCode"
		else
			draw_error "No se pudo determinar la distro"
			exit 1
		fi
	}

	install_fonts(){
		printf "║    Instalando fuentes                            ║\n"
		printf "║                                                  ║\n"


		# Verificar zip
		if [ "$DISTRO" == "Debian" ]; then
			apt install -y zip fonts-noto-color-emoji > /dev/null 2>&1 &
			pid=$!
		elif [ "$DISTRO" == "Arch" ]; then
			pacman -S zip > /dev/null 2>&1 &
			pid=$!
		elif [ "$DISTRO" == "Fedora" ]; then
			dnf install -y zip > /dev/null 2>&1 &
			pid=$!
		fi
		draw_spinner "$pid" "Instalando zip y Emoji font"

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

### FUNCIONES PENDIENTES ###

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

	install_dotfiles(){
		printf "║    Instalando dotfiles                           ║\n"
		printf "║                                                  ║\n"

		sudo -u "$SUDO_USER" git clone https://github.com/leoleguizamon97/sway.git /home/"$SUDO_USER"/.config/sway > /dev/null 2>&1 &
		draw_spinner $! "Descargando configuración de Sway"
	}

	update_fedora(){
		printf "║    Install rpm fusion repos                      ║\n"
		printf "║                                                  ║\n"
		sleep 5 & 
		draw_spinner $! "Not yet implemented"
	}

	update_arch(){
		printf "║    Install yay and AUR packages                  ║\n"
		printf "║                                                  ║\n"
		sleep 5 & 
		draw_spinner $! "Not yet implemented"
	}

	full_install(){
		printf "║    Instalacion completa de sway                  ║\n"
		printf "║                                                  ║\n"
		printf "║    Solo realizar en instalaciones nuevas         ║\n"
		printf "║    Pensado para instalaciones minimas            ║\n"
		printf "║    (NETINSTALL)                                  ║\n"
		printf "║                                                  ║\n"
		if [ "$DISTRO" == "Debian" ]; then
			printf "║    Este script migrara tu sistema Debian a       ║\n"
			printf "║    a version 'testing'                           ║\n"
			printf "║                                                  ║\n"
			printf "║    NO RECOMENDADO SI YA REALIZO LA INSTALACION   ║\n"
			printf "║    DE SWAY.                                      ║\n"
			printf "║                                                  ║\n"
		fi
		draw_footer
		printf "\033[F\033[F"
		read -p "║    ¿Deseas continuar? (s/n): " respuesta
		if [[ "$respuesta" != "s" && "$respuesta" != "S" ]]; then
			sys_invalid
			return
		fi
		draw_space
		draw_separator

		# Instalar nerd fonts
		install_fonts
		draw_separator

		# Actualizar repositorios
		update 0
		draw_separator

		# Instalar sway
		install_sway 0
		draw_separator
		
		# Instalar dotfiles
		install_dotfiles
		draw_separator
		
		# Instalar VSCode
		install_vscode
		draw_separator
		
		# Instalar Navegadores
		install_browser 1
		draw_separator

		# Finalizar
		printf "║                                                  ║\n"
		sleep 2 &
		draw_spinner $! "Instalacion finalizada"
		sleep 3 &
		draw_spinner $! "Reinicia el sistema ..."
	}

	set_dark(){
		printf "║    Estableciendo tema oscuro                     ║\n"
		printf "║                                                  ║\n"
		gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	}
### Main menu

	main(){
		while [ true ]; do
			draw_header "Instalador de SWAY"
			printf "║      Selecciona una opcion:                      ║\n"
			printf "║                                                  ║\n"
			printf "║     ╔═════════════════════════════════════╗      ║\n"
			printf "║     ║ 1. Instalar LeOS (Full install)     ║      ║\n"
			printf "║     ╠═════════════════════════════════════╣      ║\n"
			printf "║     ║ 2. Instalar Sway/apps recomendadas  ║      ║\n"
			printf "║     ║ 3. Copiar dotfiles                  ║      ║\n"
			printf "║     ║ 4. Configurar nuevos repositorios   ║      ║\n"
			printf "║     ╠═════════════════════════════════════╣      ║\n"
			printf "║     ║ 5. Configurar modo oscuro           ║      ║\n"
			printf "║     ╠═════════════════════════════════════╣      ║\n"
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
				draw_header "$DISTRO - LeOS Edition"
				full_install
			elif [ "$opcion" == "2" ]; then
				draw_header "Instalando Escritorio Sway"
				install_sway 1
			elif [ "$opcion" == "3" ]; then
				draw_header "Descargar dotfiles"
				install_dotfiles
			elif [ "$opcion" == "4" ]; then
				draw_header "Actualizando Repos $DISTRO"
				update 1
			elif [ "$opcion" == "5" ]; then
				draw_header "Configurar Modo oscuro"
				set_dark
				draw_footer
			elif [ "$opcion" == "6" ]; then
				draw_header "Instalando VSCode"
				install_vscode
			elif [ "$opcion" == "7" ]; then
				draw_header "Instalando Navegador"
				install_browser 0
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