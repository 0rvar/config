#!/usr/bin/env bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Configuration
VM_DIR="$CURRENT_DIR/tmp"
VM_NAME="nixos"
VM_IMAGE="$VM_DIR/$VM_NAME.img"
ISO_URL="https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso"
ISO_FILE="$VM_DIR/nixos-minimal.iso"
IMAGE_SIZE="64G"

# Create VM directory if it doesn't exist
mkdir -p "$VM_DIR"

# Check if --reset flag is passed
if [[ " $* " =~ " --reset " ]]; then
  rm -f "$VM_IMAGE" || true
fi

# Function to download ISO if needed
download_iso() {
  if [ ! -f "$ISO_FILE" ]; then
    echo "Downloading NixOS ISO..."
    curl -L "$ISO_URL" -o "$ISO_FILE"
    echo "Download complete!"
  else
    echo "ISO already exists at $ISO_FILE"
  fi
}

# Function to create VM image
create_image() {
  echo "Creating VM disk image of size $IMAGE_SIZE..."
  , qemu-img create -f raw "$VM_IMAGE" "$IMAGE_SIZE"
  echo "VM image created at $VM_IMAGE"
}

# Check if we need to create the image
NEEDS_INSTALL=0
if [ ! -f "$VM_IMAGE" ]; then
  echo "VM image not found"
  create_image
  NEEDS_INSTALL=1
fi

# Check if --install flag is passed
if [[ " $* " =~ " --install " ]]; then
  NEEDS_INSTALL=1
fi

# Prepare QEMU command
QEMU_CMD=", qemu-system-x86_64 \
    -accel tcg \
    -smp 4 \
    -m 8G \
    -drive file=$VM_IMAGE,if=virtio,format=raw,cache=writeback \
    -nic user,hostfwd=tcp::2222-:22,model=virtio-net-pci \
    -display default \
    -device virtio-vga \
    -device virtio-keyboard \
    -device virtio-mouse"

# Add ISO if installing
if [ $NEEDS_INSTALL -eq 1 ]; then
  download_iso
  QEMU_CMD="$QEMU_CMD -cdrom $ISO_FILE"
fi

# Print helpful information
echo "Starting VM..."
if [ $NEEDS_INSTALL -eq 1 ]; then
  echo "Installation mode: After boot, you can:"
  echo "1. Log in as 'nixos' (no password)"
  echo "2. Set password: passwd"
  echo "3. Start SSH: sudo systemctl start sshd"
  echo "4. Check disks: lsblk"
  echo "5. SSH from host: ssh -p 2222 nixos@localhost"
else
  echo "Normal boot mode"
fi

# Run the VM
echo "Running QEMU..."
eval "$QEMU_CMD"
