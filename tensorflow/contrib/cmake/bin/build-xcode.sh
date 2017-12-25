#!/bin/bash

# tensorflow_ENABLE_GPU "Enable GPU support" OFF)
# tensorflow_BUILD_CC_TESTS)

tf_opts=(
    CUDA_TOOLKIT_ROOT_DIR=/Developer/NVIDIA/CUDA-9.0
    CUDA_TOOLKIT_TARGET_DIR=/Developer/NVIDIA/CUDA-9.0
    tensorflow_PATH_STATIC_LIB=/Developer/NVIDIA/CUDA-9.0/lib
    tensorflow_CUDNN_INCLUDE=$(dirname $(dirname ${CUDNN_PATH}))/include
    tensorflow_PATH_CUDNN_STATIC_LIB=$(dirname ${CUDNN_PATH})
    tensorflow_ENABLE_GPU=ON
    tensorflow_BUILD_CC_TESTS=ON
    tensorflow_ENABLE_GRPC_SUPPORT=ON # needs 1.8
)

#polly.py --toolchain xcode-hid-sections --fwd ${tf_opts[@]} --reconfig --verbose ${*}

#--graphviz=tf_graphviz.cmake

polly.py --toolchain xcode-hid-sections --config Release --fwd ${tf_opts[@]} --verbose ${*}  --jobs 8
