#!/usr/bin/env fish

# Run all package install scripts in order.

set DIR (dirname (status filename))

for script in $DIR/*.fish
    test (basename $script) = all.fish; and continue
    chmod +x $script
    echo ">>> Running $script..."
    fish $script
end
