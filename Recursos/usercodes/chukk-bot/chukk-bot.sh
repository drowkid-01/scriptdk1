#!/bin/bash
adm="${main[0]}/data-admin.conf"
usr="${main[0]}/data-users.conf"

adm=$(echo $data|awk -F "|" '{print $1}')
pass=$(echo $data|awk -F "|" '{print $2}')
tkn=$(echo $data|awk -F "|" '{print $3}')

meu_ip_fun() {
    MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
    MIP2=$(wget -qO- ipv4.icanhazip.com)
    [[ "$MIP" != "$MIP2" ]] && IP="$MIP2" || IP="$MIP"
}

CIDdir=${main[0]} && [[ ! -d ${CIDdir} ]] && mkdir ${CIDdir}
CID="${CIDdir}/data-users.conf" && [[ ! -e ${CID} ]] && echo >${CID}
[[ $(dpkg --get-selections | grep -w "jq" | head -1) ]] || apt-get install jq -y &>/dev/null
[[ ! -e "/bin/ShellBot.sh" ]] && wget -O /bin/ShellBot.sh https://www.dropbox.com/s/gfwlkfq4f2kplze/ShellBot.sh &>/dev/null
[[ -e /etc/texto-bot ]] && rm /etc/texto-bot
LINE="━━━━━━━━━━━━━━━━━━━━━━"
source ShellBot.sh
ShellBot.init --token "$tkn" --monitor --flush --return map
ShellBot.username

reply() {
    [[ ! -z ${callback_query_message_chat_id[$id]} ]] && var=${callback_query_message_chat_id[$id]} || var=${message_chat_id[$id]}

    ShellBot.sendMessage --chat_id $var \
        --text "${repply:=$comando}" \
        --parse_mode html \
        --reply_markup "$(ShellBot.ForceReply)"
}

menu_print() {
    [[ ! -z ${callback_query_message_chat_id[$id]} ]] && var=${callback_query_message_chat_id[$id]} || var=${message_chat_id[$id]}
        ShellBot.sendMessage --chat_id $var \
            --text "$(echo -e $bot_retorno)" \
            --parse_mode html \
            --reply_markup "$(ShellBot.InlineKeyboardMarkup -b "$1")"
}

menu_tools() {
    [[ ! -z ${callback_query_message_chat_id[$id]} ]] && var=${callback_query_message_chat_id[$id]} || var=${message_chat_id[$id]}

    if [[ $(echo $permited | grep "${chatuser}") = "" ]]; then
        # ShellBot.sendMessage 	--chat_id ${message_chat_id[$id]} \
        ShellBot.sendMessage --chat_id $var \
            --text "<i>$(echo -e $bot_retorno)</i>" \
            --parse_mode html \
            --reply_markup "$(ShellBot.InlineKeyboardMarkup -b 'botao_tools_user')"
    else
        # ShellBot.sendMessage 	--chat_id ${message_chat_id[$id]} \
        ShellBot.sendMessage --chat_id $var \
            --text "<i>$(echo -e $bot_retorno)</i>" \
            --parse_mode html \
            --reply_markup "$(ShellBot.InlineKeyboardMarkup -b 'botao_tools_conf')"
    fi
}

menu_user() {
    [[ ! -z ${callback_query_message_chat_id[$id]} ]] && var=${callback_query_message_chat_id[$id]} || var=${message_chat_id[$id]}

    if [[ $(echo $permited | grep "${chatuser}") = "" ]]; then
        # ShellBot.sendMessage 	--chat_id ${message_chat_id[$id]} \
        ShellBot.sendMessage --chat_id $var \
            --text "<i>$(echo -e $bot_retorno)</i>" \
            --parse_mode html \
            --reply_markup "$(ShellBot.InlineKeyboardMarkup -b 'botao_control_user')"
    else
        # ShellBot.sendMessage 	--chat_id ${message_chat_id[$id]} \
        ShellBot.sendMessage --chat_id $var \
            --text "<i>$(echo -e $bot_retorno)</i>" \
            --parse_mode html \
            --reply_markup "$(ShellBot.InlineKeyboardMarkup -b 'botao_control_conf')"
    fi
}

msj_add() {
    ShellBot.sendMessage --chat_id ${1} \
        --text "<i>$(echo -e "$bot_retor")</i>" \
        --parse_mode html
}

upfile_fun() {
    [[ ! -z ${callback_query_message_chat_id[$id]} ]] && var=${callback_query_message_chat_id[$id]} || var=${message_chat_id[$id]}
    ShellBot.sendDocument --chat_id $var \
        --document @${1}
}

