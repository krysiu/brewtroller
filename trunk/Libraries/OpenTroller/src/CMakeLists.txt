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
	OT_LiquidCrystal.h
	OT_Menu.h
	OT_Pin.h
	OT_Stack.h
	OT_Status.h
	OT_UI.h
	OT_Util.h

    OT_LCD.h

    OTOutput.h
    OTOutputs.h
    OTOutputGroup.h
    OTOutputAVRIO.h
    OTOutputModbus.h
    OTOutputMux.h
    OTOutputBank.h
    OTOutputBankGroups.h
    OTOutputBankAVRIO.h
    OTOutputBankModbus.h
    OTOutputBankMux.h
)

# Source implementation files
set(${LibraryName}_SRCS 
    OpenTroller.cpp
    OT_1WireDS2482.cpp
    OT_1WireGPIO.cpp
    OT_Encoder.cpp
	OT_InputBank.cpp
	OT_LiquidCrystal.cpp
	OT_Menu.cpp
	OT_Pin.cpp
	OT_Stack.cpp
	OT_Status.cpp
	OT_UI.cpp
	OT_Util.cpp

    OT_LCD.cpp
    OT_LCD4Bit.cpp
    OT_LCDI2C.cpp

    OTOutput.cpp
    OTOutputs.cpp
    OTOutputGroup.cpp
    OTOutputAVRIO.cpp
    OTOutputModbus.cpp
    OTOutputMux.cpp
	OTOutputBank.cpp
    OTOutputBankGroups.cpp
    OTOutputBankAVRIO.cpp
    OTOutputBankModbus.cpp
    OTOutputBankMux.cpp
)


#  Library dependencies
set(${LibraryName}_LIBS 
	ModbusMaster
)

#  Target generation
generate_arduino_library(${LibraryName})
