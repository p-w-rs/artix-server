#!/usr/bin/env fish

# bat — syntax-highlighted cat replacement
# Tells bat where to find its config file (/etc/bat/config) and
# custom themes (/etc/bat/themes/). Must be set permanently so bat
# finds the Selenized Dark theme on every invocation.
set -gx BAT_CONFIG_DIR /etc/bat
