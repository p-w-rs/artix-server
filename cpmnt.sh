#!/usr/bin/env bash

# Copy local ./mnt config tree into /mnt on the target system.

source "$(dirname "$0")/helpers/die.sh"

SRC="./mnt"
DST="/mnt"

if [ ! -d "$SRC" ]; then
    die "Source directory '$SRC' does not exist."
fi

if [ ! -d "$DST" ]; then
    die "Destination directory '$DST' does not exist."
fi

echo ">>> Copying $SRC → $DST..."
run cp -r "$SRC"/* "$DST"

echo ">>> Done."
