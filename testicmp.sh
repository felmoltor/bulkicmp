#!/bin/bash

# Summary: Just test if a bunch of IPs are answering to ICMP echo or not.
# Author: @felmoltor

###########
# GLOBALS #
###########
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2; tput bold)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)

#############
# FUNCTIONS #
#############

function red() 
{
    echo -e "$RED$*$NORMAL"
}

function green() 
{
    echo -e "$GREEN$*$NORMAL"
}

function yellow() {
    echo -e "$YELLOW$*$NORMAL"
}

function isHostAvailable {
    local available
    error=0

    pingresponse=$( ping -c 2 $1 -q 2> /dev/null )
    pingError=$?
    if [[ $pingError != 0 || ${#pingresponse} == 0 ]];then
        error=1
    else
        packetLoss=$( echo $pingresponse | tail -n2 | head -n1 | awk -F, '{print $3}' | awk -F% '{print $1}' | tr -d ' ' )
        if [[ $packetLoss != '0' ]];then
            error=2
        fi  
    fi

    return $error
}

########
# MAIN #
########

if [[ "$1" == "" ]];then
    echo "Error. Provide a file name with domains/IPs or a single domain/IP to test ICMP echo" 1>&2
    echo "Usage: $0 <IP | Domain name| file with IP/Domains>"
    exit 1
fi

if [[ -f $1 ]];then
    # User provided a file with domains/IPs
    for line in $(cat $1 | sort -u);do
        isHostAvailable $line
        is=$?
        if [[ $is == 0 ]];then
            echo -n "$line: "
            green "Available"
        else
            echo -n "$line: "
            red "Unavailable"
        fi
    done
else
    isHostAvailable $1
    is=$?
    if [[ $is == 0 ]];then
        echo -n "$1: "
        green "Available"
    else
        echo -n "$1: "
        red "Unavailable"
    fi
fi
