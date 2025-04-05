#!/bin/bash

GREEN="\033[1;32m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}Please enter the new SSH port:${RESET}"
read -p "> " new_port

if [[ ! "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -lt 1 ] || [ "$new_port" -gt 65535 ]; then
    echo -e "${RED}Error:${RESET} Invalid port! Port must be a number between 1 and 65535."
    exit 1
fi

echo -e "${CYAN}Updating SSH port to $new_port...${RESET}"
sudo sed -i -E "s/^#?Port .*/Port $new_port/" /etc/ssh/sshd_config
grep -q "^Port $new_port" /etc/ssh/sshd_config || echo "Port $new_port" | sudo tee -a /etc/ssh/sshd_config

echo -e "${CYAN}Restarting SSH service...${RESET}"
if sudo systemctl restart sshd; then
    echo -e "${GREEN}SSH service restarted successfully!${RESET}"
else
    echo -e "${RED}Error:${RESET} Failed to restart SSH service!"
    exit 1
fi

echo -e "${CYAN}Configuring UFW...${RESET}"
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salarvand-Education/Auto-ufw/main/ufw.sh)" && \
echo -e "${GREEN}UFW configured successfully!${RESET}"

echo -e "${GREEN}Success!${RESET} New SSH Port: ${CYAN}$new_port${RESET}"
