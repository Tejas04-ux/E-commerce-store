#!/bin/bash
# Runs once on first boot (as root). Installs Docker and the Compose plugin.
set -euxo pipefail

dnf update -y
dnf install -y docker git jq libicu   # libicu is required by the GitHub Actions runner

systemctl enable --now docker
usermod -aG docker ec2-user

# Docker Compose v2 plugin
mkdir -p /usr/local/lib/docker/cli-plugins
curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker --version
docker compose version
