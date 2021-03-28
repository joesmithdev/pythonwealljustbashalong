#!/bin/bash
#===============================================================
#   Last update:    03_27_2021_2242
#   Description:    OSCP sample options.
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
    echo -e "${COLOUR_YELLOW}STATUS:${ARGS_STATUS}. Exiting...${END_COLOUR}"; sleep 3; exit 0
fi
#=================================
#===============================================================
#===============================================================
_main(){
    AUTORECON_DIR="${DIR_TMP}/AutoRecon/src/autorecon"
    RECONBOT_DIR="${DIR_TMP}/Reconbot"
    case ${ARG1} in
        1) sudo python3 ${AUTORECON_DIR}/autorecon.py ${ACTIVE_DOMAIN} ;;
        2) 
            TARGET_IP=$(dig +short ${ACTIVE_DOMAIN})
            sudo python3 ${RECONBOT_DIR}/reconbot ${TARGET_IP} --nmaponly 
        ;;
        3) 
            #Install Autorecon and Reconbot
            sudo apt install -y python3 python3-pip python3-toml seclists curl enum4linux gobuster nbtscan nikto nmap onesixtyone oscanner smbclient smbmap smtp-user-enum snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf
            sudo pip 3 install termcolor bs4
            mkdir -p ${DIR_TMP}; 
            cd ${DIR_TMP}; git clone https://github.com/Tib3rius/AutoRecon.git
            cd ${DIR_TMP}; git clone https://github.com/0bs3ssi0n/Reconbot.git
        ;;
    esac
    
    echo -e "${COLOUR_GREEN}=== DONE ===${END_COLOUR}";sleep 3
    echo -e "${COLOUR_GREEN}PRESS ENTER TO CONTINUE... ${END_COLOUR}"; read exitPrompt; return
}
#===============================================================
#===============================================================
_main $5 $6 $7 $8 $9