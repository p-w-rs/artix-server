#!/usr/bin/env fish
# finalize.fish — runs INSIDE the chroot.
# Installs GRUB for UEFI and generates grub.cfg.
# Sets up initial dinit services for first boot.
#
# Usage:
#   finalize.fish                                → internal drive (writes NVRAM entry)
#   finalize.fish -r / --removable               → USB/image (fallback EFI path, no NVRAM)
#   finalize.fish -r --id=ArtixBase            → removable with custom bootloader ID
#   finalize.fish --id=ArtixBase               → internal drive with custom bootloader ID

source (dirname (status filename))/die.fish

# ── Argument parsing ──────────────────────────────────────────────────────────
set removable false
set bootloader_id "ArtixBase"

for arg in $argv
    switch $arg
        case -r --removable
            set removable true
        case '--id=*'
            set bootloader_id (string replace --regex '^--id=' '' $arg)
        case '*'
            die "Unknown argument: $arg"
    end
end

set GRUB_FLAGS --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=$bootloader_id --recheck
if test $removable = true
    set GRUB_FLAGS $GRUB_FLAGS --removable --no-nvram
end

# ── Dinit services ────────────────────────────────────────────────────────────
echo ">>> Enabling dinit services..."
cd /etc/dinit.d/boot.d/
for svc in connmand sshd apparmor nftables bluetoothd cronie dbus
    ln -sf ../$svc .
end
cd /

# ── EFI mount ─────────────────────────────────────────────────────────────────
if not mountpoint -q /boot/efi
    echo ">>> Mounting EFI partition..."
    run mount LABEL=EFI /boot/efi
end

# ── GRUB ──────────────────────────────────────────────────────────────────────
echo ">>> grub-install (id: $bootloader_id, removable: $removable)..."
run grub-install $GRUB_FLAGS

echo ">>> grub-mkconfig..."
run grub-mkconfig -o /boot/grub/grub.cfg

echo ">>> finalize done. Ready to reboot."
