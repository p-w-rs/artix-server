#!/usr/bin/env fish

# Plugin Configuration
# Settings for Fish plugins that must be set as variables (not in config.fish).
# These are sourced before config.fish, so plugins pick them up at init time.

# ── givensuman/fish-eza ───────────────────────────────────────────────────────
# Run eza automatically when changing directories.
set -gx eza_run_on_cd true

# ── kidonng/zoxide.fish ───────────────────────────────────────────────────────
# Default hook is --on-variable PWD (fires on every cd). No config needed.
# To change the command prefix from z to something else:
# set -U zoxide_cmd j

# ── PatrickF1/fzf.fish ───────────────────────────────────────────────────────
# fzf_configure_bindings is called in config.fish (must live there).
# Per-command fzf options are set in config.fish as well (fzf_preview_file_cmd etc.)
