#===================================================================================================
# Author: Timothy Reaves
# Date: 2011/12/21
#
# Description: OpenTroller libraries CMake file
#
#===================================================================================================

set(ModbusMaster_BOARD ${board})

# Source headers
set(ModbusMaster_HDRS
    ModbusMaster/ModbusMaster.h
)

# Source implementation files
set(ModbusMaster_SRCS
    ModbusMaster/ModbusMaster.h
)

#  Target generation
generate_arduino_library(ModbusMaster)
