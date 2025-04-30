#!/bin/bash
source msg
BEIJING_UPDATE_TIME=3
BEGIN_PATH=$(pwd)
INSTALL_WAY=0
HELP=0
REMOVE=0
CHINESE=0
BASE_SOURCE_PATH="https://multi.netlify.app"
UTIL_PATH="/etc/v2ray_util/util.cfg"
UTIL_CFG="$BASE_SOURCE_PATH/v2ray_util/util_core/util.cfg"
BASH_COMPLETION_SHELL="$BASE_SOURCE_PATH/v2ray"
CLEAN_IPTABLES_SHELL="$BASE_SOURCE_PATH/v2ray_util/global_setting/clean_iptables.sh"
#Centos 临时取消别名
[[ -f /etc/redhat-release && -z $(echo $SHELL|grep zsh) ]] && unalias -a
[[ -z $(echo $SHELL|grep zsh) ]] && ENV_FILE=".bashrc" || ENV_FILE=".zshrc"

[[ $(whoami) != 'root' ]] && {
	msg -verm 'se requiere ser usuario root para ejecutar el svript!'
	rm -rf `pwd`/$0
	exit
} || {
    [[ ! -e /var/ins ]] && {
	if [[ `command -v apt-get` ]];then
		PACKAGE_MANAGER='apt-get'
	elif [[ `command -v dnf` ]];then
		PACKAGE_MANAGER='dnf'
	elif [[ `command -v yum` ]];then
		PACKAGE_MANAGER='yum'
	else
		msg -verm 'sistema operativo no soportado'
		exit 1
	fi
	touch /var/ins
   }
}

if [[ -z $1 ]]; then
	echo -e "\e[1;97muso: \e[1;93m$0 \e[1;97m[\e[35m-h\e[1;97m|\e[35m--help\e[1;97m] [\e[35m-k\e[1;97m|\e[35m--keep\e[1;97m] [\e[35m--remove\e[1;97m]\n \e[93mEjemplos:"
	echo -e "	\e[35m-h, --help \e[1;97m| Menú de ayuda"
	echo -e "	\e[35m-k, --keep \e[1;97m| Restaurar archivo de instalación."
	echo -e "	\e[35m  --remove \e[1;97m| Remover configuraciones v2ray/xray."
fi

