#====================================================================#
#  Libraries                                                         #
#====================================================================#

set(DS2482_SRCS DS2482/DS2482.cpp)
set(DS2482_HDRS DS2482/DS2482.h)
set(DS2482_BOARD ${board})
generate_arduino_library(DS2482)

set(encoder_SRCS encoder/encoder.cpp)
set(encoder_HDRS encoder/encoder.h)
set(encoder_LIBS Pin)
set(encoder_BOARD ${board})
generate_arduino_library(encoder)

set(pin_SRCS pin/pin.cpp)
set(pin_HDRS pin/pin.h)
set(pin_BOARD ${board})
generate_arduino_library(pin)

set(LiquidCrystalFP_SRCS LiquidCrystalFP/LiquidCrystalFP.cpp)
set(LiquidCrystalFP_HDRS LiquidCrystalFP/LiquidCrystalFP.h)
set(LiquidCrystalFP_BOARD ${board})
generate_arduino_library(LiquidCrystalFP)

set(menu_SRCS menu/menu.cpp)
set(menu_HDRS menu/menu.h)
set(menu_BOARD ${board})
generate_arduino_library(menu)

set(OneWire_SRCS OneWire/OneWire.cpp)
set(OneWire_HDRS OneWire/OneWire.h)
set(OneWire_BOARD ${board})
generate_arduino_library(OneWire)

set(PID_Beta6_SRCS PID_Beta6/PID_Beta6.cpp)
set(PID_Beta6_HDRS PID_Beta6/PID_Beta6.h)
set(PID_Beta6_BOARD ${board})
generate_arduino_library(PID_Beta6)
