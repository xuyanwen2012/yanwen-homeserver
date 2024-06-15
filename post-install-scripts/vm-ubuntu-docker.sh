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
    fish \
    qemu-guest-agent \
    tree

# Install Docker
sh <(curl -sSL https://get.docker.com)

# Install Helix text editor
sudo snap install helix --classic

# Set Fish as the default shell
chsh -s /usr/bin/fish

echo "Post-installation tasks completed successfully."
reboot
