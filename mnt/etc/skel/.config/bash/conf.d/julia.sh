# Julia Configuration
# Performance and development settings
export JULIA_NUM_THREADS="auto"                     # Use all available cores
export JULIA_EDITOR="hx"                            # Set your preferred editor
export JULIA_PKG_PRESERVE_TIERED_INSTALLED="true"   # Prevent accidental downgrades
export JULIA_PKG_USE_CLI_GIT="true"                 # Use system git for packages
export JULIA_ERROR_COLOR="#fa5750"                  # Selenized red
export JULIA_WARN_COLOR="#dbb32d"                   # Selenized yellow
export JULIA_INFO_COLOR="#41c7b9"                   # Selenized cyan

# Python interop via PythonCall
# JULIA_CONDAPKG_BACKEND "Null" — never let Julia manage Python itself.
# JULIA_PYTHONCALL_EXE "python3" — resolve python3 from PATH at runtime.
# When launched via jlp, PATH will contain the .venv, so PythonCall picks
# up the project-local Python automatically. Outside jlp this is a no-op
# unless a system python3 exists, which is fine since PythonCall won't be
# called without an explicit Julia project that uses it.
export JULIA_CONDAPKG_BACKEND="Null"
export JULIA_PYTHONCALL_EXE="python3"

# Julia helper functions
jlp() {
    if [[ -f ".venv/bin/activate" ]]; then
        source ".venv/bin/activate"
        env -u LD_LIBRARY_PATH julia --project=. "$@"
        deactivate
    else
        env -u LD_LIBRARY_PATH julia --project=. "$@"
    fi
}

julia() {
    command env -u LD_LIBRARY_PATH julia "$@"
}
