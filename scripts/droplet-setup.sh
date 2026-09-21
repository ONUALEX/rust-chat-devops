#!/bin/bash
# Run once on a fresh Ubuntu Droplet:  bash droplet-setup.sh
set -e
apt-get update && apt-get upgrade -y
curl -fsSL https://get.docker.com | sh
docker --version && docker compose version
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
ufw status
mkdir -p /opt/rust-chat
echo "Droplet ready."
