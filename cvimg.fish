#!/usr/bin/env fish

# cvimg.fish — convert linux.img to a format suitable for use in an emulator.
#
# Supported formats:
#   qcow2   QEMU/KVM (compressed, supports snapshots)  [default]
#   vmdk    VMware / VirtualBox
#   vdi     VirtualBox native
#   vhd     Hyper-V / Azure
#
# Usage:
#   ./cvimg.fish                          → linux.qcow2 (default)
#   ./cvimg.fish linux.img                 → linux.qcow2
#   ./cvimg.fish linux.img out.qcow2       → explicit output path
#   ./cvimg.fish linux.img out.vmdk vmdk   → explicit format

source (dirname (status filename))/helpers/die.fish

# ── Arguments (all optional) ──────────────────────────────────────────────────
set IMG    (test -n "$argv[1]"; and echo $argv[1]; or echo linux.img)
set FMT    (test -n "$argv[3]"; and echo $argv[3]; or echo qcow2)

# Derive default output name from input name + format if not given
if test -n "$argv[2]"
    set OUT $argv[2]
else
    set BASE (string replace -r '\.[^.]+$' '' $IMG)
    set OUT  {$BASE}.{$FMT}
end

test -f $IMG; or die "'$IMG' not found"

switch $FMT
    case qcow2 vmdk vdi vhd
        # supported
    case '*'
        die "Unknown format '$FMT'. Supported: qcow2, vmdk, vdi, vhd"
end

type -q qemu-img; or die "qemu-img not found — install qemu-img or qemu-utils"

# ── Zero free blocks for better compression ───────────────────────────────────
# Requires the image to be attached as a loop device.
echo ">>> Zeroing free blocks in $IMG (improves compression)..."
set LOOP (losetup --find --partscan --show $IMG)
or die "losetup failed"
zerofree -v {$LOOP}p3
run losetup -d $LOOP

# ── Convert ───────────────────────────────────────────────────────────────────
echo ">>> Converting $IMG → $OUT (format: $FMT)..."
run qemu-img convert -f raw -O $FMT -c $IMG $OUT

echo ""
qemu-img info $OUT
echo ""
echo ">>> cvimg.fish done."
