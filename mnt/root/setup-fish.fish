#!/usr/bin/env fish

# Runs INSIDE the chroot.
# Installs Fisher system-wide (/etc/fish) and all listed plugins,
# then builds the bat theme cache.
# To add/remove plugins, edit the PLUGS list below.

set FISHER_FUNC /etc/fish/functions/fisher.fish
set FISHER_URL  https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish
set PLUGS \
    kidonng/zoxide.fish \
    givensuman/fish-eza \
    PatrickF1/fzf.fish \
    jorgebucaran/autopair.fish \
    franciscolourenco/done \
    IlanCosman/tide@v6

echo "=== Fish Shell Setup ==="

echo ">>> Downloading Fisher..."
curl -sfL $FISHER_URL -o $FISHER_FUNC
or begin; echo "ERROR: curl failed"; exit 1; end

set -g fisher_path /etc/fish
source $FISHER_FUNC

echo ">>> Installing plugins..."
for plugin in $PLUGS
    echo "  $plugin"
    fisher install $plugin
    or begin; echo "ERROR: $plugin failed"; exit 1; end
end

# ── bat theme cache ───────────────────────────────────────────────────────────
# bat needs a binary cache built from the .tmTheme files in /etc/bat/themes/
# before it can use them. This is a one-time step; re-run if themes change.
echo ">>> Building bat theme cache..."
set -gx BAT_CONFIG_DIR /etc/bat
bat cache --build
or begin; echo "ERROR: bat cache --build failed"; exit 1; end

echo ">>> Done."
