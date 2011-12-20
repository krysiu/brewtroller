#=============================================================================#
# Author: QueezyTheGreat #
# Date: 26.04.2011 #
# #
# Description: Arduino CMake example #
# #
#=============================================================================#
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules) # CMake module search path
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/cmake/toolchains/Arduino.cmake) # Arduino Toolchain

cmake_minimum_required(VERSION 2.8)

#====================================================================#
# Setup Project #
#====================================================================#
project(BT2 C CXX)
find_package(Arduino 22 REQUIRED)

set(board atmega1284)

add_subdirectory(libraries)
add_subdirectory(src)

