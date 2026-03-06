#!/usr/bin/env fish

# Install pakcages

set DIR (dirname (status filename))

set BASE_PACKAGES base base-devel grub efibootmgr dinit fish
set PACKAGES linux linux-firmware linux-headers linux-firmware linux-firmware-intel linux-firmware-nvidia

for script in $DIR/*.fish
    test (basename $script) = all.fish; and continue
    source $script
end

echo ""
echo "Installing $BASE_PACKAGES $PACKAGES"
echo ""
basestrap /mnt $BASE_PACKAGES $PACKAGES
