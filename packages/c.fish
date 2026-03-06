#!/usr/bin/env fish

set LLVM     llvm llvm-libs clang lld compiler-rt openmp openmpi
set GCC      gcc gdb gcc-libs libatomic libgcc libstdc++
set MAKE     make cmake automake ninja meson pkg-config
set LIBS     libuv boost boost-libs libinput libudev libevdev libconfig protobuf openssl
set PACKAGES (string collect $PACKAGES $LLVM $GCC $MAKE $LIBS)
