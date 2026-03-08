#!/bin/bash

# Convert a human size (e.g. 100M, 4G, 512K) to plain megabytes.
# Usage: mbcalc.sh <size>

source "$(dirname "$0")/die.sh"

if [ "$#" -ne 1 ]; then
    die "Usage: mbcalc.sh <size>  (e.g. 100M, 4G, 512K)"
fi

# Split the numeric part from the unit suffix
num="${1%[KMGkmg]}"
unit="${1##*[0-9]}"
unit="${unit^^}"    # convert to uppercase

case "$unit" in
    K)  echo $(( (num + 1023) / 1024 )) ;;   # ceiling division
    M)  echo "$num" ;;
    G)  echo $(( num * 1024 )) ;;
    *)  die "Unknown unit '$unit' — use K, M, or G" ;;
esac
