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
# tf_cc_framework library
########################################################
set(tf_cc_framework_srcs
    "${tensorflow_source_dir}/tensorflow/cc/framework/ops.h"
    "${tensorflow_source_dir}/tensorflow/cc/framework/ops.cc"
    "${tensorflow_source_dir}/tensorflow/cc/framework/scope.h"
    "${tensorflow_source_dir}/tensorflow/cc/framework/scope_internal.h"
    "${tensorflow_source_dir}/tensorflow/cc/framework/scope.cc"
)
resolve_duplicate_filenames(tf_cc_framework_srcs "${tf_src_regex}")
add_library(tf_cc_framework ${TF_LIB_TYPE} ${tf_cc_framework_srcs})
tf_install_lib(tf_cc_framework)
target_link_libraries(tf_cc_framework PUBLIC tf_core_framework)
target_any_link_libraries(tf_cc_framework PUBLIC "${tensorflow_EXTERNAL_PACKAGES}")

# EIGEN_ROOT=/Users/dhirvonen/.hunter/_Base/109b2ab/93591a7/3d0e0eb/Install

########################################################
# tf_cc_op_gen_main library
########################################################
set(tf_cc_op_gen_main_srcs
    "${tensorflow_source_dir}/tensorflow/cc/framework/cc_op_gen.cc"
    "${tensorflow_source_dir}/tensorflow/cc/framework/cc_op_gen_main.cc"
    "${tensorflow_source_dir}/tensorflow/cc/framework/cc_op_gen.h"
)
resolve_duplicate_filenames(tf_cc_op_gen_main_srcs "${tf_src_regex}")

set(use_object 1)
if(${use_object})
  add_library(tf_cc_op_gen_main OBJECT ${tf_cc_op_gen_main_srcs})
  add_dependencies(tf_cc_op_gen_main tf_core_framework) # add manual dependency if using OBJECT lib  
else()
  add_library(tf_cc_op_gen_main STATIC ${tf_cc_op_gen_main_srcs})
  target_link_libraries(tf_cc_op_gen_main PUBLIC tf_core_framework)
endif()
target_any_link_libraries(tf_cc_op_gen_main PUBLIC "${tensorflow_EXTERNAL_PACKAGES}")

########################################################
# tf_gen_op_wrapper_cc executables
########################################################

# create directory for ops generated files
set(cc_ops_target_dir ${CMAKE_CURRENT_BINARY_DIR}/tensorflow/cc/ops)

add_custom_target(create_cc_ops_header_dir
    COMMAND ${CMAKE_COMMAND} -E make_directory ${cc_ops_target_dir}
)

set_property(TARGET create_cc_ops_header_dir PROPERTY FOLDER "custom")

set(tf_cc_ops_generated_files)

set(tf_cc_op_lib_names
    ${tf_op_lib_names}
    "user_ops"
    )

file(WRITE tf_null.cc "")
  
