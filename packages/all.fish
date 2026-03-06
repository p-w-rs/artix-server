#!/usr/bin/env fish

set DIR (dirname (status filename))

for script in $DIR/*.fish
    chmod +x $file
    fish $file
end
