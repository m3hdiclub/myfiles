#!/bin/bash

GREEN="\033[1;32m"
CYAN="\033[1;36m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${CYAN}┌──────────────────────────────────┐${RESET}"
echo -e "${CYAN}│      Ubuntu DNS Server Setup      │${RESET}"
echo -e "${CYAN}└──────────────────────────────────┘${RESET}"
echo

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root${RESET}"
    echo -e "Please run with ${YELLOW}sudo bash dns.sh${RESET}"
    exit 1
fi

echo -e "${CYAN}Setting up DNS servers...${RESET}"
PRIMARY_DNS="8.8.8.8 8.8.4.4"
FALLBACK_DNS="1.1.1.1 1.0.0.1"

CONFIG_FILE="/etc/systemd/resolved.conf"

if grep -q "^#*DNS=" "$CONFIG_FILE"; then
    sudo sed -i "s/^#*DNS=.*/DNS=$PRIMARY_DNS/" "$CONFIG_FILE"
    echo -e "${GREEN}DNS set to ${YELLOW}$PRIMARY_DNS${RESET}"
else
    echo "DNS=$PRIMARY_DNS" | sudo tee -a "$CONFIG_FILE" > /dev/null
    echo -e "${GREEN}DNS added as ${YELLOW}$PRIMARY_DNS${RESET}"
fi

if grep -q "^#*FallbackDNS=" "$CONFIG_FILE"; then
    sudo sed -i "s/^#*FallbackDNS=.*/FallbackDNS=$FALLBACK_DNS/" "$CONFIG_FILE"
    echo -e "${GREEN}FallbackDNS set to ${YELLOW}$FALLBACK_DNS${RESET}"
else
    echo "FallbackDNS=$FALLBACK_DNS" | sudo tee -a "$CONFIG_FILE" > /dev/null
    echo -e "${GREEN}FallbackDNS added as ${YELLOW}$FALLBACK_DNS${RESET}"
fi

echo -e "${CYAN}Restarting systemd-resolved service...${RESET}"
if sudo systemctl restart systemd-resolved; then
    echo -e "${GREEN}systemd-resolved service restarted successfully!${RESET}"
else
    echo -e "${RED}Error: Failed to restart systemd-resolved service!${RESET}"
    exit 1
fi

echo -e "\n${CYAN}System DNS information after changes:${RESET}"
echo -e "${YELLOW}$(systemd-resolve --status | grep -A 2 'DNS Servers')${RESET}"

echo -e "\n${GREEN}DNS settings successfully configured!${RESET}"
