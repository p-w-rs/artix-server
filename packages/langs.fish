#!/usr/bin/env fish

set LG       uv python julia lua luarocks rust cargo
set PACKAGES (string collect $PACKAGES $LG)
