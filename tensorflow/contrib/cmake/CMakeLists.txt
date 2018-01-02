# Minimum CMake required
cmake_minimum_required(VERSION 3.10)

# Project
project(tensorflow VERSION 1.4 LANGUAGES C CXX)

# Define the export name to be used throughout
set(TARGETS_EXPORT_NAME "${PROJECT_NAME}Targets")
function(tf_install_lib target)
  install(
    TARGETS ${target}
    EXPORT ${TARGETS_EXPORT_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)
endfunction()

set(TF_LIB_TYPE STATIC) # future use

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Set C++14 as standard for the whole project
set(CMAKE_CXX_STANDARD 14)

# Actual source is the ../../.. directory
get_filename_component(tf_contrib_source_dir ${tensorflow_SOURCE_DIR} PATH)
get_filename_component(tf_tf_source_dir ${tf_contrib_source_dir} PATH)
get_filename_component(tensorflow_source_dir ${tf_tf_source_dir} PATH)

message("TF: tensorflow_SOURCE_DIR ${tensorflow_SOURCE_DIR}")
message("TF: tf_contrib_source_dir ${tf_contrib_source_dir}")  
message("TF: tf_tf_source_dir ${tf_tf_source_dir}")
message("TF: tensorflow_source_dir ${tensorflow_source_dir}")

# [CLEANUP] Not sure if this is needed (copied from Protobuf)
# CMake policies
cmake_policy(SET CMP0022 NEW)

# Options
option(tensorflow_VERBOSE "Enable for verbose output" OFF)
option(tensorflow_ENABLE_SSL_SUPPORT "Enable boringssl support" OFF)
option(tensorflow_ENABLE_GRPC_SUPPORT "Enable gRPC support" ON) # need 1.8
option(tensorflow_ENABLE_HDFS_SUPPORT "Enable HDFS support" OFF)
option(tensorflow_ENABLE_JEMALLOC_SUPPORT "Enable jemalloc support" OFF)
option(tensorflow_BUILD_CC_EXAMPLE "Build the C++ tutorial example" ON)
option(tensorflow_BUILD_PYTHON_BINDINGS "Build the Python bindings" OFF) # NEED SWIG
option(tensorflow_BUILD_ALL_KERNELS "Build all OpKernels" ON)
option(tensorflow_BUILD_CONTRIB_KERNELS "Build OpKernels from tensorflow/contrib/..." ON)
option(tensorflow_BUILD_CC_TESTS "Build cc unit tests " OFF)
option(tensorflow_BUILD_PYTHON_TESTS "Build python unit tests " OFF)
option(tensorflow_BUILD_MORE_PYTHON_TESTS "Build more python unit tests for contrib packages" OFF)
option(tensorflow_BUILD_SHARED_LIB "Build TensorFlow as a shared library" OFF) # else static
option(tensorflow_OPTIMIZE_FOR_NATIVE_ARCH "Enable compiler optimizations for the native processor architecture (if available)" ON)
option(tensorflow_WIN_CPU_SIMD_OPTIONS "Enables CPU SIMD instructions" ON)
option(tensorflow_ENABLE_SNAPPY_SUPPORT "Enable SNAPPY compression support" ON)
option(tensorflow_DISABLE_EIGEN_FORCEINLINE "Disable forceinline, to speed up build on windows." OFF)
option(tensorflow_ENABLE_FIND_PACKAGE "Use find_package()" ON)

# GPU, CUDA and cuDNN options
option(tensorflow_ENABLE_GPU "Enable GPU support" OFF)
set(tensorflow_CUDA_VERSION 9.0 CACHE STRING "CUDA version to build against")
set(tensorflow_CUDNN_VERSION 7 CACHE STRING "cuDNN version to build against")

# Compatibiltiy with CMake's CUDA_SELECT_NVCC_ARCH_FLAGS
# https://gitlab.kitware.com/cmake/cmake/blob/2b0256c5ade94ca19467fd42075b3c22bd3856f2/Modules/FindCUDA/select_compute_arch.cmake
# * All     : all CUDA architectures
# * Auto    : for the detected CUDA architecture only
# * Commaon : all common CUDA architectures
# * Default : default tensorflow CUDA architectures
# * Min     : minimum CUDA architecture
set(tensorflow_CUDA_VALID_TYPES Auto Common All Default Min)
set(tensorflow_CUDA_TYPE Default CACHE STRING "Cuda type (Auto|Common|All|Default|Min)")
set_property(CACHE tensorflow_CUDA_TYPE PROPERTY STRINGS ${tensorflow_CUDA_VALID_TYPES})
if(NOT tensorflow_CUDA_TYPE IN_LIST tensorflow_CUDA_VALID_TYPES)
    message(FATAL_ERROR "tensorflow_CUDA_TYPE must be one of ${tensorflow_CUDA_VALID_TYPES}")
endif()

message("tensorflow_CUDA_VERSION: ${tensorflow_CUDA_VERSION} ")
message("tensorflow_CUDNN_VERSION: ${tensorflow_CUDNN_VERSION} ")

if(HAIKU)
	option(tensorflow_ENABLE_POSITION_INDEPENDENT_CODE "Enable PIE support" OFF)
else()
	option(tensorflow_ENABLE_POSITION_INDEPENDENT_CODE "Enable PIE support" ON)
endif()

option(tensorflow_ENABLE_XSMM_SUPPORT "Enable XSMM support" OFF)

if(tensorflow_BUILD_SHARED_LIB)
  set(TF_SDK_TYPE SHARED)
else()
  set(TF_SDK_TYPE STATIC)
endif()

if (NOT WIN32)
  # Threads: defines CMAKE_THREAD_LIBS_INIT and adds -pthread compile option
  # for targets that link ${CMAKE_THREAD_LIBS_INIT}.
  find_package (Threads)

  option(tensorflow_PATH_STATIC_LIB "Additional library search path for libcudnn_static.a, libnccl_static.a, libculibos.a" /usr/local/cuda/lib64/)
  option(tensorflow_CUDNN_INCLUDE "cudnn.h header install path" /usr/include/)
  if (NOT tensorflow_CUDNN_INCLUDE)
    # option's default value is OFF. Fill it with real default values
    set(tensorflow_CUDNN_INCLUDE /usr/include)
  endif (NOT tensorflow_CUDNN_INCLUDE)
  option(tensorflow_PATH_CUDNN_STATIC_LIB "Override PATH_STATIC_LIB for libcudnn_static.a" ${tensorflow_PATH_STATIC_LIB})
  if (NOT tensorflow_PATH_CUDNN_STATIC_LIB)
    # option's default value is OFF. Fill it with real default values
    set (tensorflow_PATH_CUDNN_STATIC_LIB ${tensorflow_PATH_STATIC_LIB})
  endif (NOT tensorflow_PATH_CUDNN_STATIC_LIB)
  option(tensorflow_PATH_NCCL_STATIC_LIB "Override PATH_STATIC_LIB for libnccl_static.a" ${tensorflow_PATH_STATIC_LIB})
  if (NOT tensorflow_PATH_NCCL_STATIC_LIB)
    # option's default value is OFF. Fill it with real default values
    set (tensorflow_PATH_NCCL_STATIC_LIB ${tensorflow_PATH_STATIC_LIB})
  endif (NOT tensorflow_PATH_NCCL_STATIC_LIB)
  option(tensorflow_CUDA_LIBRARY_PATH "Designate the default CUDA library paths" /usr/local/cuda/lib64)
  if (NOT tensorflow_CUDA_LIBRARY_PATH)
    # option's default value is OFF. Fill it with real default values
    set(tensorflow_CUDA_LIBRARY_PATH /usr/local/cuda/lib64)
  endif (NOT tensorflow_CUDA_LIBRARY_PATH)
endif()

if (WIN32)
  set(BOOL_WIN32 ON)
else (WIN32)
  set(BOOL_WIN32 OFF)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
endif (WIN32)

# [CLEANUP] Remove when done
# For debugging
function(SHOW_VARIABLES)
    get_cmake_property(_variableNames VARIABLES)
    foreach (_variableName ${_variableNames})
        message(STATUS "${_variableName}=${${_variableName}}")
    endforeach()
endfunction()

# External dependencies
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/external)
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

