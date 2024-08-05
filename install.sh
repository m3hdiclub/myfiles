#!/bin/bash
red='\033[0;31m'
bblue='\033[0;34m'
yellow='\033[0;33m'
green='\033[0;32m'
plain='\033[0m'
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
yellow(){ echo -e "\033[33m\033[01m$1\033[0m";}
blue(){ echo -e "\033[36m\033[01m$1\033[0m";}
white(){ echo -e "\033[37m\033[01m$1\033[0m";}
bblue(){ echo -e "\033[34m\033[01m$1\033[0m";}
rred(){ echo -e "\033[35m\033[01m$1\033[0m";}
readtp(){ read -t5 -n26 -p "$(yellow "$1")" $2;}
readp(){ read -p "$(yellow "$1")" $2;}

# install requirements
if ! command -v qrencode &> /dev/null || ! command -v jq &> /dev/null || ! dpkg -l | grep -q net-tools; then
    sudo apt-get update
    if ! command -v qrencode &> /dev/null; then
        rred "qrencode is not installed. Installing..."
        sudo apt-get install qrencode -y

        # Check if installation was successful
        if [ $? -eq 0 ]; then
            red "qrencode is now installed."
        else
            red "Error: Failed to install qrencode."
        fi
    else
        green "qrencode is already installed."
    fi

    if ! command -v jq &> /dev/null; then
        rred "Installing jq..."
        if sudo apt-get install jq -y; then
            red "jq installed successfully."
        else
            red "Error: Failed to install jq."
            exit 1
        fi
    else
        green "jq is already installed."
    fi

    if ! dpkg -l | grep -q net-tools; then
        rred "net-tools is not installed. Installing..."
        sudo apt-get install net-tools -y

        # Check if installation was successful
        if [ $? -eq 0 ]; then
            red "net-tools is now installed."
        else
            red "Error: Failed to install net-tools."
            exit 1
        fi
    else
        green "net-tools is already installed."
    fi
else
    green "qrencode, jq, and net-tools are already installed."
fi

# ----------------------------------------Show Menus------------------------------------------------
display_main_menu() {
    clear 
    echo
    echo
    bblue "                 █████╗ ██╗ ██████╗              "
    bblue "                ██╔══██╗██║██╔═══██╗             "
    bblue "                ███████║██║██║   ██║             "
    bblue "                ██╔══██║██║██║   ██║             "
    bblue "                ██║  ██║██║╚██████╔╝             "
    bblue "                ╚═╝  ╚═╝╚═╝ ╚═════╝              "
    bblue "               All-in-one Proxy Tool             "
    white "                  Created by Hosy                "
    white "------------------------------------------------------"
    white " Github: https://github.com/hrostami"
    white " Twitter: https://twitter.com/hosy000"
    echo
    echo -e "${plain}Thanks ${red}iSegaro${plain} for all the tutorials and new methods! "
    echo
    yellow "-----------------Protocols----------------------------"
    green "1. Chisel Tunnel         2. Hysteria V2"
    echo
    green "3. Tuic                  4. Naive"
    echo
    green "5. SSH                   6. Reality+Tuic+Hy2+ws+Argo"
    echo
    yellow "--------------------Tools-----------------------------"
    green "7. Reverse TLS Tunnel    8. Install Panels"
    echo
    green "9. Warp                  10. Telegram Proxy"
    echo
    green "11. Show used Ports      12. Set Domains"
    echo
    green "13. DNS(SmartSNI)        14. Hiddify Reality Scanner"
    echo
    rred "0. Exit"
    echo "------------------------------------------------------"
}

display_dns_menu() {
    clear
    echo "------------------------------------------------------"
    echo -e "${plain}SmartSNI is created by ${yellow}bepass-org${plain}"
    echo -e "Please check out and ${yellow}star ${plain}his Github repo"
    echo -e "${yellow}https://github.com/bepass-org/smartSNI${plain}"
    echo "------------------------------------------------------"
    echo
    echo "**********************************************"
    yellow "                DNS Menu                 "
    echo "**********************************************"
    green "1. Auto Install"
    echo
    green "2. Add website"
    echo
    green "0. Back to Main Menu"
    echo "**********************************************"
    JSON_FILE="/root/smartSNI/config.json"
    existing_domains=$(jq -r '.domains | keys[]' "$JSON_FILE")
    yellow "Existing domains: "
    white "$existing_domains"
    echo
    echo "**********************************************"
}
