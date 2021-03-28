#!/bin/bash
#===============================================================
#   Last update:    03_27_2021_2036
#   Description:    Validator. Checks for empty required arguments.
#===============================================================
#=== Required ===
SHOW_GUI=$1
ACTIVE_ENV=$2
ACTIVE_USER=$3
ACTIVE_DOMAIN=$4
#===============================================================
#===============================================================
_main(){
    #=== Required arguments check ===
    RETURN_VAL="VALID"
    if [[ ${#ACTIVE_ENV} = 0 ]]; then
        RETURN_VAL="ENV INVALID"; 
    fi

    if [[ ${#ACTIVE_USER} = 0 ]]; then
        RETURN_VAL="USER INVALID"; 
    fi

    if [[ ${#ACTIVE_DOMAIN} = 0 ]]; then
        RETURN_VAL="DOMAIN INVALID"; 
    fi

    if [[ ${#SHOW_GUI} = 0 ]]; then
        RETURN_VAL="GUI INVALID"; 
    fi

    echo ${RETURN_VAL}
}
#===============================================================
#===============================================================
_main $5 $6 $7 $8 $9