#!/bin/bash

# Runs INSIDE the chroot.
# Installs GRUB (UEFI), generates grub.cfg, and enables dinit services.
# Usage:
#   finalize.sh                        → internal drive (writes NVRAM entry)
#   finalize.sh -r / --removable       → USB/image (fallback EFI path, no NVRAM)
#   finalize.sh --id=MyLabel           → custom bootloader ID
#   finalize.sh -r --id=MyLabel        → removable + custom ID

source "$(dirname "$0")/die.sh"

# ── Args ──────────────────────────────────────────────────────────────────────
removable=false
bootloader_id=ArtixBase

for arg in "$@"; do
    case "$arg" in
        -r|--removable) removable=true ;;
        --id=*)         bootloader_id="${arg#--id=}" ;;
        *)              die "Unknown argument: $arg" ;;
    esac
done

GRUB_FLAGS=(--target=x86_64-efi --efi-directory=/boot/efi
            --bootloader-id="$bootloader_id" --recheck)
[ "$removable" = true ] && GRUB_FLAGS+=(--removable --no-nvram)

# ── Dinit services ────────────────────────────────────────────────────────────
echo ">>> Enabling dinit services..."
cd /etc/dinit.d/boot.d/
for svc in connmand sshd apparmor nftables bluetoothd cronie dbus; do
    ln -sf "../$svc" .
done
cd /

# ── EFI mount ─────────────────────────────────────────────────────────────────
if ! mountpoint -q /boot/efi; then
    echo ">>> Mounting EFI partition..."
    run mount LABEL=EFI /boot/efi
fi

# ── GRUB ──────────────────────────────────────────────────────────────────────
echo ">>> Installing GRUB (id: $bootloader_id, removable: $removable)..."
run grub-install "${GRUB_FLAGS[@]}"

echo ">>> Generating grub.cfg..."
run grub-mkconfig -o /boot/grub/grub.cfg

echo ">>> Done. Ready to reboot."
