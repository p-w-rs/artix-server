#!/usr/bin/env fish

set LLVM     llvm llvm-libs clang lld
set OTHER    git make
set PACKAGES (string collect $PACKAGES $LLVM $OTHER)
