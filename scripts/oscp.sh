#!/bin/bash
#===============================================================
#   Last update:    01_05_2021_0606
#   Description:    OSCP sample options.
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
TARGET_DOMAIN=${ACTIVE_DOMAIN}
_setTarget(){
    clear; echo -e "${COLOUR_YELLOW}== Please enter a target domain (eg. demo.testfire.net) ==${END_COLOUR}";
    read TARGET_DOMAIN; echo -e "${COLOUR_YELLOW}= TARGET_DOMAIN: ${TARGET_DOMAIN} =${END_COLOUR}"; sleep 3
    sed -i "s/${ACTIVE_DOMAIN}/${TARGET_DOMAIN}/g" "${DIR_ROOT}/.env"
}

_main(){
    _cfgENV
    TARGET_DOMAIN=${ACTIVE_DOMAIN}
    AUTORECON_DIR="${DIR_TMP}/AutoRecon/src/autorecon"
    RECONBOT_DIR="${DIR_TMP}/Reconbot"
    case ${TARGET_DOMAIN} in
        NOT_SET) _setTarget ;;
    esac

    echo -e "${COLOUR_YELLOW}=== TESTED on Kali. Results may differ on on ther distros. ===${END_COLOUR}";sleep 3
    case ${ARG1} in
        1) sudo python3 ${AUTORECON_DIR}/autorecon.py ${TARGET_DOMAIN} ;;
        2) 
            TARGET_IP=$(dig +short ${TARGET_DOMAIN})
            sudo python3 ${RECONBOT_DIR}/reconbot ${TARGET_IP} --nmaponly 
        ;;
        3) 
            #Install Autorecon and Reconbot
            sudo apt update;
            sudo apt install python3 python3-pip python3-toml curl gobuster nbtscan nikto nmap onesixtyone smbclient smbmap snmp whatweb wkhtmltopdf -y; 
            sudo apt install seclists enum4linux oscanner smtp-user-enum sslscan sipvicious tnscmd10g -y; 
            sudo pip3 install termcolor bs4
            mkdir -p ${DIR_TMP}; 
            cd ${DIR_TMP}; git clone https://github.com/Tib3rius/AutoRecon.git
            cd ${DIR_TMP}; git clone https://github.com/0bs3ssi0n/Reconbot.git
        ;;
    esac
    
    echo -e "${COLOUR_GREEN}=== DONE ===${END_COLOUR}";sleep 3
    echo -e "${COLOUR_GREEN}PRESS ENTER TO CONTINUE... ${END_COLOUR}"; read exitPrompt; exit 0
}
#===============================================================
#===============================================================
_main