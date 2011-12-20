#====================================================================#
#  Settings                                                          #
#====================================================================#
set(FirmwareName OpenTroller)

set(${FirmwareName}_BOARD ${board})               # Arduino Target board

set(${FirmwareName}_HDRS
	BrewCore.h
	BrewTroller.h
	Com.h
	Com_BTnic.h
	Com_BTPD.h
	Com_S0ASC.h
	Config.h
	EEPROM.h
	Enum.h
	Events.h
	HWProfile.h
	Outputs.h
	PVOut.h
	StepLogic.h
	Temp.h
	Timer.h
	UI_LCD.h
	UI.h
	Util.h
	Volume.h
)

set(${FirmwareName}_SRCS 
	BrewCore.c
	BrewTroller.c
	Com.c
	Com_BTPD.c
	Com_S0ASC.c
	EEPROM.c
	Events.c
	Outputs.c
	StepLogic.c
	Temp.c
	Timer.c
	UI.c
	Util.c
	Volume.c
)


#====================================================================#
#  Library dependencies                                              #
#====================================================================#
set(${FirmwareName}_LIBS 
	DS2482
	encoder
        pin
	LiquidCrystalFP
	menu
	OneWire
        PID_Beta6
)

#====================================================================#
#  Target generation                                                 #
#====================================================================#
generate_arduino_firmware(${FirmwareName})
