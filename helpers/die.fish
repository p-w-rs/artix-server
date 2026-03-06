#!/usr/bin/env fish

# Provides two helpers for install scripts:
#   die [msg]  — print error and exit 1
#   run CMD…   — run a command; die on failure

function die
    echo "ERROR: $argv" >&2
    exit 1
end

function run
    $argv; or die "'$argv' failed"
end
