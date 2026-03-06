#!/usr/bin/env fish

set TOOLS    helix git less wget curl htop strace lsof btop eza bat nvme-cli parted dosfstools
set PACKAGES (string collect $PACKAGES $TOOLS)
