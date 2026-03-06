#!/usr/bin/env fish

cd /etc/dinit.d/boot.d/
ln -s ../connmand /etc/dinit.d/boot.d/
ln -s ../sshd /etc/dinit.d/boot.d/
ln -s ../apparmor /etc/dinit.d/boot.d/
ln -s ../nftables /etc/dinit.d/boot.d/
ln -s ../bluetoothd /etc/dinit.d/boot.d/
ln -s ../cronie /etc/dinit.d/boot.d/
ln -s ../dbus /etc/dinit.d/boot.d/
cd /

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