# Location where external projects will be downloaded
set (DOWNLOAD_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/downloads"
     CACHE PATH "Location where external projects will be downloaded.")
mark_as_advanced(DOWNLOAD_LOCATION)

if (tensorflow_ENABLE_POSITION_INDEPENDENT_CODE)
	set(CMAKE_POSITION_INDEPENDENT_CODE ON)
else()
	set(CMAKE_POSITION_INDEPENDENT_CODE OFF)
endif()

if (tensorflow_DISABLE_EIGEN_FORCEINLINE)
  add_definitions(-DEIGEN_STRONG_INLINE=inline)
endif()

add_definitions(-DEIGEN_AVOID_STL_ARRAY)
if(WIN32)
  add_definitions(-DNOMINMAX -D_WIN32_WINNT=0x0A00 -DLANG_CXX11 -DCOMPILER_MSVC)
  add_definitions(-DWIN32 -DOS_WIN -D_MBCS -DWIN64 -DWIN32_LEAN_AND_MEAN -DNOGDI -DPLATFORM_WINDOWS)
  add_definitions(-DTENSORFLOW_USE_EIGEN_THREADPOOL -DEIGEN_HAS_C99_MATH)
  add_definitions(-DTF_COMPILE_LIBRARY)
  add_definitions(/bigobj /nologo /EHsc /GF /MP /Gm-)
  # Suppress warnings to reduce build log size.
  add_definitions(/wd4267 /wd4244 /wd4800 /wd4503 /wd4554 /wd4996 /wd4348 /wd4018)
  add_definitions(/wd4099 /wd4146 /wd4267 /wd4305 /wd4307)
  add_definitions(/wd4715 /wd4722 /wd4723 /wd4838 /wd4309 /wd4334)
  add_definitions(/wd4003 /wd4244 /wd4267 /wd4503 /wd4506 /wd4800 /wd4996)
  # Suppress linker warnings.
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /ignore:4049 /ignore:4197 /ignore:4217 /ignore:4221")
  set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /ignore:4049 /ignore:4197 /ignore:4217 /ignore:4221")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /ignore:4049 /ignore:4197 /ignore:4217 /ignore:4221")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")
  set(CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG /MDd /Ob2")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /D_ITERATOR_DEBUG_LEVEL=0")
  set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} /D_ITERATOR_DEBUG_LEVEL=0")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /D_ITERATOR_DEBUG_LEVEL=0")
