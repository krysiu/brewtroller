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
using System.IO.Ports;

namespace BrewTrollerCommunicator
{
	public interface IBTCommunicator
	{
		#region Properties

		bool LogEnabled { get; set; }
		List<BTComMessage> BTComLog { get; set; }

		string ComLogFile { get; set; }
		string ErrorLogFile { get; set; }

		string TxD { get; }
		string RxD { get; }

		TimeSpan TimeStamp { get; }

		string ConnectionString { get; }
		string PortName { get; }
		int BaudRate { get; }
		Parity Parity { get; }
		int DataBits { get; }
		StopBits StopBits { get; }
		int ComRetries { get; set; }

		BTVersion Version { get; }
		int ComSchema { get; }
		bool IsConnected { get; }

		#endregion


		void SaveXmlConfiguration(BTConfig btConfig, string configFile);

		BTConfig LoadXmlConfiguration(string configFile);

		bool GetLogStatus();
		void SetLogStatus(bool status);

		void SendBTCommand(string cmdStr);
		string GetBTResponse(int timeout);


		bool Connect(string connectionString);
		void Disconnect();

		BTVersion GetVersion();

		decimal GetBoilTemp();
		void SetBoilTemp(decimal boilTemp);

		decimal GetBoilPower();
		void SetBoilPower(decimal boilPower);

		decimal GetEvapRate();
		void SetEvapRate(decimal evapRate);

		BTHeatOutputConfig GetHeatOutputConfig(BTHeatOutputID heatOutputID);
		void SetHeatOutputConfig(BTHeatOutputConfig btHeatOutConfig);

		BTRecipe GetRecipe(int recipeSlot);
		void SetRecipe(BTRecipe btRecipe);

		TSAddress GetTempSensorAddress(TSLocation tsLocation);
		void SetTempSensorAddress(TSAddress tsAddress);
		TSAddress TempSensorScan();

		BTVesselCalibration GetVesselCalibration(BTVesselID vessel);
		void SetVesselCalibration(BTVesselCalibration btVesselCalibration);

		BTValveProfile GetValveProfile(BTProfileID profileID);
		void SetValveProfile(BTValveProfile btValveProfile);


		BTVolumeSetting GetVolumeSetting(BTVesselID vessel);
		void SetVolumeSetting(BTVolumeSetting btVolumeSettings);

		void AdvanceStep(BTBrewStep step);
		void ExitStep(BTBrewStep step);
		void InitStep(BTBrewStep step);

		void SetAlarm(bool bVal);
		void SetAutoValve(BTAutoValveMode value);
		void SetSetpoint(BTHeatOutputID heatOutputID, decimal value);
		void SetTimerStatus(BTTimerID timerID, bool value);
		void SetTimerValue(BTTimerID timerID, decimal value);
		void SetValve(UInt64 mask, UInt64 state);
		void SetValveProfile();

		void VolumeRead();
		void SoftReset();
	}


	public interface IBTDataClass
	{
		void HydrateFromParamList(BTVersion version, List<string> rspParams);
		List<string> EmitToParamsList(BTVersion version);

		void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len);
		byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset);
	}

}

