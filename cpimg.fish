#!/usr/bin/env fish

# Write linux.img to a device and expand the root partition to fill it.
# Usage: ./cpimg.fish <image> <device>
#   ./cpimg.fish linux.img /dev/sda
#   ./cpimg.fish linux.img /dev/nvme0n1

source (dirname (status filename))/helpers/die.fish

test (count $argv) -eq 2; or die "Usage: "(status filename)" <image> <device>"
set IMG $argv[1]
set DEV $argv[2]

test -f $IMG; or die "'$IMG' not found"
test -b $DEV; or die "'$DEV' is not a block device"

string match -qr 'nvme' $DEV; and set P {$DEV}p; or set P $DEV

echo "WARNING: This will DESTROY all data on $DEV"
read -P "Type $DEV to confirm: " CONFIRM
test "$CONFIRM" = "$DEV"; or die "Aborted."

echo ">>> Writing $IMG → $DEV..."
run dd if=$IMG of=$DEV bs=4M status=progress conv=fsync

echo ">>> Fixing GPT for new disk size..."
run sgdisk -e $DEV

echo ">>> Expanding root partition to fill disk..."
run parted $DEV resizepart 3 100%
run resize2fs {$P}3

echo ""
echo ">>> Done. Root partition expanded on $DEV."