case $1 in
 -k | --keep);;
 -h | --help);;
    --instal)
	if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
		setenforce 0
	fi
        echo -e "${Info} Sincronizando tiempo!.. ${Font}"
        if [[ `command -v ntpdate` ]];then
            ntpdate pool.ntp.org
        elif [[ `command -v chronyc` ]];then
            chronyc -a makestep
        fi

        if [[ $? -eq 0 ]];then 
            echo -e "${OK} Tiempo Sync Exitosamente ${Font}"
            echo -e "${OK} Ahora: `date -R`${Font}"
        fi
    [[ ! $(type pip 2>/dev/null) ]] && colorEcho $RED "pip no install!" && exit 1

    [[ -e /etc/profile.d/iptables.sh ]] && rm -f /etc/profile.d/iptables.sh

    RC_SERVICE=`systemctl status rc-local|grep loaded|egrep -o "[A-Za-z/]+/rc-local.service"`

    RC_FILE=`cat $RC_SERVICE|grep ExecStart|awk '{print $1}'|cut -d = -f2`

    if [[ ! -e $RC_FILE || -z `cat $RC_FILE|grep iptables` ]];then
        LOCAL_IP=`curl -s http://api.ipify.org 2>/dev/null`
        [[ `echo $LOCAL_IP|grep :` ]] && IPTABLE_WAY="ip6tables" || IPTABLE_WAY="iptables" 
        if [[ ! -e $RC_FILE || -z `cat $RC_FILE|grep "/bin/bash"` ]];then
            echo "#!/bin/bash" >> $RC_FILE
        fi
        if [[ -z `cat $RC_SERVICE|grep "\[Install\]"` ]];then
            cat >> $RC_SERVICE << EOF

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload
        fi
        echo "[[ -e /root/.iptables ]] && $IPTABLE_WAY-restore -c < /root/.iptables" >> $RC_FILE
        chmod +x $RC_FILE
        systemctl restart rc-local
        systemctl enable rc-local

		$IPTABLE_WAY-save -c > /root/.iptables
	fi
	pip install -U v2ray_util
	if [[ -e $UTIL_PATH ]];then
		[[ -z $(cat $UTIL_PATH|grep lang) ]] && echo "lang=en" >> $UTIL_PATH
	else
		mkdir -p /etc/v2ray_util
		curl $UTIL_CFG > $UTIL_PATH
	fi
	[[ $CHINESE == 1 ]] && sed -i "s/lang=en/lang=zh/g" $UTIL_PATH
	rm -f /usr/local/bin/v2ray >/dev/null 2>&1
	ln -s $(which v2ray-util) /usr/local/bin/v2ray
	rm -f /usr/local/bin/xray >/dev/null 2>&1
	ln -s $(which v2ray-util) /usr/local/bin/xray
	[[ -e /etc/bash_completion.d/v2ray.bash ]] && rm -f /etc/bash_completion.d/v2ray.bash
	[[ -e /usr/share/bash-completion/completions/v2ray.bash ]] && rm -f /usr/share/bash-completion/completions/v2ray.bash
	curl $BASH_COMPLETION_SHELL > /usr/share/bash-completion/completions/v2ray
	curl $BASH_COMPLETION_SHELL > /usr/share/bash-completion/completions/xray
	if [[ -z $(echo $SHELL|grep zsh) ]];then
		source /usr/share/bash-completion/completions/v2ray
		source /usr/share/bash-completion/completions/xray
	fi
	bash <(curl -L -s https://multi.netlify.app/go.sh) --version v4.45.2
	[[ $(grep v2ray ~/$ENV_FILE) ]] && sed -i '/v2ray/d' ~/$ENV_FILE && source ~/$ENV_FILE
	[[ -z $(grep PYTHONIOENCODING=utf-8 ~/$ENV_FILE) ]] && echo "export PYTHONIOENCODING=utf-8" >> ~/$ENV_FILE && source ~/$ENV_FILE
	v2ray new

	echo ""
	clear&&clear
	config='/etc/v2ray/config.json'
	tmp='/etc/v2ray/temp.json'
	[[ ! -e $config ]] && touch $config
	chmod 777 $config
	msg -bar
	if [[ $(v2ray restart|grep success) ]]; then
		[[ $(which v2ray) ]] && v2ray info
		msg -bar
		echo -e "\033[1;32mINSTALACION FINALIZADA"
	else
	    	[[ $(which v2ray) ]] && v2ray info
	    	msg -bar
	        print_center -verm2 "INSTALACION FINALIZADA"
	        echo -e "\033[1;31m "  'Pero fallo el reinicio del servicio v2ray'
		echo -e " LEA DETALLADAMENTE LOS MENSAJES "
		echo -e ""
	fi
	cd ${BEGIN_PATH}
	msg -verd "multi-v2ray install success!\n"
	echo -e  "Por favor verifique el log"
	enter
 ;;
    --remove)
	bash <(curl -L -s https://multi.netlify.app/go.sh) --remove >/dev/null 2>&1
	bash <(curl -L -s https://multi.netlify.app/go.sh) --remove -x >/dev/null 2>&1
	for delete in `echo "/etc/v2ray /var/log/v2ray /etc/xray /var/log/xray"`; do
			(
		  rm -rf "$delete"
			) &> /dev/null
	done
	bash <(curl -L -s https://multi.netlify.app/v2ray_util/global_setting/clean_iptables.sh)
	pip uninstall v2ray_util -y
	for delete in `echo "/usr/share/bash-completion/completions/v2ray.bash /usr/share/bash-completion/completions/v2ray /usr/share/bash-completion/completions/xray /etc/bash_completion.d/v2ray.bash /usr/local/bin/v2ray /etc/v2ray_util /etc/profile.d/iptables.sh /root/.iptables"`; do
			(
		  rm -rf "$delete"
			) &> /dev/null
	done
	crontab -l|sed '/SHELL=/d;/v2ray/d'|sed '/SHELL=/d;/xray/d' > crontab.txt
	crontab crontab.txt >/dev/null 2>&1
	rm -f crontab.txt >/dev/null 2>&1
	if [[ ${PACKAGE_MANAGER} == 'dnf' || ${PACKAGE_MANAGER} == 'yum' ]];then
		systemctl restart crond >/dev/null 2>&1
	else
		systemctl restart cron >/dev/null 2>&1
	fi
	sed -i '/v2ray/d' ~/$ENV_FILE
	sed -i '/xray/d' ~/$ENV_FILE
	source ~/$ENV_FILE
	RC_SERVICE=`systemctl status rc-local|grep loaded|egrep -o "[A-Za-z/]+/rc-local.service"`
	RC_FILE=`cat $RC_SERVICE|grep ExecStart|awk '{print $1}'|cut -d = -f2`
	sed -i '/iptables/d' ~/$RC_FILE
	msg -bar&&echo -e "	$(msg -verd '[✓] módulo v2ray/xray desinstalado correctamente! [✓] ')"
;;
esac

