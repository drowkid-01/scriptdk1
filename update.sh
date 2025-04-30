#!/bin/bash
source msg

ofus(){
unset server
server=$(echo ${txt_ofuscatw}|cut -d':' -f1)
unset txtofus
number=$(expr length $1)
for((i=1; i<$number+1; i++)); do
txt[$i]=$(echo "$1" | cut -b $i)
case ${txt[$i]} in
".")txt[$i]="x";;
"x")txt[$i]=".";;
"5")txt[$i]="s";;
"s")txt[$i]="5";;
"1")txt[$i]="@";;
"@")txt[$i]="1";;
"2")txt[$i]="?";;
"?")txt[$i]="2";;
"4")txt[$i]="0";;
"0")txt[$i]="4";;
"/")txt[$i]="K";;
"K")txt[$i]="/";;
esac
txtofus+="${txt[$i]}"
done
echo "$txtofus" | rev
}

key=$(</etc/cghkey)
ip=`echo $key|awk -F ":" '{print $2}'`

msg -bar
echo -e "      \e[1m$(printext 'ＥＳＰＥＲＥ  ＵＮ  ＭＯＭＥＮＴＯ')"
msg -bar
if curl -sSL http://$(ofus $ip):81/ChumoGH/checkIP.log|grep ${key//$ip/} &> /dev/null; then
	idd=$(curl -sSL http://$(ofus $ip):81/ChumoGH/checkIP.log|grep ${key//$ip/}|awk -F "|" '{print $1}')
	url="https://api.telegram.org/bot$(curl -sSL https://raw.githubusercontent.com/drowkid01/scriptdk1/main/Control/token.sh|awk '{print $1}')/getChatMember"

	while read user; do
		name=$(echo $user|jq -r .result.user.first_name)
		usrname=$(echo $user|jq -r .result.user.username)
	done <<< $(curl -s -X POST $url -d chat_id="$idd" -d user_id="$idd")

	date=$(curl -sSL http://$(ofus $ip):81/ChumoGH/checkIP.log|grep `echo $key|awk -F ':' '{print $1}'`|awk -F '|' '{print $4}')
	

	echo -e "	$(msg -verm 'DATOS DE LA KEY')"
	msg -bar
	echo -e "\e[1;97m$(printext 'NOMBRE:') \e[1;97m$name"
	echo -e "$(printext 'ALIAS/USER:') \e[1;97m$usrname"
	echo -e "$(printext 'FECHA DE INSTALACIÓN:') \e[1;97m$date"
	msg -bar
	sleep 3
	clear
	cat <<< '┏━┓┏━╸┏━╸┏━┓   ╺┳╸╻ ╻   ╻┏ ┏━╸╻ ╻
┣━┛┣╸ ┃╺┓┣━┫    ┃ ┃ ┃   ┣┻┓┣╸ ┗┳┛
╹  ┗━╸┗━┛╹ ╹    ╹ ┗━┛   ╹ ╹┗━╸ ╹ '
	msg -bar
	while read -p $'\e[41mKey: \e[0m\e[1;37m ' key; do
		if [[ -z $key ]]; then
			msg -verm 'PEGA TU KEY'&&sleep 2
			del 1
		elif [[ ${#key} == 45 ]]; then
			msg -verm 'VERIFICANDO KEY'
			key=$(echo $key|tr -d '[[:space:]]')
			break
		else
			msg -verm 'PEGA TU KEY'&&sleep 2
			del 1
		fi
	done

fi

ip=`ofus $(echo $key|awk -F ":" '{print $2}')`
 [[ $(curl -s --connect-timeout 5 $ip:8888 ) ]] && { 
	msg -bar
	echo -e " \e[90m\e[43m CHECK KEY : \033[0;33m"&&sleep 2
	tput cuu1&&tput dl1
	txt='ENLAZADA AL GENERADOR'
	echo -ne "	\e[1;32m"
	for((i=0;i<=${#txt};i++));do
		echo -ne "${txt:$i:1}"
	done
	tput cuu1 && tput dl1
	msg -bar3
	ip=`ofus $(echo $key|awk -F ":" '{print $2}')`
	wget --no-check-certificate -O $HOME/lista-arq $(ofus "$key")/$ip > /dev/null 2>&1 && echo -ne "\033[1;34m [ \e[3;32m VERIFICANDO KEY  \e[0m \033[1;34m]\033[0m"
 } || {
	echo -e "	$(msg -verm 'CONEXIÓN FALLIDA')"
	exit&&rm -f ~/*
 }
	ip=`ofus $(echo $key|awk -F ":" '{print $2}')`
	rekuest=$(ofus "$key"|cut -d'/' -f2)
	for arqx in $(cat $HOME/lista-arq); do
		wget --no-check-certificate -O /etc/adm-lite/${arqx} ${ip}:81/${rekuest}/${arqx} > /dev/null 2>&1 && chmod +x /etc/adm-lite/$arqx
	done
	[[ -s /etc/adm-lite/menu ]] && {
		echo $key > /etc/cghkey
	}

rm ~/*
