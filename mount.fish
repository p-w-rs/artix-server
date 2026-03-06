#!/usr/bin/env fish

# Mount a partitioned Linux disk under /mnt.
# Usage: ./mount.fish <device>
#   ./mount.fish /dev/loop0      (disk image)
#   ./mount.fish /dev/sda        (SATA/SCSI)
#   ./mount.fish /dev/nvme0n1    (NVMe)

source (dirname (status filename))/helpers/die.fish

test (count $argv) -eq 1; or die "Usage: "(status filename)" <device>"
set DEV $argv[1]

string match -qr '(nvme|loop)' $DEV; and set P {$DEV}p; or set P $DEV

echo ">>> Mounting $DEV → /mnt..."
run mount    {$P}3 /mnt
run mkdir -p /mnt/boot/efi
run mount    {$P}1 /mnt/boot/efi
run swapon   {$P}2

echo ""
echo "Done. To unmount: swapoff {$P}2 && umount /mnt/boot/efi && umount /mnt"
