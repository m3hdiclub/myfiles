#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

clear
echo -e "${BLUE}=== S-UI Panel Manager ===${NC}"

install_sui() {
    clear
    echo -e "${YELLOW}Installing S-UI Panel...${NC}"
    echo -e "${BLUE}This will install the latest version of S-UI Panel${NC}"
    read -p "Do you want to continue? (y/N): " confirm
    
    if [[ "$confirm" == [yY] ]]; then
        echo -e "${GREEN}Starting installation...${NC}"
        bash <(curl -Ls https://raw.githubusercontent.com/alireza0/s-ui/master/install.sh)
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}S-UI Panel has been installed successfully${NC}"
        else
            echo -e "${RED}Installation failed${NC}"
        fi
    else
        echo -e "${YELLOW}Installation cancelled${NC}"
    fi
}

custom_install_sui() {
    clear
    echo -e "${YELLOW}Custom Install S-UI Panel${NC}"
    echo -e "${BLUE}You can specify the version to install${NC}"
    read -p "Enter the version (e.g. 1.1): " version
    
    if [[ ! -z "$version" ]]; then
        echo -e "${GREEN}Starting installation of version ${BLUE}$version${NC}..."
        bash <(curl -Ls https://raw.githubusercontent.com/alireza0/s-ui/master/install.sh) $version
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}S-UI Panel version $version has been installed successfully${NC}"
        else
            echo -e "${RED}Installation failed${NC}"
        fi
    else
        echo -e "${RED}No version specified, installation cancelled${NC}"
    fi
}

delete_sui() {
    clear
    echo -e "${RED}WARNING: This will delete S-UI Panel!${NC}"
    read -p "Are you sure you want to delete S-UI? (y/N): " confirm
    
    if [[ "$confirm" == [yY] ]]; then
        echo -e "${YELLOW}Deleting S-UI Panel...${NC}"
        s-ui delete
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}S-UI Panel has been deleted successfully${NC}"
        else
            echo -e "${RED}Deletion failed${NC}"
        fi
    else
        echo -e "${YELLOW}Deletion cancelled${NC}"
    fi
}

while true; do
    clear
    echo -e "${BLUE}=== S-UI Panel Manager ===${NC}"
    echo -e "${YELLOW}1)${NC} Install S-UI Panel"
    echo -e "${YELLOW}2)${NC} Custom Install (Specify Version)"
    echo -e "${RED}3)${NC} Delete S-UI Panel"
    echo -e "${BLUE}0)${NC} Return to Main Menu"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1) install_sui; read -p "Press Enter to continue..." ;;
        2) custom_install_sui; read -p "Press Enter to continue..." ;;
        3) delete_sui; read -p "Press Enter to continue..." ;;
        0) clear; echo -e "${GREEN}Returning to main menu...${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
    esac
done
