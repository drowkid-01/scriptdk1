#!/bin/bash
source msg
config='/etc/v2ray/config.json'
tmp='/etc/v2ray/temp.json'
clear
if [[ ! -e /usr/games/v2r ]]; then
	if [[ ! -e /etc/systemd/system/v2ray.service ]]; then
		msg -bar
		[[ $(dpkg --get-selections|grep "lolcat") ]] || {
			sudo apt-get install lolcat &>/dev/null
			sudo gem install lolcat &>/dev/null
		}
		echo -e "	$(msg -verm 'AÚN NO HAZ INSTALADO V2RAY!')"
		msg -bar&&msg -ne '¿DESEAS INSTALAR V2RAY? [S|s/n|N]'
		read -p $'\e[1;91m:\e[1;32m ' inx
		case $inx in
		    S|s|Y|y|[Ss]i|[Yy]es|[Ss]imon)
				clear
				while [[ -z $inst ]]; do
					sudo apt-get install software-properties-common -y&&add-apt-repository universe&&apt update -y; apt upgrade -y
					clear&&echo -e "\033[92m        $(printext '-- INSTALANDO PAQUETES NECESARIOS --') "
					msg -bar
					value=( [1]="bc" [2]="uuid-runtime" [3]="python" [4]="python-pip" [5]="python3" [6]="qrencode" [7]="jq" [8]="curl" [9]="npm" [10]="nodejs" [11]="socat" [12]="netcat" [13]="netcat-traditional" [14]="net-tools" [15]="cowsay" [16]="figlet" [17]="lolcat"  )
					for((i=1;i<=17;i++));do
						unset -v pak dig status pts length
						pak="${value[$i]}"&&dig="${#pak}"
						( 	sudo apt-get install ${pak} -y ) &> /dev/null
						status=$(if [[ $(dpkg --get-selections|grep "${value[$i]}") ]]; then echo -e "\e[1;32mINSTALADO" ; else echo -e "\e[1;91mNO INSTALADO" ; fi)
						#echo -e "\e[91mINSTALANDO ${value[$i]}"
						echo -ne "\033[1;97m  # apt-get install ${value[$i]} "
						pts="."&&length=$(( 27 - ${dig} ))
						for((x=1;x<$length;x++));do
							pts+="."
						done
						echo -ne "${pts} ${status}\n"
					done
					msg -ama "$(msg -bar)\n    \e[1;33mSI ALGÚN PAQUETE NO SE INSTALÓ CORRECTAMENTE\n	   $(msg -verm 'REINICIA LA INSTALACIÓN!')"
					msg -bar
					msg -ne "	¿REINICIAR LA INSTALACIÓN? [s/n]: "&&read inst
					[[ $inst == @('s'|'S'|'Si'|'si'|'Yes'|'yes'|'y') ]] && unset inst
				done
				clear
				cat <<< '╻┏┓╻┏━┓╺┳╸┏━┓╻  ┏━┓┏┓╻╺┳┓┏━┓   ╻ ╻┏━┓┏━┓┏━┓╻ ╻
┃┃┗┫┗━┓ ┃ ┣━┫┃  ┣━┫┃┗┫ ┃┃┃ ┃   ┃┏┛┏━┛┣┳┛┣━┫┗┳┛
╹╹ ╹┗━┛ ╹ ╹ ╹┗━╸╹ ╹╹ ╹╺┻┛┗━┛   ┗┛ ┗━╸╹┗╸╹ ╹ ╹ '
				msg -bar
				echo "source <(curl -sSL https://gitea.com/drowkid01/scriptdk1/raw/branch/main/Recursos/menu_inst/v2ray_manager.url.sh)" > /usr/games/v2r
				chmod +x /usr/games/v2r
				msg -ama " La instalacion puede tener\n alguna fallas!\n por favor observe atentamente\n el log de intalacion,\n este podria contener informacion\n sobre algunos errores!\n estos deveras ser corregidos de\n forma manual antes de continual\n usando el script"
				sleep 0.2
				enter
				source <(curl -sSL https://gitea.com/drowkid01/scriptdk1/raw/branch/main/Recursos/menu_inst/v2ray.sh)
				#source <(curl -sSL https://gitea.com/drowkid01/scriptdk1/raw/branch/main/Recursos/down-vxray.sh) --instal
				cat >> /etc/systemd/system/v2ray.service <<- eof
					[Unit]
					Description=V2Ray Service
					After=network.target nss-lookup.target
					StartLimitIntervalSec=0

					[Service]
					Type=simple
					User=root
					CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
					AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
					NoNewPrivileges=true
					ExecStart=/usr/bin/v2ray/v2ray -config /etc/v2ray/config.json
					Restart=always
					RestartSec=3s


					[Install]
					WantedBy=multi-user.target
				eof
				systemctl daemon-reload &>/dev/null
				systemctl start v2ray &>/dev/null
				systemctl enable v2ray &>/dev/null
				systemctl restart v2ray.service
				msg -bar
				clear&&clear
				cat <<< '┏━┓┏━┓┏┓╻┏━╸╻     ╻ ╻┏━┓┏━┓╻ ╻
┣━┛┣━┫┃┗┫┣╸ ┃     ┏╋┛┣┳┛┣━┫┗┳┛
╹  ╹ ╹╹ ╹┗━╸┗━╸   ╹ ╹╹┗╸╹ ╹ ╹ '
				msg -bar
			 	echo -e " \033[0;31mEsta opcion es aparte, para habilitar XRAY Install"
				echo -e " Habilitaremos el modulo XRAY previo al V2RAY ya instalado \033[0m"
				echo -e "  Accederas al pannel original si es la primera vez !!\n\033[0m"
				msg -bar
				msg -ne "¿DESEAS INSTALAR XRAY?: [s/n] "&&read xrr
				case $xrr in
					[Ss]|[Yy])msg -bar
					[[ -e /usr/games/xr ]] && xr || {
						echo "source <(curl -sSL https://gitea.com/drowkid01/scriptdk1/raw/branch/main/Recursos/xray_manager.sh)" > /usr/games/xr
						chmod +x /usr/games/xr
					}
					;;
					[Nn]|Nn])msg -bar
						clear&&v2r
					;;
				esac

			;;
			*)tput cuu1&&tput dl1
				echo -e "	$(msg -verm 'VOLVIENDO AL MENÚ ANTERIOR!')"&&sleep 2&&return $?;;
		esac

	fi
fi

