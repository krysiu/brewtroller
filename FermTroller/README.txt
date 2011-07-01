FermTroller 2.0 Release Notes
-----------------------------

-----------------------------------

Hardware Profile:

You will need to copy the appropriate hardware profile (HWProfile.h) for your system type to the root of the FermTroller folder before compiling.
There are two different hardware profiles available for the BT 3.x and BT 4.0 Pro boards. The default versions use the heat outputs (HLT, Mash, Kettle, Steam and Buzzer) to provide 5 onboard outputs. The '* - PVOUT' versions use the 16 Pump/Valve outputs instead.

-----------------------------------

Zones:

By default FermTroller will create as many zones as outputs provided in your hardware profile. This assumes that you will use one zone with no outputs to monitor ambient temperature and one output will be assigned to the Alarm output profile. The remaining four outputs would be assigned to 4 zones in a single stage system (heat only or cool only). You may override the default number of zones in the Config.pde prior to compiling.

-----------------------------------

Outputs:

No outputs are used directly in FermTroller 2.0. Outputs must be assigned in the appropriate output profile. This is done in the user interface by accessing the System Setup menu on the home screen and selecting 'Outputs'. Each zone has Heat and Cool profiles although you do not have to use both. You may also assign an output to the Alarm profile to operate a buzzer.

-----------------------------------

Alarms:

Each zone has it's own Alarm Threshhold and a set of three alarms:
	* TSensor: A setpoint is set but the assigned sensor address could not be read
	* Temp High: The temperature is/was greater than the setpoint plus the alarm threshhold value
	* Temp Low: The temperature has is/was lower thanthe setpoint minus the alarm threshhold value

Each alarm can be in one of four states:
	* No alarm status
	* Active [ie 'TSensor (Active)']: Currently occurring and unacknowledged (alarm output profile enabled)
	* Acknowledged [ie 'TSensor (Ack)']: Currently occurring but acknowledged (alarm output profile will be silenced)
	* Historical [ie 'TSensor']: An alarm has occurred in the past but has not yet been acknowledged (alarm output profile enabled)

When any alarm is active or unacknowledged a bell icon will be displayed in the top right corner next to the unlock icon. When the main Menu or a Zone menu is opened a 'View Alarms' option will be available. This option will list all the zones with alarms (active or unacknowledged). If you select the zone the errors will de displayed. Clicking on the error acknowledges the alarm. If all alarms have been ack'ed the alarm will be silent.

-----------------------------------

Minimum Cool On/Off Periods:

To protect a compressor from being turned on and off too rapidly when used with a Cool Output Profile 'Min Cool On' and 'Min Cool Off' options are available in the Outputs menu. You may specify a value in minutes of up to 4 hours for either option. These values will override the default setpoint + hysteresis logic so that the cool output will continue to run even if the setpoint has been reached until the minimum on time has been met. Likewise the cool output will not be activated even if the temp falls below the setpoint minus the hysteresis if the minimum off time has not yet been met. Note: the minimum cool off value must be met before the cool output is activated on initial boot up.

-----------------------------------

Zone Naming:

By default the zones are named as 'Zone 1', 'Zone 2', etc. You may name the zone differently to identify it's function or contents from the Zone menu. The zone name can be up to 17 chars long.

-----------------------------------