#!/usr/bin/env fish

# Runs INSIDE the chroot.
# Generates locale, hardens permissions, sets root password, and creates the admin user.

source (dirname (status filename))/die.fish

echo "=== System Configuration ==="

echo ">>> Generating locale + clock..."
ln -sf /usr/share/zoneinfo/America/Boise /etc/localtime
hwclock --systohc
locale-gen

echo ">>> Hardening permissions..."
chmod 440 /etc/sudoers.d/u_root
chmod 440 /etc/sudoers.d/g_wheel
chmod 440 /etc/sudoers
chmod 600 /etc/nftables.conf

echo ""
echo ">>> Set ROOT password:"
run passwd root
chsh -s /usr/bin/fish root

echo ""
read -P ">>> Admin username: " ADMIN_USER
run useradd -m -G wheel $ADMIN_USER
echo ">>> Set password for $ADMIN_USER:"
run passwd $ADMIN_USER
# Build bat theme cache for the new user
sudo -u $ADMIN_USER BAT_CONFIG_DIR=/etc/bat bat cache --build

echo ""
echo ">>> Done."
echo "    Hostname : "(cat /etc/hostname)
echo "    User     : $ADMIN_USER (wheel)"
