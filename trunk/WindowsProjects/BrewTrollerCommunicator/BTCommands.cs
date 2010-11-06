/*
	Copyright (C) 2010, Tom Harkaway, TL Systems, LLC (tlsystems_AT_comcast_DOT_net)

	BrewTrollerCommunicator is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	BrewTrollerCommunicator is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with BrewTrollerCommunicator.  If not, see <http://www.gnu.org/licenses/>.
*/

using System;
using System.Collections.Generic;
using System.IO;
using System.Diagnostics;
using System.Text;
using System.Xml.Serialization;

namespace BrewTrollerCommunicator
{

	public partial class BTCommunicator
	{

		#region Connect/Disconnect

		/// <summary> Connect to BrewTroller </summary>
		/// <remarks>
		/// This routine will attempt to connect to the BrewTroller using information in the connection
		/// string. If a successful connection is established, the version information will be read
		/// from the BrewTroller.
		/// </remarks>
		/// <param name="connectionString">PortName, [baudRate, parity, dataBits, stopBits]</param>
		/// <returns>True if connection is successful.</returns>
		/// 
		public bool Connect(string connectionString)
		{
			if (_connected)
				throw NewBTComException("BrewTroller is already connected.");

			if (!ParseConnectionString(connectionString))
				throw NewBTComException(String.Format("Connection String '{0}' is invalid.", connectionString));

			Debug.Assert(_serialPort == null, "_SerialPort == null");

			OpenComPort();

			try
			{
				if (ComType == BTComType.Unknown)
				{
					ComType = BTComType.ASCII;
				}
				GetVersion();

				ComType = _btVersion.ComType;

				// if original schema, get the units from the GetBoilInfo call
				if (Version.ComType == BTComType.ASCII && Version.ComSchema == 0)
				{
					Version.Units = GetUnitsFromBoilTemp();
				}

				_connected = true;
			}
			catch (Exception)
			{
				if (_serialPort != null)
					_serialPort.Dispose();
				_serialPort = null;
				ComType = BTComType.Unknown;
			}

			return _connected;
		}

		private BTUnits GetUnitsFromBoilTemp()
		{
			Debug.Assert(Version.ComSchema == 0, "Version.ComSchema == 0");
			var boilTemp = new GenericDecimal { ByteCount = 1, ScaleFactor = 1, HasUnits = true };
			ProcessBTCommand(BTCommand.GetBoilTemp, boilTemp, null);
			return boilTemp.Units;
		}

		/// <summary> Disconnect from the BrewTroller </summary>
		/// <remarks>
		/// Close and dispose the serial port.
		/// </remarks>
		public void Disconnect()
		{
			ConnectionString = String.Empty;
			PortName = String.Empty;

			if (_serialPort != null)
			{
				if (_serialPort.IsOpen)
					_serialPort.Close();

				_serialPort.Dispose();
				_serialPort = null;
			}

			_connected = false;

		}

		/// <summary> Get BrewTroller Version Information </summary>
		/// 
		public BTVersion GetVersion()
		{
			ProcessBTCommand(BTCommand.GetVersion, _btVersion, null);
			return _btVersion;
		}



		#endregion


		#region Basic BT Information/Control


		/// <summary> Get a Recipe from the BrewTroller </summary>
		/// <param name="recipeSlot">Recipe Slot Number</param>
		public BTRecipe GetRecipe(int recipeSlot)
		{
			if (recipeSlot < 0 || recipeSlot >= BTConfig.NumberOfRecipes)
				throw new ArgumentOutOfRangeException("recipeSlot");

			var btRecipe = new BTRecipe(Version.Units);
			ProcessBTCommand(BTCommand.GetRecipe, btRecipe, new List<int> { recipeSlot });
			return btRecipe;
		}

		/// <summary> Send a recipe to the BrewTroller </summary>
		/// 
		public void SetRecipe(BTRecipe btRecipe)
		{
			if (btRecipe.Slot < 0 || btRecipe.Slot >= BTConfig.NumberOfRecipes)
				throw new ArgumentOutOfRangeException("recipeSlot");

			ProcessBTCommand(BTCommand.SetRecipe, btRecipe, null);
		}

