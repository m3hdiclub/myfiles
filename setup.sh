#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

handle_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

INSTALL_DIR="/root/m3hdiclub/bash"
echo -e "${BLUE}Checking installation directory...${NC}"
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Directory $INSTALL_DIR does not exist. Creating it now...${NC}"
    mkdir -p "$INSTALL_DIR" || handle_error "Failed to create directory $INSTALL_DIR"
    echo -e "${GREEN}Directory created successfully.${NC}"
fi

echo -e "${BLUE}Updating the system...${NC}"
apt update -y || handle_error "Failed to update the system"

echo -e "${BLUE}Upgrading the system...${NC}"
apt upgrade -y || handle_error "Failed to upgrade the system"

echo -e "${BLUE}Installing required packages...${NC}"
apt install curl sqlite3 unzip rar -y || handle_error "Failed to install required packages"

echo -e "${BLUE}Downloading the ZIP file...${NC}"
curl -L -o "$INSTALL_DIR/file.zip" "https://drive.google.com/uc?id=16HGnrrpe4Fl2AtBBIc10SKUw-D8JGyy9&export=download#m3hdiclub" || handle_error "Failed to download the ZIP file"

echo -e "${BLUE}Extracting the ZIP file...${NC}"
unzip -o "$INSTALL_DIR/file.zip" -d "$INSTALL_DIR" || handle_error "Failed to unzip the file"

echo -e "${BLUE}Removing the ZIP file...${NC}"
rm "$INSTALL_DIR/file.zip" || handle_error "Failed to remove the ZIP file"

echo -e "${BLUE}Setting correct permissions...${NC}"
chmod +x "$INSTALL_DIR/menu.sh" \
         "$INSTALL_DIR/ufw.sh" \
         "$INSTALL_DIR/ssh.sh" \
         "$INSTALL_DIR/dns.sh" \
         "$INSTALL_DIR/s-ui.sh" \
         "$INSTALL_DIR/3x-ui.sh" \
         "$INSTALL_DIR/telegrambot.sh" \
         "$INSTALL_DIR/telegrambot_googledrive.sh" \
         "$INSTALL_DIR/telegrambot_qrcode.sh" \
         "$INSTALL_DIR/telegrambot_sui.sh" \
         "$INSTALL_DIR/telegrambot_serverdetail.sh" \
         "$INSTALL_DIR/telegrambot_backup.sh" || handle_error "Failed to set permissions"

clear
echo -e "${GREEN}Setup completed. Starting menu...${NC}"
"$INSTALL_DIR/menu.sh" || handle_error "Failed to execute menu.sh"

echo -e "${GREEN}Script completed successfully.${NC}"
