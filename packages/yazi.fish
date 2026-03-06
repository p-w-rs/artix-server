#!/usr/bin/env fish

set YAZI     yazi file ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick xclip wl-clipboard chafa
set PACKAGES (string collect $PACKAGES $YAZI)
