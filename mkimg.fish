#!/usr/bin/env fish

# Create and partition a raw disk image.
# Attaches a loop device, writes GPT (EFI + swap + root), and formats all three.
# Usage: ./mkimg.fish
# Next steps: install-pkgs, then run-chroot.

source (dirname (status filename))/helpers/die.fish
set CALC (dirname (status filename))/helpers/mbcalc.fish

# ── Config ────────────────────────────────────────────────────────────────────
set IMG_FILE  linux.img
set IMG_SIZE  64G
set EFI_SIZE  100M
set SWAP_SIZE 8G

# ── Partition layout ──────────────────────────────────────────────────────────
set EFI_MB   (fish $CALC $EFI_SIZE)
set SWAP_MB  (fish $CALC $SWAP_SIZE)
set EFI_END  (math "1 + $EFI_MB")M
set SWAP_END (math "1 + $EFI_MB + $SWAP_MB")M

# ── Create image ──────────────────────────────────────────────────────────────
echo ">>> Creating $IMG_SIZE image: $IMG_FILE..."
run truncate -s $IMG_SIZE $IMG_FILE

echo ">>> Attaching loop device..."
set LOOP (losetup --find --partscan --show $IMG_FILE)
or die "losetup failed"
echo "    Loop device: $LOOP"

# ── Partition + format ────────────────────────────────────────────────────────
echo ">>> Partitioning..."
run parted --script $LOOP \
    mklabel gpt \
    mkpart EFI  fat32      1M       $EFI_END  \
    mkpart swap linux-swap $EFI_END $SWAP_END \
    mkpart root ext4       $SWAP_END 100%     \
    set 1 esp on

sleep 1

echo ">>> Formatting..."
run mkfs.vfat -F32 -n EFI  {$LOOP}p1
run mkswap    -L   swap    {$LOOP}p2
run mkfs.ext4 -L   root    {$LOOP}p3

echo ""
echo "Done. Loop device: $LOOP"
echo "Detach when finished: losetup -d $LOOP"
