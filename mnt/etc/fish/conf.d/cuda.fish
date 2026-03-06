#!/usr/bin/env fish

# CUDA — supplement /etc/profile.d/cuda.sh (handles PATH and CUDA_PATH).
# Only set what fish won't pick up from the profile.d script.
if test -d /opt/cuda
    set -gx CUDNN_PATH      /opt/cuda
    set -gx LD_LIBRARY_PATH /opt/cuda/lib64 $LD_LIBRARY_PATH
end
