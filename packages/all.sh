#!/usr/bin/env bash

# Install packages

DIR="$(dirname "$0")"

BASE_PACKAGES="base base-devel dinit"
PACKAGES="linux linux-firmware linux-headers linux-firmware linux-firmware-intel linux-firmware-nvidia"

for script in "$DIR"/*.sh; do
    if [ "$(basename "$script")" = "all.sh" ]; then
        continue
    fi
    source "$script"
done

# Deduplicate PACKAGES by splitting into words, filtering unique values, and rejoining
PACKAGES=$(echo "$PACKAGES" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)

echo ""
echo "Installing $BASE_PACKAGES $PACKAGES"
echo ""
basestrap /mnt $BASE_PACKAGES $PACKAGES
