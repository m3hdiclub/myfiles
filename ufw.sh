#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to install required packages
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

# Check root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Install required packages
install_packages

# Function to show ports and rules
show_ports() {
    clear
    # Create a temporary file
    temp_file=$(mktemp)
    echo -e "${YELLOW}Active System Ports:${NC}"
    echo "--------------------------------"
    
    # Get all ports and their programs, remove duplicates
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
    # Show UFW rules
    echo -e "\n${YELLOW}UFW Rules:${NC}"
    echo "--------------------------------"
    
    # Process UFW rules
    counter=1
    ufw status | grep -v "(v6)" | grep ALLOW | while read -r line; do
        port=$(echo "$line" | awk '{print $1}')
        if [[ ! -z "$port" ]]; then
            printf "${GREEN}%3d${NC} │ Port: ${BLUE}%-6s${NC}\n" "$counter" "$port"
            ((counter++))
        fi
    done
    # Show UFW status
    if ufw status | grep -q "Status: active"; then
        echo -e "\nFirewall Status: ${GREEN}Active${NC}"
    else
        echo -e "\nFirewall Status: ${RED}Inactive${NC}"
    fi
}

# Function to add port
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

# Function to update ports
update_ports() {
    clear
    echo -e "${YELLOW}Updating firewall ports...${NC}"
    
    # Create temp file for unique ports
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
    # Add each unique port if not already in UFW rules
    while read -r port; do
        if ! ufw status | grep -q "$port"; then
            echo -e "Adding port ${BLUE}$port${NC}"
            ufw allow "$port"
        fi
    done < "$temp_file"
    # Clean up
    rm -f "$temp_file"
    echo -e "${GREEN}Port update complete${NC}"
}

# Function to delete single rule
delete_single_rule() {
    clear
    echo -e "${YELLOW}Delete Individual Rule${NC}"
    echo "--------------------------------"
    
    # Get list of rules with numbers
    rules=()
    while read -r line; do
        if [[ ! -z "$line" && "$line" =~ "ALLOW" ]]; then
            rules+=("$line")
        fi
    done < <(ufw status numbered | grep -v "(v6)")
    
    # Display rules
    if [ ${#rules[@]} -eq 0 ]; then
        echo -e "${RED}No rules found${NC}"
        return
    fi
    
    for i in "${!rules[@]}"; do
        rule_num=$(echo "${rules[$i]}" | awk '{print $1}' | tr -d '[]')
        rule_desc=$(echo "${rules[$i]}" | awk '{$1=""; print $0}')
        echo -e "${GREEN}$rule_num${NC}) $rule_desc"
    done
    
    echo
    read -p "Enter rule number to delete (or 0 to cancel): " rule_to_delete
    
    if [[ "$rule_to_delete" =~ ^[0-9]+$ ]]; then
        if [ "$rule_to_delete" -eq 0 ]; then
            echo -e "${YELLOW}Operation cancelled${NC}"
            return
        fi
        
        # Check if rule exists
        if ufw status numbered | grep -q "^\[$rule_to_delete\]"; then
            echo -e "${YELLOW}Deleting rule number $rule_to_delete...${NC}"
            ufw --force delete "$rule_to_delete"
            echo -e "${GREEN}Rule deleted${NC}"
        else
            echo -e "${RED}Rule number $rule_to_delete not found${NC}"
        fi
    else
        echo -e "${RED}Invalid input${NC}"
    fi
}

# Function to delete rules
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

# Function to toggle UFW
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

# Main menu loop
while true; do
    clear
    echo -e "${BLUE}=== UFW Manager ===${NC}"
    echo -e "${YELLOW}1)${NC} Show Ports & Rules"
    echo -e "${YELLOW}2)${NC} Add Port"
    echo -e "${YELLOW}3)${NC} Auto-Update Ports"
    echo -e "${GREEN}4)${NC} Toggle UFW (On/Off)"
    echo -e "${RED}5)${NC} Delete Single Rule"
    echo -e "${RED}6)${NC} Delete All Rules"
    echo -e "${BLUE}0)${NC} Exit"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1) show_ports; read -p "Press Enter to continue..." ;;
        2) add_port; read -p "Press Enter to continue..." ;;
        3) update_ports; read -p "Press Enter to continue..." ;;
        4) toggle_ufw; read -p "Press Enter to continue..." ;;
        5) delete_single_rule; read -p "Press Enter to continue..." ;;
        6) delete_rules; read -p "Press Enter to continue..." ;;
        0) clear; echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
    esac
done