		/// <summary> Get BrewTroller Calculated Temperatures for a specified recipe </summary>
		/// 
		public BTCalcTemps GetCalcTemps(int recipeSlot)
		{
			var calcTemps = new BTCalcTemps(_btVersion.Units);
			ProcessBTCommand(BTCommand.GetCalcTemps, calcTemps, new List<int> { recipeSlot });
			return calcTemps;
		}

		/// <summary> Get BrewTroller Calculated Volumes for a specified recipe </summary>
		/// 
		public BTCalcVols GetCalcVols(int recipeSlot)
		{
			var calcVols = new BTCalcVols(_btVersion.Units);
			ProcessBTCommand(BTCommand.GetCalcVols, calcVols, new List<int> { recipeSlot });
			return calcVols;
		}

		/// <summary> Get the BrewTroller's AutoLogging Status </summary>
		/// 
		public bool GetLogStatus()
		{
			var logStatus = new GenericBoolean();
			ProcessBTCommand(BTCommand.GetLogStatus, logStatus, null);
			return logStatus.Value;
		}

		/// <summary> Set the BrewTroller's AutoLogging Status </summary>
		/// 
		public void SetLogStatus(bool status)
		{
			//var logStatus = new GenericBoolean { Value = status };
			//ProcessBTCommand(BTCommand.SetLogStatus, logStatus, null);
			var cmdStr = string.Format("{0},{1}", _btCmdList[BTCommand.SetLogStatus].ASCIICommand, status ? 1 : 0);
			SendBTCommand(cmdStr);
		}

		/// <summary> Get the BrewTroller's Log Data </summary>
		/// 
		public string GetLog()
		{
			var recordsPerLogStep = new[] { 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1 };
			var sb = new StringBuilder();
			switch (ComType)
			{
				case BTComType.ASCII:
					for (var i = 0; i < recordsPerLogStep.Length; i++)
					{
						var cmdStr = string.Format("{0},{1}", _btCmdList[BTCommand.GetLog].ASCIICommand, i);
						SendBTCommand(cmdStr);
						for (var j = 0; j < recordsPerLogStep[i]; j++)
							sb.AppendFormat("{0}\n", GetBTResponse(2000));
					}
					break;

				case BTComType.Binary:
					{
						var logData = new BTLogData(Version.Units);
						ProcessBTCommand(BTCommand.GetLog, logData, null);
						sb.Append(logData.ToString("verbose", null));
					}
					break;
			}

			return sb.ToString();
		}

		#endregion


		#region Configuration Commands

		/// <summary> Get BrewTroller Boil Information </summary>
		/// 
		public decimal GetBoilTemp()
		{
			var boilTemp = new GenericDecimal { ByteCount = 1, ScaleFactor = 1, HasUnits = Version.IsAsciiSchema0 };
			ProcessBTCommand(BTCommand.GetBoilTemp, boilTemp, null);
			return boilTemp.Value;
		}

		/// <summary> Set BrewTroller Boil Temp </summary>
		/// 160/70  Mt Everest
		/// 215/102 DeadSea 
		public void SetBoilTemp(decimal temp)
		{
			if (!BTConfig.ValidateBoilTemp(temp, Version.Units))
				throw new ArgumentOutOfRangeException("temp");
			var boilTemp = new GenericDecimal { ByteCount = 1, ScaleFactor = 1, Value = temp };
			ProcessBTCommand(BTCommand.SetBoilTemp, boilTemp, null);
		}

		/// <summary> Get BrewTroller Boil Information </summary>
		/// 
		public decimal GetBoilPower()
		{
			var boilPower = new GenericDecimal { ByteCount = 1, ScaleFactor = 1 };
			ProcessBTCommand(BTCommand.GetBoilPower, boilPower, null);
			return boilPower.Value;
		}

		/// <summary> Set BrewTroller Boil Power  </summary>
		/// 
		public void SetBoilPower(decimal power)
		{
			if (!BTConfig.ValidateBoilPower(power))
				throw new ArgumentOutOfRangeException("power");
			var evapRate = new GenericDecimal { ByteCount = 1, ScaleFactor = 1, Value = power };
			ProcessBTCommand(BTCommand.SetBoilPower, evapRate, null);
		}

		/// <summary> Get BrewTroller Cycle Start Delay Time </summary>
		/// 
		public decimal GetDelayTime()
		{
			var delayTime = new GenericDecimal { ByteCount = 2, ScaleFactor = 1 };
			ProcessBTCommand(BTCommand.GetDelayTime, delayTime, null);
			return delayTime.Value;
		}

