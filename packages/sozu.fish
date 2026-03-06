#!/usr/bin/env fish

set RUST     rust
set OTHER    git pkg-config protobuf openssl
set PACKAGES (string collect $PACKAGES $RUST $OTHER)
