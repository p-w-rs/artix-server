#!/usr/bin/env fish

set RUST     rust cargo
set OTHER    git pkg-config protobuf openssl
set PACKAGES (string collect $PACKAGES $RUST $OTHER)
