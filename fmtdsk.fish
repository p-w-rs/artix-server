#!/usr/bin/env fish

# Partition and format a physical disk. DESTRUCTIVE.
# Writes GPT (EFI + swap + root) and formats all three.
# Usage: ./fmtdsk.fish /dev/sda

source (dirname (status filename))/helpers/die.fish

# ── Config ────────────────────────────────────────────────────────────────────
set EFI_SIZE  100M
set SWAP_SIZE 8G

# ── Args + safety check ───────────────────────────────────────────────────────
test (count $argv) -eq 1; or die "Usage: "(status filename)" <disk>  e.g. /dev/sda"
set DISK $argv[1]
test -b $DISK; or die "'$DISK' is not a block device"

echo "WARNING: This will DESTROY all data on $DISK"
read -P "Type $DISK to confirm: " CONFIRM
test "$CONFIRM" = "$DISK"; or die "Aborted."

# ── Partition layout ──────────────────────────────────────────────────────────
set CALC (dirname (status filename))/helpers/mbcalc.fish
set EFI_END  (math "1 + "(fish $CALC $EFI_SIZE))M
set SWAP_END (math "1 + "(fish $CALC $EFI_SIZE)" + "(fish $CALC $SWAP_SIZE))M

string match -qr '(nvme|loop)' $DISK; and set P {$DISK}p; or set P $DISK

# ── Partition + format ────────────────────────────────────────────────────────
echo ">>> Partitioning $DISK..."
run parted --script $DISK \
    mklabel gpt \
    mkpart EFI  fat32      1M       $EFI_END  \
    mkpart swap linux-swap $EFI_END $SWAP_END \
    mkpart root ext4       $SWAP_END 100%     \
    set 1 esp on

sleep 1

echo ">>> Formatting..."
run mkfs.vfat -F32 -n EFI  {$P}1
run mkswap    -L   swap    {$P}2
run mkfs.ext4 -L   root    {$P}3

echo ""
echo "Done. $DISK is partitioned and formatted."
