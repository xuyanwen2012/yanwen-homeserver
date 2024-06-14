#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Update and upgrade the system
apt update && apt upgrade -y

# Install necessary packages
apt install -y docker.io docker-compose fish qemu-guest-agent htop tree

# Create user 'marisa' with UID 1000
useradd -m -u 1000 -s /usr/bin/fish marisa

# Set fish as the default shell for 'marisa' and 'root'
chsh -s /usr/bin/fish marisa
chsh -s /usr/bin/fish root

# Add 'marisa' to the docker group
usermod -aG docker marisa

# Start and enable Docker service
systemctl start docker
systemctl enable docker

echo "Post-installation tasks completed successfully."
