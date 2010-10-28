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
using System.Text;


namespace BrewTrollerCommunicator
{
	[SerializableAttribute]
	public class BTLogData : IFormattable, IBTDataClass
	{
		BTUnits Units { get; set; }

		byte Schema { get; set; }
		UInt32 TimeStamp { get; set; }
		byte[] StepStatus { get; set; }
		bool MashTimerStatus { get; set; }
		UInt32 MashTimerValue { get; set; }
		bool BoilTimerStatus { get; set; }
		UInt32 BoilTimerValue { get; set; }
		bool AlarmStatus { get; set; }
		UInt32[] VesselVolumeAvg { get; set; }
		UInt32[] VesselFlowRate { get; set; }
		decimal[] Temperature { get; set; }
		UInt32 SteamPressure { get; set; }
		byte[] HeatOutput { get; set; }
		int[] HeatSetpoint { get; set; }
		UInt32 AutoValveMode { get; set; }
		UInt32 ValveProfile { get; set; }

		public BTLogData(BTUnits units)
		{
			Units = units;
			StepStatus = new byte[15];
			VesselVolumeAvg = new UInt32[3];
			VesselFlowRate = new UInt32[3];
			Temperature = new decimal[9];
			HeatOutput = new byte[4];
			HeatSetpoint = new int[4];
		}

		public void HydrateFromParamList(int schema, List<string> rspParams)
		{
			throw new NotImplementedException();
		}

		public List<string> EmitToParamsList(int schema)
		{
			throw new NotImplementedException();
		}

		public void HydrateFromBinary(int schema, byte[] btBuf, int offset, int len)
		{
			if (len != 95)
				throw new Exception("BTLog.HydrateFromBinary: Buffer Size Error.");
			var startIndex = offset;

			Schema = btBuf[offset++];
			TimeStamp = GetUInt32(btBuf, offset);
			offset += sizeof(UInt32);

			//StepStatus 
			for (var i = 0; i < StepStatus.Length; i++)
			{
				StepStatus[i] = btBuf[offset++];
			}

			//MashTimer
			MashTimerValue = GetUInt32(btBuf, offset);
			offset += sizeof(UInt32);
			MashTimerStatus = btBuf[offset++] != 0;

			//BoilTimer
			BoilTimerValue = GetUInt32(btBuf, offset);
			offset += sizeof(UInt32);
			BoilTimerStatus = btBuf[offset++] != 0;

			//AlarmStatus 
			AlarmStatus = btBuf[offset++] != 0;

			//Vessel Vol & Flow 
			for (var i = 0; i < VesselVolumeAvg.Length; i++)
			{
				VesselVolumeAvg[i] = GetUInt32(btBuf, offset);
				offset += sizeof(UInt32);
				VesselFlowRate[i] = GetUInt32(btBuf, offset);
				offset += sizeof(UInt32);
			}

			//Temperature 
			for (var i = 0; i < Temperature.Length; i++)
			{
				Temperature[i] = GetInt16(btBuf, offset) / 100m;
				offset += sizeof(Int16);
			}

			//SteamPressure 
			SteamPressure = GetUInt32(btBuf, offset);
			offset += sizeof(UInt32);

			//HeatOutput 
			for (var i = 0; i < HeatOutput.Length; i++)
			{
				HeatOutput[i] = btBuf[offset++];
			}

			//HeatSetpoint 
			for (var i = 0; i < HeatSetpoint.Length; i++)
			{
				HeatSetpoint[i] = GetInt16(btBuf, offset);
				offset += sizeof(Int16);
			}

			//AutoValveMode
			SteamPressure = GetUInt16(btBuf, offset);
			offset += sizeof(UInt16);

			//ValveProfile 
			SteamPressure = GetUInt32(btBuf, offset);
			offset += sizeof(UInt32);

			System.Diagnostics.Debug.Assert(offset == startIndex + len, "offset == startIndex + len");
		}

		public static Int16 GetInt16(byte[] btBuf, int offset)
		{
			Int16 retVal = 0;
			for (var i = 0; i < sizeof(Int16); i++)
			{
				retVal <<= 8;
				retVal += btBuf[offset++];
			}
			return retVal;
		}

		public static UInt16 GetUInt16(byte[] btBuf, int offset)
		{
			UInt16 retVal = 0;
			for (var i = 0; i < sizeof(Int16); i++)
			{
				retVal <<= 8;
				retVal += btBuf[offset++];
			}
			return retVal;
		}

		public static UInt32 GetUInt32(byte[] btBuf, int offset)
		{
			UInt32 retVal = 0;
			for (var i = 0; i < sizeof(UInt32); i++)
			{
				retVal <<= 8;
				retVal += btBuf[offset++];
			}
			return retVal;
		}

		public byte EmitToBinary(int schema, byte[] cmdBuf, byte offset)
		{
			throw new NotImplementedException();
		}

		public override string ToString()
		{
			return String.Format("BT Log Data @ {0} ", TimeStamp);
		}

		public string ToString(string format, IFormatProvider formatProvider)
		{
			switch (format)
			{
			case "verbose":
				return VerboseRecipeText();

			case "G": return ToString();
			default: return ToString();
			}
		}

		private string VerboseRecipeText()
		{
			StringBuilder sb = new StringBuilder();
			sb.AppendFormat("Schema        : {0}\n", Schema);
			sb.AppendFormat("TimeStamp     : {0}\n", TimeStamp);

			sb.Append("StepStatus    : ");
			foreach (var step in StepStatus)
				sb.AppendFormat("{0,2} ", step == 255 ? "--" : step.ToString());
			sb.Length = sb.Length - 1;
			sb.Append("\n");

			sb.AppendFormat("MashTimer     : {0} min. ({1})\n", MashTimerValue, MashTimerStatus);
			sb.AppendFormat("BoilTimer     : {0} min. ({1})\n", BoilTimerValue, BoilTimerStatus);

			sb.AppendFormat("Alarm         : {0}\n", AlarmStatus ? "On": "Off");

			for (var i = 0; i < VesselVolumeAvg.Length; i++)
			{
				sb.AppendFormat("{0,-12}  : Vol={1,5:n3}{2}, Flow={3,-5:n3}{4}\n", (BTVesselType)i, 
				                                            VesselVolumeAvg[i], Units == BTUnits.US ? "gal" : "l",
				                                            VesselFlowRate[i], Units == BTUnits.US ? "gal/min" : "l/min");
			}

			for (var i = 0; i < Temperature.Length; i++)
			{
				sb.AppendFormat("{0,-12}  : {1} {2}\n", (TSLocation)i, 
														Temperature[i] == -327.68M ? "----" : Temperature[i].ToString("n1"),
														Units == BTUnits.US ? "F" : "C");
			}

			sb.AppendFormat("SteamPressure : {0} psi\n", SteamPressure);

			for (var i = 0; i < HeatOutput.Length; i++)
			{
				sb.AppendFormat("{0,-12}  : {1:n0}%, {2:n1} {3}\n", (BTHeatOutputID)i,
														  HeatOutput[i], 
														  HeatSetpoint[i],
														  Units == BTUnits.US ? "F" : "C");
			}

			
			sb.AppendFormat("AutoValveMode : 0x{0:X4}\n", AutoValveMode);
			sb.AppendFormat("ValveProfile  : 0x{0:X8}\n", ValveProfile);

			return sb.ToString();
		}

	}

}