foreach(tf_cc_op_lib_name ${tf_cc_op_lib_names})
    # Using <TARGET_OBJECTS:...> to work around an issue where no ops were
    # registered (static initializers dropped by the linker because the ops
    # are not used explicitly in the *_gen_cc executables).

    if(${use_object})
      add_executable(${tf_cc_op_lib_name}_gen_cc tf_null.cc  $<TARGET_OBJECTS:tf_cc_op_gen_main>)
      # $<TARGET_OBJECTS:tf_${tf_cc_op_lib_name}>
      # $<TARGET_OBJECTS:tf_core_lib>
      # $<TARGET_OBJECTS:tf_core_framework>
    else()
      add_executable(${tf_cc_op_lib_name}_gen_cc tf_null.cc)
    endif()

    message("ADD ${tf_cc_op_lib_name}_gen_cc w/ ${tf_libs}")
      
    set_property(TARGET ${tf_cc_op_lib_name}_gen_cc PROPERTY FOLDER "app/gen")

    set(my_libs
      tf_${tf_cc_op_lib_name}
      tf_core_lib
      tf_core_framework
      )

    if(NOT ${use_object})
      list(APPEND my_libs tf_cc_op_gen_main)
    endif()

    target_link_libraries(${tf_cc_op_lib_name}_gen_cc PUBLIC
        tf_protos_cc
        ${tensorflow_EXTERNAL_PACKAGES}
        ${tensorflow_EXTERNAL_LIBRARIES}
        sqlite3
        ${my_libs} # from OBJECTS
        )

    set(cc_ops_include_internal 0)
    if(${tf_cc_op_lib_name} STREQUAL "sendrecv_ops")
        set(cc_ops_include_internal 1)
    endif()

    # https://stackoverflow.com/a/32513174
    # Here we use the OUTPUT signature of add_custom_command
    # in order to create a dependency on these files
    # in downstream targets
    #
    # Note that this doesn't seem to work:
    # DEPENDS ${tf_cc_op_lib_name}_gen_cc
    #
    # How do we create a dependency between custom command and another target
    add_custom_command(
      OUTPUT ${cc_ops_target_dir}/${tf_cc_op_lib_name}.h
        ${cc_ops_target_dir}/${tf_cc_op_lib_name}.cc
        ${cc_ops_target_dir}/${tf_cc_op_lib_name}_internal.h
        ${cc_ops_target_dir}/${tf_cc_op_lib_name}_internal.cc
      COMMAND ${tf_cc_op_lib_name}_gen_cc ${cc_ops_target_dir}/${tf_cc_op_lib_name}.h ${cc_ops_target_dir}/${tf_cc_op_lib_name}.cc ${tensorflow_source_dir}/tensorflow/cc/ops/op_gen_overrides.pbtxt ${cc_ops_include_internal} ${tensorflow_source_dir}/tensorflow/core/api_def/base_api
      DEPENDS ${tf_cc_op_lib_name}_gen_cc create_cc_ops_header_dir
    )

  list(APPEND tf_cc_ops_generated_files
    ${cc_ops_target_dir}/${tf_cc_op_lib_name}.h
    ${cc_ops_target_dir}/${tf_cc_op_lib_name}.cc
    ${cc_ops_target_dir}/${tf_cc_op_lib_name}_internal.h
    ${cc_ops_target_dir}/${tf_cc_op_lib_name}_internal.cc)
endforeach()

########################################################
# tf_cc_ops library
########################################################
set(tf_cc_ops_srcs
  ${tf_cc_ops_generated_files}
  "${tensorflow_source_dir}/tensorflow/cc/ops/const_op.h"
  "${tensorflow_source_dir}/tensorflow/cc/ops/const_op.cc"
  "${tensorflow_source_dir}/tensorflow/cc/ops/standard_ops.h"
  )
resolve_duplicate_filenames(tf_cc_ops_srcs "${tf_src_regex}")
add_library(tf_cc_ops ${TF_LIB_TYPE} ${tf_cc_ops_srcs})
tf_install_lib(tf_cc_ops)
target_any_link_libraries(tf_cc_ops PUBLIC "${tensorflow_EXTERNAL_PACKAGES}")

########################################################
# tf_cc_while_loop library
########################################################
set(tf_cc_while_loop_srcs
  "${tensorflow_source_dir}/tensorflow/cc/ops/while_loop.h"
  "${tensorflow_source_dir}/tensorflow/cc/ops/while_loop.cc"
  )
resolve_duplicate_filenames(tf_cc_while_loop_srcs "${tf_src_regex}")
add_library(tf_cc_while_loop ${TF_LIB_TYPE} ${tf_cc_while_loop_srcs})
tf_install_lib(tf_cc_while_loop)
target_link_libraries(tf_cc_while_loop  PUBLIC tf_core_framework tf_cc_ops)
target_any_link_libraries(tf_cc_while_loop PUBLIC "${tensorflow_EXTERNAL_PACKAGES}")

########################################################
# tf_cc library
########################################################
file(GLOB_RECURSE tf_cc_srcs
    "${tensorflow_source_dir}/tensorflow/cc/client/*.h"
    "${tensorflow_source_dir}/tensorflow/cc/client/*.cc"
    "${tensorflow_source_dir}/tensorflow/cc/gradients/*.h"
    "${tensorflow_source_dir}/tensorflow/cc/gradients/*.cc"
    "${tensorflow_source_dir}/tensorflow/cc/training/*.h"
    "${tensorflow_source_dir}/tensorflow/cc/training/*.cc"
)

