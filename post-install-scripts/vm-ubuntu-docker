#!/bin/bash

# Exit script on any error
set -e

# Update and upgrade the system
echo "Updating and upgrading the system..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install necessary packages
echo "Installing required packages..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    fish \
    qemu-guest-agent \
    tree

# Install Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Helix text editor
sudo snap install helix --classic

# Set Fish as the default shell
chsh -s /usr/bin/fish

# Create user marisa and add to docker group
# echo "Creating user 'marisa' and adding to docker group..."
# sudo useradd -m -s /usr/bin/fish -G docker -u 1000 marisa
# echo "Please set the password for the new user 'marisa':"
# sudo passwd marisa

echo "Post-installation tasks completed successfully."
