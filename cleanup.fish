#!/usr/bin/env fish

# Unmount the installed system and release the loop device (if any).
# Usage: ./cleanup.fish <device>
#   ./cleanup.fish /dev/loop0      (disk image)
#   ./cleanup.fish /dev/sda        (SATA/SCSI)
#   ./cleanup.fish /dev/nvme0n1    (NVMe)

source (dirname (status filename))/helpers/die.fish

test (count $argv) -eq 1; or die "Usage: "(status filename)" <device>"
set DEV $argv[1]

string match -qr '(nvme|loop)' $DEV; and set P {$DEV}p; or set P $DEV

echo ">>> Unmounting $DEV..."
run umount  /mnt/boot/efi
run swapoff {$P}2
run umount  /mnt

if string match -qr 'loop' $DEV
    echo ">>> Detaching $DEV..."
    run losetup -d $DEV
end

echo ">>> Done."
