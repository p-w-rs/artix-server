#!/usr/bin/env fish

# Make all .fish files in a directory tree executable.
# Usage: mkexec.fish <directory>

function make_fish_executable
    test -n "$argv[1]"; or begin; echo "Usage: mkexec.fish <directory>"; return 1; end
    test -d "$argv[1]"; or begin; echo "Error: '$argv[1]' is not a directory"; return 1; end

    for f in (find $argv[1] -name "*.fish" -type f)
        chmod +x $f
        echo "  $f"
    end
end
