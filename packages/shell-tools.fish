#!/usr/bin/env fish

set TOOLS    git less wget curl htop strace lsof btop eza bat nvme-cli parted dosfstools
set PACKAGES (string collect $PACKAGES $TOOLS)
