# eza / ls colors — Selenized Dark
# EZA_COLORS extends LS_COLORS. Format: LS_COLORS codes, semicolon-separated.
# We highlight directories, symlinks, executables, and git status in Selenized.
# 38;2;R;G;B = truecolor fg,  48;2;R;G;B = truecolor bg
# Selenized:  blue(70,149,247)  cyan(65,199,185)  green(117,185,56)
#             yellow(219,179,45)  red(250,87,80)  violet(175,136,235)
export LS_COLORS="\
di=38;2;70;149;247:\\
ln=38;2;65;199;185:\\
ex=38;2;117;185;56:\\
*.tar=38;2;250;87;80:*.gz=38;2;250;87;80:*.zip=38;2;250;87;80:\\
*.jpg=38;2;175;136;235:*.png=38;2;175;136;235:*.gif=38;2;175;136;235:\\
*.mp4=38;2;219;179;45:*.mp3=38;2;219;179;45:\\
"

# Apply the same colors to eza
export EZA_COLORS="$LS_COLORS"
