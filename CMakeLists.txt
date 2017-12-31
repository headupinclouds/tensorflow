cmake_minimum_required(VERSION 3.10)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/tensorflow/contrib/cmake")

include("${CMAKE_CURRENT_LIST_DIR}/tensorflow/contrib/cmake/cmake/HunterGate.cmake")
HunterGate(
  URL "https://github.com/ruslo/hunter/archive/v0.19.210.tar.gz"
  SHA1 "87eb902de6ca89e1dafc71e475344f523ef67729"
  FILEPATH "${CMAKE_CURRENT_LIST_DIR}/tensorflow/contrib/cmake/cmake/Hunter/config.cmake"
)

# Project
project(tensorflow VERSION 1.4 LANGUAGES C CXX)

add_subdirectory(tensorflow/contrib/cmake)
