#!/usr/bin/env fish

# Julia Configuration
# Performance and development settings
set -gx JULIA_NUM_THREADS auto                    # Use all available cores
set -gx JULIA_EDITOR "hx"                       # Set your preferred editor
set -gx JULIA_PKG_PRESERVE_TIERED_INSTALLED true  # Prevent accidental downgrades
set -gx JULIA_PKG_USE_CLI_GIT true               # Use system git for packages
set -gx JULIA_ERROR_COLOR "\033[91m"             # Red error messages
set -gx JULIA_WARN_COLOR "\033[93m"              # Yellow warnings
set -gx JULIA_INFO_COLOR "\033[36m"              # Cyan info messages

# Python interop via PythonCall
# JULIA_CONDAPKG_BACKEND "Null" — never let Julia manage Python itself.
# JULIA_PYTHONCALL_EXE "python3" — resolve python3 from PATH at runtime.
# When launched via jlp, PATH will contain the .venv, so PythonCall picks
# up the project-local Python automatically. Outside jlp this is a no-op
# unless a system python3 exists, which is fine since PythonCall won't be
# called without an explicit Julia project that uses it.
set -gx JULIA_CONDAPKG_BACKEND "Null"
set -gx JULIA_PYTHONCALL_EXE  "python3"

# Julia helper functions
function jlp --description "Launch Julia with project in current directory, activating .venv if present"
    if test -f .venv/bin/activate.fish
        source .venv/bin/activate.fish
        env -u LD_LIBRARY_PATH julia --project=. $argv
        deactivate
    else
        env -u LD_LIBRARY_PATH julia --project=. $argv
    end
end

function julia --description "Launch Julia clearing LD_LIBRARY_PATH"
    command env -u LD_LIBRARY_PATH julia $argv
end
