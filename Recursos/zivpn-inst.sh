#!/bin/bash
clear
cat <<< '╻┏┓╻┏━┓╺┳╸┏━┓╻  ┏━┓┏┓╻╺┳┓┏━┓   ╺━┓╻╻ ╻┏━┓┏┓╻
┃┃┗┫┗━┓ ┃ ┣━┫┃  ┣━┫┃┗┫ ┃┃┃ ┃   ┏━┛┃┃┏┛┣━┛┃┗┫
╹╹ ╹┗━┛ ╹ ╹ ╹┗━╸╹ ╹╹ ╹╺┻┛┗━┛   ┗━╸╹┗┛ ╹  ╹ ╹'
msg -bar
msg -ama 'ACTUALIZANDO PAQUETES'
apt update -y && apt upgrade -y
systemctl stop zivpn.service 1> /dev/null 2> /dev/null
clear
msg -bar
msg -ama 'DESCARGANDO CÓDIGO BASE DE ZIVPN'
[[ $(uname -m) != 'x86_64' ]] && {
	fun_bar 'wget https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn'
} || {
	fun_bar "$(wget -O /usr/local/bin/zivpn https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-arm64 &> /dev/null)"
}

chmod +x /usr/local/bin/zivpn
[[ ! -d /etc/adm-lite/zivpn ]] && {
	mkdir /etc/adm-lite/zivpn 1> /dev/null 2> /dev/null
	ln -s /etc/adm-lite/zivpn /etc/zivpn
}
sleep 2
for((i=0;i<2;i++));do tput cuu1&&tput dl1 ; done
msg -ama 'DESCARGANDO COMPONENTES ESENCIALES'
fun_bar 'wget https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/config.json -O /etc/adm-lite/zivpn/config.json'
sleep 2
clear
cat <<< '╻┏┓╻┏━┓╺┳╸┏━┓╻  ┏━┓┏┓╻╺┳┓┏━┓   ╺━┓╻╻ ╻┏━┓┏┓╻
┃┃┗┫┗━┓ ┃ ┣━┫┃  ┣━┫┃┗┫ ┃┃┃ ┃   ┏━┛┃┃┏┛┣━┛┃┗┫
╹╹ ╹┗━┛ ╹ ╹ ╹┗━╸╹ ╹╹ ╹╺┻┛┗━┛   ┗━╸╹┗┛ ╹  ╹ ╹'
msg -bar
echo -e "	$(printext 'GENERANDO CERTIFICADO')"
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=California/L=Los Angeles/O=@drowkid01/OU=@drowkid01/CN=@drowkid01" -keyout "/etc/adm-lite/zivpn/zivpn.key" -out "/etc/adm-lite/zivpn/zivpn.crt"
sysctl -w net.core.rmem_max=16777216 1> /dev/null 2> /dev/null
sysctl -w net.core.wmem_max=16777216 1> /dev/null 2> /dev/null
cat <<EOF > /etc/systemd/system/zivpn.service
[Unit]
Description=UDP-ZIVPN by @drowkid01
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/adm-lite/zivpn
ExecStart=/usr/local/bin/zivpn server -c /etc/adm-lite/zivpn/config.json
Restart=always
RestartSec=3
Environment=ZIVPN_LOG_LEVEL=info
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF
tput cuu1&&tput dl1
echo -e "	$(msg -verd '[✓] CERTIFICADO GENERADO CORRECTAMENTE [✓]')"
echo -e "	    \e[1;97mCertificado alojado en: /etc/zivpn"
msg -bar
msg -ama 'Ingrese 1 ó varias contraseñas separadas por comas, ejemplo: elkakas,chumoghesjoto,melapela'
#read -p "Enter passwords separated by commas, example: passwd1,passwd2 (Press enter for Default 'zi'): " input_config
msg -ne 'Ingrese la/las contraseña/s'
read -p $': \e[1;32m ' input_config
if [ -n "$input_config" ]; then
    IFS=',' read -r -a config <<< "$input_config"
    if [ ${#config[@]} -eq 1 ]; then
        config+=(${config[0]})
    fi
else
    config=("zi")
fi

new_config_str="\"config\": [$(printf "\"%s\"," "${config[@]}" | sed 's/,$//')]"

sed -i -E "s/\"config\": ?\[[[:space:]]*\"zi\"[[:space:]]*\]/${new_config_str}/g" /etc/zivpn/config.json

systemctl enable zivpn.service
systemctl start zivpn.service
iptables -t nat -A PREROUTING -i $(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1) -p udp --dport 6000:19999 -j DNAT --to-destination :5667
ufw allow 6000:19999/udp
ufw allow 5667/udp
rm zi2.* 1> /dev/null 2> /dev/null
clear
msg -bar&&msg -verd '[✓] MÓDULO ZIVPN INSTALADO CORRECTAMENTE [✓]'

