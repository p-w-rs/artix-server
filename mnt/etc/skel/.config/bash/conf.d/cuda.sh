#!/bin/bash

# CUDA — supplement /etc/profile.d/cuda.sh (handles PATH and CUDA_PATH).
if [[ -d "/opt/cuda" ]]; then
    export CUDNN_PATH="/opt/cuda"
    export LD_LIBRARY_PATH="/opt/cuda/lib64:$LD_LIBRARY_PATH"
fi
