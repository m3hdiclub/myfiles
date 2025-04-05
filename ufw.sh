#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

install_packages() {
    if ! command -v ufw &> /dev/null; then
        echo -e "${YELLOW}UFW not found, installing...${NC}"
        apt-get update && apt-get install -y ufw
    fi

    if ! command -v netstat &> /dev/null; then
        echo -e "${YELLOW}Net-tools not found, installing...${NC}"
        apt-get update && apt-get install -y net-tools
    fi
}

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

install_packages

show_ports() {
    clear
    temp_file=$(mktemp)
    echo -e "${YELLOW}Active System Ports:${NC}"
    echo "--------------------------------"
    
    netstat -tulpn | grep LISTEN | while read -r line; do
        addr=$(echo "$line" | awk '{print $4}')
        prog=$(echo "$line" | awk '{print $7}')
        
        if [[ $addr == *:* ]]; then
            port=$(echo "$addr" | rev | cut -d: -f1 | rev)
            name=$(echo "$prog" | cut -d'/' -f2 | sed 's/:$//')
            if [[ ! -z "$port" && "$port" =~ ^[0-9]+$ ]]; then
                echo "$port $name"
            fi
        fi
    done | sort -n -u | while read -r line; do
        port=$(echo "$line" | awk '{print $1}')
        prog=$(echo "$line" | cut -d' ' -f2-)
        printf "Port: ${BLUE}%-6s${NC} Program: ${YELLOW}%s${NC}\n" "$port" "$prog"
    done
    echo -e "\n${YELLOW}UFW Rules:${NC}"
    echo "--------------------------------"
    
    counter=1
    ufw status | grep -v "(v6)" | grep ALLOW | while read -r line; do
        port=$(echo "$line" | awk '{print $1}')
        if [[ ! -z "$port" ]]; then
            printf "${GREEN}%3d${NC} │ Port: ${BLUE}%-6s${NC}\n" "$counter" "$port"
            ((counter++))
        fi
    done
    if ufw status | grep -q "Status: active"; then
        echo -e "\nFirewall Status: ${GREEN}Active${NC}"
    else
        echo -e "\nFirewall Status: ${RED}Inactive${NC}"
    fi
}

add_port() {
    clear
    echo -e "${YELLOW}Add New Port${NC}"
    read -p "Enter port number (1-65535): " port
    
    if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
        echo -e "\n1) TCP"
        echo "2) UDP"
        echo "3) Both TCP and UDP"
        read -p "Select protocol (1-3): " proto
        
        case $proto in
            1) ufw allow "$port"/tcp && echo -e "Added TCP port ${BLUE}$port${NC}" ;;
            2) ufw allow "$port"/udp && echo -e "Added UDP port ${BLUE}$port${NC}" ;;
            3) ufw allow "$port" && echo -e "Added port ${BLUE}$port${NC}" ;;
            *) echo -e "${RED}Invalid selection${NC}" ;;
        esac
    else
        echo -e "${RED}Invalid port number${NC}"
    fi
}

update_ports() {
    clear
    echo -e "${YELLOW}Updating firewall ports...${NC}"
    
    temp_file=$(mktemp)
    netstat -tulpn | grep LISTEN | while read -r line; do
        addr=$(echo "$line" | awk '{print $4}')
        if [[ $addr == *:* ]]; then
            port=$(echo "$addr" | rev | cut -d: -f1 | rev)
            if [[ ! -z "$port" && "$port" =~ ^[0-9]+$ ]]; then
                echo "$port"
            fi
        fi
    done | sort -n | uniq > "$temp_file"
    while read -r port; do
        if ! ufw status | grep -q "$port"; then
            echo -e "Adding port ${BLUE}$port${NC}"
            ufw allow "$port"
        fi
    done < "$temp_file"
    rm -f "$temp_file"
    echo -e "${GREEN}Port update complete${NC}"
}

delete_rules() {
    clear
    echo -e "${RED}WARNING: This will delete all UFW rules!${NC}"
    read -p "Are you sure? (y/N): " confirm
    
    if [[ "$confirm" == [yY] ]]; then
        ufw --force reset
        echo -e "${GREEN}All rules deleted${NC}"
    else
        echo -e "${YELLOW}Operation cancelled${NC}"
    fi
}

toggle_ufw() {
    if ufw status | grep -q "Status: active"; then
        echo -e "${YELLOW}Stopping UFW...${NC}"
        ufw disable
        echo -e "${RED}UFW is now disabled${NC}"
    else
        echo -e "${YELLOW}Starting UFW...${NC}"
        ufw --force enable
        echo -e "${GREEN}UFW is now enabled${NC}"
    fi
}

while true; do
    clear
    echo -e "${BLUE}=== UFW Manager ===${NC}"
    echo -e "${YELLOW}1)${NC} Show Ports & Rules"
    echo -e "${YELLOW}2)${NC} Add Port"
    echo -e "${YELLOW}3)${NC} Auto-Update Ports"
    echo -e "${GREEN}4)${NC} Toggle UFW (On/Off)"
    echo -e "${RED}5)${NC} Delete All Rules"
    echo -e "${BLUE}0)${NC} Exit"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1) show_ports; read -p "Press Enter to continue..." ;;
        2) add_port; read -p "Press Enter to continue..." ;;
        3) update_ports; read -p "Press Enter to continue..." ;;
        4) toggle_ufw; read -p "Press Enter to continue..." ;;
        5) delete_rules; read -p "Press Enter to continue..." ;;
        0) clear; echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
    esac
done