		/// <summary> Set the Cycle Start Delay Time </summary>
		/// 
		public void SetDelayTime(decimal time)
		{
			if (!BTConfig.ValidateDelayTime(time))
				throw new ArgumentOutOfRangeException("time");
			var delayTime = new GenericDecimal { ByteCount = 2, ScaleFactor = 1, Value = time };
			ProcessBTCommand(BTCommand.SetDelayTime, delayTime, null);
		}

		/// <summary> Get BrewTroller Evaporation Rate </summary>
		/// 
		public decimal GetEvapRate()
		{
			var evapRate = new GenericDecimal { ByteCount = 1, ScaleFactor = 1 };
			ProcessBTCommand(BTCommand.GetEvapRate, evapRate, null);
			//. ToDo Decide if rate should be 2% or .02
			//.	Make SetEvapRate and to string match
			//. 
			return evapRate.Value; //. / 100;
		}

		/// <summary> Set BrewTroller Evaporation Rate  </summary>
		/// 
		public void SetEvapRate(decimal rate)
		{
			if (!BTConfig.ValidateEvapRate(rate))
				throw new ArgumentOutOfRangeException("rate");
			var evapRate = new GenericDecimal { ByteCount = 1, ScaleFactor = 1, Value = rate };
			ProcessBTCommand(BTCommand.SetEvapRate, evapRate, null);
		}

		/// <summary> Get BrewTroller Starting Grain Temp </summary>
		/// 
		public decimal GetGrainTemp()
		{
			var grainTemp = new GenericDecimal { ByteCount = 1, ScaleFactor = 1 };
			ProcessBTCommand(BTCommand.GetGrainTemp, grainTemp, null);
			return grainTemp.Value;
		}

		/// <summary> Set the GrainTemp in the BrewTroller </summary>
		/// 
		public void SetGrainTemp(decimal temp)
		{
			if (!BTConfig.ValidateGrainTemp(temp))
				throw new ArgumentOutOfRangeException("temp");
			var grainTemp = new GenericDecimal { ByteCount = 1, ScaleFactor = 1, Value = temp };
			ProcessBTCommand(BTCommand.SetGrainTemp, grainTemp, null);
		}

		/// <summary> Get Configuration Information for a BrewTroller's Heat Output </summary>
		/// <param name="heatOutputID">ID of Heat Output</param>
		public BTHeatOutputConfig GetHeatOutputConfig(BTHeatOutputID heatOutputID)
		{
			var btHeatOutConfig = new BTHeatOutputConfig();
			ProcessBTCommand(BTCommand.GetHeatOutputConfig, btHeatOutConfig, new List<int> { (int)heatOutputID });
			return btHeatOutConfig;
		}

		/// <summary> Set the configuration for a Heat Output </summary>
		/// 
		public void SetHeatOutputConfig(BTHeatOutputConfig btHeatOutConfig)
		{
			ProcessBTCommand(BTCommand.SetHeatOutputConfig, btHeatOutConfig, null);
		}

		/// <summary> Get the address of a BrewTroller Temperature Sensor </summary>
		/// <param name="tsLocation">Location of Temperature Sensor</param>
		public TSAddress GetTempSensorAddress(TSLocation tsLocation)
		{
			var tsAddr = new TSAddress(tsLocation);
			ProcessBTCommand(BTCommand.GetTempSensorAddr, tsAddr, new List<int> { (int)tsLocation });
			return tsAddr;
		}

		/// <summary> Set the Address of a BrewTroller Temperature Sensor  </summary>
		/// 
		public void SetTempSensorAddress(TSAddress tsAddress)
		{
			ProcessBTCommand(BTCommand.SetTempSensorAddr, tsAddress, null);
		}

		/// <summary> Get Profile for a BrewTroller AutoValve </summary>
		/// <param name="profileID">ID of AutoValve Profile</param>
		public BTValveProfile GetValveProfile(BTProfileID profileID)
		{
			BTValveProfile profile = new BTValveProfile();
			ProcessBTCommand(BTCommand.GetValveProfile, profile, new List<int> { (int)profileID });
			return profile;
		}

