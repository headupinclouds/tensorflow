# Copyright 2017 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
########################################################
# tf_core_kernels library
########################################################

if(tensorflow_BUILD_ALL_KERNELS)
  file(GLOB_RECURSE tf_core_kernels_srcs
     "${tensorflow_source_dir}/tensorflow/core/kernels/*.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/*.cc"
  )
else(tensorflow_BUILD_ALL_KERNELS)
  # Build a minimal subset of kernels to be able to run a test program.
  set(tf_core_kernels_srcs
     "${tensorflow_source_dir}/tensorflow/core/kernels/bounds_check.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/constant_op.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/constant_op.cc"
     "${tensorflow_source_dir}/tensorflow/core/kernels/fill_functor.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/fill_functor.cc"
     "${tensorflow_source_dir}/tensorflow/core/kernels/matmul_op.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/matmul_op.cc"
     "${tensorflow_source_dir}/tensorflow/core/kernels/no_op.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/no_op.cc"
     "${tensorflow_source_dir}/tensorflow/core/kernels/ops_util.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/ops_util.cc"
     "${tensorflow_source_dir}/tensorflow/core/kernels/sendrecv_ops.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/sendrecv_ops.cc"
  )
endif(tensorflow_BUILD_ALL_KERNELS)

if(tensorflow_BUILD_CONTRIB_KERNELS)
  set(tf_contrib_kernels_srcs
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/kernels/model_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/kernels/prediction_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/kernels/quantile_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/kernels/split_handler_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/kernels/stats_accumulator_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/kernels/training_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/lib/utils/batch_features.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/lib/utils/dropout_utils.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/lib/utils/examples_iterable.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/lib/utils/parallel_for.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/lib/utils/sparse_column_iterable.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/lib/utils/tensor_utils.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/lib/learner/common/partitioners/example_partitioner.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/lib/models/multiple_additive_trees.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/lib/trees/decision_tree.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/ops/model_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/ops/prediction_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/ops/quantile_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/ops/split_handler_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/ops/stats_accumulator_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/boosted_trees/ops/training_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/cudnn_rnn/kernels/cudnn_rnn_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/cudnn_rnn/ops/cudnn_rnn_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/data/kernels/prefetching_kernels.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/data/ops/prefetching_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/factorization/kernels/clustering_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/factorization/kernels/masked_matmul_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/factorization/kernels/wals_solver_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/factorization/ops/clustering_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/factorization/ops/factorization_ops.cc"
      #"${tensorflow_source_dir}/tensorflow/contrib/ffmpeg/decode_audio_op.cc"
      #"${tensorflow_source_dir}/tensorflow/contrib/ffmpeg/encode_audio_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/framework/kernels/zero_initializer_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/framework/ops/variable_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/image/kernels/adjust_hsv_in_yiq_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/image/kernels/bipartite_match_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/image/kernels/image_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/image/kernels/single_image_random_dot_stereograms_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/image/ops/distort_image_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/image/ops/image_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/image/ops/single_image_random_dot_stereograms_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/layers/kernels/sparse_feature_cross_kernel.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/layers/ops/sparse_feature_cross_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/libsvm/kernels/decode_libsvm_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/libsvm/ops/libsvm_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/nearest_neighbor/kernels/hyperplane_lsh_probes.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/nearest_neighbor/ops/nearest_neighbor_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/resampler/kernels/resampler_ops.cc"
      #"${tensorflow_source_dir}/tensorflow/contrib/resampler/ops/resampler_occlps.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/rnn/kernels/blas_gemm.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/rnn/kernels/gru_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/rnn/kernels/lstm_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/rnn/ops/gru_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/rnn/ops/lstm_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/seq2seq/kernels/beam_search_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/seq2seq/ops/beam_search_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/ops/tensor_forest_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/kernels/reinterpret_string_to_float_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/kernels/scatter_add_ndim_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/kernels/tree_utils.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/hybrid/core/ops/hard_routing_function_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/hybrid/core/ops/k_feature_gradient_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/hybrid/core/ops/k_feature_routing_function_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/hybrid/core/ops/routing_function_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/hybrid/core/ops/routing_gradient_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/hybrid/core/ops/stochastic_hard_routing_function_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/hybrid/core/ops/stochastic_hard_routing_gradient_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/hybrid/core/ops/unpack_path_op.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tensor_forest/hybrid/core/ops/utils.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/text/kernels/skip_gram_kernels.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/text/ops/skip_gram_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tpu/ops/cross_replica_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tpu/ops/infeed_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tpu/ops/outfeed_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tpu/ops/replication_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/tpu/ops/tpu_configuration_ops.cc"
    )
  list(APPEND tf_core_kernels_srcs ${tf_contrib_kernels_srcs})

  if(tensorflow_USE_NCCL)
    list(APPEND tf_core_kernels_srcs
      "${tensorflow_source_dir}/tensorflow/contrib/nccl/kernels/nccl_manager.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/nccl/kernels/nccl_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/nccl/ops/nccl_ops.cc"
      )
  endif()

