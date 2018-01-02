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

set(tf_libs
  tf_c
  tf_cc
  tf_cc_framework
  tf_cc_ops
  tf_cc_while_loop
  tf_core_lib
  tf_core_cpu
  tf_core_framework
  tf_core_ops
  tf_core_direct_session
  tf_tools_transform_graph_lib
  tf_core_kernels
  )

if(TARGET tf_core_distributed_runtime)
  list(APPEND tf_libs tf_core_distributed_runtime)
endif()

if(tensorflow_ENABLE_GPU)

  if(TARGET tf_core_kernels_cpu_only)
    list(APPEND tf_libs tf_core_kernels_cpu_only)
  endif()

  if(TARGET tf_stream_executor)
    list(APPEND tf_stream_executor)
  endif()
  
endif()


if(WIN32 AND tensorflow_BUILD_SHARED_LIB)
  # Windows: build a static library with the same objects as tensorflow.dll.
  # This can be used to build for a standalone exe and also helps us to
  # find all symbols that need to be exported from the dll which is needed
  # to provide the tensorflow c/c++ api in tensorflow.dll.
  # From the static library we create the def file with all symbols that need to
  # be exported from tensorflow.dll. Because there is a limit of 64K sybmols
  # that can be exported, we filter the symbols with a python script to the namespaces
  # we need.
  #

  # TODO: create empty *.cc files for the lib
  # and use copy_if_different to avoid rebuilds
  
  add_library(tensorflow_static STATIC
      # $<TARGET_OBJECTS:tf_c>
      # $<TARGET_OBJECTS:tf_cc>
      # $<TARGET_OBJECTS:tf_cc_framework>
      # $<TARGET_OBJECTS:tf_cc_ops>
      # $<TARGET_OBJECTS:tf_cc_while_loop>
      # $<TARGET_OBJECTS:tf_core_lib>
      # $<TARGET_OBJECTS:tf_core_cpu>
      # $<TARGET_OBJECTS:tf_core_framework>
      # $<TARGET_OBJECTS:tf_core_ops>
      # $<TARGET_OBJECTS:tf_core_direct_session>
      # $<TARGET_OBJECTS:tf_tools_transform_graph_lib>
      # $<$<BOOL:${tensorflow_ENABLE_GRPC_SUPPORT}>:$<TARGET_OBJECTS:tf_core_distributed_runtime>>
      # $<TARGET_OBJECTS:tf_core_kernels>
      # $<$<BOOL:${tensorflow_ENABLE_GPU}>:$<TARGET_OBJECTS:tf_core_kernels_cpu_only>>
      # $<$<BOOL:${tensorflow_ENABLE_GPU}>:$<TARGET_OBJECTS:tf_stream_executor>>
  )

  target_link_libraries(tensorflow_static PUBLIC
    tf_protos_cc
    ${tf_libs} # from OBJECT libs
    )
  set(tensorflow_static_dependencies
      $<TARGET_FILE:tensorflow_static>
      $<TARGET_FILE:tf_protos_cc>
  )

  set(tensorflow_deffile "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/tensorflow.def")
  set_source_files_properties(${tensorflow_deffile} PROPERTIES GENERATED TRUE)

  add_custom_command(TARGET tensorflow_static POST_BUILD
      COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/tools/create_def_file.py
          --input "${tensorflow_static_dependencies}"
          --output "${tensorflow_deffile}"
          --target tensorflow.dll
  )
endif()

# tensorflow is a shared library containing all of the
# TensorFlow runtime and the standard ops and kernels.
add_library(${PROJECT_NAME} ${TF_SDK_TYPE} # (SHARED | STATIC)
    # $<TARGET_OBJECTS:tf_c>
    # $<TARGET_OBJECTS:tf_cc>
    # $<TARGET_OBJECTS:tf_cc_framework>
    # $<TARGET_OBJECTS:tf_cc_ops>
    # $<TARGET_OBJECTS:tf_cc_while_loop>
    # $<TARGET_OBJECTS:tf_core_lib>
    # $<TARGET_OBJECTS:tf_core_cpu>
    # $<TARGET_OBJECTS:tf_core_framework>
    # $<TARGET_OBJECTS:tf_core_ops>
    # $<TARGET_OBJECTS:tf_core_direct_session>
    # $<TARGET_OBJECTS:tf_tools_transform_graph_lib>
    # $<$<BOOL:${tensorflow_ENABLE_GRPC_SUPPORT}>:$<TARGET_OBJECTS:tf_core_distributed_runtime>>
    # $<TARGET_OBJECTS:tf_core_kernels>
    # $<$<BOOL:${tensorflow_ENABLE_GPU}>:$<$<BOOL:${BOOL_WIN32}>:$<TARGET_OBJECTS:tf_core_kernels_cpu_only>>>
    # $<$<BOOL:${tensorflow_ENABLE_GPU}>:$<TARGET_OBJECTS:tf_stream_executor>>
    ${tensorflow_deffile}
)

target_link_libraries(tensorflow PUBLIC
    ${tf_core_gpu_kernels_lib}
    ${tensorflow_EXTERNAL_PACKAGES}
    ${tensorflow_EXTERNAL_LIBRARIES}
    tf_protos_cc
    ${tf_libs} # from OBJECT libs
    )

tf_install_lib(tensorflow)

