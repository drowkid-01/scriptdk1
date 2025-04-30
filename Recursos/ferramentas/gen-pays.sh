#!/bin/bash
source msg

mr=(GET CONNECT PUT OPTIONS DELETE HEAD TRACE PROPATCH PATH)
xr=(realData netData raw)

value=$IP
[[ -z $value ]] && value='127.0.0.1'
cat <<< '┏━┓┏━┓╻ ╻╻  ┏━┓┏━┓╺┳┓┏━┓
┣━┛┣━┫┗┳┛┃  ┃ ┃┣━┫ ┃┃┗━┓
╹  ╹ ╹ ╹ ┗━╸┗━┛╹ ╹╺┻┛┗━┛'
msg -bar
while [[ -z $host ]]; do
	msg -ne 'Ingresa tu host: '&&read host
	if [[ -z $host ]]; then
		msg -verm 'INGRESA UN HOST VÁLIDO'
		sleep 2&&tput cuu1&&tput dl1&&unset host
	else
		host=$(echo $host|tr -d '[[:space:]]')
	fi
done
tput cuu1&&tput dl1
echo -e "$(msg -ama 'HOST:')\e[1;97m $host"
msg -bar
echo -e "	$(msg -ne 'ELIJA UN MÉTODO DE RESPUESTA')"
msg -bar
menu_func 'GET' 'CONNECT' 'PUT' 'OPTIONS' 'DELETE' 'HEAD' 'TRACE' 'PROPATCH' 'PATH'
back
echo -ne "\033[1;30m╰► Seleccione su opción: \e[92m"&&read rr
[[ $rr == @([1-9]) ]] && {
	rr=$(( $rr - 1 ))
	met=${mr[$rr]}
	del 14
	msg -ama "método: \e[1;97m$met"
}
msg -bar
echo -e "	$(msg -ne 'ELIJA UN MÉTODO DE INYECCIÓN')"
msg -bar
menu_func 'realData' 'netData' 'raw'
back
echo -ne "\033[1;30m╰► Seleccione su opción: \e[92m"&&read zz
[[ $zz == @([1-3]) ]] && {
	zz=$(( $zz - 1 ))
	mxt=${xr[$zz]}&&del 8
	msg -ama "inject: \e[1;97m$mxt"
}
msg -bar
echo -e "	$(printext 'GENERANDO PAYLOADS')"
if [[ -e ${sdir[0]}/payloads ]]; then
	cat ${sdir[0]}/payloads > ~/pays.txt
else
	wget -O ~/pays.txt https://gitea.com/drowkid01/scriptdk1/raw/branch/main/Lista/payloads &> /dev/null
fi

if [[ -e ~/pays.txt ]]; then
	sed -s "s;realData;abc;g" ~/pays.txt > $HOME/xd.txt
	mv -f ~/xd.txt ~/pays.txt
	sed -i "s;netData;abc;g" ~/pays.txt
	sed -i "s;raw;abc;g" ~/pays.txt
	sed -i "s;abc;$mxt;g" ~/pays.txt
	sed -i "s;get;$met;g" ~/pays.txt
	sed -i "s;mhost;$host;g" ~/pays.txt
	sed -i "s;mip;$value;g" ~/pays.txt
	msg -bar
	msg -verd "[✓] PAYLOADS GENERADOS [✓]"
	msg -bar
	cat ~/pays.txt|tail -30
	msg -bar
	enter
else
	msg -verm 'error'
fi

