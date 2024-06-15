#!/bin/bash

# Exit script on any error
set -e

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

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

# Install Helix text editor
snap install helix --classic

# Set Fish as the default shell
chsh -s /usr/bin/fish

# Install Docker
sh <(curl -sSL https://get.docker.com)

echo "Post-installation tasks completed successfully."
