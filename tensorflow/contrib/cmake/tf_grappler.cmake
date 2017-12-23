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
# tf_grappler library
########################################################
file(GLOB tf_grappler_srcs
   "${tensorflow_source_dir}/tensorflow/core/grappler/clusters/single_machine.cc"
   "${tensorflow_source_dir}/tensorflow/core/grappler/clusters/single_machine.h"
   "${tensorflow_source_dir}/tensorflow/python/grappler/cost_analyzer.cc"
   "${tensorflow_source_dir}/tensorflow/python/grappler/cost_analyzer.h"
   "${tensorflow_source_dir}/tensorflow/python/grappler/model_analyzer.cc"
   "${tensorflow_source_dir}/tensorflow/python/grappler/model_analyzer.h"
 )
resolve_duplicate_filenames(tf_grappler_srcs "${tf_src_regex}")
add_library(tf_grappler ${TF_LIB_TYPE} ${tf_grappler_srcs})
tf_install_lib(tf_grappler)
target_link_libraries(tf_grappler PUBLIC tf_core_cpu)
target_any_link_libraries(tf_grappler PUBLIC "${tensorflow_EXTERNAL_PACKAGES}")
