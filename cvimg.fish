#!/usr/bin/env fish

# Convert linux.img to a VM-compatible format.
# Usage: ./cvimg.fish [image [output [format]]]
#   ./cvimg.fish                           → linux.qcow2  (default)
#   ./cvimg.fish linux.img                 → linux.qcow2
#   ./cvimg.fish linux.img out.vmdk vmdk   → explicit format
# Formats: qcow2 (default), vmdk, vdi, vhd

source (dirname (status filename))/helpers/die.fish

# ── Args ──────────────────────────────────────────────────────────────────────
set IMG (test -n "$argv[1]"; and echo $argv[1]; or echo linux.img)
set FMT (test -n "$argv[3]"; and echo $argv[3]; or echo qcow2)
set OUT (test -n "$argv[2]"; and echo $argv[2]; or echo (string replace -r '\.[^.]+$' '' $IMG).$FMT)

test -f $IMG; or die "'$IMG' not found"
contains $FMT qcow2 vmdk vdi vhd; or die "Unknown format '$FMT'. Supported: qcow2, vmdk, vdi, vhd"
type -q qemu-img; or die "qemu-img not found"

# ── Zero free blocks (improves compression) ───────────────────────────────────
echo ">>> Zeroing free space in $IMG..."
set LOOP (losetup --find --partscan --show $IMG)
or die "losetup failed"
zerofree -v {$LOOP}p3
run losetup -d $LOOP

# ── Convert ───────────────────────────────────────────────────────────────────
echo ">>> Converting $IMG → $OUT ($FMT)..."
run qemu-img convert -f raw -O $FMT -c $IMG $OUT

echo ""
qemu-img info $OUT
echo ""
echo ">>> Done."
