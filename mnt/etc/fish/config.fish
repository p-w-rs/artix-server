#!/usr/bin/env fish
# /etc/fish/config.fish — system-wide interactive shell configuration
# Sourced once per interactive session, after all conf.d files.
# Non-interactive shells (scripts, scp, etc.) bail out immediately.

status is-interactive; or return

# ── Greeting ──────────────────────────────────────────────────────────────────
set -g fish_greeting ""

# ── PATH ──────────────────────────────────────────────────────────────────────
# /opt/bin holds manually managed binaries (odin, ols, sozu, etc.)
fish_add_path /opt/bin
fish_add_path /usr/local/bin

# ── Editor / Pager ────────────────────────────────────────────────────────────
set -gx EDITOR   helix
set -gx VISUAL   helix
set -gx PAGER    less
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# ── Selenized Dark — terminal color palette reference ─────────────────────────
#
#   bg_0    #103c48    bg_1    #184956    bg_2    #2d5b69
#   dim_0   #72898f    fg_0    #adbcbc    fg_1    #cad8d9
#
#   red     #fa5750    green   #75b938    yellow  #dbb32d
#   blue    #4695f7    magenta #f275be    cyan    #41c7b9
#   orange  #ed8649    violet  #af88eb
#
#   br_red  #ff665c    br_grn  #84c747    br_yel  #ebc13d
#   br_blu  #58a3ff    br_mag  #ff84cd    br_cyn  #53d6c7
#   br_org  #fd9456    br_vio  #bd96f9
#
# The canonical way to apply Selenized is to set your terminal emulator's
# 16-color palette to these values. Every tool that respects ANSI colors
# (bat with base16 theme, fzf, eza, fish, etc.) then inherits them for free.
# See: https://github.com/jan-warchol/selenized/blob/master/manual-installation.md

# ── bat ───────────────────────────────────────────────────────────────────────
# BAT_CONFIG_DIR is set in conf.d/bat.fish so it's available to all contexts.
# Theme, style, and pager flags live in /etc/bat/config.
# Replace cat here in the interactive shell. Use `command cat` to bypass.
if type -q bat
    function cat --wraps=bat --description "bat: syntax-highlighted cat"
        bat $argv
    end
end

# ── fzf.fish ──────────────────────────────────────────────────────────────────
# Key bindings must be configured here (not conf.d) per fzf.fish docs.
# Defaults:
#   Ctrl+Alt+F  Search Directory    Ctrl+R      Search History
#   Ctrl+Alt+L  Search Git Log      Ctrl+V      Search Variables
#   Ctrl+Alt+S  Search Git Status   Ctrl+Alt+P  Search Processes
fzf_configure_bindings

# fd options for Search Directory (hidden files, skip .git)
set -g fzf_fd_opts --hidden --exclude .git

# Use bat for file previews in Search Directory (inherits Selenized via base16)
if type -q bat
    set -g fzf_preview_file_cmd bat --style=numbers --color=always --line-range=:100
end

# fzf colors — mapped directly to Selenized Dark hex values.
# fg/bg use the terminal palette; accent colors use truecolor.
set -gx FZF_DEFAULT_OPTS "\
  --color=dark \
  --color=bg:#103c48,bg+:#184956,border:#2d5b69 \
  --color=fg:#adbcbc,fg+:#cad8d9 \
  --color=hl:#dbb32d,hl+:#ebc13d \
  --color=info:#41c7b9,prompt:#4695f7,pointer:#f275be \
  --color=marker:#75b938,spinner:#fa5750,header:#72898f \
  --height=40% --layout=reverse --border --cycle"

# ── Fish syntax highlighting — Selenized Dark ────────────────────────────────
# These color the command line itself (not the prompt — Tide handles that).
# Values map directly to Selenized roles:
#   commands      → blue  (#4695f7)    keywords     → violet (#af88eb)
#   quotes        → green (#75b938)    redirections → cyan   (#41c7b9)
#   errors        → red   (#fa5750)    params       → fg_0   (#adbcbc)
#   comments      → dim_0 (#72898f)    operators    → cyan   (#41c7b9)
#   autosuggests  → bg_2  (#2d5b69)    escapes      → orange (#ed8649)
set -g fish_color_normal         adbcbc   # fg_0
set -g fish_color_command        4695f7   # blue
set -g fish_color_keyword        af88eb   # violet
set -g fish_color_quote          75b938   # green
set -g fish_color_redirection    41c7b9   # cyan
set -g fish_color_end            cad8d9   # fg_1  (semicolons, pipes)
set -g fish_color_error          fa5750   # red
set -g fish_color_param          adbcbc   # fg_0
set -g fish_color_comment        72898f   # dim_0
set -g fish_color_operator       41c7b9   # cyan
set -g fish_color_escape         ed8649   # orange
set -g fish_color_autosuggestion 2d5b69   # bg_2  (dim, unobtrusive)
set -g fish_color_valid_path     --underline
set -g fish_color_match          --background=184956  # bg_1
set -g fish_color_search_match   --background=2d5b69  # bg_2
set -g fish_pager_color_prefix          ebc13d   # br_yellow (matched prefix)
set -g fish_pager_color_completion      adbcbc   # fg_0
set -g fish_pager_color_description     72898f   # dim_0
set -g fish_pager_color_progress        41c7b9   # cyan
set -g fish_pager_color_selected_background --background=184956

# ── eza / ls colors — Selenized Dark ─────────────────────────────────────────
# EZA_COLORS extends LS_COLORS. Format: LS_COLORS codes, semicolon-separated.
# We highlight directories, symlinks, executables, and git status in Selenized.
# 38;2;R;G;B = truecolor fg,  48;2;R;G;B = truecolor bg
# Selenized:  blue(70,149,247)  cyan(65,199,185)  green(117,185,56)
#             yellow(219,179,45)  red(250,87,80)  violet(175,136,235)
set -gx LS_COLORS "\
di=38;2;70;149;247:\
ln=38;2;65;199;185:\
ex=38;2;117;185;56:\
*.tar=38;2;250;87;80:*.gz=38;2;250;87;80:*.zip=38;2;250;87;80:\
*.jpg=38;2;175;136;235:*.png=38;2;175;136;235:*.gif=38;2;175;136;235:\
*.mp4=38;2;219;179;45:*.mp3=38;2;219;179;45:\
"
set -gx EZA_COLORS "$LS_COLORS"

# ── done (long-command notifications) ────────────────────────────────────────
# franciscolourenco/done fires a desktop notification when commands take >5s.
# Requires libnotify + a notification daemon (dunst, mako, etc.).
# Uncomment to tune the threshold:
# set -U __done_min_cmd_duration 10000

# ── Tide prompt ───────────────────────────────────────────────────────────────
# Tide stores its config as universal variables, set per-user.
# On first login, run: tide configure
