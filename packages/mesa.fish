#!/usr/bin/env fish

basestrap /mnt

set MS       mesa glfw glu cairo sdl3 opencl-nvidia intel-media-driver
set PACKAGES (string collect $PACKAGES $MS)
