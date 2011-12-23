#===================================================================================================
# Author: Timothy Reaves
# Date: 2011/12/21
#
# Description: OpenTroller main CMake file
#
#===================================================================================================
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules) # CMake module search path
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/cmake/toolchains/Arduino.cmake) # Arduino Toolchain


cmake_minimum_required(VERSION 2.8)

#===================================================================================================
# Setup Project
#===================================================================================================
project(OpenTroller C CXX)
# The Arduino IDE to use: currently, the cmake support requires up-to 0023
find_package(Arduino 22 REQUIRED)
# The board to compile the project for
set(board atmega1284)

#===================================================================================================
# Project inludes.
# Each non-Arduino provided library should be put into the libraries directory.  They will be picked
# up automatically.  However, each one will need to be listed here for the includes compiler option
# search path
#===================================================================================================
include_directories(
	${CMAKE_SOURCE_DIR}/src
	${CMAKE_SOURCE_DIR}/libraries/ModbusMaster
)

add_subdirectory(src)

#===================================================================================================
# Generate API documentation with Doxygen
#===================================================================================================
find_package(Doxygen)
if(DOXYGEN_FOUND)
    configure_file(${PROJECT_SOURCE_DIR}/Doxyfile.in ${CMAKE_SOURCE_DIR}/Doxyfile @ONLY)
    add_custom_target(
        doc
        ${DOXYGEN_EXECUTABLE} ${CMAKE_SOURCE_DIR}/Doxyfile
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Generating API documentation with Doxygen" VERBATIM
    )
endif(DOXYGEN_FOUND)
