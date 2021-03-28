#!/bin/bash
#===============================================================
#   Last update:    03_27_2021_2040
#   Description:    Wireguard management.
#===============================================================
#=== Required ===
SHOW_GUI=$1
ACTIVE_ENV=$2
ACTIVE_USER=$3
ACTIVE_DOMAIN=$4
#=== Optional ===
ARG1=$5
ARG2=$6
ARG3=$7
ARG4=$8
ARG5=$9
#===============================================================
#=== TERMINAL ===
TERMINAL_HEIGHT=$(tput lines) || {
    TERMINAL_HEIGHT=20
}
TERMINAL_WIDTH=$(tput cols) || {
    TERMINAL_WIDTH=60
}
TERMINAL_LINES=12
#=== Terminal Text Output Colours ===
COLOUR_RED="\e[31m"
COLOUR_GREEN="\e[32m"
COLOUR_YELLOW="\e[33m"
COLOUR_BLUE="\e[34m"
END_COLOUR="\e[0m"
#echo -e "${COLOUR_RED}YIKES!${END_COLOUR}"
#===============================================================
#=== Working Global Variables ===
DATA_ARRAY=("")

DIR_SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" 
DIR_ROOT="$(cd "$(dirname "${DIR_SCRIPT_ROOT}")" && pwd)"
DIR_TMP="/tmp/wrkingTMP"
DIR_WORKSPACE="WORKSPACE"

gl_validator="validator.sh"
#===============================================================
echo "=== CONFIG ==="
echo "WHIPTAIL: $1"
echo "ENV: $2"
echo "USER: $3"
echo "DOMAIN: $4"
echo "Script directory: ${DIR_SCRIPT_ROOT}"
echo "Root directory: ${DIR_ROOT}"
echo "TMP directory: ${DIR_TMP}"
echo "Workspace directory: ${DIR_WORKSPACE}"
echo "============="
echo "=== MAIN FUNCTION SWITCHES ==="
echo "ARG1 1: $5"
echo "ARG2 2: $6"
echo "ARG3 3: $7"
echo "ARG4 4: $8"
echo "ARG5 5: $9"
echo "============="
#zenity --question --text="Start mining now?"
#zenity --info --text="You pressed \"Yes\"!"
#===============================================================
#===============================================================
#=== Support Fuctions ===
_menuPrint(){
#------------------------------------------------------------------------------------------
#   Description -   Formatted console output.
#   Usage       -   _menuPrint -t "Menu Name"
#                   _menuPrint -o "1" "Tag" "Description"                        
#------------------------------------------------------------------------------------------
    FORMAT="%-15s %4s %1s\n"
    FORMATH="%-15s %-4s %1s\n"
    case $1 in
        -t) clear; echo -e "${COLOUR_BLUE}---------- $2 ${DBG_BANNER} ----------${END_COLOUR}" ;; #Title
        -o) printf "${FORMAT}" "$2 - $3" "||" "$4" ;; #Menu option
        -i) echo -e "${COLOUR_BLUE}* -INFO- * $2${END_COLOUR}";; #Info message
        -h) printf "${FORMATH}" "$2" "||" "$3"; echo "-----------------------------------------------" ;; #Help menu option
        -p) echo "-----------------------------------------------";echo "$2"; echo "" ;; #Prompt
    esac
}

_runScript(){
#------------------------------------------------------------------------------------------
#   Description -   Run a script.  
#   Usage       -   _runScript ${scriptName} ${scriptArgs} #arguments as an array
#------------------------------------------------------------------------------------------
    SCRIPT_NAME=$1
    SCRIPT_FLAGS=(${DATA_ARRAY[@]})
    bash ${DIR_SCRIPT_ROOT}/${SCRIPT_NAME} ${SHOW_GUI} ${ACTIVE_ENV} ${ACTIVE_USER} ${ACTIVE_DOMAIN} ${SCRIPT_FLAGS[@]}
}

_terminalResize(){
#------------------------------------------------------------------------------------------
#   Description -   Resets the global variables related to the terminal size when using
#                   whiptail menus.   
#------------------------------------------------------------------------------------------
    TERMINAL_HEIGHT=$(tput lines) || {
        TERMINAL_HEIGHT=20
    }
    TERMINAL_WIDTH=$(tput cols) || {
        TERMINAL_WIDTH=60
    }
}