endif()

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions -std=c++11")
endif()

if (tensorflow_OPTIMIZE_FOR_NATIVE_ARCH)
  include(CheckCXXCompilerFlag)
  CHECK_CXX_COMPILER_FLAG("-march=native" COMPILER_OPT_ARCH_NATIVE_SUPPORTED)
  if (COMPILER_OPT_ARCH_NATIVE_SUPPORTED)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native")
  endif()
endif()

# MSVC SIMD instructions
if (tensorflow_WIN_CPU_SIMD_OPTIONS)
  if (WIN32)
    CHECK_CXX_COMPILER_FLAG("${tensorflow_WIN_CPU_SIMD_OPTIONS}" COMPILER_OPT_WIN_CPU_SIMD_SUPPORTED)
    if(COMPILER_OPT_WIN_CPU_SIMD_SUPPORTED)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${tensorflow_WIN_CPU_SIMD_OPTIONS}")
    else()
      message(FATAL_ERROR "${tensorflow_WIN_CPU_SIMD_OPTIONS} not supported")
    endif()
  endif()
endif()

if (tensorflow_ENABLE_JEMALLOC_SUPPORT)
  add_definitions(-DTENSORFLOW_USE_JEMALLOC -DJEMALLOC_EXPORT=)
endif()

# External dependencies

if(NOT tensorflow_ENABLE_FIND_PACKAGE)
  message(FATAL_ERROR "Must default to tensorflow external package add")
endif()

# include(zlib)
hunter_add_package(ZLIB)
find_package(ZLIB CONFIG REQUIRED) # ZLIB::zlib

# include(gif)
hunter_add_package(giflib)
find_package(giflib CONFIG REQUIRED) # giflib::giflib

# include(png)
hunter_add_package(PNG)
find_package(PNG CONFIG REQUIRED) # PNG::png

# include(jpeg)
hunter_add_package(Jpeg)
find_package(Jpeg CONFIG REQUIRED) # JPEG::jpeg

# include(lmdb)
hunter_add_package(lmdb)
find_package(liblmdb CONFIG REQUIRED) #  liblmdb::lmdb

# include(eigen)
hunter_add_package(Eigen)
find_package(Eigen3 CONFIG REQUIRED) # Eigen3::Eigen

# include(gemmlowp)
hunter_add_package(gemmlowp)
find_package(gemmlowp CONFIG REQUIRED) # gemmlowp::gemmlowp

# include(jsoncpp)
hunter_add_package(jsoncpp)
find_package(jsoncpp CONFIG REQUIRED) # jsoncpp_lib_static

# include(farmhash)
hunter_add_package(farmhash)
find_package(farmhash CONFIG REQUIRED) # farmhash::farmhash

# include(fft2d)
hunter_add_package(fft2d)
find_package(fft2d CONFIG REQUIRED) # fft2d::fft2d

# include(highwayhash)
hunter_add_package(highwayhash)
find_package(highwayhash CONFIG REQUIRED) # highwayhash::highwayhash)

# include(nsync)
hunter_add_package(nsync)
find_package(nsync CONFIG REQUIRED) # nsync::nsync)

SHOW_VARIABLES()

