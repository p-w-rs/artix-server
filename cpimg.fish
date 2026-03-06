#!/usr/bin/env fish

# cpimg.fish — write linux.img to a device and resize the last partition to fill it.
#
# Usage: ./cpimg.fish <image> <device>
#   ./cpimg.fish linux.img /dev/sda
#   ./cpimg.fish linux.img /dev/nvme0n1

source (dirname (status filename))/helpers/die.fish

test (count $argv) -eq 2; or die "Usage: "(status filename)" <image> <device>"
set IMG $argv[1]
set DEV $argv[2]

test -f $IMG;  or die "'$IMG' not found"
test -b $DEV;  or die "'$DEV' is not a block device"

if string match -qr 'nvme' $DEV
    set P {$DEV}p
else
    set P $DEV
end

echo "WARNING: This will DESTROY all data on $DEV"
read -P "Type the device name to confirm: " CONFIRM
test "$CONFIRM" = "$DEV"; or die "Confirmation failed. Aborting."

# ── Write image ───────────────────────────────────────────────────────────────
echo ">>> Writing $IMG to $DEV..."
run dd if=$IMG of=$DEV bs=4M status=progress conv=fsync

# ── Fix GPT for larger device ─────────────────────────────────────────────────
# dd copies the backup GPT to the wrong location for a larger disk; sgdisk fixes it.
echo ">>> Fixing GPT..."
run sgdisk -e $DEV

# ── Resize last partition to fill disk ────────────────────────────────────────
echo ">>> Resizing partition 3 to fill $DEV..."
run parted $DEV resizepart 3 100%

# ── Resize filesystem ─────────────────────────────────────────────────────────
echo ">>> Resizing filesystem on {$P}3..."
run resize2fs {$P}3

echo ""
echo ">>> write-img done. $IMG written to $DEV with root partition expanded."
