# Minimum CMake required
cmake_minimum_required(VERSION 3.5)

include("cmake/HunterGate.cmake")
HunterGate(
  URL "https://github.com/ruslo/hunter/archive/v0.19.188.tar.gz"
  SHA1 "67ab3a0206d8cdb9372ce22dc28eafc1d6bcc557"
  LOCAL # cmake/config.cmake
)

# Project
project(tensorflow VERSION 1.4 LANGUAGES C CXX)

option(tensorflow_USE_OBJECT_LIBS "Use internal object libs" ON)
if(tensorflow_USE_OBJECT_LIBS)
  set(TF_LIB_TYPE OBJECT)
else()
  set(TF_LIB_TYPE STATIC)
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Set C++14 as standard for the whole project
set(CMAKE_CXX_STANDARD 14)

# Actual source is the ../../.. directory
get_filename_component(tf_contrib_source_dir ${tensorflow_SOURCE_DIR} PATH)
get_filename_component(tf_tf_source_dir ${tf_contrib_source_dir} PATH)
get_filename_component(tensorflow_source_dir ${tf_tf_source_dir} PATH)

# [CLEANUP] Not sure if this is needed (copied from Protobuf)
# CMake policies
cmake_policy(SET CMP0022 NEW)

# Options
option(tensorflow_VERBOSE "Enable for verbose output" OFF)
option(tensorflow_ENABLE_GPU "Enable GPU support" OFF)
option(tensorflow_ENABLE_SSL_SUPPORT "Enable boringssl support" OFF)
option(tensorflow_ENABLE_GRPC_SUPPORT "Enable gRPC support" ON)
option(tensorflow_ENABLE_HDFS_SUPPORT "Enable HDFS support" OFF)
option(tensorflow_ENABLE_JEMALLOC_SUPPORT "Enable jemalloc support" OFF)
option(tensorflow_BUILD_CC_EXAMPLE "Build the C++ tutorial example" ON)
option(tensorflow_BUILD_PYTHON_BINDINGS "Build the Python bindings" OFF) # NEED SWIG
option(tensorflow_BUILD_ALL_KERNELS "Build all OpKernels" ON)
option(tensorflow_BUILD_CONTRIB_KERNELS "Build OpKernels from tensorflow/contrib/..." ON)
option(tensorflow_BUILD_CC_TESTS "Build cc unit tests " OFF)
option(tensorflow_BUILD_PYTHON_TESTS "Build python unit tests " OFF)
option(tensorflow_BUILD_MORE_PYTHON_TESTS "Build more python unit tests for contrib packages" OFF)
option(tensorflow_BUILD_SHARED_LIB "Build TensorFlow as a shared library" ON)
option(tensorflow_OPTIMIZE_FOR_NATIVE_ARCH "Enable compiler optimizations for the native processor architecture (if available)" ON)
option(tensorflow_WIN_CPU_SIMD_OPTIONS "Enables CPU SIMD instructions")
option(tensorflow_ENABLE_SNAPPY_SUPPORT "Enable SNAPPY compression support" ON)

option(tensorflow_ENABLE_XSMM_SUPPORT "Enable XSMM support" OFF)

if (NOT WIN32)
  # Threads: defines CMAKE_THREAD_LIBS_INIT and adds -pthread compile option
  # for targets that link ${CMAKE_THREAD_LIBS_INIT}.
  find_package (Threads)
endif()

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

message("DJH PROTOBUF_PROTOC_EXECUTABLE = ${PROTOBUF_PROTOC_EXECUTABLE}") 
message("DJH PROTOBUF_INCLUDE_DIRS = ${PROTOBUF_INCLUDE_DIRS}")

#########################

# include(re2)
hunter_add_package(re2)
find_package(RE2 CONFIG REQUIRED) # RE2::re2

# include(cub)
# >> Notes: optinal for mobile platforms:
hunter_add_package(cub)
find_package(cub CONFIG REQUIRED)

