#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Check if CHROOT_DIR is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/chroot"
  exit 1
fi

# Variables
CHROOT_DIR="$1"
UBUNTU_RELEASE="noble"  # Ubuntu 24.04 LTS codename
ARCH="amd64"  # Change to your desired architecture (e.g., amd64, arm64)

# Create the chroot directory if it does not exist
mkdir -p "$CHROOT_DIR"

# Install debootstrap if it's not installed
if ! command -v debootstrap &> /dev/null; then
  echo "debootstrap not found. Installing..."
  apt-get update && apt-get install -y debootstrap
fi

# Run debootstrap to create the chroot environment for Ubuntu
debootstrap --arch="$ARCH" "$UBUNTU_RELEASE" "$CHROOT_DIR" http://192.168.1.52:3142/archive.ubuntu.com/ubuntu/

# Check if debootstrap was successful
if [ $? -eq 0 ]; then
  echo "Chroot environment created successfully at $CHROOT_DIR"
else
  echo "Failed to create the chroot environment."
  exit 1
fi

# Copy necessary configuration files into the chroot environment
cp /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf"
echo "Copied /etc/resolv.conf into the chroot environment."

cp /etc/hosts "$CHROOT_DIR/etc/hosts"
echo "Copied /etc/hosts into the chroot environment."

if [ -f /etc/apt/apt.conf.d/00aptproxy ]; then
  cp /etc/apt/apt.conf.d/00aptproxy "$CHROOT_DIR/etc/apt/apt.conf.d/00aptproxy"
  echo "Copied /etc/apt/apt.conf.d/00aptproxy into the chroot environment."
else
  echo "Warning: /etc/apt/apt.conf.d/00aptproxy not found, skipping."
fi

# Set up /etc/apt/sources.list in the chroot environment
cat <<EOF > "$CHROOT_DIR/etc/apt/sources.list"
deb http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse
EOF
echo "Configured /etc/apt/sources.list for Ubuntu 24.04 LTS in the chroot environment."

# Mount necessary filesystems
mount -t proc /proc "$CHROOT_DIR/proc"
mount --rbind /sys "$CHROOT_DIR/sys"
mount --rbind /dev "$CHROOT_DIR/dev"
echo "Mounted proc, sys, and dev filesystems."

echo "Setup complete. Use the shell.sh script to enter the chroot environment."