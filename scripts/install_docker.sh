#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- Starting Server Installation (Docker + Caddy) ---"

# --- PART 1: DOCKER INSTALLATION ---

echo "[1/2] Installing Docker..."

# 1. Update existing list of packages
sudo apt update

# 2. Install prerequisites
sudo apt install -y ca-certificates curl gnupg lsb-release debian-keyring debian-archive-keyring apt-transport-https

# 3. Add Docker’s official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Set up the Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Update package index again
sudo apt update

# 6. Install Docker Engine and plugins
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 7. Add user to docker group
sudo usermod -aG docker $USER

echo "Docker installed successfully."

# --- PART 2: CADDY INSTALLATION ---

echo "[2/2] Installing Caddy Web Server..."

# 1. Add Caddy GPG key
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor --yes -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

# 2. Add Caddy Repository
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list

# 3. Update and Install Caddy
sudo apt update
sudo apt install -y caddy

echo "Caddy installed successfully."

# --- PART 3: CADDY CONFIGURATION ---

echo "--- Configuration ---"
echo "We need to configure Caddy to point to your Docker container."
read -p "Enter your full Domain URL (e.g., mystreamer.duckdns.org): " USER_DOMAIN

if [ -z "$USER_DOMAIN" ]; then
  echo "No domain entered. Skipping Caddyfile configuration."
else
  echo "Writing configuration to /etc/caddy/Caddyfile..."
  
  # This writes the config block to the file using sudo
  cat <<EOF | sudo tee /etc/caddy/Caddyfile
$USER_DOMAIN {
    reverse_proxy 127.0.0.1:7000
}
EOF

  echo "Restarting Caddy to apply changes..."
  sudo systemctl restart caddy
fi

echo "--- Installation Complete ---"
echo "1. Docker is ready."
echo "2. Caddy is running and serving $USER_DOMAIN -> Port 7000."
echo "3. Please log out and log back in to use Docker commands without 'sudo'."
