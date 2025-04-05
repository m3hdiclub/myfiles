#!/bin/bash

echo "Updating the system..."
sudo apt update -y
if [ $? -ne 0 ]; then
    echo "Failed to update the system."
    exit 1
fi

echo "Upgrading the system..."
sudo apt upgrade -y
if [ $? -ne 0 ]; then
    echo "Failed to upgrade the system."
    exit 1
fi

echo "Installing curl..."
sudo apt install curl -y
if [ $? -ne 0 ]; then
    echo "Failed to install curl."
    exit 1
fi

echo "Installing sqlite3..."
sudo apt install sqlite3 -y
if [ $? -ne 0 ]; then
    echo "Failed to install sqlite3."
    exit 1
fi

echo "Installing unzip..."
sudo apt install unzip -y
if [ $? -ne 0 ]; then
    echo "Failed to install unzip."
    exit 1
fi

echo "Installing rar..."
sudo apt install rar
if [ $? -ne 0 ]; then
    echo "Failed to install unzip."
    exit 1
fi

echo "Downloading the ZIP file..."
curl -L -o /root/m3hdiclub/bash/file.zip "https://drive.google.com/uc?id=16HGnrrpe4Fl2AtBBIc10SKUw-D8JGyy9&export=download#m3hdiclub"

if [ $? -ne 0 ]; then
    echo "Failed to download the ZIP file."
    exit 1
fi

echo "Extracting the ZIP file..."
sudo unzip /root/m3hdiclub/bash/file.zip -d /root/m3hdiclub/bash
if [ $? -ne 0 ]; then
    echo "Failed to unzip the file."
    exit 1
fi

echo "Removing the ZIP file..."
rm /root/m3hdiclub/bash/file.zip
if [ $? -ne 0 ]; then
    echo "Failed to remove the ZIP file."
    exit 1
fi

echo "Changing permissions for m3hdiclub.sh..."
sudo chmod +x /root/m3hdiclub/bash/menu.sh
sudo chmod +x /root/m3hdiclub/bash/ufw.sh
sudo chmod +x /root/m3hdiclub/bash/ssh.sh
sudo chmod +x /root/m3hdiclub/bash/dns.sh
sudo chmod +x /root/m3hdiclub/bash/s-ui.sh
if [ $? -ne 0 ]; then
    echo "Failed to change permissions."
    exit 1
fi

clear
echo "Executing menu.sh..."
sudo /root/m3hdiclub/bash/menu.sh
if [ $? -ne 0 ]; then
    echo "Failed to execute Menu.sh."
    exit 1
fi

echo "Script completed successfully."
