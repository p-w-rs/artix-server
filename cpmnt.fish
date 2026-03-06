#!/usr/bin/env fish

# Copy local ./mnt config tree into /mnt on the target system.

source (dirname (status filename))/helpers/die.fish

set SRC ./mnt
set DST /mnt

test -d $SRC; or die "Source directory '$SRC' does not exist."
test -d $DST; or die "Destination directory '$DST' does not exist."

echo ">>> Copying $SRC → $DST..."
run cp -r $SRC/* $DST

echo ">>> Done."
