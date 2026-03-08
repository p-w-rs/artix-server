#!/bin/bash

# Convert linux.img to a VM-compatible format.
# Usage: ./cvimg.sh [image [output [format]]]
#   ./cvimg.sh                           → linux.qcow2  (default)
#   ./cvimg.sh linux.img                 → linux.qcow2
#   ./cvimg.sh linux.img out.vmdk vmdk   → explicit format
# Formats: qcow2 (default), vmdk, vdi, vhd

source "$(dirname "$0")/helpers/die.sh"

# ── Args ──────────────────────────────────────────────────────────────────────
IMG="${1:-linux.img}"
FMT="${3:-qcow2}"

# If no output name given, replace the input file's extension with the format
if [ -n "$2" ]; then
    OUT="$2"
else
    OUT="${IMG%.*}.$FMT"
fi

if [ ! -f "$IMG" ]; then
    die "'$IMG' not found"
fi

case "$FMT" in
    qcow2|vmdk|vdi|vhd) ;;
    *) die "Unknown format '$FMT'. Supported: qcow2, vmdk, vdi, vhd" ;;
esac

if ! command -v qemu-img > /dev/null 2>&1; then
    die "qemu-img not found"
fi

# ── Zero free blocks (improves compression) ───────────────────────────────────
echo ">>> Zeroing free space in $IMG..."
LOOP=$(losetup --find --partscan --show "$IMG")
if [ $? -ne 0 ]; then
    die "losetup failed"
fi

zerofree -v "${LOOP}p3"
run losetup -d "$LOOP"

# ── Convert ───────────────────────────────────────────────────────────────────
echo ">>> Converting $IMG → $OUT ($FMT)..."
run qemu-img convert -f raw -O "$FMT" -c "$IMG" "$OUT"

echo ""
qemu-img info "$OUT"
echo ""
echo ">>> Done."