#########################
### include(protobuf) ###
#########################
# If we cross compile for Android or iOS build a separate 
# protoc executable on host to compile .proto files in CMake
if(IOS OR ANDROID)
  # add cmake/host subdiretcory as host project to install protoc
  include(hunter_experimental_add_host_project)
  hunter_experimental_add_host_project(cmake/host)

  add_executable(protobuf::protoc IMPORTED)
  set_property(TARGET protobuf::protoc APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
  set_target_properties(protobuf::protoc PROPERTIES IMPORTED_LOCATION_RELEASE "${HUNTER_HOST_ROOT}/bin/protoc")

  message(STATUS "Using imported protoc from host: ${HUNTER_HOST_ROOT}/bin/protoc")
endif(IOS OR ANDROID)

hunter_add_package(Protobuf)
find_package(Protobuf CONFIG REQUIRED) # TODO

set(PROTOBUF_PROTOC_EXECUTABLE protobuf::protoc)
get_target_property(PROTOBUF_INCLUDE_DIRS protobuf::libprotobuf INTERFACE_INCLUDE_DIRECTORIES)

#########################

# include(re2)
hunter_add_package(re2)
find_package(RE2 CONFIG REQUIRED) # RE2::re2

# include(cub)
if(tensorflow_ENABLE_GPU)
  hunter_add_package(cub)
  find_package(cub CONFIG REQUIRED) # cub::cub
endif()

# include(sqlite)
hunter_add_package(SQLite3)
find_package(SQLite3 REQUIRED) # sqlite3

if (tensorflow_BUILD_CC_TESTS)
  #  include(googletest)
  hunter_add_package(GTest)
  find_package(GTest CONFIG REQUIRED) # GTest::main
endif()

# set(tensorflow_EXTERNAL_LIBRARIES
#     ${zlib_STATIC_LIBRARIES}
#     ${gif_STATIC_LIBRARIES}
#     ${png_STATIC_LIBRARIES}
#     ${jpeg_STATIC_LIBRARIES}
#     ${lmdb_STATIC_LIBRARIES}
#     ${jsoncpp_STATIC_LIBRARIES}
#     ${farmhash_STATIC_LIBRARIES}
#     ${fft2d_STATIC_LIBRARIES}
#     ${highwayhash_STATIC_LIBRARIES}
#     ${nsync_STATIC_LIBRARIES}
#     ${protobuf_STATIC_LIBRARIES}
#     ${re2_STATIC_LIBRARIES}
#     ${sqlite_STATIC_LIBRARIES}
# )

set(tensorflow_EXTERNAL_PACKAGES
  ZLIB::zlib
  giflib::giflib
  PNG::png
  JPEG::jpeg
  liblmdb::lmdb
  Eigen3::Eigen
  gemmlowp::gemmlowp
  jsoncpp_lib_static
  farmhash::farmhash
  fft2d::fft2d
  highwayhash::highwayhash
  nsync::nsync
  protobuf::libprotobuf       # required?
  protobuf::libprotobuf-lite  # required?
  protobuf::libprotoc         # required?
  RE2::re2
  )

if(tensorflow_ENABLE_GPU)
  list(APPEND tensorflow_EXTERNAL_PACKAGES cub::cub)
endif()

set(tensorflow_EXTERNAL_LIBRARIES
  sqlite3
  )

# Note: For *_copy_headers_to_destination we 
#
# set(tensorflow_EXTERNAL_DEPENDENCIES
#     zlib_copy_headers_to_destination
#     gif_copy_headers_to_destination
#     png_copy_headers_to_destination
#     jpeg_copy_headers_to_destination
#     lmdb_copy_headers_to_destination
#     jsoncpp
#     farmhash_copy_headers_to_destination
#     highwayhash_copy_headers_to_destination
#     nsync_copy_headers_to_destination
#     protobuf
#     eigen
#     gemmlowp
#     cub
#     fft2d
#     re2
#     sqlite_copy_headers_to_destination
# )

function(list_sources srcs)
  foreach(src ${${srcs}})
    message("\t${srcs} ${src}")
  endforeach()
endfunction(list_sources)

function(target_any_link_libraries target scope libraries)
  get_target_property(target_type ${target} TYPE)
  string( COMPARE EQUAL "${target_type}" "OBJECT_LIBRARY" is_object_library)
  if(${is_object_library})
    foreach(dep ${libraries})
      target_include_directories(${target} ${scope} $<TARGET_PROPERTY:${dep},INTERFACE_INCLUDE_DIRECTORIES>)
      target_compile_definitions(${target} ${scope} $<TARGET_PROPERTY:${dep},INTERFACE_COMPILE_DEFINITIONS>)
      target_include_directories(${target} ${scope} ${EIGEN_ROOT}/include/eigen3) # for unsupported
    endforeach()
  else()
    foreach(dep ${libraries})
      target_link_libraries(${target} ${scope} ${dep})
      target_include_directories(${target} ${scope} ${EIGEN_ROOT}/include/eigen3) # for unsupported
    endforeach() 
  endif()
  set_property(TARGET ${target} PROPERTY FOLDER "lib")
endfunction(target_any_link_libraries)

include_directories(
    # Source and generated code.
    ${tensorflow_source_dir}
    ${CMAKE_CURRENT_BINARY_DIR}
    # External dependencies.

    # HUNTER: Linking with hunter packages will provide header paths automatically
    
#     ${zlib_INCLUDE_DIR}
#     ${gif_INCLUDE_DIR}
#     ${png_INCLUDE_DIR}
#     ${jpeg_INCLUDE_DIR}
#     ${lmdb_INCLUDE_DIR}
#     ${eigen_INCLUDE_DIRS}
#     ${gemmlowp_INCLUDE_DIR}
#     ${jsoncpp_INCLUDE_DIR}
#     ${farmhash_INCLUDE_DIR}
#     ${highwayhash_INCLUDE_DIR}
#     ${cub_INCLUDE_DIR}
#     ${nsync_INCLUDE_DIR}
#     ${PROTOBUF_INCLUDE_DIRS}
#     ${re2_INCLUDE_DIR}
#     ${sqlite_INCLUDE_DIR}
)

if(tensorflow_ENABLE_SSL_SUPPORT)
  #   include(boringssl)
  #   list(APPEND tensorflow_EXTERNAL_LIBRARIES ${boringssl_STATIC_LIBRARIES})
  #   list(APPEND tensorflow_EXTERNAL_DEPENDENCIES boringssl)
  #   include_directories(${boringssl_INCLUDE_DIR})
  hunter_add_package(BoringSSL)
  find_package(BoringSSL CONFIG REQUIRED)
  list(APPEND tensorflow_EXTERNAL_PACKAGES BoringSSL::ssl BoringSSL::crypto)
endif()
if(tensorflow_ENABLE_GRPC_SUPPORT)
  #   include(grpc)
  #   list(APPEND tensorflow_EXTERNAL_LIBRARIES ${grpc_STATIC_LIBRARIES})
  #   list(APPEND tensorflow_EXTERNAL_DEPENDENCIES grpc)
  #   include_directories(${GRPC_INCLUDE_DIRS})
  hunter_add_package(gRPC)
  find_package(gRPC CONFIG REQUIRED)
  list(APPEND tensorflow_EXTERNAL_PACKAGES
    gRPC::gpr
    gRPC::grpc
    gRPC::grpc_cronet
    gRPC::grpc_unsecure
    gRPC::grpc++
    gRPC::grpc++_cronet
    gRPC::grpc++_error_details
    gRPC::grpc++_reflection
    gRPC::grpc++_unsecure
    gRPC::grpc_plugin_support
    #gRPC::grpc_csharp_ext
    #gRPC::check_epollexclusive
    #gRPC::gen_hpack_tables
    #gRPC::gen_legal_metadata_characters
    #gRPC::gen_percent_encoding_tables
    #gRPC::grpc_create_jwt
    #gRPC::grpc_print_google_default_creds_token
    #gRPC::grpc_verify_jwt
    #gRPC::grpc_cpp_plugin
    #gRPC::grpc_csharp_plugin
    #gRPC::grpc_node_plugin
    #gRPC::grpc_objective_c_plugin
    #gRPC::grpc_php_plugin
    #gRPC::grpc_python_plugin
    #gRPC::grpc_ruby_plugin
    )
  
  find_program(GRPC_CPP_PLUGIN
    grpc_cpp_plugin
    HINTS
    ${CMAKE_FIND_ROOT_PATH}/bin
    NO_DEFAULT_PATH
    )
  
  add_executable(grpc_cpp_plugin IMPORTED)
  set_property(TARGET grpc_cpp_plugin APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
  set_target_properties(grpc_cpp_plugin PROPERTIES IMPORTED_LOCATION_RELEASE "${CMAKE_FIND_ROOT_PATH}/bin/grpc_cpp_plugin")

  message("HUNTER_ROOT = ${HUNTER_ROOT}")
  message("HUNTER_HOST_ROOT/bin/grpc_cpp_plugin: ${HUNTER_HOST_ROOT}/bin/grpc_cpp_plugin ")
  
  # find_program(grpc_cpp_plugin_exe NAMES grpc_cpp_plugin)
  # if(grpc_cpp_plugin_exe-NOTFOUND)
  #   message(FATAL_ERROR "Couldn't find grpc_cpp_plugin")
  # endif()
  
endif()
if(tensorflow_ENABLE_JEMALLOC_SUPPORT)
  #   include(jemalloc)
  #   list(APPEND tensorflow_EXTERNAL_LIBRARIES ${jemalloc_STATIC_LIBRARIES})
  #   list(APPEND tensorflow_EXTERNAL_DEPENDENCIES jemalloc)
  #   include_directories(${jemalloc_INCLUDE_DIRS})
  hunter_add_package(jemalloc)
  find_package(jemalloc CONFIG REQUIRED)
  list(APPEND tensorflow_EXTERNAL_PACKAGES jemalloc::jemalloc)
endif()
if(tensorflow_ENABLE_SNAPPY_SUPPORT)
  #   include(snappy)
  #   list(APPEND tensorflow_EXTERNAL_LIBRARIES ${snappy_STATIC_LIBRARIES})
  #   list(APPEND tensorflow_EXTERNAL_DEPENDENCIES snappy)
  #   include_directories(${snappy_INCLUDE_DIR})
  hunter_add_package(Snappy)
  find_package(Snappy CONFIG REQUIRED)
  list(APPEND tensorflow_EXTERNAL_PACKAGES Snappy::snappy)
endif()
if(WIN32)
  list(APPEND tensorflow_EXTERNAL_LIBRARIES wsock32 ws2_32 shlwapi)
endif()
if(UNIX)
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${CMAKE_THREAD_LIBS_INIT} ${CMAKE_DL_LIBS})
endif()
if(HAIKU)
  list(APPEND tensorflow_EXTERNAL_LIBRARIES network)
endif()

# Platform checks
string(COMPARE EQUAL "${CMAKE_SYSTEM_NAME}" "Darwin" is_osx)

if(is_osx)
  set(XCODE_TAG "_osx")
  set(use_nccl FALSE)
else()
  set(XCODE_TAG "")  
  set(use_nccl TRUE)
endif()

option(tensorflow_USE_NCCL "Use NCCL lib" ${use_ncc})

if (tensorflow_ENABLE_GPU)
  if (NOT WIN32)
    # Default install paths for cuda libraries in Linux
    # In some Linux distros, find_package(CUDA) seems to require CMAKE_LIBRARY_PATH to include cuda-lib paths
    list(APPEND CMAKE_LIBRARY_PATH "${tensorflow_CUDA_LIBRARY_PATH}")
    list(APPEND CMAKE_LIBRARY_PATH "${tensorflow_CUDA_LIBRARY_PATH}/stubs")
  endif (NOT WIN32)

  find_package(CUDA ${tensorflow_CUDA_VERSION} REQUIRED)

  #CUDA_DETECT_INSTALLED_GPUS(tf_cuda_arch_list)

  # by default we assume compute cabability 3.5 and 5.2. If you change this change it in
  # CUDA_NVCC_FLAGS and cuda_config.h below
  message("tensorflow_CUDA_TYPE = ${tensorflow_CUDA_TYPE}")
  if("${tensorflow_CUDA_TYPE}" STREQUAL "Default")
    set(tf_cuda_nvcc_arch_flags
      "-gencode arch=compute_30,code=\"sm_30,compute_30\""
      "-gencode arch=compute_35,code=\"sm_35,compute_35\""
      "-gencode arch=compute_52,code=\"sm_52,compute_52\"")
  elseif("${tensorflow_CUDA_TYPE}" STREQUAL "Min")
    set(tf_cuda_nvcc_arch_flags
      "-gencode arch=compute_30,code=\"sm_30,compute_30\"")
  else()
    CUDA_SELECT_NVCC_ARCH_FLAGS(tf_cuda_nvcc_arch_flags ${tensorflow_CUDA_TYPE})
  endif()

  list(APPEND CUDA_NVCC_FLAGS
    ${tf_cuda_nvcc_arch_flags}
    --include-path ${PROJECT_BINARY_DIR}/$\{build_configuration\}
    --expt-relaxed-constexpr
    -ftz=true  # Flush denormals to zero
    -O0 # fast compilation (to improve build times while debugging)
    )
  
  set(CUDA_INCLUDE ${CUDA_TOOLKIT_TARGET_DIR} ${CUDA_TOOLKIT_TARGET_DIR}/extras/CUPTI/include)
  include_directories(${CUDA_INCLUDE})

  # extract version strings from tf_cuda_nvcc_arch_flags
  # i.e., map default ${tf_cuda_nvcc_arch_flags} above to
  # * comma separated list "3.0,3.5,5.2" for add_definitions(-DTF_EXTRA_CUDA_CAPABILITIES...)
  # * CudaVersion("3.0")  for configure_file() w/ cuda_config.h
  # Note, below we use "|" since "[,$]" doesn't work in the regex https://cmake.org/Bug/view.php?id=5380&history=1 
  STRING(REGEX MATCHALL "\([0-9]+\)" tf_cuda_arch_list "${tf_cuda_nvcc_arch_flags}")
  list(REMOVE_DUPLICATES tf_cuda_arch_list)
  string(REPLACE ";" "," tf_cuda_arch_list "${tf_cuda_arch_list}")
  string(REGEX REPLACE  "([0-9])+([0-9])([,|])" "\\1\.\\2\\3" tf_cuda_arch_list_commas "${tf_cuda_arch_list}|")
  string(REPLACE "|" "" tf_cuda_arch_list_commas ${tf_cuda_arch_list_commas})
  string(REGEX REPLACE  "([0-9])+([0-9])([,|])" "CudaVersion(\"\\1\.\\2\")\\3" tf_cuda_arch_list_format "${tf_cuda_arch_list}|")
  string(REPLACE "|" "" tf_cuda_arch_list_format ${tf_cuda_arch_list_format})

  message("tf_cuda_arch_list_commas ${tf_cuda_arch_list_commas}")
  message("tf_cuda_arch_list_format ${tf_cuda_arch_list_format}")
  
  # add definition for tensorflow/tensorflow//core/common_runtime/gpu/gpu_device.cc
  add_definitions(-DGOOGLE_CUDA=1 -DTF_EXTRA_CUDA_CAPABILITIES="${tf_cuda_arch_list_commas}")

  if (WIN32)
    # add cudnn
    if(NOT CUDNN_HOME)
      set(CUDNN_HOME ${CUDA_TOOLKIT_TARGET_DIR})
    endif(NOT CUDNN_HOME)
    include_directories(${CUDNN_HOME})
    set(CUDA_LIBRARIES ${CUDA_LIBRARIES} ${CUDA_CUDA_LIBRARY} ${CUDA_CUBLAS_LIBRARIES} ${CUDA_CUFFT_LIBRARIES}
      ${CUDA_curand_LIBRARY} ${CUDA_cupti_LIBRARY} ${CUDA_cusolver_LIBRARY} ${CUDNN_HOME}/lib/x64/cudnn.lib)
  else (WIN32)
    set(CUDNN_INCLUDE "${tensorflow_CUDNN_INCLUDE}")

    if(tensorflow_USE_NCCL)
      find_library(nccl_STATIC_LIBRARY NAMES libnccl_static.a PATHS ${tensorflow_PATH_NCCL_STATIC_LIB} ${CUDA_TOOLKIT_ROOT_DIR})
      if (NOT nccl_STATIC_LIBRARY)
        message(FATAL_ERROR "NCCL is required for GPU-build")
      else (NOT nccl_STATIC_LIBRARY)
        message("nccl-static: ${nccl_STATIC_LIBRARY}")
        # something like /usr/lib64/libnccl_static.a
      endif (NOT nccl_STATIC_LIBRARY)
    endif()

    find_library(cudnn_STATIC_LIBRARY NAMES libcudnn_static.a PATHS ${tensorflow_PATH_CUDNN_STATIC_LIB} ${CUDA_TOOLKIT_ROOT_DIR})
    if (NOT cudnn_STATIC_LIBRARY)
      message(FATAL_ERROR "CUDNN is required for GPU-build")
    else (NOT cudnn_STATIC_LIBRARY)
      message("cudnn-static: ${cudnn_STATIC_LIBRARY}")
    endif (NOT cudnn_STATIC_LIBRARY)

    find_library(culibos_STATIC_LIBRARY NAMES libculibos.a PATHS ${tensorflow_PATH_STATIC_LIB} ${CUDA_TOOLKIT_ROOT_DIR})
    if (NOT culibos_STATIC_LIBRARY)
      message(FATAL_ERROR "CULIBOS is required for GPU-build")
    else (NOT culibos_STATIC_LIBRARY)
      message("culibos-static: ${culibos_STATIC_LIBRARY}")
    endif (NOT culibos_STATIC_LIBRARY)

    if(APPLE)
      # cupti_wrapper.h : "extras/CUPTI/include/cupti.h"
      include_directories(${CUDA_TOOLKIT_ROOT_DIR})
    endif()
    
    include_directories(${CUDNN_INCLUDE})
    set(CUDA_LIBRARIES
      ${CUDA_LIBRARIES}
      ${CUDA_CUDA_LIBRARY}
      ${CUDA_CUBLAS_LIBRARIES}
      ${CUDA_CUFFT_LIBRARIES}
      ${CUDA_curand_LIBRARY}
      ${CUDA_cupti_LIBRARY}
      ${CUDA_cusolver_LIBRARY}
      ${cudnn_STATIC_LIBRARY}
      ${culibos_STATIC_LIBRARY}
      ${nccl_STATIC_LIBRARY})
  endif (WIN32)

  # Remove "." from CUDA version variable.
  string(REPLACE "." "" short_CUDA_VER ${tensorflow_CUDA_VERSION})

  # create cuda_config.h

  # Generate file:
  #   @cuda_compute_capabilities@
  #   @cuda_version@
  #   @cudnn_version@
  #   @cuda_toolkit_path@
  set(cuda_compute_capabilities "${tf_cuda_arch_list_format}")
  set(cuda_version "64_${short_CUDA_VER}")
  set(cudnn_version "64_${tensorflow_CUDNN_VERSION}")
  set(cuda_toolkit_path "${CUDA_TOOLKIT_ROOT_DIR}")
  set(cuda_config_h "${tensorflow_source_dir}/third_party/gpus/cuda/cuda_config.h")
  set(cuda_config_h_in "${tensorflow_source_dir}/third_party/gpus/cuda/cuda_config.h.in")
  configure_file("${cuda_config_h_in}" "${cuda_config_h}" @ONLY)

  # tf assumes in various places header files to be in cuda/include. On windows the cuda sdk
  # installs them under cuda/version/include and to avoid that we need to change tf we copy a
  # few files to cuda/include    
  set(cuda_header_files
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cuda.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cuComplex.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cublas_v2.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cufft.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/curand.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cuda_runtime_api.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cusolverDn.h
    )
  if (WIN32)
    list(APPEND cuda_header_files ${CUDNN_HOME}/include/cudnn.h)
  else(WIN32)
    list(APPEND cuda_header_files ${CUDNN_INCLUDE}/cudnn.h)
  endif(WIN32)
  set(cuda_include_install "${tensorflow_source_dir}/third_party/gpus/cuda/include/")
  add_custom_target(
    tf_cuda_headers
    COMMAND ${CMAKE_COMMAND} -E make_directory "${cuda_include_install}"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${cuda_header_files} "${cuda_include_install}"
    )  

  # TODO: replace global
  include_directories(${tensorflow_source_dir}/third_party/gpus)
  # add cuda libraries to tensorflow_EXTERNAL_LIBRARIES
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${CUDA_LIBRARIES})

  # NOTE(mrry): Update these flags when the version of CUDA or cuDNN used
  # in the default build is upgraded.
  if(WIN32)
    set(tensorflow_BUILD_INFO_FLAGS --build_config cuda --key_value
        msvcp_dll_name=msvcp140.dll
        cudart_dll_name=cudart64_${short_CUDA_VER}.dll
        cuda_version_number=${tensorflow_CUDA_VERSION}
        nvcuda_dll_name=nvcuda.dll
        cudnn_dll_name=cudnn64_${tensorflow_CUDNN_VERSION}.dll
        cudnn_version_number=${tensorflow_CUDNN_VERSION})
  else(WIN32)
    set(tensorflow_BUILD_INFO_FLAGS --build_config cuda --key_value
	    cuda_version_number=${tensorflow_CUDA_VERSION}
	    cudnn_version_number=${tensorflow_CUDNN_VERSION})
  endif(WIN32)
