#!/usr/bin/env fish

basestrap /mnt dbus dbus-dinit apparmor apparmor-dinit openssh openssh-dinit connman connman-dinit wpa_supplicant wpa_supplicant-dinit \
    nftables nftables-dinit cronie cronie-dinit bluez bluez-dinit libnotify dunst
