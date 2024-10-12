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

# Check if the chroot directory exists
if [ ! -d "$CHROOT_DIR" ]; then
  echo "Chroot directory $CHROOT_DIR does not exist. Please ensure it exists or run create.sh first."
  exit 1
fi

# Enter the chroot environment
chroot "$CHROOT_DIR" /bin/bash

# After exiting the chroot, unmount filesystems
echo "Unmounting filesystems..."
umount -l "$CHROOT_DIR/proc"
umount -l "$CHROOT_DIR/sys"
umount -l "$CHROOT_DIR/dev"
echo "Unmounted proc, sys, and dev."

echo "Exited the chroot environment."

