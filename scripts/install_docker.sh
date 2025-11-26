#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- Starting Docker Installation ---"

# 1. Update existing list of packages
echo "Updating package database..."
sudo apt update

# 2. Install prerequisite packages that allow apt to use a repository over HTTPS
echo "Installing prerequisites..."
sudo apt install -y ca-certificates curl gnupg lsb-release

# 3. Add Docker’s official GPG key
echo "Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
# Added --yes to automatically overwrite the key if it already exists
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Set up the repository
echo "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Update the package index again with the new Docker repo
echo "Updating package database with Docker repo..."
sudo apt update

# 6. Install Docker Engine, containerd, and Docker Compose
echo "Installing Docker Engine and plugins..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 7. Add the current user to the 'docker' group to run without sudo
echo "Adding user $USER to the docker group..."
sudo usermod -aG docker $USER

echo "--- Installation Complete ---"
