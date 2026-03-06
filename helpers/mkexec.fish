#!/usr/bin/env fish

function make_fish_executable -d "Make all .fish files executable recursively"
    set -l target_directory $argv[1]

    if test -z "$target_directory"
        echo "Usage: make_fish_executable <directory>"
        return 1
    end

    if not test -d "$target_directory"
        echo "Error: Directory '$target_directory' does not exist."
        return 1
    end

    for file in (find "$target_directory" -name "*.fish" -type f)
        chmod +x "$file"
        echo "Made executable: $file"
    end
end