# include(sqlite)
hunter_add_package(SQLite3)
find_package(SQLite3 REQUIRED) # TODO

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

set(tensorflow_EXTERNAL_LIBRARIES
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
  cub::cub                    # if(TENSORFLOW_USE_CUDA)
#  sqlite3
)

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
  message("TARGET = ${target} TYPE = ${target_type}")
  
  string( COMPARE EQUAL "${target_type}" "OBJECT_LIBRARY" is_object_library)
  if(${is_object_library})
    foreach(dep ${libraries})
      #message("dep: ${dep}")
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
  list(APPEND tensorflow_EXTERNAL_LIBRARIES BoringSSL::ssl BoringSSL::crypto)
endif()
if(tensorflow_ENABLE_GRPC_SUPPORT)
  #   include(grpc)
  #   list(APPEND tensorflow_EXTERNAL_LIBRARIES ${grpc_STATIC_LIBRARIES})
  #   list(APPEND tensorflow_EXTERNAL_DEPENDENCIES grpc)
  #   include_directories(${GRPC_INCLUDE_DIRS})
  hunter_add_package(gRPC)
  find_package(gRPC CONFIG REQUIRED)
  list(APPEND tensorflow_EXTERNAL_LIBRARIES
    gRPC::gpr
    gRPC::grpc
    gRPC::grpc_cronet
    gRPC::grpc_unsecure
    gRPC::grpc++
    gRPC::grpc++_cronet
    gRPC::grpc++_error_details
    gRPC::grpc++_reflection
    gRPC::grpc++_unsecure
    #gRPC::grpc_plugin_support
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

  get_cmake_property(_variableNames VARIABLES)
  foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
  endforeach()
  message("$$$$$$")
  
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
  list(APPEND tensorflow_EXTERNAL_LIBRARIES jemalloc::jemalloc)
endif()
if(tensorflow_ENABLE_SNAPPY_SUPPORT)
  #   include(snappy)
  #   list(APPEND tensorflow_EXTERNAL_LIBRARIES ${snappy_STATIC_LIBRARIES})
  #   list(APPEND tensorflow_EXTERNAL_DEPENDENCIES snappy)
  #   include_directories(${snappy_INCLUDE_DIR})
  hunter_add_package(Snappy)
  find_package(Snappy CONFIG REQUIRED)
  list(APPEND tensorflow_EXTERNAL_LIBRARIES Snappy::snappy)
endif()
if(WIN32)
  list(APPEND tensorflow_EXTERNAL_LIBRARIES wsock32 ws2_32 shlwapi)
endif()
if(UNIX)
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${CMAKE_THREAD_LIBS_INIT} ${CMAKE_DL_LIBS})
endif()

