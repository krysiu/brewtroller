#===================================================================================================
# Author: Timothy Reaves
# Date: 2011/12/21
#
# Description: OpenTroller src CMake file
#
#===================================================================================================

#===================================================================================================
#  Settings
#===================================================================================================
set(LibraryName OpenTroller)

# Arduino Target board
set(${LibraryName}_BOARD ${board})

# Source headers
set(${LibraryName}_HDRS
	OT_1Wire.h
	OT_1WireDS2482.h
	OT_1WireGPIO.h
	OT_1WireGPIO.h
	OT_Encoder.h
	OT_HWProfile.h
	OT_InputBank.h
	OT_LCD.h
	OT_LiquidCrystal.h
	OT_Menu.h
	OT_Outputs.h
	OT_Pin.h
	OT_Stack.h
	OT_Status.h
	OT_UI.h
	OT_Util.h
)

# Source implementation files
set(${LibraryName}_SRCS 
	OT_1WireDS2482.cpp
	OT_Encoder.cpp
	OT_InputBank.cpp
	OT_LCD.cpp
	OT_LiquidCrystal.cpp
	OT_Menu.cpp
	OT_Outputs.cpp
	OT_Pin.cpp
	OT_Stack.cpp
	OT_Status.cpp
	OT_UI.cpp
	OT_Util.cpp
)


#  Library dependencies
set(${LibraryName}_LIBS 
	ModbusMaster
)

#  Target generation
generate_arduino_library(${LibraryName})