endif(tensorflow_BUILD_CONTRIB_KERNELS)

if(NOT tensorflow_ENABLE_SSL_SUPPORT)
  # Cloud libraries require boringssl.
  file(GLOB tf_core_kernels_cloud_srcs
      "${tensorflow_source_dir}/tensorflow/contrib/cloud/kernels/*.h"
      "${tensorflow_source_dir}/tensorflow/contrib/cloud/kernels/*.cc"
  )
list(REMOVE_ITEM tf_core_kernels_srcs ${tf_core_kernels_cloud_srcs})
endif()

file(GLOB_RECURSE tf_core_kernels_exclude_srcs
   "${tensorflow_source_dir}/tensorflow/core/kernels/*test*.h"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*test*.cc"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*testutil.h"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*testutil.cc"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*test_utils.h"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*test_utils.cc"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*main.cc"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*.cu.cc"
   "${tensorflow_source_dir}/tensorflow/core/kernels/fuzzing/*"
   "${tensorflow_source_dir}/tensorflow/core/kernels/hexagon/*"
   "${tensorflow_source_dir}/tensorflow/core/kernels/remote_fused_graph_rewriter_transform*.cc"
   )
    
list(REMOVE_ITEM tf_core_kernels_srcs ${tf_core_kernels_exclude_srcs})

#list_sources(tf_core_kernels_exclude_srcs)
list_sources(tf_core_kernels_srcs) 

if(WIN32)
  file(GLOB_RECURSE tf_core_kernels_windows_exclude_srcs
      # not working on windows yet
      "${tensorflow_source_dir}/tensorflow/core/kernels/neon/*"
      # not in core - those are loaded dynamically as dll
      "${tensorflow_source_dir}/tensorflow/contrib/nearest_neighbor/kernels/hyperplane_lsh_probes.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/nearest_neighbor/ops/nearest_neighbor_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/resampler/kernels/resampler_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/rnn/kernels/blas_gemm.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/rnn/kernels/gru_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/rnn/kernels/lstm_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/rnn/ops/gru_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/rnn/ops/lstm_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/seq2seq/kernels/beam_search_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/seq2seq/ops/beam_search_ops.cc"
  )
  list(REMOVE_ITEM tf_core_kernels_srcs ${tf_core_kernels_windows_exclude_srcs})
endif(WIN32)

file(GLOB_RECURSE tf_core_gpu_kernels_srcs
    "${tensorflow_source_dir}/tensorflow/core/kernels/*.cu.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/framework/kernels/zero_initializer_op_gpu.cu.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/image/kernels/*.cu.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/rnn/kernels/*.cu.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/seq2seq/kernels/*.cu.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/resampler/kernels/*.cu.cc"
)

