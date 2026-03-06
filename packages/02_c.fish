#!/usr/bin/env fish

basestrap /mnt llvm llvm-libs clang lld compiler-rt
basestrap /mnt gcc gdb gcc-libs libatomic libgcc libstdc++
basestrap /mnt make cmake automake ninja meson pkg-config
basestrap /mnt libuv boost boost-libs libinput libudev libevdev libconfig
