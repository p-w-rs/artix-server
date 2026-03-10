NET="connman connman-dinit wpa_supplicant wpa_supplicant-dinit openssh openssh-dinit nftables nftables-dinit"
CORE="dbus dbus-dinit apparmor apparmor-dinit  cronie cronie-dinit"
OTHER="bluez bluez-dinit libnotify dunst"
PACKAGES="$PACKAGES $NET $CORE $OTHER"
