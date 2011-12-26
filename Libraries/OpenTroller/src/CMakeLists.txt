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
    OpenTroller.h
	OT_1Wire.h
	OT_1WireDS2482.h
	OT_1WireGPIO.h
	OT_Encoder.h
	OT_HWProfile.h
	OT_InputBank.h
	OT_LCD.h
	OT_LiquidCrystal.h
	OT_Menu.h
	OT_Pin.h
	OT_Stack.h
	OT_Status.h
	OT_UI.h
	OT_Util.h

    outputs/OTOutput.h
    outputs/OTOutputs.h
    outputs/OTOutputGroup.h
    outputs/OTOutputGPIO.h
    outputs/OTOutputModbus.h
    outputs/OTOutputMux.h
    outputs/OTOutputBank.h
    outputs/OTOutputBankGroups.h
    outputs/OTOutputBankGPIO.h
    outputs/OTOutputBankModbus.h
    outputs/OTOutputBankMux.h
)

# Source implementation files
set(${LibraryName}_SRCS 
	OT_1WireDS2482.cpp
    OT_1WireGPIO.cpp
    OT_Encoder.cpp
	OT_InputBank.cpp
	OT_LCD.cpp
	OT_LiquidCrystal.cpp
	OT_Menu.cpp
	OT_Pin.cpp
	OT_Stack.cpp
	OT_Status.cpp
	OT_UI.cpp
	OT_Util.cpp

    outputs/OTOutput.cpp
    outputs/OTOutputs.cpp
    outputs/OTOutputGroup.cpp
    outputs/OTOutputGPIO.cpp
    outputs/OTOutputModbus.cpp
    outputs/OTOutputMux.cpp
	outputs/OTOutputBank.cpp
    outputs/OTOutputBankGroups.cpp
    outputs/OTOutputBankGPIO.cpp
    outputs/OTOutputBankModbus.cpp
    outputs/OTOutputBankMux.cpp
)


#  Library dependencies
set(${LibraryName}_LIBS 
	ModbusMaster
)

#  Target generation
generate_arduino_library(${LibraryName})
