#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Clear screen function
clear_screen() {
    clear
    show_banner
}

# Check root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}This script must be run as root${NC}"
        echo -e "Please run with: ${YELLOW}sudo bash script.sh${NC}"
        exit 1
    fi
}

# Show banner
show_banner() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${WHITE}         System Management Tools        ${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo
}

# Function to show script descriptions
show_description() {
    case $1 in
        1) echo -e "   ${CYAN}└─ UFW Firewall Manager${NC}" ;;
        2) echo -e "   ${CYAN}└─ Changing SSH Port${NC}" ;;
		3) echo -e "   ${CYAN}└─ Set DNS Address${NC}" ;;
    esac
}

# Main menu display function
show_menu() {
    echo -e "${YELLOW}Available Tools:${NC}"
    echo
    echo -e "${GREEN}1)${NC} UFW Manager"
    show_description 1
    echo
    echo -e "${GREEN}2)${NC} SSH Port"
    show_description 2
	echo
    echo -e "${GREEN}3)${NC} DNS Manager"
    show_description 3
    echo
    echo -e "${RED}0)${NC} Exit"
    echo
    echo -e "${BLUE}────────────────────────────────────────${NC}"
    echo -e "${YELLOW}Enter your choice [0-3]:${NC} \c"
}

# Functions to run scripts
run_script() {
    clear_screen
    case $1 in
        1) 
            echo -e "${YELLOW}Running UFW Manager...${NC}"
            sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/m3hdiclub/myfiles/main/ufw.sh)"
            ;;
        2)
            echo -e "${YELLOW}Running Changing SSH port...${NC}"
            sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/m3hdiclub/myfiles/main/ssh.sh)"
            ;;
		3)
            echo -e "${YELLOW}Running DNS Manager...${NC}"
            sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/m3hdiclub/myfiles/main/dns.sh)"
            ;;
    esac
    if [ $? -ne 0 ]; then
        echo -e "${RED}An error occurred!${NC}"
    fi
    
    echo
    read -p "Press Enter to return to main menu..."
}

# Main loop
main() {
    check_root
    while true; do
        clear_screen
        show_menu
        read choice
        case $choice in
            [1-3]|3) run_script $choice ;; # Updated to allow '10' as a valid choice
            0) 
                clear
                echo -e "${GREEN}Thank you for using System Management Tools!${NC}"
                exit 0 
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Start script
main