set(tf_cc_srcs
    ${tf_cc_srcs}
    "${tensorflow_source_dir}/tensorflow/cc/framework/grad_op_registry.h"
    "${tensorflow_source_dir}/tensorflow/cc/framework/grad_op_registry.cc"
    "${tensorflow_source_dir}/tensorflow/cc/framework/gradient_checker.h"
    "${tensorflow_source_dir}/tensorflow/cc/framework/gradient_checker.cc"
    "${tensorflow_source_dir}/tensorflow/cc/framework/gradients.h"
    "${tensorflow_source_dir}/tensorflow/cc/framework/gradients.cc"
    "${tensorflow_source_dir}/tensorflow/cc/framework/while_gradients.h"
    "${tensorflow_source_dir}/tensorflow/cc/framework/while_gradients.cc"
)

file(GLOB_RECURSE tf_cc_test_srcs
    "${tensorflow_source_dir}/tensorflow/cc/*test*.cc"
)

list(REMOVE_ITEM tf_cc_srcs ${tf_cc_test_srcs})
list_sources(tf_cc_srcs)

list_sources(tf_cc_test_srcs)

resolve_duplicate_filenames(tf_cc_srcs "${tf_src_regex}")
add_library(tf_cc ${TF_LIB_TYPE} ${tf_cc_srcs})
tf_install_lib(tf_cc)
target_link_libraries(tf_cc PUBLIC tf_cc_framework tf_cc_ops)
target_any_link_libraries(tf_cc PUBLIC "${tensorflow_EXTERNAL_PACKAGES}")

if (WIN32)
  set (pywrap_tensorflow_lib "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/pywrap_tensorflow_internal.lib")
else (WIN32)
  set (pywrap_tensorflow_lib "${CMAKE_CURRENT_BINARY_DIR}/libpywrap_tensorflow_internal.so")
endif (WIN32)
add_custom_target(tf_extension_ops)
set_property(TARGET tf_extension_ops PROPERTY FOLDER "app/gen")

function(AddUserOps)
  cmake_parse_arguments(_AT "" "" "TARGET;SOURCES;GPUSOURCES;DEPENDS;DISTCOPY" ${ARGN})
  if (tensorflow_ENABLE_GPU AND _AT_GPUSOURCES)
    # if gpu build is enabled and we have gpu specific code,
    # hint to cmake that this needs to go to nvcc
    set (gpu_source ${_AT_GPUSOURCES})
    set (gpu_lib "${_AT_TARGET}_gpu")
    set_source_files_properties(${gpu_source} PROPERTIES CUDA_SOURCE_PROPERTY_FORMAT OBJ)
    cuda_compile(gpu_lib ${gpu_source})
  endif()
  # create shared library from source and cuda obj
  add_library(${_AT_TARGET} SHARED ${_AT_SOURCES} ${gpu_lib})
  tf_install_lib(${_AT_TARGET})
  target_link_libraries(${_AT_TARGET} PUBLIC ${pywrap_tensorflow_lib} sqlite3)
  if (tensorflow_ENABLE_GPU AND _AT_GPUSOURCES)
      # some ops call out to cuda directly; need to link libs for the cuda dlls
      target_link_libraries(${_AT_TARGET} PUBLIC ${CUDA_LIBRARIES})
  endif()
  if (_AT_DISTCOPY)
      add_custom_command(TARGET ${_AT_TARGET} POST_BUILD
          COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${_AT_TARGET}> ${_AT_DISTCOPY}/)
  endif()
  if (_AT_DEPENDS)
    target_link_libraries(${_AT_TARGET} PUBLIC ${_AT_DEPENDS})
  endif()
  # make sure TF_COMPILE_LIBRARY is not defined for this target
  get_target_property(target_compile_flags  ${_AT_TARGET} COMPILE_FLAGS)
  if(target_compile_flags STREQUAL "target_compile_flags-NOTFOUND")
    if (WIN32)
      set(target_compile_flags "/UTF_COMPILE_LIBRARY")
    else (WIN32)
      # gcc uses UTF as default
      set(target_compile_flags "-finput-charset=UTF-8")
    endif (WIN32)
  else()
    if (WIN32)
      set(target_compile_flags "${target_compile_flags} /UTF_COMPILE_LIBRARY")
    else (WIN32)
      # gcc uses UTF as default
      set(target_compile_flags "${target_compile_flags} -finput-charset=UTF-8")
    endif (WIN32)
  endif()
  set_target_properties(${_AT_TARGET} PROPERTIES COMPILE_FLAGS ${target_compile_flags})
  target_link_libraries(tf_extension_ops PUBLIC ${_AT_TARGET})
endfunction(AddUserOps)