if (tensorflow_ENABLE_GPU)
  if (WIN32)
    find_package(CUDA 8.0 REQUIRED)

    # by default we assume compute cabability 3.5 and 5.2. If you change this change it in
    # CUDA_NVCC_FLAGS and cuda_config.h below
    set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};-gencode arch=compute_30,code=\"sm_30,compute_30\";-gencode arch=compute_35,code=\"sm_35,compute_35\";-gencode arch=compute_52,code=\"sm_52,compute_52\")
    set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};--include-path ${PROJECT_BINARY_DIR}/$\{build_configuration\};--expt-relaxed-constexpr)
    set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};-ftz=true)  # Flush denormals to zero
    set(CUDA_INCLUDE ${CUDA_TOOLKIT_TARGET_DIR} ${CUDA_TOOLKIT_TARGET_DIR}/extras/CUPTI/include)
    include_directories(${CUDA_INCLUDE})
    add_definitions(-DGOOGLE_CUDA=1 -DTF_EXTRA_CUDA_CAPABILITIES=3.0,3.5,5.2)

    # add cudnn
    if(NOT CUDNN_HOME)
      set(CUDNN_HOME ${CUDA_TOOLKIT_TARGET_DIR})
    endif(NOT CUDNN_HOME)
    include_directories(${CUDNN_HOME})
    set(CUDA_LIBRARIES ${CUDA_LIBRARIES} ${CUDA_CUDA_LIBRARY} ${CUDA_CUBLAS_LIBRARIES} ${CUDA_CUFFT_LIBRARIES}
      ${CUDA_curand_LIBRARY} ${CUDA_cupti_LIBRARY} ${CUDA_cusolver_LIBRARY} ${CUDNN_HOME}/lib/x64/cudnn.lib)

    # create cuda_config.h
    FILE(WRITE ${tensorflow_source_dir}/third_party/gpus/cuda/cuda_config.h
      "#ifndef CUDA_CUDA_CONFIG_H_\n"
      "#define CUDA_CUDA_CONFIG_H_\n"
      "#define TF_CUDA_CAPABILITIES CudaVersion(\"3.0\"),CudaVersion(\"3.5\"),CudaVersion(\"5.2\")\n"
      "#define TF_CUDA_VERSION \"64_80\"\n"
      "#define TF_CUDNN_VERSION \"64_6\"\n"
      "#define TF_CUDA_TOOLKIT_PATH \"${CUDA_TOOLKIT_ROOT_DIR}\"\n"
      "#endif  // CUDA_CUDA_CONFIG_H_\n"
    )

    # tf assumes in various places header files to be in cuda/include. On windows the cuda sdk
    # installs them under cuda/version/include and to avoid that we need to change tf we copy a
    # few files to cuda/include
    FILE(COPY
      ${CUDA_TOOLKIT_TARGET_DIR}/include/cuda.h ${CUDA_TOOLKIT_TARGET_DIR}/include/cuComplex.h
      ${CUDA_TOOLKIT_TARGET_DIR}/include/cublas_v2.h ${CUDNN_HOME}/include/cudnn.h
      ${CUDA_TOOLKIT_TARGET_DIR}/include/cufft.h ${CUDA_TOOLKIT_TARGET_DIR}/include/curand.h
      ${CUDA_TOOLKIT_TARGET_DIR}/include/cuda_runtime_api.h
      ${CUDA_TOOLKIT_TARGET_DIR}/include/cusolverDn.h
      DESTINATION ${tensorflow_source_dir}/third_party/gpus/cuda/include
    )
    include_directories(${tensorflow_source_dir}/third_party/gpus)
    # add cuda libraries to tensorflow_EXTERNAL_LIBRARIES
    list(APPEND tensorflow_EXTERNAL_LIBRARIES ${CUDA_LIBRARIES})

    # NOTE(mrry): Update these flags when the version of CUDA or cuDNN used
    # in the default build is upgraded.
    set(tensorflow_BUILD_INFO_FLAGS --build_config cuda --key_value
      msvcp_dll_name=msvcp140.dll
      cudart_dll_name=cudart64_80.dll
      cuda_version_number=8.0
      nvcuda_dll_name=nvcuda.dll
      cudnn_dll_name=cudnn64_6.dll
      cudnn_version_number=6)
  else(WIN32)
    message(FATAL_ERROR "CMake GPU build is currently only supported on Windows.")
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

# Let's get to work!
include(tf_core_framework.cmake)

# NOTE: Disabled until issue #3996 is fixed.
# include(tf_stream_executor.cmake)
if (tensorflow_ENABLE_GPU)
  if (WIN32)
    include(tf_stream_executor.cmake)
  endif()
endif()

include(tf_core_cpu.cmake)

include(tf_core_ops.cmake)

include(tf_core_direct_session.cmake)

include(tf_core_kernels.cmake)

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
if(tensorflow_BUILD_SHARED_LIB)
  include(tf_shared_lib.cmake)
endif()
if(tensorflow_BUILD_CC_TESTS OR tensorflow_BUILD_PYTHON_TESTS)
  include(tf_tests.cmake)
endif()

message("DJH: totally done")