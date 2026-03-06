#!/usr/bin/env fish

set NV       nvidia-open-dkms nvidia-settings cuda cudnn nvtop gdb glu nsight-compute nsight-systems rdma-core opencl-nvidia
set PACKAGES (string collect $PACKAGES $NV)