invalido_fun() {
    [[ ! -z ${callback_query_message_chat_id[$id]} ]] && var=${callback_query_message_chat_id[$id]} || var=${message_chat_id[$id]}
    local bot_retorno="$LINE\n"
    bot_retorno+="❌ COMANDO INVÁLIDO ❌\n"
    bot_retorno+="$LINE\n"
    ShellBot.sendMessage --chat_id $var \
        --text "<i>$(echo -e $bot_retorno)</i>" \
        --parse_mode html
    return 0
}

msj_fun() {
    [[ ! -z ${callback_query_message_chat_id[$id]} ]] && var=${callback_query_message_chat_id[$id]} || var=${message_chat_id[$id]}
    ShellBot.sendMessage --chat_id $var \
        --text "<i>$(echo -e "$bot_retorno")</i>" \
        --parse_mode html
    return 0
}
upfile_src() {
    cp ${CID} $HOME/
    upfile_fun $HOME/User-ID
    rm $HOME/User-ID
}
infosys_src() {

    #HORA Y FECHA
    unset _hora
    unset _fecha
    _hora=$(printf '%(%H:%M:%S)T')
    _fecha=$(printf '%(%D)T')

    #PROCESSADOR
    unset _core
    unset _usop
    _core=$(printf '%-1s' "$(grep -c cpu[0-9] /proc/stat)")
    _usop=$(printf '%-1s' "$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')")

    #MEMORIA RAM
    unset ram1
    unset ram2
    unset ram3
    ram1=$(free -h | grep -i mem | awk {'print $2'})
    ram2=$(free -h | grep -i mem | awk {'print $4'})
    ram3=$(free -h | grep -i mem | awk {'print $3'})

    unset _ram
    unset _usor
    _ram=$(printf ' %-9s' "$(free -h | grep -i mem | awk {'print $2'})")
    _usor=$(printf '%-8s' "$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')")

    unset os_sys
    os_sys=$(echo $(cat -n /etc/issue | grep 1 | cut -d' ' -f6,7,8 | sed 's/1//' | sed 's/      //')) && echo $system | awk '{print $1, $2}'
    meu_ip=$(wget -qO- ifconfig.me)
    bot_retorno="$LINE\n"
    bot_retorno+="S.O: $os_sys\n"
    bot_retorno+="Su IP es: $meu_ip\n"
    bot_retorno+="$LINE\n"
    bot_retorno+="Ram: $ram1 || En Uso: $_usor\n"
    bot_retorno+="USADA: $ram3 || LIBRE: $ram2\n"
    bot_retorno+="$LINE\n"
    bot_retorno+="CPU: $_core || En Uso: $_usop\n"
    bot_retorno+="$LINE\n"
    bot_retorno+="FECHA: $_fecha\n"
    bot_retorno+="HORA: $_hora\n"
    bot_retorno+="$LINE\n"
    menu_print 'adm'
}

cache_src() {

    #MEMORIA RAM
    unset ram1
    unset ram2
    unset ram3
    unset _usor
    _usor=$(printf '%-8s' "$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')")
    ram1=$(free -h | grep -i mem | awk {'print $2'})
    ram2=$(free -h | grep -i mem | awk {'print $4'})
    ram3=$(free -h | grep -i mem | awk {'print $3'})
    bot_retorno="==========Antes==========\n"
    bot_retorno+="Ram: $ram1 || EN Uso: $_usor\n"
    bot_retorno+="USADA: $ram3 || LIBRE: $ram2\n"
    bot_retorno+="=========================\n"
    msj_fun

    sleep 2

    sudo sync
    sudo sysctl -w vm.drop_caches=3 >/dev/null 2>&1

    unset ram1
    unset ram2
    unset ram3
    unset _usor
    _usor=$(printf '%-8s' "$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')")
    ram1=$(free -h | grep -i mem | awk {'print $2'})
    ram2=$(free -h | grep -i mem | awk {'print $4'})
    ram3=$(free -h | grep -i mem | awk {'print $3'})
    bot_retorno="==========Ahora==========\n"
    bot_retorno+="Ram: $ram1 || EN Uso: $_usor\n"
    bot_retorno+="USADA: $ram3 || LIBRE: $ram2\n"
    bot_retorno+="=========================\n"
    menu_print 'extras'
}

myid_src() {
    bot_retorno="====================\n"
    bot_retorno+="SU ID: ${chatuser}\n"
    bot_retorno+="====================\n"
    menu_print 'atras'
}

