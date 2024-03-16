#!/bin/bash

# Update package lists
sudo apt update -y

# Upgrade installed packages
sudo apt upgrade -y

# Install x-ui from GitHub
bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)
