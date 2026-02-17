#!/usr/bin/env bash
set -euo pipefail

echo "=== Fedora Workstation bootstrap starting ==="

########################################
# 0) Run as root (sudo)
########################################
if [[ $EUID -ne 0 ]]; then
  echo "Please run with sudo:"
  echo "  sudo bash $0"
  exit 1
fi

REAL_USER="${SUDO_USER:-}"
if [[ -z "${REAL_USER}" || "${REAL_USER}" == "root" ]]; then
  echo "This script expects to be run via sudo from a normal user."
  exit 1
fi

USER_HOME="$(getent passwd "${REAL_USER}" | cut -d: -f6)"
if [[ -z "${USER_HOME}" || ! -d "${USER_HOME}" ]]; then
  echo "Could not determine home directory for user: ${REAL_USER}"
  exit 1
fi

########################################
# 1) RPM Fusion
########################################
dnf install -y \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

########################################
# 2) Microsoft Edge (official repo)
########################################
rpm --import https://packages.microsoft.com/keys/microsoft.asc

cat >/etc/yum.repos.d/microsoft-edge.repo <<'EOF'
[microsoft-edge]
name=Microsoft Edge
baseurl=https://packages.microsoft.com/yumrepos/edge
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

dnf install -y microsoft-edge-stable

########################################
# 3) Flatpak + Flathub
########################################
dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

########################################
# 4) Apps
#    - KeePassXC via RPM (lean on GNOME; avoids KDE runtime)
#    - rclone for data syncing
#    - oathtool for MFA 
########################################
dnf install -y keepassxc
sudo dnf install -y rclone
sudo dnf install oathtool

########################################
# 5) Create folder
########################################
mkdir -p "${USER_HOME}/onedrive_hotty"
chown -R "${REAL_USER}:${REAL_USER}" "${USER_HOME}/onedrive_hotty"

########################################
# Final output
########################################

echo "=== Installed these packages ==="
echo "1) MS Edge Browser"
echo "2) KeePassXC"
echo "3) oathtool (for MFA)"
echo "4) rclone (for data syncing)"
