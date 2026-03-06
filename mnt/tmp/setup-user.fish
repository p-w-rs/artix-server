#!/usr/bin/env fish

# apply-config.fish — runs INSIDE the chroot.
# Compiles locales, hardens file permissions, and creates the admin user.
# Static config files were already copied in by run-chroot.

source (dirname (status filename))/die.fish

echo "=== System Configuration ==="

echo ">>> Generating localtime..."
ln -sf /usr/share/zoneinfo/America/Boise /etc/localtime

# Permissions that must be exact — enforce after the file copy
echo ">>> Hardening permissions..."
chmod 440 /etc/sudoers.d/wheel
chmod 600 /etc/nftables.conf

# Root password
echo ""
echo ">>> Set ROOT password:"
run passwd root

# Admin user
# wheel is added explicitly here so plain 'useradd -m <name>' later won't get sudo
echo ""
read -P ">>> Admin username: " ADMIN_USER
run useradd -m -G wheel $ADMIN_USER
echo ">>> Set password for $ADMIN_USER:"
run passwd $ADMIN_USER

echo ""
echo ">>> apply-config done."
echo "    Hostname : "(cat /etc/hostname)
echo "    Timezone : "(grep ^TIMEZONE /etc/rc.conf | cut -d'"' -f2)
echo "    User     : $ADMIN_USER (wheel)"