#=== Required arguments check ===
echo -e "${COLOUR_YELLOW}Validating script args...${END_COLOUR}"
ARGS_STATUS=$(_runScript ${gl_validator}) 
if [[ "${ARGS_STATUS}" != "VALID" ]]; then
    echo -e "${COLOUR_YELLOW}STATUS:${ARGS_STATUS}. Exiting...${END_COLOUR}"; sleep 3; exit 0
fi
#=================================

#===============================================================
#===============================================================
_main(){
    __network="10.10.40.0/24"
    __oct1="$(echo ${__network} | cut -d \. -f 1)"
    __oct2=$(echo ${__network} | cut -d \. -f 2)
    __oct3=$(echo ${__network} | cut -d \. -f 3)
    __srvrAddress="1"
    __netMask=$(echo ${__network} | cut -d \/ -f 2)
    __net1="131"
    __net2="151"
    __net3="181"
    __clientIPAddress=""
    __workingPUBKey=""
    __remoteServer="0.0.0.0:51820"
    
    _pkgInstall(){
        sudo apt update; sudo add-apt-repository ppa:wireguard/wireguard -y
        sudo apt install -y software-properties-common ufw openresolv wireguard wireguard-tools wireguard-dkms
    }

    _setNetIP(){
        __oct1=$(echo $1 | cut -d \. -f 1)
        __oct2=$(echo $1 | cut -d \. -f 2)
        __oct3=$(echo $1 | cut -d \. -f 3)
        __oct4=$(echo $(echo $1 | cut -d \. -f 4) | cut -d \/ -f 1)
        __netMask=$(echo $1 | cut -d \/ -f 2)
        __network=${__oct1}.${__oct2}.${__oct3}.${__oct4}/${__netMask}
    }

    _setNetwork(){
        MENU_TITLE=("=== Networking Options ===" "")
        MENU_PROMPT="Please enter a number:"
        MENU_OPTION1=("N1" "${__oct1}.${__oct2}.$__net1.0/${__netMask}")
        MENU_OPTION2=("N2" "${__oct1}.${__oct2}.$__net2.0/${__netMask}")
        MENU_OPTION3=("N3" "${__oct1}.${__oct2}.$__net3.0/${__netMask}")
        MENU_OPTION4=("ENTER" "Enter a different network")
        MENU_WARNING="*WARNING* Menu option not selected."

        if [[ "${SHOW_GUI}" == "False" ]]; then
            _menuPrint -t "${MENU_TITLE} (q to Quit)"
            _menuPrint -o "1" "${MENU_OPTION1[0]}" "${MENU_OPTION1[1]}"
            _menuPrint -o "2" "${MENU_OPTION2[0]}" "${MENU_OPTION2[1]}"
            _menuPrint -o "3" "${MENU_OPTION3[0]}" "${MENU_OPTION3[1]}"
            _menuPrint -o "4" "${MENU_OPTION4[0]}" "${MENU_OPTION4[1]}"
            _menuPrint -p "${MENU_PROMPT}" 
            read INPUT_VAL
            case ${INPUT_VAL} in 
                1) SELECTED_OPTION="${MENU_OPTION1[0]}" ;;
                2) SELECTED_OPTION="${MENU_OPTION2[0]}" ;;
                3) SELECTED_OPTION="${MENU_OPTION3[0]}" ;;
                4) SELECTED_OPTION="${MENU_OPTION4[0]}" ;;
                q) exit 0 ;;
            esac
        else
            _terminalResize; SELECTED_OPTION=$(whiptail --title "${MENU_TITLE} ${DBG_BANNER}" --radiolist \
            "${MENU_PROMPT}" ${TERMINAL_HEIGHT} ${TERMINAL_WIDTH} ${TERMINAL_LINES} \
            "${MENU_OPTION1[0]}" "${MENU_OPTION1[1]}" OFF \
            "${MENU_OPTION2[0]}" "${MENU_OPTION2[1]}" OFF \
            "${MENU_OPTION3[0]}" "${MENU_OPTION3[1]}" OFF \
            "${MENU_OPTION4[0]}" "${MENU_OPTION4[1]}" OFF 3>&1 1>&2 2>&3) || {
                echo "${MENU_WARNING}" 
            }
        fi
      
        if [[ ${#SELECTED_OPTION} = 0 ]]; then 
            echo -e "${COLOUR_GREEN}Exiting... PRESS ENTER TO CONTINUE... ${END_COLOUR}"; read exitPrompt; exit 0    
        else
            echo "User selected: ${SELECTED_OPTION}" 
          
            case ${SELECTED_OPTION} in
                N1) __newNetIP="${__oct1}.${__oct2}.${__net1}.0/${__netMask}" ;;
                N2) __newNetIP="${__oct1}.${__oct2}.${__net2}.0/${__netMask}" ;;
                N3) __newNetIP="${__oct1}.${__oct2}.${__net3}.0/${__netMask}" ;;
                ENTER)
                    MENU_PROMPT="Enter an address. eg. \"10.10.77.0/24\""
                    _menuPrint -p "${MENU_PROMPT}" 
                    read __newNetIP || {
                        echo "*WARNING* Network not set. Exiting..."; sleep 5; return
                    }
                ;;
                *) echo -e "${COLOUR_GREEN}Exiting. PRESS ENTER TO CONTINUE... ${END_COLOUR}"; read exitPrompt; exit 0 ;;
            esac          
            _setNetIP ${__newNetIP}
        fi
    }

    _setWorkingPUBKey(){
        clear
        echo "******************************************"
        echo "Please enter the public key for the $1:"
        read __workingPUBKey || {
            echo "No key entered. Exiting..."; sleep 5; return
        }
    }

    _setRemoteServer(){
        MENU_PROMPT="PleaseEnter an address for the remote server with the port. eg. \"0.0.0.0:51820\""
        _menuPrint -p "${MENU_PROMPT}" 
        read __remoteServer || {
            echo "*WARNING* Remote server not set. Exiting..."; sleep 5; return
        }
    }

    _serverInstall(){
        _setNetwork
        _pkgInstall
        sudo wg genkey | sudo tee /etc/wireguard/server_private.key | sudo wg pubkey | sudo tee /etc/wireguard/server_public.key
        __srvrPUBKey=$(sudo cat /etc/wireguard/server_public.key)
        __srvrPRIKey=$(sudo cat /etc/wireguard/server_private.key)   
        sudo bash -c 'cat > /etc/wireguard/wg0.conf' << EOFWGS
[Interface]
Address = ${__oct1}.${__oct2}.${__oct3}.$__srvrAddress/${__netMask}
SaveConfig = true
PrivateKey = ${__srvrPRIKey}
ListenPort = 51820
MTU = 1500

#sample
#[Peer]
#PublicKey = CLIENT-PUBLIC-KEY
#AllowedIPs = ${__oct1}.${__oct2}.${__oct3}.0/${__netMask}
#sample

EOFWGS
        sudo chmod 600 /etc/wireguard/ -R

        __targetLine="net.ipv4.ip_forward"
        __change="#net.ipv4.ip_forward"
        sudo sed -i -e "s|${__targetLine}|${__change}|g" /etc/sysctl.conf
        echo -e "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
        
        sudo sysctl -p || {
            echo "Catch Error"
        }
        
        __targetLine="DEFAULT_FORWARD_POLICY"
        __change="#DEFAULT_FORWARD_POLICY"
        sed -i -e "s|${__targetLine}|${__change}|g" /etc/sysctl.conf
        echo -e "DEFAULT_FORWARD_POLICY=\"ACCEPT\"" | sudo tee -a /etc/sysctl.conf
        
        clear; ip addr
        echo "******************************************"
        echo "Please enter the interface name. Example: ens18"
        read __interfaceName || {
            echo "No interface name entered. Exiting"; sleep 5; return
        }

        echo -e "# NAT table rules" | sudo tee -a /etc/ufw/before.rules
        echo -e "*nat" | sudo tee -a /etc/ufw/before.rules
        echo -e ":POSTROUTING ACCEPT [0:0]" | sudo tee -a /etc/ufw/before.rules
        echo -e "-A POSTROUTING -o ${__interfaceName} -j MASQUERADE" | sudo tee -a /etc/ufw/before.rules
        echo -e "# End each table with the 'COMMIT' line or these rules won't be processed" | sudo tee -a /etc/ufw/before.rules
        echo -e "COMMIT" | sudo tee -a /etc/ufw/before.rules

        sudo ufw enable || {
            echo "UFW not installed."
        }         
        
        sudo iptables -t nat -L POSTROUTING || {
            echo "Catch error"
        }  

        sudo apt install bind9 -y
        sudo systemctl start bind9 || {
            service bind9 start
        }
        
        sudo sed -i "/listen-on-v6/a allow-recursion { 127.0.0.1; ${__network}; };" /etc/bind/named.conf.options
        sudo systemctl restart bind9 || {
            service bind9 restart
        }

        sudo ufw insert 1 allow in from ${__network}
        sudo ufw allow 51820/udp
        
        sudo systemctl restart ufw || {
            service ufw restart || {
                echo "UFW not installed."
            }
        } 

        sudo systemctl start wg-quick@wg0 || {
            service wg-quick@wg0 start
        }

        sudo systemctl enable wg-quick@wg0 || {
            echo "No systemd"
        }
        sudo wg;
    }
 
    _clientInstall(){
        clear; echo "******************************************"
        echo "Enter an address for this client. eg. \"10.10.131.2/24\""
        read __clientIPAddress || {
            echo "No client IP entered. Exiting"; sleep 5; return
        }

        _setNetIP ${__clientIPAddress}
        _pkgInstall
        sudo wg genkey | sudo tee /etc/wireguard/client_private.key | sudo wg pubkey | sudo tee /etc/wireguard/client_public.key
        __clientPRIKey=$(sudo cat /etc/wireguard/client_private.key)
        __workingPUBKey=$(sudo cat /etc/wireguard/client_public.key)
        clear
        echo "Client public key: ${__workingPUBKey}"
        sudo bash -c 'cat > /etc/wireguard/wg-client0.conf' << EOFWGC
[Interface]
Address = ${__network}
SaveConfig = true
DNS = ${__oct1}.${__oct2}.${__oct3}.${__srvrAddress}/${__netMask}
PrivateKey = $__clientPRIKey

#sample
#[Peer]
#PublicKey = REMOTE_SERVER_PUBLIC_KEY
#AllowedIPs = 0.0.0.0/0
#Endpoint = REMOTE_SERVER_ADDRESS
#PersistentKeepalive = 25 
#sample
EOFWGC
        sudo chmod 600 /etc/wireguard/ -R
    }

    _menuAction(){
        SELECTED_OPTION=$1 
        case ${SELECTED_OPTION} in
            SI|1) _serverInstall ;;
            SA-User|2)
                _setNetwork
                clear; echo "******************************************"
                echo "Enter an address for the client. eg. \"10.10.131.2/32\""
                read __clientIPAddress || {
                    echo "No client IP entered. Exiting"; sleep 5; return
                }
                _setWorkingPUBKey CLIENT
                sudo wg set wg0 peer ${__workingPUBKey} allowed-ips ${__clientIPAddress}; sudo wg
            ;;
            SR-User|3) _setWorkingPUBKey CLIENT; sudo wg set wg0 peer ${__workingPUBKey} remove; sudo wg ;;
            CI|4) _clientInstall ;;
            CL-DOWN|5) sudo systemctl start wg-quick@wg-client0; sudo systemctl status wg-quick@wg-client0; sleep 5; return ;;
            CL-UP|6) sudo systemctl stop wg-quick@wg-client0; sudo systemctl status wg-quick@wg-client0; sleep 5; return ;;
            CA-Server|7)
                clear; echo -e "${COLOUR_YELLOW}INFO: Wireguard needs to be running to add or remove servers.${END_COLOUR}";sleep 3;
                _setRemoteServer 
                _setWorkingPUBKey SERVER
                sudo wg set wg-client0 peer ${__workingPUBKey} endpoint $__remoteServer allowed-ips 0.0.0.0/0 persistent-keepalive 25; sudo wg
            ;;
            CR-Server|8) 
                clear; echo -e "${COLOUR_YELLOW}INFO: Wireguard needs to be running to add or remove servers.${END_COLOUR}";sleep 3; 
                _setWorkingPUBKey SERVER ; sudo wg set wg-client0 peer ${__workingPUBKey} remove; sudo wg 
            ;;                
        esac
    }

    if [[ ${#ARG1} != 0 ]]; then 
        _menuAction ${ARG1}; 
        echo -e "${COLOUR_GREEN}=== Wireguard action complete ===${END_COLOUR}";sleep 3
        echo -e "${COLOUR_GREEN}PRESS ENTER TO CONTINUE... ${END_COLOUR}"; read exitPrompt; exit 0
    fi

    while true
    do
        MENU_TITLE=("Wireguard" "")
        MENU_PROMPT="Please select an option:"
        MENU_OPTION1=("SI" "Install Wireguard SERVER")
        MENU_OPTION2=("SA-User" "Add a user to the server")
        MENU_OPTION3=("SR-User" "Remove a user from the server")
        MENU_OPTION4=("CI" "Install Wireguard CLIENT")
        MENU_OPTION5=("CL-DOWN" "Stop WG")
        MENU_OPTION6=("CL-UP" "Start WG")
        MENU_OPTION7=("CA-Server" "Add a Server to the client config.")
        MENU_OPTION8=("CR-Server" "Remove a Server from the client config.")
        MENU_WARNING="*WARNING* Menu option not selected."

        if [[ "${SHOW_GUI}" == "False" ]]; then
            _menuPrint -t "${MENU_TITLE} (q to Quit)"
            _menuPrint -o "1" "${MENU_OPTION1[0]}" "${MENU_OPTION1[1]}"
            _menuPrint -o "2" "${MENU_OPTION2[0]}" "${MENU_OPTION2[1]}"
            _menuPrint -o "3" "${MENU_OPTION3[0]}" "${MENU_OPTION3[1]}"
            _menuPrint -o "4" "${MENU_OPTION4[0]}" "${MENU_OPTION4[1]}"
            _menuPrint -o "5" "${MENU_OPTION5[0]}" "${MENU_OPTION5[1]}"
            _menuPrint -o "6" "${MENU_OPTION6[0]}" "${MENU_OPTION6[1]}"
            _menuPrint -o "7" "${MENU_OPTION7[0]}" "${MENU_OPTION7[1]}"
            _menuPrint -o "8" "${MENU_OPTION8[0]}" "${MENU_OPTION8[1]}"
            _menuPrint -p "${MENU_PROMPT}" 
            read INPUT_VAL
            case ${INPUT_VAL} in 
                1) SELECTED_OPTION="${MENU_OPTION1[0]}" ;;
                2) SELECTED_OPTION="${MENU_OPTION2[0]}" ;;
                3) SELECTED_OPTION="${MENU_OPTION3[0]}" ;;
                4) SELECTED_OPTION="${MENU_OPTION4[0]}" ;;
                5) SELECTED_OPTION="${MENU_OPTION5[0]}" ;;
                6) SELECTED_OPTION="${MENU_OPTION6[0]}" ;;
                7) SELECTED_OPTION="${MENU_OPTION7[0]}" ;;
                8) SELECTED_OPTION="${MENU_OPTION8[0]}" ;;
                q) exit 0 ;;
            esac
        else
            _terminalResize; SELECTED_OPTION=$(whiptail --title "${MENU_TITLE} ${DBG_BANNER}" --radiolist \
            "${MENU_PROMPT}" ${TERMINAL_HEIGHT} ${TERMINAL_WIDTH} ${TERMINAL_LINES} \
            "${MENU_OPTION1[0]}" "${MENU_OPTION1[1]}" OFF \
            "${MENU_OPTION2[0]}" "${MENU_OPTION2[1]}" OFF \
            "${MENU_OPTION3[0]}" "${MENU_OPTION3[1]}" OFF \
            "${MENU_OPTION4[0]}" "${MENU_OPTION4[1]}" OFF \
            "${MENU_OPTION5[0]}" "${MENU_OPTION5[1]}" OFF \
            "${MENU_OPTION6[0]}" "${MENU_OPTION6[1]}" OFF \
            "${MENU_OPTION7[0]}" "${MENU_OPTION7[1]}" OFF \
            "${MENU_OPTION8[0]}" "${MENU_OPTION8[1]}" OFF 3>&1 1>&2 2>&3) || {
                echo "${MENU_WARNING}" 
            }
        fi
        
        if [[ ${#SELECTED_OPTION} = 0 ]]; then 
            echo -e "${COLOUR_YELLOW}Exiting...${END_COLOUR}"; sleep 3; exit 0
        else
            _menuAction ${SELECTED_OPTION} 
            echo -e "${COLOUR_GREEN}=== Wireguard action complete ===${END_COLOUR}";sleep 3
            echo -e "${COLOUR_GREEN}PRESS ENTER TO CONTINUE... ${END_COLOUR}"; read exitPrompt; return
        fi
    done
}
#===============================================================
#===============================================================
_main $5 $6 $7 $8 $9