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
curl -L -o /root/file.zip "https://drive.google.com/uc?id=1b_jMbEgcCnh2HEIub6tLUppK6dCeUIyn&export=download"

if [ $? -ne 0 ]; then
    echo "Failed to download the ZIP file."
    exit 1
fi

echo "Extracting the ZIP file..."
sudo unzip /root/file.zip -d /root
if [ $? -ne 0 ]; then
    echo "Failed to unzip the file."
    exit 1
fi

echo "Removing the ZIP file..."
rm /root/file.zip
if [ $? -ne 0 ]; then
    echo "Failed to remove the ZIP file."
    exit 1
fi

echo "Changing permissions for m3hdiclub.sh..."
sudo chmod +x /root/m3hdiclub.sh
if [ $? -ne 0 ]; then
    echo "Failed to change permissions."
    exit 1
fi

clear
echo "Executing m3hdiclub.sh..."
sudo /root/m3hdiclub.sh
if [ $? -ne 0 ]; then
    echo "Failed to execute m3hdiclub.sh."
    exit 1
fi

echo "Script completed successfully."
