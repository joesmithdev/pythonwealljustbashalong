#!/bin/bash
#===============================================================
#   Last update:    01_05_2021_0606
#   Description:    ETH mining. 
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
_cfgENV; 
DIR_MINING="/tmp/ETHMINER"
SP_SERVER="eth-us.sparkpool.com:3333"
SP_ACC="<ENTER_SPARKPOOL_ACCOUNT>" #Optional.

_installReq(){
    sudo add-apt-repository ppa:ethereum/ethereum;
    sudo apt update; sudo apt install -y nvidia-cuda-toolkit git mesa-common-dev cmake ethereum;
}

_installWallet(){
    echo -e "${COLOUR_GREEN}=== Installing Wallet ===${END_COLOUR}";sleep 3
    sudo rm -rf ${DIR_MINING}/wallet;
    sudo mkdir -p ${DIR_MINING}/wallet;
    sudo wget -P ${DIR_MINING}/wallet https://github.com/ethereum/mist/releases/download/v0.10.0/Ethereum-Wallet-linux64-0-10-0.zip
    cd ${DIR_MINING}/wallet; sudo unzip Ethereum-Wallet-linux64-0-10-0.zip 
    __userName=$(whoami)
    sudo chown -R ${__userName}:${__userName} ${DIR_MINING}
}

_startMining(){
    case ${ETH_WALLET} in
        *0x0_set_wallet_address*) _setAddress; _cfgENV ;;
    esac
    sudo rm -rf ${DIR_MINING}/worker; sudo mkdir -p ${DIR_MINING}/worker;
    sudo wget -P ${DIR_MINING}/worker https://github.com/ethereum-mining/ethminer/releases/download/v0.18.0/ethminer-0.18.0-cuda-9-linux-x86_64.tar.gz; cd ${DIR_MINING}/worker
    sudo tar -xzvf ethminer-0.18.0-cuda-9-linux-x86_64.tar.gz; cd ${DIR_MINING}/worker/bin;
    sudo ./ethminer -U -P stratum1+tcp://${ETH_WALLET}@${SP_SERVER};
    #sudo ./ethminer -U -P stratum1+tcp://${SP_ACC}@${SP_SERVER};
}

_setAddress(){
    clear; echo -e "${COLOUR_YELLOW}== Please enter your wallet address (eg. 0x0...42) ==${END_COLOUR}";
    read NEW_ETH_WALLET; echo -e "${COLOUR_GREEN}= Address: ${NEW_ETH_WALLET} =${END_COLOUR}"; sleep 3
    sed -i "s/${ETH_WALLET}/${NEW_ETH_WALLET}/g" "${DIR_ROOT}/.env"
}

_main(){
    case ${ARG1} in
        -a) _setAddress; return ;;
        -i) _installReq; return ;;
        -w) _installWallet; return ;;
        -m) _startMining; return ;;
        -d) 
            clear; echo -e "${COLOUR_GREEN}= How Long? (eg. 30m or 1h) =${END_COLOUR}";
            read TIME_DELAY; echo -e "${COLOUR_YELLOW}= Sleeping for ${TIME_DELAY} =${END_COLOUR}";
            sleep ${TIME_DELAY} || {
                echo -e "${COLOUR_YELLOW}=== Exiting Script ===${END_COLOUR}";sleep 3; return
            }
            _startMining; return 
        ;;
        -o) _installWallet; ${DIR_MINING}/wallet/ethereumwallet ;;
    esac

    echo -e "${COLOUR_GREEN}=== Exiting Script ===${END_COLOUR}";sleep 3
    echo -e "${COLOUR_GREEN}PRESS ENTER TO CONTINUE... ${END_COLOUR}"; read exitPrompt; return
}
#===============================================================
#===============================================================
_main