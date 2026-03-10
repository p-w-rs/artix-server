# Source all configuration snippets
if [[ -d "$HOME/.config/bash/conf.d" ]]; then
    for config_file in "$HOME/.config/bash/conf.d"/*.sh; do
        [[ -f "$config_file" ]] && source "$config_file"
    done
fi

# Source all functions
if [[ -d "$HOME/.config/bash/functions" ]]; then
    for func_file in "$HOME/.config/bash/functions"/*; do
        [[ -f "$func_file" ]] && source "$func_file"
    done
fi

# Extend programmable completion directory
if [[ -d "$HOME/.config/bash/completions" ]]; then
    export BASH_COMPLETION_USER_DIR="$HOME/.config/bash/completions"
fi
