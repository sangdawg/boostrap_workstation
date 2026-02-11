#!/bin/bash

# Define the repository
REPO="hiddify/hiddify-app"

echo "Checking for the latest Hiddify RPM..."

# 1. Get the download URL for the latest x64 RPM
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/$REPO/releases/latest | \
  grep "browser_download_url" | \
  grep -i ".rpm" | \
  grep -i "x64" | \
  cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not find the RPM download URL."
    echo "Try a manual download of the Hiddify RPM file here: https://github.com/hiddify/hiddify-app/releases"
    exit 1
fi

echo "Found latest release: $(basename $DOWNLOAD_URL)"

# 2. Install directly using DNF
# This handles the download and the installation in one step
echo "Starting installation..."
sudo dnf install -y "$DOWNLOAD_URL"

echo "Hiddify installation complete!"
