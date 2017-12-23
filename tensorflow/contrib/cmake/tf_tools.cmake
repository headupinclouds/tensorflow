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
set(tf_tools_proto_text_src_dir "${tensorflow_source_dir}/tensorflow/tools/proto_text")

file(GLOB tf_tools_proto_text_srcs
    "${tf_tools_proto_text_src_dir}/gen_proto_text_functions.cc"
    "${tf_tools_proto_text_src_dir}/gen_proto_text_functions_lib.h"
    "${tf_tools_proto_text_src_dir}/gen_proto_text_functions_lib.cc"
)

set(proto_text "proto_text")

add_executable(${proto_text}
    ${tf_tools_proto_text_srcs}
    #$<TARGET_OBJECTS:tf_core_lib>
    )

target_link_libraries(${proto_text} PUBLIC
  ${tensorflow_EXTERNAL_PACKAGES}
  ${tensorflow_EXTERNAL_LIBRARIES}
  tf_protos_cc
  sqlite3
  tf_core_lib # from OBJECT
)

set_property(TARGET ${proto_text} PROPERTY FOLDER "app")

target_link_libraries(${proto_text} PUBLIC tf_core_lib)

# Use Hunter
# if(tensorflow_ENABLE_GRPC_SUPPORT)
#     target_link_libraries(${proto_text} PUBLIC grpc)
# endif(tensorflow_ENABLE_GRPC_SUPPORT)