deleteID_reply() {
    delid=$(sed -n ${message_text[$id]}p ${CID})
    sed -i "${message_text[$id]}d" ${CID}
    bot_retorno="$LINE\n"
    bot_retorno+="ID eliminado con exito!\n"
    bot_retorno+="ID: ${delid}\n"
    bot_retorno+="$LINE\n"
    msj_fun
    #upfile_src
}

herramientas() {
    bot_retorno="-----[HERRAMIENTAS VIP]------\n"
    menu_tools
}

menu_src() {
    bot_retorno="━━━━━━━━━━━━━━━━━━━━━━\n"
    bot_retorno+="<b>HOLA!</b> ${message_from_username:=$message_from_first_name}\n"
    if [[ $(cat $adm | grep "${chatuser}") = "" ]]; then
        if [[ $(cat ${usr} | grep "${chatuser}") = ""            ]]; then
	    bot_retorno+="❌ NO CUENTAS CON ACCESO A ESTE BOT ❌\n"
	    msj_fun
        else
            bot_retorno+="━━━━━━━━━━━━━━━━━\n"
	    bot_retorno+="<b>COMANDOS</b>\n"
            bot_retorno+="━━━━━━━━━━━━━━━━━\n"
	    bot_retorno+="/infovps	=> detalles de tu vps.\n"
	    bot_retorno+="/puertos	=> puertos activos de tu vps.\n"
            bot_retorno+="━━━━━━━━━━━━━━━━━\n"
	    bot_retorno+="/add-ssh	=> crear usuario ssh.\n"
	    bot_retorno+="/add-v2ray	=> crear usuario v2ray.\n"
	    bot_retorno+="/add-ss	=> crear usuario shadowsocks.\n"
	    bot_retorno+="/add-ssr	=> crear usuario shadowsocks-r.\n"
	    bot_retorno+="/del-ssh	=> borrar usuario ssh.\n"
	    bot_retorno+="/del-v2ray	=> borrar usuario v2ray.\n"
	    bot_retorno+="/del-ss	=> borrar usuario shadowsocks.\n"
	    bot_retorno+="/del-ssr	=> borrar usuario shadowsocks-r.\n"
            bot_retorno+="━━━━━━━━━━━━━━━━━\n"
	    bot_retorno+="/backup	=> backup usuarios.\n"
	    bot_retorno+="/instal	=> instalar protocolos.\n"
	    bot_retorno+="/uninstall	=> desinstalar protocolos.\n"
            bot_retorno+="━━━━━━━━━━━━━━━━━\n"
	    bot_retorno+="⚡ <b>Powered by @drowkid01</b>⚡\n"
            bot_retorno+="━━━━━━━━━━━━━━━━━\n"
	    menu_print 'usr'
        fi

    else
            bot_retorno+="━━━━━━━━━━━━━━━━━\n"
	    bot_retorno+="<b>COMANDOS</b>\n"
            bot_retorno+="━━━━━━━━━━━━━━━━━\n"
	    bot_retorno+="/infovps	=> detalles de tu vps.\n"
	    bot_retorno+="/puertos	=> puertos activos de tu vps.\n"
            bot_retorno+="━━━━━━━━━━━━━━━━━\n"
	    bot_retorno+="/add-ssh	=> crear usuario ssh.\n"
	    bot_retorno+="/add-v2ray	=> crear usuario v2ray.\n"
	    bot_retorno+="/add-ss	=> crear usuario shadowsocks.\n"
	    bot_retorno+="/add-ssr	=> crear usuario shadowsocks-r.\n"
	    bot_retorno+="/del-ssh	=> borrar usuario ssh.\n"
	    bot_retorno+="/del-v2ray	=> borrar usuario v2ray.\n"
	    bot_retorno+="/del-ss	=> borrar usuario shadowsocks.\n"
	    bot_retorno+="/del-ssr	=> borrar usuario shadowsocks-r.\n"
            bot_retorno+="━━━━━━━━━━━━━━━━━\n"
	    bot_retorno+="/backup	=> backup usuarios.\n"
	    bot_retorno+="/instal	=> instalar protocolos.\n"
	    bot_retorno+="/uninstall	=> desinstalar protocolos.\n"
            bot_retorno+="━━━━━━━━━━━━━━━━━\n"
	    bot_retorno+="⚡ <b>Powered by @drowkid01</b>⚡\n"
            bot_retorno+="━━━━━━━━━━━━━━━━━\n"
        menu_print 'adm'
    fi
}


ShellBot.InlineKeyboardButton --button 'botao_conf' --line 1 --text '👤 CONTROL USER' --callback_data '/user'
ShellBot.InlineKeyboardButton --button 'botao_conf' --line 2 --text '❌ POWER ✅' --callback_data '/power'
ShellBot.InlineKeyboardButton --button 'botao_conf' --line 2 --text '🛠️ MENU' --callback_data '/menu'

