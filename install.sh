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

ZIP_URL="https://drive.google.com/uc?id=1M39cDiKOy9N1qEVQbfLKWP9KL1kc0ugm&export=download"
ZIP_FILE="/root/yourfile.zip"

echo "Downloading the ZIP file..."
curl -o $ZIP_FILE $ZIP_URL
if [ $? -ne 0 ]; then
    echo "Failed to download the ZIP file."
    exit 1
fi

echo "Extracting the ZIP file..."
sudo unzip $ZIP_FILE -d /root
if [ $? -ne 0 ]; then
    echo "Failed to unzip the file."
    exit 1
fi

echo "Removing the ZIP file..."
sudo rm $ZIP_FILE
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

echo "Executing m3hdiclub.sh..."
sudo /root/m3hdiclub.sh
if [ $? -ne 0 ]; then
    echo "Failed to execute m3hdiclub.sh."
    exit 1
fi

echo "Script completed successfully."