if(WIN32 AND tensorflow_ENABLE_GPU)
  file(GLOB_RECURSE tf_core_kernels_cpu_only_srcs
      # GPU implementation not working on Windows yet.
      "${tensorflow_source_dir}/tensorflow/core/kernels/matrix_diag_op.cc"
      "${tensorflow_source_dir}/tensorflow/core/kernels/one_hot_op.cc")
  list(REMOVE_ITEM tf_core_kernels_srcs ${tf_core_kernels_cpu_only_srcs})
  resolve_duplicate_filenames(tf_core_kernels_cpu_only_srcs "${tf_src_regex}")
  add_library(tf_core_kernels_cpu_only ${TF_LIB_TYPE} ${tf_core_kernels_cpu_only_srcs})
  tf_install_lib(tf_core_kernels_cpu_only)
  target_link_libraries(tf_core_kernels_cpu_only PUBLIC tf_core_cpu)
  target_any_link_libraries(tf_core_kernels_cpu_only PUBLIC "${tensorflow_EXTERNAL_PACKAGES}")
  
  # Undefine GOOGLE_CUDA to avoid registering unsupported GPU kernel symbols.
  get_target_property(target_compile_flags tf_core_kernels_cpu_only COMPILE_FLAGS)
  if(target_compile_flags STREQUAL "target_compile_flags-NOTFOUND")
    set(target_compile_flags "/UGOOGLE_CUDA")
  else()
    set(target_compile_flags "${target_compile_flags} /UGOOGLE_CUDA")
  endif()
  set_target_properties(tf_core_kernels_cpu_only PROPERTIES COMPILE_FLAGS ${target_compile_flags})
endif(WIN32 AND tensorflow_ENABLE_GPU)

resolve_duplicate_filenames(tf_core_kernels_srcs "${tf_src_regex}")
add_library(tf_core_kernels ${TF_LIB_TYPE} ${tf_core_kernels_srcs})
tf_install_lib(tf_core_kernels)
target_link_libraries(tf_core_kernels PUBLIC tf_core_cpu)
# For hunter
target_any_link_libraries(tf_core_kernels PUBLIC "${tensorflow_EXTERNAL_PACKAGES}")

if (WIN32)
  target_compile_options(tf_core_kernels PUBLIC /MP)
endif (WIN32)

if (tensorflow_ENABLE_GPU)

  list_sources(tf_core_gpu_kernels_srcs)

  # Xcode requires *.cu extensions:
  set(tf_core_gpu_kernels_srcs_cu "")
  foreach(file ${tf_core_gpu_kernels_srcs})
    file(RELATIVE_PATH file_relative "${CMAKE_SOURCE_DIR}" ${file})
    get_filename_component(file_dir ${file_relative} DIRECTORY)
    get_filename_component(file_ext ${file_relative} EXT)
    get_filename_component(file_name ${file_relative} NAME_WE)
    set(mirror "${CMAKE_BINARY_DIR}/${file_dir}/${file_name}.cu")
    configure_file(${file} ${mirror} COPYONLY)
    message("mirror: ${mirror}")
    list(APPEND tf_core_gpu_kernels_srcs_cu ${mirror})    
  endforeach()

  message("MIRROR: ${tf_core_gpu_kernels_srcs_cu}")

  set_source_files_properties(${tf_core_gpu_kernels_srcs_cu} PROPERTIES CUDA_SOURCE_PROPERTY_FORMAT OBJ)
  set(tf_core_gpu_kernels_lib tf_core_gpu_kernels)

  # we need at least one cpp file for cuda_add_library() to produce a lib
  set(tf_null_tmp ${CMAKE_CURRENT_BINARY_DIR}/tf_null.cc)
  set(tf_null ${CMAKE_CURRENT_LIST_DIR}/tf_null.cc)
  file(WRITE ${tf_null_tmp} "")
  add_custom_command(
    OUTPUT "${tf_null}"
    DEPENDS "${tf_null_tmp}"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${tf_null_tmp}" "${tf_null}"
    )

  cuda_add_library(${tf_core_gpu_kernels_lib} STATIC ${tf_core_gpu_kernels_srcs_cu} ${tf_null})
  tf_install_lib(${tf_core_gpu_kernels_lib})
  set_target_properties(${tf_core_gpu_kernels_lib}
                        PROPERTIES DEBUG_POSTFIX ""
                        COMPILE_FLAGS "${TF_REGULAR_CXX_FLAGS}"
  )
target_link_libraries(${tf_core_gpu_kernels_lib} tf_core_cpu) # FindCUDA uses "plain" target_link_libraries

endif()