#ShellBot.InlineKeyboardButton --button 'botao_conf' --line 2 --text '👤 CONECTAR SSH' --callback_data '/ssh'

ShellBot.InlineKeyboardButton --button 'botao_conf' --line 3 --text '🔑 KEYGEN' --callback_data '/keygen'

#ShellBot.InlineKeyboardButton --button 'botao_user' --line 1 --text '🌍New Pass' --callback_data '/pass'
#ShellBot.InlineKeyboardButton --button 'botao_conf' --line 3 --text '🌍New Pass' --callback_data '/pass'

ShellBot.InlineKeyboardButton --button 'botao_conf' --line 4 --text '⬇️DESCARGAR NIKOBHYN TOOLS⬇️' --callback_data '/descargar'
ShellBot.InlineKeyboardButton --button 'botao_user' --line 1 --text '⬇️DESCARGAR NIKOBHYN TOOLS⬇️' --callback_data '/descargar'

ShellBot.InlineKeyboardButton --button 'botao_user' --line 1 --text '♻️AGREGAR RESELLER♻️' --callback_data '/rell'
#ShellBot.InlineKeyboardButton --button 'botao_user' --line 1 --text '👤 CONECTAR SSH' --callback_data '/ssh'

ShellBot.InlineKeyboardButton --button 'botao_user' --line 1 --text '🛠️ TOOLS 🛠️' --callback_data '/tools'
ShellBot.InlineKeyboardButton --button 'botao_conf' --line 3 --text '🛠️ TOOLS 🛠️' --callback_data '/tools'

# BOTON DE CONECTAR SSH
#   BOTON USER
ShellBot.InlineKeyboardButton --button 'botao_tools_user' --line 1 --text '-> CAMBIAR PASSWORD ✅' --callback_data '/pass'
ShellBot.InlineKeyboardButton --button 'botao_tools_user' --line 2 --text '-> CREAR USUARIO KEY | AWS ✅' --callback_data '/pem'
ShellBot.InlineKeyboardButton --button 'botao_tools_user' --line 3 --text '-> CAMBIAR ROOT | AWS -> KEY ✅' --callback_data '/aws'
ShellBot.InlineKeyboardButton --button 'botao_tools_user' --line 4 --text '-> CAMBIAR ROOT | AZURE -> PASS ❌' --callback_data '/azure'
ShellBot.InlineKeyboardButton --button 'botao_tools_user' --line 5 --text '-> INSTALAR | SCRIPT -> NIXON-MX ✅' --callback_data '/ssh'
#  BOTON DE ADMIN
ShellBot.InlineKeyboardButton --button 'botao_tools_conf' --line 1 --text '-> CAMBIAR PASSWORD ✅' --callback_data '/pass'
ShellBot.InlineKeyboardButton --button 'botao_tools_conf' --line 2 --text '-> CREAR USUARIO KEY | AWS ✅' --callback_data '/pem'
ShellBot.InlineKeyboardButton --button 'botao_tools_conf' --line 3 --text '-> CAMBIAR ROOT | AWS -> KEY ✅' --callback_data '/aws'
ShellBot.InlineKeyboardButton --button 'botao_tools_conf' --line 4 --text '-> CAMBIAR ROOT | AZURE -> PASS ❌' --callback_data '/azure'
ShellBot.InlineKeyboardButton --button 'botao_tools_conf' --line 5 --text '-> INSTALAR | SCRIPT -> NIXON-MX ✅' --callback_data '/ssh'

