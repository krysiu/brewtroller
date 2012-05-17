# Name: Makefile
# Author: <insert your name here>
# Copyright: <insert your copyright message here>
# License: <insert your license reference here>

# This is a prototype Makefile. Modify it according to your needs.
# You should at least check the settings for
# DEVICE ....... The AVR device you compile for
# CLOCK ........ Target AVR clock rate in Hertz
# OBJECTS ...... The object files created from your source files. This list is
#                usually the same as the list of source files with suffix ".o".
# PROGRAMMER ... Options to avrdude which define the hardware you use for
#                uploading to the AVR and the interface where this hardware
#                is connected.
# FUSES ........ Parameters for avrdude to flash the fuses appropriately.

DEVICE     	= atmega168

CLOCK      	= 8000000

PROGRAMMER 	= -c avrispmkii -P usb

TARGET		= main

OBJECTS    	= $(TARGET).o \
			twi.o \
			tlc5947.o \
			input.o \
			modbus/port/portserial.o \
			modbus/port/portevent.o \
			modbus/port/porttimer.o \
			modbus/port/mbcrc.o \
			modbus/mb.o \
			modbus/rtu/mbrtu.o \
			modbus/ascii/mbascii.o \
			modbus/functions/mbfunccoils.o \
			modbus/functions/mbfuncdiag.o \
			modbus/functions/mbfuncholding.o \
			modbus/functions/mbfuncinput.o \
			modbus/functions/mbfuncother.o \
			modbus/functions/mbfuncdisc.o \
			modbus/functions/mbutils.o 

# additional includes (e.g. -I/path/to/mydir)
EXTRAINC	= -I. \
			-Imodbus/port \
			-Imodbus/rtu \
			-Imodbus/ascii \
			-Imodbus/include 
	
CFLAGS		= -DRTS_ENABLE

FUSES      	= -U lfuse:w:0xe2:m -U hfuse:w:0xdd:m -U efuse:w:0x01:m

# Tune the lines below only if you know what you are doing:

AVRDUDE = avrdude $(PROGRAMMER) -p $(DEVICE)
COMPILE = avr-gcc -Wall -Os -DF_CPU=$(CLOCK) -mmcu=$(DEVICE) \
		-std=gnu99 $(EXTRAINC) $(CFLAGS)

# symbolic targets:
all:	hex size

.c.o:
	$(COMPILE) -c $< -o $@

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@
# "-x assembler-with-cpp" should not be necessary since this is the default
# file type for the .S (with capital S) extension. However, upper case
# characters are not always preserved on Windows. To ensure WinAVR
# compatibility define the file type manually.

.c.s:
	$(COMPILE) -S $< -o $@

flash:	all fuse
	$(AVRDUDE) -U flash:w:$(TARGET).hex:i

fuse:
	$(AVRDUDE) $(FUSES)

# Xcode uses the Makefile targets "", "clean" and "install"
install: flash fuse

clean:
	rm -f $(TARGET).hex $(TARGET).elf $(OBJECTS)

# file targets:
elf: $(OBJECTS)
	$(COMPILE) -o $(TARGET).elf $(OBJECTS)

hex: elf
	rm -f $(TARGET).hex
	avr-objcopy -j .text -j .data -O ihex $(TARGET).elf $(TARGET).hex
# If you have an EEPROM section, you must also create a hex file for the
# EEPROM and add it to the "flash" target.

# Targets for code debugging and analysis:
disasm:	$(TARGET).elf
	avr-objdump -d $(TARGET).elf

cpp:
	$(COMPILE) -E $(TARGET).c
	
size:
	avr-size -C --mcu=$(MCU) $(TARGET).elf
#	avr-objdump -h main.elf | grep .bss | ruby -e 'puts "\n\n--- Requires %s bytes of SRAM" % STDIN.read.match(/0[0-9a-f]+\s/)[0].to_i(16)'
#	avr-size *.hex *.elf $(OBJECTS)
