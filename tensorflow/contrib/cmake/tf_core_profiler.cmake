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
# tf_core_profiler library
########################################################
file(GLOB_RECURSE tf_core_profiler_srcs
    "${tensorflow_source_dir}/tensorflow/core/profiler/*.proto"
    "${tensorflow_source_dir}/tensorflow/core/profiler/internal/*.h"
    "${tensorflow_source_dir}/tensorflow/core/profiler/internal/*.cc"
    "${tensorflow_source_dir}/tensorflow/core/profiler/internal/advisor/*.h"
    "${tensorflow_source_dir}/tensorflow/core/profiler/internal/advisor/*.cc"
    "${tensorflow_source_dir}/tensorflow/core/platform/regexp.h"
)

file(GLOB_RECURSE tf_core_profiler_exclude_srcs
    "${tensorflow_source_dir}/tensorflow/core/profiler/internal/*test.cc"
    "${tensorflow_source_dir}/tensorflow/core/profiler/internal/advisor/*test.cc"
    "${tensorflow_source_dir}/tensorflow/core/profiler/internal/print_model_analysis.cc"
    "${tensorflow_source_dir}/tensorflow/core/profiler/internal/print_model_analysis.h"
    )
  
list(REMOVE_ITEM tf_core_profiler_srcs ${tf_core_profiler_exclude_srcs})

list_sources(tf_core_profiler_srcs)
list_sources(tf_core_profiler_exclude_srcs)

resolve_duplicate_filenames(tf_core_profiler_srcs "${tf_src_regex}")
add_library(tf_core_profiler ${TF_LIB_TYPE} ${tf_core_profiler_srcs})
tf_install_lib(tf_core_profiler)
target_link_libraries(tf_core_profiler PUBLIC tf_core_lib)
target_any_link_libraries(tf_core_profiler PUBLIC "${tensorflow_EXTERNAL_PACKAGES}")
