#!/bin/bash
#===============================================================
#   Last update:    01_05_2021_0607
#   Description:    Server BASE config.
#===============================================================

#BASE-CFG-s
#===============================================================
#=== Working Global Variables ===
VALIDATOR="validator.sh"
DATA_ARRAY=("")
DIR_SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR_ROOT="$(cd "$(dirname "${DIR_SCRIPT_ROOT}")" && pwd)"
DIR_SCRIPTS=$(sudo find ${DIR_ROOT} -type d -name "scripts" )
DIR_TMP="/tmp/workingTMP"
DIR_WORKSPACE="WORKSPACE"
ENV_FILE_NAME=".env"
ENV_FILE_LOCATION=$(find ${DIR_ROOT} -name "${ENV_FILE_NAME}")
ACTIVE_ENV=""
ACTIVE_USER=""
ACTIVE_DOMAIN=""
BASH_WHIPTAIL=""
ETH_WALLET=""
ARG1=$1
ARG2=$2
ARG3=$3
ARG4=$4
ARG5=$5
#=== Working Global Variables ===
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
#echo -e ${COLOUR_RED}YIKES!${END_COLOUR}
#=== TERMINAL ===
#===============================================================
#=== Support Fuctions ===
_cfgENV(){
#------------------------------------------------------------------------------------------
#   Description -   Read values from the environment file and store for local use.
#   Usage       -   _cfgENV
#------------------------------------------------------------------------------------------
    if [[ -s ${ENV_FILE_LOCATION} ]]; then
        while IFS= read line || [ -n "${line}" ]
        do
            case "${line}" in 
                ACTIVE_ENV*) ACTIVE_ENV="$(echo ${line//"ACTIVE_ENV="})" ;;
                ACTIVE_USER*) ACTIVE_USER="$(echo ${line//"ACTIVE_USER="})" ;;
                ACTIVE_DOMAIN*) ACTIVE_DOMAIN="$(echo ${line//"ACTIVE_DOMAIN="})" ;;
                BASH_WHIPTAIL*) BASH_WHIPTAIL="$(echo ${line//"BASH_WHIPTAIL="})" ;;
                ETH_WALLET*) ETH_WALLET="$(echo ${line//"ETH_WALLET="})" ;;
            esac
        done < ${ENV_FILE_LOCATION}
    fi
    _menuPrint "-c";
}
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
        -c)
            echo "=== CONFIG ==="
            echo "Script directory: ${DIR_SCRIPT_ROOT}"
            echo "Root directory: ${DIR_ROOT}"
            echo "TMP directory: ${DIR_TMP}"
            echo "Workspace directory: ${DIR_WORKSPACE}"
            echo "============="
            echo "=== MAIN FUNCTION SWITCHES ==="
            echo "ARG1 1: ${ARG1}"
            echo "ARG2 2: ${ARG2}"
            echo "ARG3 3: ${ARG3}"
            echo "ARG4 4: ${ARG4}"
            echo "ARG5 5: ${ARG5}"
            echo "============="
            echo "ACTIVE_ENV: ${ACTIVE_ENV}"
            echo "ACTIVE_USER: ${ACTIVE_USER}"
            echo "ACTIVE_DOMAIN: ${ACTIVE_DOMAIN}"
            echo "BASH_WHIPTAIL: ${BASH_WHIPTAIL}"
            echo "ETH_WALLET: ${ETH_WALLET}"
        ;;
    esac
}
_runScript(){
#------------------------------------------------------------------------------------------
#   Description -   Run a script.  
#   Usage       -   _runScript ${scriptName} ${scriptArgs} #arguments as an array
#------------------------------------------------------------------------------------------
    SCRIPT_NAME=$1
    SCRIPT_FLAGS=(${DATA_ARRAY[@]})
    bash ${DIR_SCRIPT_ROOT}/${SCRIPT_NAME} ${SCRIPT_FLAGS[@]}
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
#=== Support Fuctions ===
#===============================================================
#=== .env check ===
#Default vaules for .env (NOT_SET, 0x0_set_wallet_address) will return INVALID.
# echo -e "${COLOUR_YELLOW}Validating script args...${END_COLOUR}";
# ARGS_STATUS=$(_runScript ${VALIDATOR}) 
# if [[ "${ARGS_STATUS}" != "VALID" ]]; then
#     echo -e "${COLOUR_YELLOW}STATUS:${ARGS_STATUS}. Exiting...${END_COLOUR}"; read userWait; exit 0
# fi
#===============================================================
#_cfgENV; #Load the values from the .env file to local variables.
#===============================================================

#BASE-CFG-e


#===============================================================
#===============================================================
script_sys_config_docker="sys_config_docker.sh"
_cfgVbox(){
#------------------------------------------------------------------------------------------
#   Description -   Install VirtualBox guest additions
#------------------------------------------------------------------------------------------
    echo "Please insert the Guest Additions CD then press enter."
    echo "Devices -> Insert Guest Additions CD image"
    read insertCD
    sudo apt update -y
    sudo mkdir /media/cdrom
    sudo mount -t iso9660 /dev/cdrom /media/cdrom
    sudo apt install build-essential -y
    cd /media/cdrom/
    sudo ./VBoxLinuxAdditions.run;cd
    sudo umount /dev/cdrom
}

_generateDH(){
#------------------------------------------------------------------------------------------
#   Description -   Generate Diffie???Hellman key exchange certificate.
#------------------------------------------------------------------------------------------
    #---------- Quick -----------
    case $1 in
        -q) sudo openssl dhparam -dsaparam -out /etc/ssl/dhparam.pem 4096; echo -e "${COLOUR_GREEN}=== DONE ===${END_COLOUR}";sleep 3;return ;; 
    esac
    #----------------------------
    MENU_TITLE=("Diffie???Hellman key exchange certificate" "")
    MENU_PROMPT="Please select an option:"
    MENU_OPTION1=("1" "4096 bit certificate")
    MENU_OPTION2=("2" "2048 bit certificate")
    MENU_WARNING="*WARNING* Menu option not selected."

    if [[ "${SHOW_GUI}" == "False" ]]; then
        _menuPrint -t "${MENU_TITLE} (q to Quit)"
        _menuPrint -o "1" "${MENU_OPTION1[0]}" "${MENU_OPTION1[1]}"
        _menuPrint -o "2" "${MENU_OPTION2[0]}" "${MENU_OPTION2[1]}"
        _menuPrint -p "${MENU_PROMPT}"      
        read INPUT_VAL
        case ${INPUT_VAL} in 
            1) SELECTED_OPTION="${MENU_OPTION1[0]}" ;;
            2) SELECTED_OPTION="${MENU_OPTION2[0]}" ;;
            q) return ;;
        esac
    else
        _terminalResize; SELECTED_OPTION=$(whiptail --title "${MENU_TITLE} ${DBG_BANNER}" --radiolist \
        "${MENU_PROMPT}" ${TERMINAL_HEIGHT} ${TERMINAL_WIDTH} ${TERMINAL_LINES} \
        "${MENU_OPTION1[0]}" "${MENU_OPTION1[1]}" OFF \
        "${MENU_OPTION2[0]}" "${MENU_OPTION2[1]}" OFF 3>&1 1>&2 2>&3) || {
            echo "${MENU_WARNING}" 
        }
    fi

    case ${SELECTED_OPTION} in
        1) sudo openssl dhparam -dsaparam -out /etc/ssl/dhparam.pem 4096 ;;
        2) sudo openssl dhparam -dsaparam -out /etc/ssl/dhparam.pem 2048 ;;
        *) echo "Skipping DH cert generation." ;;    
    esac
}
_installPKGS() { 
#------------------------------------------------------------------------------------------
#   Description -   Package installation.
#   Usage       -   DATA_ARRAY=("tmux" "git" "iperf"); _installPKGS apt ${DATA_ARRAY}
#------------------------------------------------------------------------------------------
    LIST_PACKAGES=(${DATA_ARRAY[@]})
    FLAG_INSTALL="False"

    _findPackage(){
        FLAG_INSTALL="False"
        CHECK_PACKAGE=$(which $1)
        if [[ ${#CHECK_PACKAGE} = 0 ]]; then
            echo -e "${COLOUR_GREEN}=== Installing: $1 === ${END_COLOUR}"; sleep 1; FLAG_INSTALL="True"
        else
            echo -e "${COLOUR_BLUE}=== Already installed: $1 ===${END_COLOUR}"; sleep 1
        fi
    }

    for pkg in "${LIST_PACKAGES[@]}"; do
        _findPackage $pkg
        if [[ "${FLAG_INSTALL}" == "True" ]]; then
            if [[ "$1" == "apt" ]]; then
                sudo apt install -y $i || {
                    echo -e "${COLOUR_RED}=== Error. Skipping install for $pkg ===${END_COLOUR}"; sleep 1
                }
            fi

            # if [[ "$1" == "pacman" ]]; then
            #     pacman -S $pkg || {
            #         echo -e "${COLOUR_RED}=== Error. Skipping install for $pkg ===${END_COLOUR}"; sleep 1
            #     }
            # fi

            # if [[ "$1" == "yum" ]]; then
            #     yum install -y $pkg || {
            #         echo -e "${COLOUR_RED}=== Error. Skipping install for $pkg ===${END_COLOUR}"; sleep 1
            #     }
            # fi

            # if [[ "$1" == "pip3" ]]; then
            #     pip3 install $pkg || {
            #         echo -e "${COLOUR_RED}=== Error. Skipping install for $pkg ===${END_COLOUR}"; sleep 1
            #     }
            # fi
        fi
    done   
}

_main(){
#------------------------------------------------------------------------------------------
#   Description -   Server options.
#------------------------------------------------------------------------------------------
    _cfgENV
    case ${ACTIVE_ENV} in
        *VBOX*) _cfgVbox ;;
        *PRX*) sudo apt-get install qemu-guest-agent -y ;;
    esac
    
    #*************** Basic config ***************
    clear;
    sudo apt update && sudo apt dist-upgrade -y
    sudo dpkg-reconfigure -plow unattended-upgrades 
    sudo apt install ufw; sudo ufw allow 22  
    DATA_ARRAY=("git" "curl" "dnsutils" "vim" "nano" "screenfetch" "smbclient" "unzip" "tmux" "nmap" "make" "build-essential" "openssh-server" "tasksel" "net-tools" "iperf" "tree" "apache2-utils" "whois")
    _installPKGS apt ${DATA_ARRAY[@]}
    sudo wget -P ${DIR_TMP} https://launchpad.net/veracrypt/trunk/1.24-update7/+download/veracrypt-console-1.24-Update7-Ubuntu-20.04-amd64.deb;
    sudo dpkg -i ${DIR_TMP}/veracrypt-console-1.24-Update7-Ubuntu-20.04-amd64.deb
    sudo apt clean; sudo apt autoremove -y     
    #******************************
    
    MENU_TITLE=("=== Docker ===" "")
    MENU_PROMPT="Install Docker?"
    MENU_OPTION1=("1" "Yes")
    MENU_OPTION2=("2" "No")
    
    if [[ "${SHOW_GUI}" == "False" ]]; then
        _menuPrint -t "${MENU_TITLE} "
        _menuPrint -o "1" "${MENU_OPTION1[0]}" "${MENU_OPTION1[1]}"
        _menuPrint -o "2" "${MENU_OPTION2[0]}" "${MENU_OPTION2[1]}"
        _menuPrint -p "${MENU_PROMPT}"      
        read INPUT_VAL
        case ${INPUT_VAL} in 
            1) DATA_ARRAY=("-i"); _runScript ${script_sys_config_docker} ${DATA_ARRAY[@]};;
            *) echo "Skipping install." ;;
        esac
    else
        if (whiptail --title "${MENU_TITLE}" --yesno "${MENU_PROMPT}" ${TERMINAL_HEIGHT} ${TERMINAL_WIDTH}); then
            DATA_ARRAY=("-i"); _runScript ${script_sys_config_docker} ${DATA_ARRAY[@]}
        fi
    fi    

    _generateDH -q
    echo -e "${COLOUR_GREEN}=== Server base config complete ===${END_COLOUR}";sleep 3
    echo -e "${COLOUR_GREEN}PRESS ENTER TO CONTINUE... ${END_COLOUR}"; read exitPrompt
}
#===============================================================
#===============================================================
_main