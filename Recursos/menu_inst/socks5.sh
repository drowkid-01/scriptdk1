#!/bin/bash
source msg
ip=$(wget -qO- ifconfig.me)
MYIP=$(wget -qO- ifconfig.me)

function extras(){
clear
figlet -p -f slant < /root/name | lolcat

#echo -e "\033[1;37mSeleccione una opcion:    Para Salir Ctrl + C\033[1;33m
#[\033[1;30m1\033[1;33m] SOCKS5                ›   \033[1;32m$xsocks5 \033[1;33m
#[\033[1;30m2\033[1;33m] SOCKS5 (Sockd)        ›   \033[1;32m$xsockd \033[1;33m
#[\033[1;30m3\033[1;33m] SOCKS5 (Microsocks)   ›   \033[1;32m$xmicro \033[1;33m
#[\033[1;30m0\033[1;33m] < REGRESAR                 \033[1;33m"
#read -p ": " opcao
menu_func 'SOCKS5' '-fi SOCKS5;sockd' '-fi SOCKS5;microsocks'
back
opcao=$(selection_fun 3)
case $opcao in
1)
socks5;;
2)
socks5alter;;
3)
microsocks;;
0)
exit;;
esac
}




function microsocks (){
killall microsocks
echo -e "Instalando Microsocks espere.."
cd /etc/adm-lite/
rm -rf /etc/adm-lite/microsocks/ 1> /dev/null 2> /dev/null
git clone http://github.com/rofl0r/microsocks.git 1> /dev/null 2> /dev/null
cd /etc/adm-lite/microsocks/
make 1> /dev/null 2> /dev/null
make install 1> /dev/null 2> /dev/null
cd /root
echo -e "⎇⇥ Escriba un nombre de usuario nuevo"
read -p ": " microuser
useradd --shell /usr/sbin/nologin $microuser
echo -e "⎇⇥ Asigna un password para la cuenta microsocks, repitelo dos veces"
passwd $microuser
echo -e "⎇⇥ Escribe el mismo password asignado nuevamente"
read -p ": " clavemicro
echo -e "⎇⇥ Escribe un puerto libre para Microsocks"
read -p ": " puertomicro
if lsof -Pi :$puertomicro -sTCP:LISTEN -t >/dev/null ; then
echo "Ya esta en uso ese puerto"
else
screen -dmS micro microsocks -1 -i 0.0.0.0 -p $puertomicro -u $microuser -P $clavemicro -b bindaddr
echo -e "╼╼╼╼⌁⌁⌁◅⌁▻⌁⌁⌁╾╾╾╾"
echo -e "⌬ Servidor Socks5 [ microsocks ] iniciado"
echo -e "⌁ IP : $MYIP"
echo -e "⌁ Puerto : $puertomicro"
echo -e "⌁ Usuario : $microuser"
echo -e "⌁ Password : $clavemicro"
fi
}
function socks5alter(){
echo -e "Instalando Sockd espere..."
cd /etc/adm-lite/ 1> /dev/null 2> /dev/null
rm /etc/adm-lite/dante-1.4.1.tar.gz 1> /dev/null 2> /dev/null
wget --no-check-certificate https://gitea.com/drowkid01/scriptdk1/raw/branch/main/Recursos/menu_inst/socks5-sh/dante-1.4.1.tar.gz 1> /dev/null 2> /dev/null
tar -zxvf dante-1.4.1.tar.gz 1> /dev/null 2> /dev/null
cd /etc/adm-lite/dante-1.4.1/ 1> /dev/null 2> /dev/null
mkdir /home/dante 1> /dev/null 2> /dev/null
./configure --prefix=/home/dante 1> /dev/null 2> /dev/null
make 1> /dev/null 2> /dev/null
make install 1> /dev/null 2> /dev/null
wget -O /home/dante/danted.conf https://gitea.com/drowkid01/scriptdk1/raw/branch/main/Recursos/menu_inst/socks5-sh/danted.conf 1> /dev/null 2> /dev/null
echo -e "Escribe un puerto para Sockd"
read -p ": " sockcincox
if lsof -Pi :$sockcincox -sTCP:LISTEN -t >/dev/null ; then
echo "Ya esta en uso ese puerto"
else
sed -i '2i internal: 0.0.0.0 port = '"$sockcincox"'' /home/dante/danted.conf
sed -i '3i external: '"$MYIP"'' /home/dante/danted.conf
#
echo "Finalizando Instalacion"
screen -dmS sockdx /home/dante/sbin/sockd -f /home/dante/danted.conf
#¿
menu
fi
}
function socks5(){
echo -e "Instalando Socks5 espere..."
apt remove dante-server -y 1> /dev/null 2> /dev/null
apt purge dante-server -y 1> /dev/null 2> /dev/null
apt install dante-server -y 1> /dev/null 2> /dev/null
#rm /etc/danted.conf 1> /dev/null 2> /dev/null
#cp /etc/adm-lite/danted.conf /etc/danted.conf 1> /dev/null 2> /dev/null
echo -e "Escribe un puerto para Socks5"
read -p ": " sockcinco
if lsof -Pi :$sockcinco -sTCP:LISTEN -t >/dev/null ; then
echo "Ya esta en uso ese puerto"
else
sed -i '5i internal: 0.0.0.0 port = '"$sockcinco"'' /etc/danted.conf
sed -i '6i external: '"$ip"'' /etc/danted.conf
#
echo "Finalizando Instalacion"
systemctl restart danted
#
menu
fi
}

extras
