#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Bootstrapping Dev Container..."

# Update system packages
sudo apt-get update && sudo apt-get upgrade -y

# Set timezone to Europe/Kyiv
sudo ln -sf /usr/share/zoneinfo/Europe/Kyiv /etc/localtime
sudo dpkg-reconfigure -f noninteractive tzdata

# Ensure Python 3.12 is available
if ! command -v python3.12 &> /dev/null; then
  echo "❌ Python 3.12 not found. Please install it in the container base image."
  exit 1
fi

python3.12 -m pip install --upgrade pip

# Run Makefile targets
echo "🔍 Running make verify..."
make verify

echo "🧪 Running make test..."
make test

echo "✅ Dev Container bootstrap complete."
