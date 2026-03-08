#!/bin/bash

# Write linux.img to a device and expand the root partition to fill it.
# Usage: ./cpimg.sh <image> <device>
#   ./cpimg.sh linux.img /dev/sda
#   ./cpimg.sh linux.img /dev/nvme0n1

source "$(dirname "$0")/helpers/die.sh"

if [ "$#" -ne 2 ]; then
    die "Usage: $0 <image> <device>"
fi

IMG="$1"
DEV="$2"

if [ ! -f "$IMG" ]; then
    die "'$IMG' not found"
fi

if [ ! -b "$DEV" ]; then
    die "'$DEV' is not a block device"
fi

if echo "$DEV" | grep -qE 'nvme'; then
    PART_PREFIX="${DEV}p"
else
    PART_PREFIX="$DEV"
fi

echo "WARNING: This will DESTROY all data on $DEV"
read -rp "Type $DEV to confirm: " CONFIRM

if [ "$CONFIRM" != "$DEV" ]; then
    die "Aborted."
fi

echo ">>> Writing $IMG → $DEV..."
run dd if="$IMG" of="$DEV" bs=4M status=progress conv=fsync

echo ">>> Fixing GPT for new disk size..."
run sgdisk -e "$DEV"

echo ">>> Expanding root partition to fill disk..."
run parted "$DEV" resizepart 3 100%
run resize2fs "${PART_PREFIX}3"

echo ""
echo ">>> Done. Root partition expanded on $DEV."
