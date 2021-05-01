#!/bin/bash
#===============================================================
#   Last update:    01_05_2021_0607
#   Description:    Environment file validator. Base config management.
#--------------------------------------------------------------
#   -u         :    Copy all data between the tags base tags to all other scripts.
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
_cfgUpdate(){
    cd ${DIR_SCRIPTS}; SCRIPT_LIST=$(ls)
    for item in ${SCRIPT_LIST[*]}; do
        if [[ "${item}" == "${VALIDATOR}" ]]; then
            echo -e "${COLOUR_YELLOW}== Skipping validator ==${END_COLOUR}"
        else
            _tagOperations -c "BASE-CFG" "${DIR_SCRIPTS}/${VALIDATOR}" "${DIR_SCRIPTS}/${item}";
        fi
    done
    echo -e "${COLOUR_GREEN}== Base config updated ==${END_COLOUR}"
}

_tagOperations(){
#------------------------------------------------------------------------------------------
#   Description -   Copy or wipe data between tags. 
#   Arg         -   [w/c] - Wipe,Copy to destFile.
#   Usage       -   _tagOperations -w tagName targetFile
#   Usage       -   _tagOperations -c tagName srcFile destFile
#------------------------------------------------------------------------------------------
    _wipeTag(){
    #------------------------------------------------------------------------------------------
    #   Description -   Clears the data between the specified tags in a file.  
    #   Usage       -   _wipeTag tagName targetFile
    #------------------------------------------------------------------------------------------
        echo "wiping tag..."
        TAG_NAME=$1 || {
            echo "A name is required."; return
        }

        TAG_TARGET_FILE=$2 || {
            echo "A target file is required."; return
        }

        TAG_START=$(grep -n ${TAG_NAME}-s ${TAG_TARGET_FILE} )
        TAG_END=$(grep -n ${TAG_NAME}-e ${TAG_TARGET_FILE} )
        TAG_LINE_START=${TAG_START%:*} 
        TAG_LINE_END=${TAG_END%:*}
        
        if [[ -z "${TAG_START}"  ||  -z "${TAG_END}" ]];then
            echo "Tag \"${TAG_NAME}\" was not found in ${TAG_TARGET_FILE}";
            echo "Creating tag...";
            sudo sed -i "7 i#${TAG_NAME}-s" ${TAG_TARGET_FILE}
            sudo sed -i "8 i#${TAG_NAME}-e" ${TAG_TARGET_FILE}
        else
            LINE_FIRST=$((${TAG_LINE_START} + 1))
            if [[ ${TAG_LINE_END} -eq ${LINE_FIRST} ]];then
                echo "The specified tag is already empty.";
            else
                echo -e "Tag \"${TAG_NAME}\" found in ${TAG_TARGET_FILE} \nRemoving old data..."
                LINE_ADJUSTED_START=$((${TAG_LINE_START} + 1))
                LINE_ADJUSTED_END=$((${TAG_LINE_END} - 1))
                sudo sed -i "${LINE_ADJUSTED_START},${LINE_ADJUSTED_END}d" ${TAG_TARGET_FILE}
                echo "Lines ${LINE_ADJUSTED_START} to ${LINE_ADJUSTED_END} were removed from ${TAG_TARGET_FILE}"
            fi
        fi
    }

    _copyTag(){
    #------------------------------------------------------------------------------------------
    #   Description -   Copies the data between the specified target file.  
    #   Usage       -   _copyTag tagName srcFile destFile
    #------------------------------------------------------------------------------------------
        TAG_NAME=$1 || {
            echo "A name is required."; return
        }

        TAG_SOURCE_FILE=$2 || {
            echo "A source file is required."; return
        }

        TAG_DESTINATION_FILE=$3 || {
            echo "A destination file is required."; return
        }

        sudo rm -rf ${DIR_TMP}/copyData.txt 2> /dev/null || {
            echo "Please wait..." ;
        }
        mkdir -p ${DIR_TMP}; touch ${DIR_TMP}/copyData.txt

        TAG_SOURCE_FILE_START=$(grep -n ${TAG_NAME}-s ${TAG_SOURCE_FILE} )
        TAG_SOURCE_FILE_END=$(grep -n ${TAG_NAME}-e ${TAG_SOURCE_FILE} )
        TAG_SOURCE_FILE_LINE_START=${TAG_SOURCE_FILE_START%:*} 
        TAG_SOURCE_FILE_LINE_END=${TAG_SOURCE_FILE_END%:*}
        
        if [[ -z "${TAG_SOURCE_FILE_START}"  ||  -z "${TAG_SOURCE_FILE_END}" ]];then
            echo "Tag \"${TAG_NAME}\" was not found in ${TAG_SOURCE_FILE}"; sleep 3
        else
            echo -e "Tag \"${TAG_NAME}\" found in ${TAG_SOURCE_FILE}"
            LINE_ADJUSTED_START=$((${TAG_SOURCE_FILE_LINE_START} + 1))
            LINE_ADJUSTED_END=$((${TAG_SOURCE_FILE_LINE_END} - 1))
            sudo sed -n "${LINE_ADJUSTED_START},${LINE_ADJUSTED_END}p" ${TAG_SOURCE_FILE} > ${DIR_TMP}/copyData.txt
            _tagOperations -w ${TAG_NAME} ${TAG_DESTINATION_FILE}
            
            __destStartTAG=$(grep -n ${TAG_NAME}-s ${TAG_DESTINATION_FILE} )
            __destEndTAG=$(grep -n ${TAG_NAME}-e ${TAG_DESTINATION_FILE} )
            __destStartLINE=${__destStartTAG%:*} 
            __insertLINE=$((${__destStartLINE} + 1))
            
            cat ${DIR_TMP}/copyData.txt | sudo sed -i "${__insertLINE}e cat /dev/stdin" ${TAG_DESTINATION_FILE}
            echo "Tag ops complete for ${TAG_NAME} at ${TAG_DESTINATION_FILE}"
        fi
        sudo rm -rf ${DIR_TMP}/copyData.txt 2> /dev/null || {
            echo "Please wait..." ;
        }
    }

    case $1 in
        -w) _wipeTag "$2" "$3" ;;
        -c) _copyTag "$2" "$3" "$4" ;;
    esac
}

