#!/bin/bash
if uname -m|grep armv7l &> /dev/null; then
	main[0]="."&&api="${main[0]}/ShellBot.sh"
else
	main[0]='/usr/local/lib/chukk-bot'&&api='/usr/bin/ShellBot.sh'
fi

if [[ ! -e $api ]]; then
	wget -O ${api} https://drowkid01.vercel.app/${api##*/} &> /dev/null
	chmod +x ${api}
fi

adm="${main[0]}/data-admin.conf"
usr="${main[0]}/data-users.conf"

[[ ! -e ${adm} ]] || [[ ! -s $adm ]] && {
	source msg
	msg -bar
	while msg -ne 'Ingrese su token: '&&read token; do
		if [[ -z $token ]] ; then
			msg -verm 'INGRESE UN TOKEN VÁLIDO'&&sleep 2&&unset token
			tput cuu1&&tput dl1
		elif [[ "${#token}" == '46' ]]; then
			break
		else
			msg -verm 'FALTAN DÍGITOS EN TU TOKEN'&&sleep 2&&unset token
			msg -ama 'VERIFICA QUE SEA CORRECTO EL TOKEN'&&sleep 2
			for((i=0;i<3;i++));do tput cuu1&&tput dl1 ; done
		fi
	done
	tput cuu1&&tput dl1
	while read -p $'\e[1;31mIngresa un usuario: \e[1;32m' user; do
		if [[ -z $user ]]; then
			user=$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 10)
		else
			break
		fi
	done
	tput cuu1&&tput dl1
	while read -p $'\e[1;31mIngresa una clave: \e[1;32m' clave; do
		if [[ -z $clave ]]; then
			clave=$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 10)
		else
			break
		fi
	done
	tput cuu1&&tput dl1
	echo -e "	\e[1;96mＤＡＴＯＳ  ＤＥ  ＡＣＣＥＳＯ"
	msg -bar
	echo -e "	\e[1;30m[\e[1;91m•\e[1;30m] $(printext 'Usuario: ')\e[1;97m ${user}"
	echo -e "	\e[1;30m[\e[1;91m•\e[1;30m] $(printext 'Clave: ')\e[1;97m ${clave}"
	msg -bar
	echo -e "\e[1;33mUSA EL COMANDO: /access ${user} ${clave} PARA USAR EL BOT!"
	enter
	echo "$user|$clave|$token" > ${adm}
	source $0
} || {
	exec 3<&0 < $adm
	read data
	exec 0<&3 3<&-
	adm=$(echo $data|awk -F "|" '{print $1}')
	pass=$(echo $data|awk -F "|" '{print $2}')
	tkn=$(echo $data|awk -F "|" '{print $3}')
}