#
ShellBot.InlineKeyboardButton --button 'botao_control_conf' --line 1 --text '👤 AGREGAR ID' --callback_data '/add'
ShellBot.InlineKeyboardButton --button 'botao_control_conf' --line 2 --text '🚮 ELIMINAR' --callback_data '/del'
ShellBot.InlineKeyboardButton --button 'botao_control_conf' --line 3 --text '👥 LISTA USER' --callback_data '/list'
ShellBot.InlineKeyboardButton --button 'botao_control_conf' --line 4 --text '🆔 ID' --callback_data '/ID'
ShellBot.InlineKeyboardButton --button 'botao_control_conf' --line 5 --text '♻️AGREGAR RESELLER♻️' --callback_data '/rell'
# Ejecutando escucha del bot
while true; do
    ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 30
    for id in $(ShellBot.ListUpdates); do

        chatuser="$(echo ${message_chat_id[$id]} | cut -d'-' -f2)"
        [[ -z $chatuser ]] && chatuser="$(echo ${callback_query_from_id[$id]} | cut -d'-' -f2)"
        echo $chatuser >&2
        #echo "user id $chatuser"

        comando=(${message_text[$id]})
        [[ -z $comando ]] && comando=(${callback_query_data[$id]})
        #echo "comando $comando"

        [[ ! -e "${CIDdir}/Admin-ID" ]] && echo "null" >${CIDdir}/Admin-ID
        permited=$(cat ${CIDdir}/Admin-ID)

        if [[ $(echo $permited | grep "${chatuser}") = "" ]]; then
            if [[ $(cat ${CID} | grep "${chatuser}") = "" ]]; then
                case ${comando[0]} in
                /[Ii]d | /[Ii]D) myid_src & ;;
                /[Aa]cceso | [Aa]cceso) autori & ;;
                /[Mm]enu | [Mm]enu | /[Ss]tart | [Ss]tart | [Cc]omensar | /[Cc]omensar) menu_src & ;;
                /[Aa]yuda | [Aa]yuda | [Hh]elp | /[Hh]elp) ayuda_id & ;;
                /* | *) invalido_fun & ;;
                esac
            else
                if [[ ${message_reply_to_message_message_id[$id]} ]]; then
                    case ${message_reply_to_message_text[$id]} in
                    '/rell') rell_reply ;;
                    '/ssh') ssh_reply ;;
                    '/pass') pass_reply ;;
                    '/aws') aws_reply ;;
                    '/pem') pem_reply ;;
                    *) invalido_fun ;;
                    esac

                elif [[ ${message_text[$id]} || ${callback_query_data[$id]} ]]; then
                    case ${comando[0]} in
                    /[Mm]enu | /[Ss]tart | /[Cc]omensar) menu_src & ;;
                    /[Ii]d) myid_src & ;;
                    /[Ii]nstalador) link_src & ;;
                    /[Rr]esell | /[Rr]eseller) mensajecre "${comando[1]}" & ;;
                    /[Rr]ell | /[Ss]sh | /[Pp]ass | /[Aa]ws | /[Pp]em) reply & ;;
                    /[Dd]escargar) descargar_apk & ;;
                    /[Tt]ools) herramientas & ;;
                    /[Kk]eygen | /[Gg]erar)
                        if grep -q "${chatuser}|1" "${CID}"; then
                            gerar_key &
                        else
                            otra_accion &
                        fi
                        ;;
                    # /[Cc]ambiar) creditos & ;;
                    *) invalido_fun & ;;
                    esac

                fi

            fi
        else

            if [[ ${message_reply_to_message_message_id[$id]} ]]; then
                case ${message_reply_to_message_text[$id]} in
                '/del') deleteID_reply ;;
                '/add') addID_reply ;;
                '/rell') rell_reply ;;
                '/ssh') ssh_reply ;;
                '/pass') pass_reply ;;
                '/aws') aws_reply ;;
                '/pem') pem_reply ;;
                *) invalido_fun ;;
                esac

            elif [[ ${message_document_file_id[$id]} ]]; then
                download_file

            elif [[ ${message_text[$id]} || ${callback_query_data[$id]} ]]; then

                case ${comando[0]} in
                /[Mm]enu | [Mm]enu | /[Ss]tart | [Ss]tart | [Cc]omensar | /[Cc]omensar) menu_src & ;;
                /[Aa]yuda | [Aa]yuda | [Hh]elp | /[Hh]elp) ayuda_src & ;;
                /[Ii]d | /[Ii]D) myid_src & ;;
                /[Aa]dd | /[Dd]el | /[Rr]ell) reply & ;;
                /[Ss]sh) reply & ;;
                /[Pp]ass) reply & ;;
                /[Aa]ws) reply & ;;
                /[Pp]em) reply & ;;
                /[Pp]ower) start_gen & ;;
                /[Dd]escargar) descargar_apk & ;;
                /[Uu]ser) usercontrol & ;;
                /[Tt]ools) herramientas & ;;
                /[Rr]esell | /[Rr]eseller) mensajecre "${comando[1]}" & ;;
                /[Kk]eygen | /[Gg]erar | [Gg]erar | [Kk]eygen) gerar_key & ;;
                    #
                    # /[Cc]ambiar)creditos &;;
                /[Ii]nfosys) infosys_src & ;;
                /[Ll]ist) listID_src & ;;
                /[Ii]nstalador) link_src & ;;
                /[Cc]ache) cache_src & ;;
                /* | *) invalido_fun & ;;
                esac

            fi

        fi
    done
done
