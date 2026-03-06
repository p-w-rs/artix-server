#!/usr/bin/env fish

# Runs INSIDE the chroot.
# Installs GRUB (UEFI), generates grub.cfg, and enables dinit services.
# Usage:
#   finalize.fish                        → internal drive (writes NVRAM entry)
#   finalize.fish -r / --removable       → USB/image (fallback EFI path, no NVRAM)
#   finalize.fish --id=MyLabel           → custom bootloader ID
#   finalize.fish -r --id=MyLabel        → removable + custom ID

source (dirname (status filename))/die.fish

# ── Args ──────────────────────────────────────────────────────────────────────
set removable     false
set bootloader_id ArtixBase

for arg in $argv
    switch $arg
        case -r --removable;  set removable true
        case '--id=*';        set bootloader_id (string replace -r '^--id=' '' $arg)
        case '*';             die "Unknown argument: $arg"
    end
end

set GRUB_FLAGS --target=x86_64-efi --efi-directory=/boot/efi \
               --bootloader-id=$bootloader_id --recheck
test $removable = true; and set GRUB_FLAGS $GRUB_FLAGS --removable --no-nvram

# ── Dinit services ────────────────────────────────────────────────────────────
echo ">>> Enabling dinit services..."
cd /etc/dinit.d/boot.d/
for svc in connmand sshd apparmor nftables bluetoothd cronie dbus
    ln -sf ../$svc .
end
cd /

# ── EFI mount ─────────────────────────────────────────────────────────────────
mountpoint -q /boot/efi
or begin
    echo ">>> Mounting EFI partition..."
    run mount LABEL=EFI /boot/efi
end

# ── GRUB ──────────────────────────────────────────────────────────────────────
echo ">>> Installing GRUB (id: $bootloader_id, removable: $removable)..."
run grub-install $GRUB_FLAGS

echo ">>> Generating grub.cfg..."
run grub-mkconfig -o /boot/grub/grub.cfg

echo ">>> Done. Ready to reboot."
