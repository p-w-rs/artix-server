#!/bin/bash

# Provides two helpers for install scripts:
#   die [msg]  — print error and exit 1
#   run CMD…   — run a command; die on failure

die() {
    echo "ERROR: $*" >&2
    exit 1
}

run() {
    "$@"
    if [ $? -ne 0 ]; then
        die "'$*' failed"
    fi
}
