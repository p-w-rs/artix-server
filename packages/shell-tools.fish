#!/usr/bin/env fish

set TOOLS    git wget curl htop btop eza bat nvme-cli less strace lsof parted dosfstools
set PACKAGES (string collect $PACKAGES $TOOLS)