# There is a bug in GCC 5 resulting in undefined reference to a __cpu_model function when
# linking to the tensorflow library. Adding the following libraries fixes it.
# See issue on github: https://github.com/tensorflow/tensorflow/issues/9593
if(CMAKE_COMPILER_IS_GNUCC AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 5.0)
    target_link_libraries(tensorflow PUBLIC gcc_s gcc)
endif()

if(WIN32 AND tensorflow_BUILD_SHARED_LIB)
  target_link_libraries(tensorflow PUBLIC tensorflow_static)
endif()

if(NOT tensorflow_ENABLE_FIND_PACKAGE)
  target_include_directories(tensorflow PUBLIC 
    $<INSTALL_INTERFACE:include/> # redundant
    $<INSTALL_INTERFACE:include/external/nsync/public>)
endif()

##############################################################################
# Installation
#
# https://github.com/forexample/package-example/blob/master/Foo/CMakeLists.txt
##############################################################################

# Generate:
#   * ${CMAKE_CURRENT_BINARY_DIR}/generated_headers/${PROJECT_NAME}/${PROJECT_NAME}_EXPORT.h
# Renaming because:
# * We need prefix '${PROJECT_NAME}' to fit OSX/iOS frameworks layout
# * File name matches name of the macro
set(generated_headers "${CMAKE_CURRENT_BINARY_DIR}/generated_headers")
set(tf_export "${generated_headers}/${PROJECT_NAME}/${PROJECT_NAME}_EXPORT.h")
include(GenerateExportHeader)
generate_export_header(${PROJECT_NAME} EXPORT_FILE_NAME ${tf_export})

# Layout. This works for all platforms:
#   * <prefix>/lib/cmake/<PROJECT-NAME>
#   * <prefix>/lib/
#   * <prefix>/include/
set(config_install_dir "lib/cmake/${PROJECT_NAME}")
set(include_install_dir "include")

set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")

# Configuration
set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(namespace "${PROJECT_NAME}::")

# Include module with fuction 'write_basic_package_version_file'
include(CMakePackageConfigHelpers)

# Configure '<PROJECT-NAME>ConfigVersion.cmake'
# Use:
#   * PROJECT_VERSION
write_basic_package_version_file(
    "${version_config}" COMPATIBILITY SameMajorVersion
)

# Configure '<PROJECT-NAME>Config.cmake'
# Use variables:
#   * TARGETS_EXPORT_NAME
#   * PROJECT_NAME
configure_package_config_file(
    "cmake/Config.cmake.in"
    "${project_config}"
    INSTALL_DESTINATION "${config_install_dir}"
)

# Targets:
#   * <prefix>/lib/libtensorflow.a
#   * header location after install: <prefix>/include/${PROJECT_NAME}/xyz/abc.hpp
#   * headers can be included by C++ code `#include <tensorflow/xyz/abc.hpp>`
install(
    TARGETS "${PROJECT_NAME}"
    EXPORT "${TARGETS_EXPORT_NAME}"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
    RUNTIME DESTINATION "bin"
    INCLUDES DESTINATION "${include_install_dir}"
)

# Export headers:
#     ${CMAKE_CURRENT_BINARY_DIR}/.../${PROJECT_NAME}_EXPORT.h ->
#    <prefix>/include/${PROJECT_NAME}/${PROJECT_NAME}_EXPORT.h
install(
    FILES "${tf_export}"
    DESTINATION "${include_install_dir}/${PROJECT_NAME}"
)

# Config
#   * <prefix>/lib/cmake/${PROJECT_NAME}/${PROJECT_NAME}Config.cmake
#   * <prefix>/lib/cmake/${PROJECT_NAME}/${PROJECT_NAME}ConfigVersion.cmake
install(
    FILES "${project_config}" "${version_config}"
    DESTINATION "${config_install_dir}"
)

# Config
#   * <prefix>/lib/cmake/${PROJECT_NAME}/${PROJECT_NAME}Targets.cmake
install(
    EXPORT "${TARGETS_EXPORT_NAME}"
    NAMESPACE "${namespace}"
    DESTINATION "${config_install_dir}"
)
# }

# install necessary headers
# tensorflow headers
set(tf_modules cc core)
foreach(module ${tf_modules})
  install(DIRECTORY ${tensorflow_source_dir}/tensorflow/${module}/
          DESTINATION include/tensorflow/${module}
          FILES_MATCHING PATTERN "*.h")
  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tensorflow/${module}/
          DESTINATION include/tensorflow/${module}
          FILES_MATCHING PATTERN "*.h")
endforeach()
install(DIRECTORY ${tensorflow_source_dir}/tensorflow/stream_executor/
        DESTINATION include/tensorflow/stream_executor
        FILES_MATCHING PATTERN "*.h")


if(tensorflow_ENABLE_FIND_PACKAGE)
  # We are using find_package()
  return()
endif()
      
# google protobuf headers
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/protobuf/src/protobuf/src/google/
        DESTINATION include/google
        FILES_MATCHING PATTERN "*.h")
# nsync headers
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/external/nsync/
        DESTINATION include/external/nsync
        FILES_MATCHING PATTERN "*.h")
# Eigen directory
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/eigen/src/eigen/Eigen/
        DESTINATION include/Eigen)
# external directory
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/external/eigen_archive/
        DESTINATION include/external/eigen_archive)
# third_party eigen directory
install(DIRECTORY ${tensorflow_source_dir}/third_party/eigen3/
        DESTINATION include/third_party/eigen3)
# unsupported Eigen directory
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/eigen/src/eigen/unsupported/Eigen/
        DESTINATION include/unsupported/Eigen)
