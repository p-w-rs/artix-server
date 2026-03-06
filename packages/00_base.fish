#!/usr/bin/env fish

basestrap /mnt base base-devel dinit fish parted dosfstools
basestrap /mnt linux linux-firmware linux-headers linux-firmware linux-firmware-intel linux-firmware-nvidia
