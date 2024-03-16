#!/bin/bash

# Update package lists
apt update -y

# Upgrade installed packages
apt upgrade -y

# Install x-ui from GitHub
bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)
