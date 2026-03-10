# fzf colors — mapped directly to Selenized Dark hex values.
# fg/bg use the terminal palette; accent colors use truecolor.
export FZF_DEFAULT_OPTS="\
  --color=dark \
  --color=bg:#103c48,bg+:#184956,border:#2d5b69 \
  --color=fg:#adbcbc,fg+:#cad8d9 \
  --color=hl:#dbb32d,hl+:#ebc13d \
  --color=info:#41c7b9,prompt:#4695f7,pointer:#f275be \
  --color=marker:#75b938,spinner:#fa5750,header:#72898f \
  --height=40% --layout=reverse --border --cycle"
