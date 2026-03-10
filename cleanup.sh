#!/usr/bin/env bash

# Unmount the installed system and release the loop device (if any).
# Usage: ./cleanup.sh <device>
#   ./cleanup.sh /dev/loop0      (disk image)
#   ./cleanup.sh /dev/sda        (SATA/SCSI)
#   ./cleanup.sh /dev/nvme0n1    (NVMe)

source "$(dirname "$0")/helpers/die.sh"

if [ "$#" -ne 1 ]; then
    die "Usage: $0 <device>"
fi

DEV="$1"

if echo "$DEV" | grep -qE '(nvme|loop)'; then
    PART_PREFIX="${DEV}p"
else
    PART_PREFIX="$DEV"
fi

echo ">>> Unmounting $DEV..."
run umount  /mnt/boot/efi
run swapoff "${PART_PREFIX}2"
run umount  /mnt

if echo "$DEV" | grep -qE 'loop'; then
    echo ">>> Detaching $DEV..."
    run losetup -d "$DEV"
fi

echo ">>> Done."
