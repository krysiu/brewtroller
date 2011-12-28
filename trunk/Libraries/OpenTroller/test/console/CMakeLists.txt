#===================================================================================================
# Author: Timothy Reaves
# Date: 2011/12/21
#
# Description: OpenTroller console app
#
#===================================================================================================


#===================================================================================================
#  Settings
#===================================================================================================
set(FirmwareName Console)

# Arduino Target board
set(${FirmwareName}_BOARD ${board})

set(${FirmwareName}_PORT /dev/ttyUSB0) # Serial upload port
set(${FirmwareName}_SERIAL picocom @INPUT_PORT@ -b 9600 -l ) # Serial terminal cmd


set(${FirmwareName}_HDRS
    console.h
)

set(${FirmwareName}_SRCS
    console.cpp
)

set(${FirmwareName}_LIBS
    OpenTroller
    Wire
)


generate_arduino_firmware(${FirmwareName})