		/// <summary> Set the AutoValve profile for a brew state </summary>
		/// 
		public void SetValveProfile(BTValveProfile btValveProfile)
		{
			ProcessBTCommand(BTCommand.SetValveProfile, btValveProfile, null);
		}

		/// <summary> Get the Calibration Information for a BrewTroller vessel </summary>
		/// <param name="vessel">ID of Vessel</param>
		public BTVesselCalibration GetVesselCalibration(BTVesselID vessel)
		{
			var calibration = new BTVesselCalibration();
			ProcessBTCommand(BTCommand.GetVesselCalib, calibration, new List<int> { (int)vessel });
			return calibration;
		}

		/// <summary> Set the calibration information for a Vessel  </summary>
		/// 
		public void SetVesselCalibration(BTVesselCalibration btVesselCalibration)
		{
			ProcessBTCommand(BTCommand.SetVesselCalib, btVesselCalibration, null);
		}

		/// <summary> Get the Volume Settings for a BrewTroller vessel </summary>
		/// <param name="vessel">ID of Heat Output</param>
		public BTVolumeSetting GetVolumeSetting(BTVesselID vessel)
		{
			var btVolumeSetting = new BTVolumeSetting();
			ProcessBTCommand(BTCommand.GetVolumnSetting, btVolumeSetting, new List<int> { (int)vessel });
			return btVolumeSetting;
		}

		/// <summary> Set the Volume information for a Vessel </summary>
		/// 
		public void SetVolumeSetting(BTVolumeSetting btVolumeSettings)
		{
			ProcessBTCommand(BTCommand.SetVolumeSetting, btVolumeSettings, null);
		}

		#endregion Configuration Commands



		public TSAddress TempSensorScan()
		{
			var tsAddr = new TSAddress(TSLocation.Undefined);
			ProcessBTCommand(BTCommand.ScanTempSensors, tsAddr, null);
			return tsAddr;
		}

		public void AdvanceStep(BTBrewStep step)
		{
			ProcessBTCommand(BTCommand.StepAdvance, null, null);
		}
		public void ExitStep(BTBrewStep step)
		{
			ProcessBTCommand(BTCommand.StepExit, null, null);
		}
		public void InitStep(BTBrewStep step)
		{
			ProcessBTCommand(BTCommand.StepInit, null, null);
		}

		/// <summary> Get BrewTroller Alarm State </summary>
		/// 
		public bool GetAlarm()
		{
			var alarmStatus = new GenericBoolean();
			ProcessBTCommand(BTCommand.GetAlarm, alarmStatus, null);
			return alarmStatus.Value;
		}

		/// <summary> Set BrewTroller Alarm State </summary>
		/// 
		public void SetAlarm(bool bVal)
		{
			var alarmStatus = new GenericBoolean { Value = bVal };
			ProcessBTCommand(BTCommand.SetAlarm, alarmStatus, null);
		}

		/// <summary> Set the active AutoValve Modes </summary>
		/// 
		public void SetAutoValve(BTAutoValveMode value)
		{
			var avMode = new GenericDecimal { Value = (int)value, ByteCount = 2 };
			ProcessBTCommand(BTCommand.SetAutoValve, avMode, null);
		}

		public void SetSetpoint(BTHeatOutputID heatOutputID, decimal value)
		{
			var setpoint = new GenericDecimal { Value = value, ByteCount = 1 };
			ProcessBTCommand(BTCommand.SetAutoValve, setpoint, new List<int> { (int)heatOutputID });
		}

		public void SetTimerStatus(BTTimerID timerID, bool value)
		{
			var timerStatus = new GenericBoolean { Value = value };
			ProcessBTCommand(BTCommand.SetTimerStatus, timerStatus, new List<int> { (int)timerID });
		}

		public void SetTimerValue(BTTimerID timerID, decimal value)
		{
			var timerStatus = new GenericDecimal { Value = value, ByteCount = 4 };
			ProcessBTCommand(BTCommand.SetTimerValue, timerStatus, new List<int> { (int)timerID });
		}

		public void SetValve(UInt64 mask, UInt64 state)
		{
			var valveState = new BTValveState { Mask = mask, State = state };
			ProcessBTCommand(BTCommand.SetTimerValue, valveState, null);
		}

		public void SetValveProfile()
		{
			throw new NotImplementedException();
		}