file(GLOB_RECURSE tf_tools_transform_graph_lib_srcs
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/*.h"
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/*.cc"
)

file(GLOB_RECURSE tf_tools_transform_graph_lib_exclude_srcs
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/*test*.h"
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/*test*.cc"
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/compare_graphs.cc"
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/summarize_graph_main.cc"
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/transform_graph_main.cc"
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/quantize_nodes.cc"
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/quantize_weights.cc"
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/round_weights.cc"
    )

list(REMOVE_ITEM tf_tools_transform_graph_lib_srcs ${tf_tools_transform_graph_lib_exclude_srcs})

list_sources(tf_tools_transform_graph_lib_srcs)
list_sources(tf_tools_transform_graph_lib_exclude_srcs)

resolve_duplicate_filenames(tf_tools_transform_graph_lib_srcs "${tf_src_regex}")
add_library(tf_tools_transform_graph_lib ${TF_LIB_TYPE} ${tf_tools_transform_graph_lib_srcs})
tf_install_lib(tf_tools_transform_graph_lib) 
target_link_libraries(tf_tools_transform_graph_lib PUBLIC
  tf_core_cpu
  tf_core_framework
  tf_core_kernels
  tf_core_lib
  tf_core_ops
  )

target_any_link_libraries(tf_tools_transform_graph_lib PUBLIC "${tensorflow_EXTERNAL_PACKAGES}")

set(transform_graph "transform_graph")

set(tf_libs
  tf_tools_transform_graph_lib
  tf_core_lib
  tf_core_cpu
  tf_core_framework
  tf_core_ops
  tf_core_direct_session
  tf_tools_transform_graph_lib
  tf_core_kernels
  )

if(tensorflow_ENABLE_GPU)
  if(${BOOL_WIN32})
    list(APPEND tf_libs tf_core_kernels_cpu_only)
  endif()
  list(APPEND tf_libs tf_stream_executor)
endif()

add_executable(${transform_graph}
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/transform_graph_main.cc"
    # $<TARGET_OBJECTS:tf_tools_transform_graph_lib>
    # $<TARGET_OBJECTS:tf_core_lib>
    # $<TARGET_OBJECTS:tf_core_cpu>
    # $<TARGET_OBJECTS:tf_core_framework>
    # $<TARGET_OBJECTS:tf_core_ops>
    # $<TARGET_OBJECTS:tf_core_direct_session>
    # $<TARGET_OBJECTS:tf_tools_transform_graph_lib>
    # $<TARGET_OBJECTS:tf_core_kernels>
    # $<$<BOOL:${tensorflow_ENABLE_GPU}>:$<$<BOOL:${BOOL_WIN32}>:$<TARGET_OBJECTS:tf_core_kernels_cpu_only>>>
    # $<$<BOOL:${tensorflow_ENABLE_GPU}>:$<TARGET_OBJECTS:tf_stream_executor>>
)

target_link_libraries(${transform_graph} PUBLIC
  tf_protos_cc
  ${tf_core_gpu_kernels_lib}
  ${tensorflow_EXTERNAL_PACKAGES}
  ${tensorflow_EXTERNAL_LIBRARIES}
  sqlite3
  ${tf_libs} # from OBJECT libraries
  )

set_property(TARGET ${transform_graph} PROPERTY FOLDER "app")

set(summarize_graph "summarize_graph")

add_executable(${summarize_graph}
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/summarize_graph_main.cc"
    # $<TARGET_OBJECTS:tf_tools_transform_graph_lib>
    # $<TARGET_OBJECTS:tf_core_lib>
    # $<TARGET_OBJECTS:tf_core_cpu>
    # $<TARGET_OBJECTS:tf_core_framework>
    # $<TARGET_OBJECTS:tf_core_ops>
    # $<TARGET_OBJECTS:tf_core_direct_session>
    # $<TARGET_OBJECTS:tf_tools_transform_graph_lib>
    # $<TARGET_OBJECTS:tf_core_kernels>
    # $<$<BOOL:${tensorflow_ENABLE_GPU}>:$<$<BOOL:${BOOL_WIN32}>:$<TARGET_OBJECTS:tf_core_kernels_cpu_only>>>
    # $<$<BOOL:${tensorflow_ENABLE_GPU}>:$<TARGET_OBJECTS:tf_stream_executor>>
)

target_link_libraries(${summarize_graph} PUBLIC
  tf_protos_cc
  ${tf_core_gpu_kernels_lib}
  ${tensorflow_EXTERNAL_PACKAGES}
  ${tensorflow_EXTERNAL_LIBRARIES}
  sqlite3
  ${tf_libs} # from OBJECT libraries  
  )

set_property(TARGET ${summarize_graph} PROPERTY FOLDER "app")

set(compare_graphs "compare_graphs")

add_executable(${compare_graphs}
    "${tensorflow_source_dir}/tensorflow/tools/graph_transforms/compare_graphs.cc"
    # $<TARGET_OBJECTS:tf_tools_transform_graph_lib>
    # $<TARGET_OBJECTS:tf_core_lib>
    # $<TARGET_OBJECTS:tf_core_cpu>
    # $<TARGET_OBJECTS:tf_core_framework>
    # $<TARGET_OBJECTS:tf_core_ops>
    # $<TARGET_OBJECTS:tf_core_direct_session>
    # $<TARGET_OBJECTS:tf_tools_transform_graph_lib>
    # $<TARGET_OBJECTS:tf_core_kernels>
    # $<$<BOOL:${tensorflow_ENABLE_GPU}>:$<$<BOOL:${BOOL_WIN32}>:$<TARGET_OBJECTS:tf_core_kernels_cpu_only>>>
    # $<$<BOOL:${tensorflow_ENABLE_GPU}>:$<TARGET_OBJECTS:tf_stream_executor>>
)

target_link_libraries(${compare_graphs} PUBLIC
  tf_protos_cc
  ${tf_core_gpu_kernels_lib}
  ${tensorflow_EXTERNAL_PACKAGES}
  ${tensorflow_EXTERNAL_LIBRARIES}
  sqlite3
  ${tf_libs} # from OBJECT libs
  )

set_property(TARGET ${compare_graphs} PROPERTY FOLDER "app")

set(benchmark_model "benchmark_model")

add_executable(${benchmark_model}
    "${tensorflow_source_dir}/tensorflow/tools/benchmark/benchmark_model.cc"
    "${tensorflow_source_dir}/tensorflow/tools/benchmark/benchmark_model_main.cc"
    # $<TARGET_OBJECTS:tf_core_lib>
    # $<TARGET_OBJECTS:tf_core_cpu>
    # $<TARGET_OBJECTS:tf_core_framework>
    # $<TARGET_OBJECTS:tf_core_ops>
    # $<TARGET_OBJECTS:tf_core_direct_session>
    # $<TARGET_OBJECTS:tf_core_kernels>
    # $<$<BOOL:${tensorflow_ENABLE_GPU}>:$<$<BOOL:${BOOL_WIN32}>:$<TARGET_OBJECTS:tf_core_kernels_cpu_only>>>
    # $<$<BOOL:${tensorflow_ENABLE_GPU}>:$<TARGET_OBJECTS:tf_stream_executor>>
)

target_link_libraries(${benchmark_model} PUBLIC
  tf_protos_cc
  ${tf_core_gpu_kernels_lib}
  ${tensorflow_EXTERNAL_PACKAGES}
  ${tensorflow_EXTERNAL_LIBRARIES}
  sqlite3
  ${tf_libs} # from OBJECT libs
)

install(TARGETS ${transform_graph} ${summarize_graph} ${compare_graphs} ${benchmark_model} tf_tools_transform_graph_lib
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)

set_property(TARGET ${benchmark_model} PROPERTY FOLDER "app")
