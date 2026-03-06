#!/usr/bin/env fish

# Convert a human size (e.g. 100M, 4G, 512K) to plain megabytes.
# Usage: mbcalc.fish <size>

test (count $argv) -eq 1
    or die "Usage: mbcalc.fish <size>  (e.g. 100M, 4G, 512K)"

set num  (string replace -r '[KMGkmg]$' '' $argv[1])
set unit (string upper (string match -r '[KMGkmg]$' $argv[1]))

switch $unit
    case K;  math "ceil($num / 1024)"
    case M;  math "$num"
    case G;  math "$num * 1024"
    case '*'; echo "Error: unknown unit '$unit' — use K, M, or G" >&2; exit 1
end