		public void VolumeRead()
		{
			throw new NotImplementedException();
		}
		public void SoftReset()
		{
			throw new NotImplementedException();
		}


		public void InitializeEEPROM()
		{
			ProcessBTCommand(BTCommand.InitEEPROM, null, null);
		}

		public BT_EEPROM GetEEPROM(BT_EEPROM eePROM)
		{
			if (eePROM.Address < 0 || eePROM.Address > BT_EEPROM.EEPROM_SIZE-1)
				throw new ArgumentOutOfRangeException("eePROM.Address");

			if (eePROM.ByteCount < 0  || eePROM.ByteCount > BT_EEPROM.EEPROM_SIZE)
				throw new ArgumentOutOfRangeException("eePROM.ByteCount");

			if (!(Version.ComType == BTComType.ASCII || Version.ComType == BTComType.Binary))
				throw new ArgumentOutOfRangeException(String.Format("The {0} protocol does not support GetEEPROM.", Version.ComType));

			if (eePROM.Address + eePROM.ByteCount > BT_EEPROM.EEPROM_SIZE)
				eePROM.ByteCount = (UInt16)(BT_EEPROM.EEPROM_SIZE - eePROM.Address);

			var orgAddress = eePROM.Address;
			var orgCount = eePROM.ByteCount;

			var length = (Version.ComType == BTComType.ASCII) ? 48 : 64;

			var curAddress = orgAddress;
			var curCount = orgCount;
			while (curCount > 0)
			{
				length = Math.Min(length, curCount);
				ProcessBTCommand(BTCommand.GetEEPROM, eePROM, new List<int> { curAddress, length });
				curAddress += length;
				curCount -= length;
			}

			// restore address and byte count
			eePROM.Address = orgAddress;
			eePROM.ByteCount = orgCount;

			return eePROM;
		}

		public void SetEEPROM(BT_EEPROM eePROM)
		{
			if (eePROM.Address < 0 || eePROM.Address > BT_EEPROM.EEPROM_SIZE - 1)
				throw new ArgumentOutOfRangeException("eePROM.Address");

			if (eePROM.ByteCount < 0 || eePROM.ByteCount > BT_EEPROM.EEPROM_SIZE)
				throw new ArgumentOutOfRangeException("eePROM.ByteCount");

			if (!(Version.ComType == BTComType.ASCII || Version.ComType == BTComType.Binary))
				throw new ArgumentOutOfRangeException(String.Format("The {0} protocol does not support GetEEPROM.", Version.ComType));

			if (eePROM.Address + eePROM.ByteCount > BT_EEPROM.EEPROM_SIZE)
				eePROM.ByteCount = (UInt16)(BT_EEPROM.EEPROM_SIZE - eePROM.Address);

			var orgAddress = eePROM.Address;
			var orgCount = eePROM.ByteCount;

			var length = (Version.ComType == BTComType.ASCII) ? 48 : 64;

			var curAddress = orgAddress;
			var curCount = orgCount;
			while (curCount > 0)
			{
				eePROM.Address = curAddress;
				eePROM.ByteCount = Math.Min(length, curCount);
				ProcessBTCommand(BTCommand.SetEEPROM, eePROM, null);
				curAddress += length;
				curCount -= length;
			}

			// restore address and byte count
			eePROM.Address = orgAddress;
			eePROM.ByteCount = orgCount;
		}


		#region XML Commands

		public void SaveXmlConfiguration(BTConfig btConfig, string configFile)
		{
			try
			{
				XmlSerializer serializer = new XmlSerializer(typeof(BTConfig));
				Stream writer = new FileStream(configFile, FileMode.Create);
				serializer.Serialize(writer, btConfig);
				writer.Close();
			}
			catch (Exception ex)
			{
				throw NewBTComException("Error while serializing configuration to XML.", ex);
			}
		}

		public BTConfig LoadXmlConfiguration(string configFile)
		{
			try
			{
				XmlSerializer serializer = new XmlSerializer(typeof(BTConfig));
				StreamReader reader = new StreamReader(configFile);
				BTConfig btConfig = (BTConfig)serializer.Deserialize(reader);
				reader.Close();
				return btConfig;
			}
			catch (Exception ex)
			{
				throw NewBTComException("Error while serializing configuration from XML.", ex);
			}
		}

		#endregion XML


	}

}
