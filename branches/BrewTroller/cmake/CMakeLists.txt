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
project(BT2 CXX)
find_package(Arduino 22 REQUIRED)

set(board atmega1284)

include_directories(
    ${PROJECT_SOURCE_DIR}/libraries/DS2482
    ${PROJECT_SOURCE_DIR}/libraries/encoder
    ${PROJECT_SOURCE_DIR}/libraries/pin
    ${PROJECT_SOURCE_DIR}/libraries/LiquidCrystalFP
    ${PROJECT_SOURCE_DIR}/libraries/menu
    ${PROJECT_SOURCE_DIR}/libraries/OneWire
    ${PROJECT_SOURCE_DIR}/libraries/PID_Beta6
)


add_subdirectory(libraries)
add_subdirectory(src)

get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
foreach(dir ${dirs})
  message(STATUS "dir='${dir}'")
endforeach()