_main(){
    clear;
    case ${ARG1} in
        -u) clear; echo -e "${COLOUR_BLUE}== UPDATING ==${END_COLOUR}"; _cfgUpdate; exit 0 ;;
    esac
    RETURN_VAL="VALID"
    if [[ -s ${DIR_ROOT}/${ENV_FILE_NAME} ]]; then
        while IFS= read line || [ -n "${line}" ]
        do
            case "${line}" in 
                *NOT_SET*) RETURN_VAL="${line}"; break ;;
                *set_wallet_address*) RETURN_VAL="${line}"; break ;;
            esac
        done < ${DIR_ROOT}/${ENV_FILE_NAME}
        echo ${RETURN_VAL}
    else
        echo "Env file not found. Creating..."; _createENV
    fi
}

_createENV(){
    touch ${DIR_ROOT}/${ENV_FILE_NAME}
    echo -e "ACTIVE_ENV=NOT_SET" | tee -a ${DIR_ROOT}/${ENV_FILE_NAME}
    echo -e "ACTIVE_USER=NOT_SET" | tee -a ${DIR_ROOT}/${ENV_FILE_NAME}
    echo -e "ACTIVE_DOMAIN=NOT_SET" | tee -a ${DIR_ROOT}/${ENV_FILE_NAME}
    echo -e "BASH_WHIPTAIL=NOT_SET" | tee -a ${DIR_ROOT}/${ENV_FILE_NAME}
    echo -e "ETH_WALLET=0x0_set_wallet_address" | tee -a ${DIR_ROOT}/${ENV_FILE_NAME}
}

#===============================================================
#===============================================================
_main