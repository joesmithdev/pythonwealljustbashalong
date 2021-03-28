#!/bin/bash
#===============================================================
#   Last update:    03_27_2021_2241
#   Description:    ETH mining. 
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

DIR_SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" #Script directory
DIR_ROOT="$(cd "$(dirname "${DIR_SCRIPT_ROOT}")" && pwd)"
DIR_TMP="/tmp/workingTMP"
DIR_WORKSPACE="WORKSPACE"

gl_validator="validator.sh"

DIR_MINING="/tmp/ETHMINER"
SP_SERVER="eth-us.sparkpool.com:3333"
SP_ACC="<ENTER_SPARKPOOL_ACCOUNT>"
ETH_WAL1="<ENTER_ETH_WALLET_ADDRESS>"

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
    echo -e "${COLOUR_YELLOW}STATUS:${ARGS_STATUS}. Exiting...${END_COLOUR}"; read jhb ;sleep 3; exit 0
fi
#=================================

#===============================================================
#===============================================================
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
    sudo rm -rf ${DIR_MINING}/worker; sudo mkdir -p ${DIR_MINING}/worker;
    sudo wget -P ${DIR_MINING}/worker https://github.com/ethereum-mining/ethminer/releases/download/v0.18.0/ethminer-0.18.0-cuda-9-linux-x86_64.tar.gz; cd ${DIR_MINING}/worker
    sudo tar -xzvf ethminer-0.18.0-cuda-9-linux-x86_64.tar.gz; cd ${DIR_MINING}/worker/bin;
    #sudo ./ethminer -U -P stratum1+tcp://${ETH_WAL1}@${SP_SERVER};
    sudo ./ethminer -U -P stratum1+tcp://${SP_ACC}@${SP_SERVER};
}

_main(){
    case ${ARG1} in
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
_main $5 $6 $7 $8 $9