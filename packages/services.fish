#!/usr/bin/env fish

set NET      connman connman-dinit wpa_supplicant wpa_supplicant-dinit openssh openssh-dinit nftables nftables-dinit
set CORE     dbus dbus-dinit apparmor apparmor-dinit  cronie cronie-dinit
set OTHER    bluez bluez-dinit libnotify dunst
set PACKAGES (string collect $PACKAGES $NET $CORE $OTHER)
