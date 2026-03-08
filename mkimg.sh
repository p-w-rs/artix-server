#!/bin/bash

# Create and partition a raw disk image.
# Attaches a loop device, writes GPT (EFI + swap + root), and formats all three.
# Usage: ./mkimg.sh
# Next steps: install-pkgs, then run-chroot.

source "$(dirname "$0")/helpers/die.sh"

MBCALC="$(dirname "$0")/helpers/mbcalc.sh"

# ── Config ────────────────────────────────────────────────────────────────────
IMG_FILE="linux.img"
IMG_SIZE="64G"
EFI_SIZE="100M"
SWAP_SIZE="8G"

# ── Partition layout ──────────────────────────────────────────────────────────
EFI_MB=$(bash "$MBCALC" "$EFI_SIZE")
SWAP_MB=$(bash "$MBCALC" "$SWAP_SIZE")

EFI_END="$(( 1 + EFI_MB ))M"
SWAP_END="$(( 1 + EFI_MB + SWAP_MB ))M"

# ── Create image ──────────────────────────────────────────────────────────────
echo ">>> Creating $IMG_SIZE image: $IMG_FILE..."
run truncate -s "$IMG_SIZE" "$IMG_FILE"

echo ">>> Attaching loop device..."
LOOP=$(losetup --find --partscan --show "$IMG_FILE")
if [ $? -ne 0 ]; then
    die "losetup failed"
fi
echo "    Loop device: $LOOP"

# ── Partition + format ────────────────────────────────────────────────────────
echo ">>> Partitioning..."
run parted --script "$LOOP"  \
    mklabel gpt              \
    mkpart EFI  fat32      1M          "$EFI_END"  \
    mkpart swap linux-swap "$EFI_END"  "$SWAP_END" \
    mkpart root ext4       "$SWAP_END" 100%        \
    set 1 esp on

sleep 1

echo ">>> Formatting..."
run mkfs.vfat -F32 -n EFI  "${LOOP}p1"
run mkswap    -L   swap    "${LOOP}p2"
run mkfs.ext4 -L   root    "${LOOP}p3"

echo ""
echo "Done. Loop device: $LOOP"
echo "Detach when finished: losetup -d $LOOP"
