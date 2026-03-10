#!/usr/bin/env bash

# Mount a partitioned Linux disk under /mnt.
# Usage: ./mount.sh <device>
#   ./mount.sh /dev/loop0      (disk image)
#   ./mount.sh /dev/sda        (SATA/SCSI)
#   ./mount.sh /dev/nvme0n1    (NVMe)

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

echo ">>> Mounting $DEV → /mnt..."
run mount    "${PART_PREFIX}3" /mnt
run mkdir -p /mnt/boot/efi
run mount    "${PART_PREFIX}1" /mnt/boot/efi
run swapon   "${PART_PREFIX}2"

echo ""
echo "Done. To unmount: swapoff ${PART_PREFIX}2 && umount /mnt/boot/efi && umount /mnt"