else(tensorflow_ENABLE_GPU)
  set(tensorflow_BUILD_INFO_FLAGS --build_config cpu --key_value
    msvcp_dll_name=msvcp140.dll)
endif(tensorflow_ENABLE_GPU)

# Find python executable
include(FindPythonInterp)
if(NOT ${PYTHONINTERP_FOUND})
    message(FATAL_ERROR "CMake was unable to find a python interpreter.")
endif()

set(tf_src_regex "^.+\\.cc$")
include(resolve_duplicate_filenames.cmake)

# Let's get to work!
include(tf_core_framework.cmake)
add_dependencies(tf_protos_cc tf_cuda_headers)

include(tf_stream_executor.cmake)
include(tf_core_cpu.cmake)
include(tf_core_ops.cmake)
include(tf_core_direct_session.cmake)
include(tf_core_kernels.cmake)

# make sure cuda headers are installed
if(tensorflow_ENABLE_GPU AND tf_core_gpu_kernels_lib)
  add_dependencies(${tf_core_gpu_kernels_lib} tf_cuda_headers)
endif()

if(tensorflow_ENABLE_GRPC_SUPPORT)
  include(tf_core_distributed_runtime.cmake)
endif()

# We include tf_cc_ops first, because tf_c depends on tf_cc.
include(tf_cc_ops.cmake)
include(tf_c.cmake)
include(tf_grappler.cmake)
include(tf_core_profiler.cmake)
if(tensorflow_BUILD_CC_EXAMPLE)
  include(tf_tutorials.cmake)
  include(tf_label_image_example.cmake)
endif()
include(tf_tools.cmake)
if(tensorflow_BUILD_PYTHON_BINDINGS)
  include(tf_python.cmake)
endif()

# This is the only file that exports a tensorflow lib
# We modify this such that a lib is always created
# where tensorflow_BUILD_SHARED_LIB toggles the
# SHARED vs STATIC target type.
#if(tensorflow_BUILD_SHARED_LIB)
include(tf_shared_lib.cmake)
#endif()
  
if(tensorflow_BUILD_CC_TESTS OR tensorflow_BUILD_PYTHON_TESTS)
  include(tf_tests.cmake)
endif()
