#!/usr/bin/env fish

# Install pakcages

set DIR (dirname (status filename))

set BASE_PACKAGES base base-devel dinit fish
set PACKAGES linux linux-firmware linux-headers linux-firmware linux-firmware-intel linux-firmware-nvidia

for script in $DIR/*.fish
    test (basename $script) = all.fish; and continue
    source $script
end

echo "\n\n\nInstalling $BASE_PACKAGES $PACKAGES\n\n\n"
exit 1
basestrap /mnt $BASE_PACKAGES $PACKAGES
