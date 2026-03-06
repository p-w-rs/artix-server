#!/usr/bin/env fish

set source_dir "./mnt"
set target_dir "/mnt"

if test -d $source_dir
    mkdir -p $target_dir
    cp -r $source_dir/* $target_dir
    echo "Test copy completed to $target_dir."
else
    echo "Source directory $source_dir does not exist."
    exit 1
end
