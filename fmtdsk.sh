#!/usr/bin/env bash

# Partition and format a physical disk. DESTRUCTIVE.
# Writes GPT (EFI + swap + root) and formats all three.
# Usage: ./fmtdsk.sh /dev/sda

source "$(dirname "$0")/helpers/die.sh"

MBCALC="$(dirname "$0")/helpers/mbcalc.sh"

# ── Config ────────────────────────────────────────────────────────────────────
EFI_SIZE="100M"
SWAP_SIZE="8G"

# ── Args + safety check ───────────────────────────────────────────────────────
if [ "$#" -ne 1 ]; then
    die "Usage: $0 <disk>  e.g. /dev/sda"
fi

DISK="$1"

if [ ! -b "$DISK" ]; then
    die "'$DISK' is not a block device"
fi

echo "WARNING: This will DESTROY all data on $DISK"
read -rp "Type $DISK to confirm: " CONFIRM

if [ "$CONFIRM" != "$DISK" ]; then
    die "Aborted."
fi

# ── Partition layout ──────────────────────────────────────────────────────────
EFI_MB=$(bash "$MBCALC" "$EFI_SIZE")
SWAP_MB=$(bash "$MBCALC" "$SWAP_SIZE")

EFI_END="$(( 1 + EFI_MB ))M"
SWAP_END="$(( 1 + EFI_MB + SWAP_MB ))M"

# NVMe and loop devices use a 'p' separator before the partition number
# e.g. /dev/nvme0n1 -> /dev/nvme0n1p1,  /dev/sda -> /dev/sda1
if echo "$DISK" | grep -qE '(nvme|loop)'; then
    PART_PREFIX="${DISK}p"
else
    PART_PREFIX="$DISK"
fi

# ── Partition + format ────────────────────────────────────────────────────────
echo ">>> Partitioning $DISK..."
run parted --script "$DISK"     \
    mklabel gpt                 \
    mkpart EFI  fat32      1M          "$EFI_END"  \
    mkpart swap linux-swap "$EFI_END"  "$SWAP_END" \
    mkpart root ext4       "$SWAP_END" 100%        \
    set 1 esp on

sleep 1

echo ">>> Formatting..."
run mkfs.vfat -F32 -n EFI  "${PART_PREFIX}1"
run mkswap    -L   swap    "${PART_PREFIX}2"
run mkfs.ext4 -L   root    "${PART_PREFIX}3"

echo ""
echo "Done. $DISK is partitioned and formatted."
