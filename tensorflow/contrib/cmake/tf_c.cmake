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
# tf_c_framework library
########################################################
set(tf_c_srcs
    "${tensorflow_source_dir}/tensorflow/c/c_api.cc"
    "${tensorflow_source_dir}/tensorflow/c/c_api.h"
    "${tensorflow_source_dir}/tensorflow/c/c_api_function.cc"
    "${tensorflow_source_dir}/tensorflow/c/eager/c_api.cc"
    "${tensorflow_source_dir}/tensorflow/c/eager/c_api.h"
    "${tensorflow_source_dir}/tensorflow/c/eager/tape.h"
    "${tensorflow_source_dir}/tensorflow/c/eager/runtime.cc"
    "${tensorflow_source_dir}/tensorflow/c/eager/runtime.h"
    "${tensorflow_source_dir}/tensorflow/c/checkpoint_reader.cc"
    "${tensorflow_source_dir}/tensorflow/c/checkpoint_reader.h"
    "${tensorflow_source_dir}/tensorflow/c/tf_status_helper.cc"
    "${tensorflow_source_dir}/tensorflow/c/tf_status_helper.h"
)
resolve_duplicate_filenames(tf_c_srcs "${tf_src_regex}")
add_library(tf_c ${TF_LIB_TYPE} ${tf_c_srcs})
tf_install_lib(tf_c)
target_link_libraries(
  tf_c PUBLIC
  tf_cc_framework
  tf_cc_while_loop
  tf_core_lib
  tf_protos_cc)
target_any_link_libraries(tf_c PUBLIC "${tensorflow_EXTERNAL_PACKAGES}")

set(tf_c_python_api_srcs
  "${tensorflow_source_dir}/tensorflow/c/python_api.cc"
  "${tensorflow_source_dir}/tensorflow/c/python_api.h"
  )
resolve_duplicate_filenames(tf_c_python_api_srcs "${tf_src_regex}")
add_library(tf_c_python_api ${TF_LIB_TYPE} ${tf_c_python_api_srcs})
tf_install_lib(tf_c_python_api)
target_link_libraries(
  tf_c_python_api PUBLIC
  tf_c
  tf_core_lib
  tf_core_framework
  tf_protos_cc)
target_any_link_libraries(tf_c_python_api PUBLIC "${tensorflow_EXTERNAL_PACKAGES}")
