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
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace BrewTrollerCommunicator
{

	public enum BTUnits
	{
		Metric = 0,
		US = 1,
		Unknown = -1
	}


	public enum BTVesselID
	{
		HLT = 0,
		Mash = 1,
		Kettle = 2
	}

	public enum BTHeatMode
	{
		OnOff,
		PID
	}

	public enum BTHeatOutputID
	{
		HLT = 0,
		Mash = 1,
		Kettle = 2,
		Steam = 3
	}

	public enum BTProfileID
	{
		FillHLT = 0,
		FillMash = 1,
		AddGrain = 2,
		MashHeat = 3,
		MashIdle = 4,
		SpargeIn = 5,
		SpargeOut = 6,
		BoilAdds = 7,
		KettleLid = 8,
		ChillH2O = 9,
		ChillBeer = 10,
		BoilRecirc = 11,
		Drain = 12,
	}

	[Flags]
	public enum BTAutoValveMode
	{
		Fill = 0x01,
		Mash = 0x02,
		SpargeIn = 0x04,
		SpargeOut = 0x08,
		FlySparge = 0x10,
		Chill = 0x20
	}

	public enum BTTimerID
	{
		HLT,
		Mash
	}

	[SerializableAttribute]
	public class BTConfig : IFormattable
	{
		public static readonly int NumberOfRecipes = 20;
		public static readonly int RecipeNameSize = 19;

		// Version of BT Firmware
		public BTVersion Version { get; set; }

		// SET_BOIL Boil Temperature & Power
		public decimal BoilTemp { get; set; }
		public decimal BoilPower { get; set; }

		// SET_EVAP Evaporation Rate
		public decimal EvapRate { get; set; }

		// SET_VSET Volume Settings
		private SerializableDictionary<BTVesselID, BTVolumeSetting> _volumeSettings;
		public SerializableDictionary<BTVesselID, BTVolumeSetting> VolumeSettings { get { return _volumeSettings; } set { _volumeSettings = value; } }

		// SET_OSET Output Settings
		private SerializableDictionary<BTHeatOutputID, BTHeatOutputConfig> _heatOutputSettings;
		public SerializableDictionary<BTHeatOutputID, BTHeatOutputConfig> HeatOutputSettings { get { return _heatOutputSettings; } set { _heatOutputSettings = value; } }

		// SET_CAL Vessel Calibrations
		private SerializableDictionary<BTVesselID, BTVesselCalibration> _vesselCalibrations;
		public SerializableDictionary<BTVesselID, BTVesselCalibration> VesselCalibrations { get { return _vesselCalibrations; } set { _vesselCalibrations = value; } }

		// SET_VLVCFG Valve Profile
		private SerializableDictionary<BTProfileID, BTValveProfile> _valveProfiles;
		public SerializableDictionary<BTProfileID, BTValveProfile> ValveProfiles { get { return _valveProfiles; } set { _valveProfiles = value; } }

		// Valve/Pump Output Names
		private List<string> _valvePumpNames;
		[XmlArray]
		public List<string> ValvePumpNames { get { return _valvePumpNames; } set { _valvePumpNames = value; } }

		public BTConfig()
		{
			Version = new BTVersion();
		}

		public BTConfig(BTVersion version)
		{
			Version = version;
			Initialize();
		}

		public void Initialize()
		{
			_vesselCalibrations = new SerializableDictionary<BTVesselID, BTVesselCalibration>
          	{
          		{BTVesselID.HLT, new BTVesselCalibration()},
          		{BTVesselID.Mash, new BTVesselCalibration()},
          		{BTVesselID.Kettle, new BTVesselCalibration()}
          	};

			_volumeSettings = new SerializableDictionary<BTVesselID, BTVolumeSetting>
          	{
          		{BTVesselID.HLT, new BTVolumeSetting()},
          		{BTVesselID.Mash, new BTVolumeSetting()},
          		{BTVesselID.Kettle, new BTVolumeSetting()}
          	};

			_heatOutputSettings = new SerializableDictionary<BTHeatOutputID, BTHeatOutputConfig>
          	{
          		{BTHeatOutputID.HLT, new BTHeatOutputConfig {ID = BTHeatOutputID.HLT}},
          		{BTHeatOutputID.Mash, new BTHeatOutputConfig {ID = BTHeatOutputID.Mash}},
          		{BTHeatOutputID.Kettle, new BTHeatOutputConfig {ID = BTHeatOutputID.Kettle}},
          		{BTHeatOutputID.Steam, new BTHeatOutputConfig {ID = BTHeatOutputID.Steam}}
          	};

			_valveProfiles = new SerializableDictionary<BTProfileID, BTValveProfile>
         	{
         		{BTProfileID.FillHLT, new BTValveProfile()},
         		{BTProfileID.FillMash, new BTValveProfile()},
         		{BTProfileID.AddGrain, new BTValveProfile()},
         		{BTProfileID.MashHeat, new BTValveProfile()},
         		{BTProfileID.MashIdle, new BTValveProfile()},
         		{BTProfileID.SpargeIn, new BTValveProfile()},
         		{BTProfileID.SpargeOut, new BTValveProfile()},
         		{BTProfileID.BoilAdds, new BTValveProfile()},
         		{BTProfileID.KettleLid, new BTValveProfile()},
         		{BTProfileID.ChillH2O, new BTValveProfile()},
         		{BTProfileID.ChillBeer, new BTValveProfile()},
         		{BTProfileID.BoilRecirc, new BTValveProfile()},
         		{BTProfileID.Drain, new BTValveProfile()}
         	};

			_valvePumpNames = new List<string>();
			for (var i = 1; i <= 32; i++)
				_valvePumpNames.Add(String.Format("Valve/Pump Out {0,2}", i));
		}

		public override string ToString()
		{
			return String.Format("BrewTroller Configuration: {0}", Version);
		}

		public string ToString(string format, IFormatProvider formatProvider)
		{
			//. uncomment this if different format options are developed 
			switch (format)
			{
			case "G": return ToString();
			default: return ToString();
			}
		}

		public static bool ValidateBoilTemp(decimal temp, BTUnits units)
		{
			// 160F/70C  Mt Everest
			// 215F/102C Dead Sea 
			return (units == BTUnits.US || units == BTUnits.Unknown)
					  ? temp >= 160 && temp <= 215
					  : temp >= 70 && temp <= 102;
		}
		public static bool ValidateBoilPower(decimal power) { return power >= 0 && power <= 100; }
		public static bool ValidateEvapRate(decimal evapRate) { return evapRate >= 0 && evapRate <= 20; }
		public static bool ValidateGrainTemp(decimal temp) { return temp >= 0 && temp <= 150; }
		public static bool ValidateDelayTime(decimal time) { return time >= 0 && time <= 1439; }

	}


	[SerializableAttribute]
	public class BTVolumeSetting : IFormattable, IBTDataClass
	{
		public BTVesselID ID { get; set; }

		public decimal Capacity { get; set; }
		public decimal DeadSpace { get; set; }


		public override bool Equals(object obj)
		{
			if (obj == null || !(obj is BTVolumeSetting))
				return false;

			var vs = obj as BTVolumeSetting;
			return (ID == vs.ID && Capacity == vs.Capacity && DeadSpace == vs.DeadSpace);
		}

		public override int GetHashCode()
		{
			return base.GetHashCode();
		}

		public static bool operator ==(BTVolumeSetting vs1, BTVolumeSetting vs2) { return vs1.Equals(vs2); }
		public static bool operator !=(BTVolumeSetting vs1, BTVolumeSetting vs2) { return !vs1.Equals(vs2); }


		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			var rspCount = (version.IsAsciiSchema0) ? 4 : 3;
			Debug.Assert(rspParams.Count == rspCount, "rspParams.Count == rspCount");

			try
			{
				ID = (BTVesselID)(Convert.ToDecimal(rspParams[0]));
				Capacity = Convert.ToDecimal(rspParams[1]) / 1000m;
				DeadSpace = Convert.ToDecimal(rspParams[2]) / 1000m;
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting parameter list to BTVolumeSetting.", ex);
			}
		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			try
			{
				return new List<string>
			               	{
			               		Convert.ToString(((int)ID)),
			               		Convert.ToString(Capacity * 1000m),
												Convert.ToString(DeadSpace * 1000m)
			               	};
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting BTVolumeSetting to parameter list.", ex);
			}
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			if (len != 7)
				throw new Exception("BTVolumeSetting.HydrateFromBinary: Buffer Size Error.");

			ID = (BTVesselID)btBuf[offset++];

			Capacity = (btBuf[offset++] << 24) |
					   (btBuf[offset++] << 16) |
					   (btBuf[offset++] << 8)  |
					   (btBuf[offset++] << 0);
			Capacity /= 1000;

			DeadSpace = (btBuf[offset++] << 8) |
						(btBuf[offset++] << 0);
			DeadSpace /= 1000;
		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			throw new NotImplementedException();
		}

		public override string ToString()
		{
			return String.Format("{0} Volume: Capacity={1:N3} Dead Space={2:n3}", ID, Capacity, DeadSpace);
		}

		public string ToString(string format, IFormatProvider formatProvider)
		{
			switch (format)
			{
			case "G": return ToString();
			default: return ToString();
			}
		}

	}

	[SerializableAttribute]
	public class BTHeatOutputConfig : IFormattable, IBTDataClass
	{
		private enum HeatOutputField
		{
			ID = 0,
			Mode = 1,
			CycleTime = 2,
			PGain = 3,
			IGain = 4,
			DGain = 5,
			Hysteresis = 6,
			SteamTarget = 6,
			SteamZero = 7,
			SteamSensor = 8,
		}

		public BTHeatOutputID ID { get; set; }
		public BTHeatMode Mode { get; set; }
		[XmlIgnore]
		public TimeSpan CycleTime { get; set; }
		[XmlElement("CycleTime")]
		public string XmlDuration
		{
			get { return CycleTime.ToString(); }
			set { CycleTime = TimeSpan.Parse(value); }
		}
		public decimal PGain { get; set; }
		public decimal IGain { get; set; }
		public decimal DGain { get; set; }
		public decimal Hysteresis { get; set; }
		public decimal SteamTarget { get; set; }
		public decimal SteamZero { get; set; }
		public decimal SteamSensor { get; set; }

		[XmlIgnoreAttribute]
		public bool IsSteam { get { return ID == BTHeatOutputID.Steam; } }
		[XmlIgnoreAttribute]
		public bool IsNotSteam { get { return ID != BTHeatOutputID.Steam; } }

		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			Debug.Assert(rspParams.Count == ((version.ComType == BTComType.ASCII && version.ComSchema == 0) ? 7 : 9), "rspParams.Count == 9");

			try
			{
				ID = (BTHeatOutputID)(Convert.ToInt32(rspParams[(int)HeatOutputField.ID]));
				Mode = (BTHeatMode)(Convert.ToInt32(rspParams[(int)HeatOutputField.Mode]));
				CycleTime = TimeSpan.FromMilliseconds(Convert.ToInt32(rspParams[(int)HeatOutputField.CycleTime]) * 100);
				PGain = Convert.ToDecimal(rspParams[(int)HeatOutputField.PGain]);
				IGain = Convert.ToDecimal(rspParams[(int)HeatOutputField.IGain]);
				DGain = Convert.ToDecimal(rspParams[(int)HeatOutputField.DGain]);
				if (version.IsAsciiSchema0)
				{
					Hysteresis = Convert.ToDecimal(rspParams[(int)HeatOutputField.Hysteresis]) / 10m;
				}
				else
				{
					if (ID == BTHeatOutputID.Steam)
					{
						SteamTarget = Convert.ToDecimal(rspParams[(int)HeatOutputField.SteamTarget]);
						SteamZero = Convert.ToDecimal(rspParams[(int)HeatOutputField.SteamZero]);
						SteamSensor = Convert.ToDecimal(rspParams[(int)HeatOutputField.SteamSensor]);
					}
					else
					{
						Hysteresis = Convert.ToDecimal(rspParams[(int)HeatOutputField.Hysteresis]) / 10m;
					}
				}
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting parameter list to BTHeatOutputConfig.", ex);
			}

		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			try
			{
				var cmdParams = new List<string>
            	{
            		Convert.ToString((int) ID),
            		Convert.ToString((int) Mode),
            		Convert.ToString(Math.Truncate(CycleTime.TotalMilliseconds/100.0)),
            		Convert.ToString(PGain),
            		Convert.ToString(IGain),
            		Convert.ToString(DGain),
            		ID == BTHeatOutputID.Steam ? Convert.ToString(SteamTarget) : Convert.ToString(Hysteresis*10m),
            		Convert.ToString(SteamZero),
            		Convert.ToString(SteamSensor)
            	};
				return cmdParams;
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting BTHeatOutputConfig to parameter list.", ex);
			}
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			if (len == 0 || len != ((btBuf[offset] == (int)BTHeatOutputID.Steam) ? 11 : 7))
				throw new Exception("BTHeatOutputConfig.HydrateFromBinary: Buffer Size Error.");

			ID = (BTHeatOutputID)btBuf[offset++];
			Mode = (BTHeatMode)btBuf[offset++];
			CycleTime = TimeSpan.FromMilliseconds(btBuf[offset++] * 100);
			PGain = btBuf[offset++];
			IGain = btBuf[offset++];
			DGain = btBuf[offset++];
			if (ID != BTHeatOutputID.Steam)
			{
				Hysteresis = btBuf[offset++];
			}
			else
			{
				SteamZero = (btBuf[offset++] << 8) + (btBuf[offset++] << 8);
				SteamTarget = btBuf[offset++];
				SteamSensor = (btBuf[offset++] << 8) + (btBuf[offset++] << 8);
			}
		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			throw new NotImplementedException();
		}

		public override string ToString()
		{
			return IsSteam ? String.Format("{0} Output: Mode={1}, Cycle={2:N1} (P={3}, I={4}, D={5}, Target={6:N1}, Zero={7}, Sensitivity={8})",
											ID, Mode, CycleTime.TotalSeconds, PGain, IGain, DGain, SteamTarget, SteamZero, SteamSensor)
							: String.Format("{0} Output: Mode={1}, Cycle={2:N1} (P={3}, I={4}, D={5}, Hysteresis={6:N1})",
											ID, Mode, CycleTime.TotalSeconds, PGain, IGain, DGain, Hysteresis);
		}

		public string ToString(string format, IFormatProvider formatProvider)
		{
			switch (format)
			{
			case "G": return ToString();
			default: return ToString();
			}
		}

	}

	[SerializableAttribute]
	public class BTValveProfile : IFormattable, IBTDataClass
	{
		private enum ValveProfileField
		{
			ID = 0,
			Mask = 1
		}

		public BTProfileID ID { get; set; }
		public UInt64 Mask { get; set; }

		[XmlIgnoreAttribute]
		public bool Valve01 { get { return Mask.GetBit(0); } set { Mask = Mask.SetBit(0, value); } }
		[XmlIgnoreAttribute]
		public bool Valve02 { get { return Mask.GetBit(1); } set { Mask = Mask.SetBit(1, value); } }
		[XmlIgnoreAttribute]
		public bool Valve03 { get { return Mask.GetBit(2); } set { Mask = Mask.SetBit(2, value); } }
		[XmlIgnoreAttribute]
		public bool Valve04 { get { return Mask.GetBit(3); } set { Mask = Mask.SetBit(3, value); } }
		[XmlIgnoreAttribute]
		public bool Valve05 { get { return Mask.GetBit(4); } set { Mask = Mask.SetBit(4, value); } }
		[XmlIgnoreAttribute]
		public bool Valve06 { get { return Mask.GetBit(5); } set { Mask = Mask.SetBit(5, value); } }
		[XmlIgnoreAttribute]
		public bool Valve07 { get { return Mask.GetBit(6); } set { Mask = Mask.SetBit(6, value); } }
		[XmlIgnoreAttribute]
		public bool Valve08 { get { return Mask.GetBit(7); } set { Mask = Mask.SetBit(7, value); } }
		[XmlIgnoreAttribute]
		public bool Valve09 { get { return Mask.GetBit(8); } set { Mask = Mask.SetBit(8, value); } }
		[XmlIgnoreAttribute]
		public bool Valve10 { get { return Mask.GetBit(9); } set { Mask = Mask.SetBit(9, value); } }
		[XmlIgnoreAttribute]
		public bool Valve11 { get { return Mask.GetBit(10); } set { Mask = Mask.SetBit(10, value); } }
		[XmlIgnoreAttribute]
		public bool Valve12 { get { return Mask.GetBit(11); } set { Mask = Mask.SetBit(11, value); } }
		[XmlIgnoreAttribute]
		public bool Valve13 { get { return Mask.GetBit(12); } set { Mask = Mask.SetBit(12, value); } }
		[XmlIgnoreAttribute]
		public bool Valve14 { get { return Mask.GetBit(13); } set { Mask = Mask.SetBit(13, value); } }
		[XmlIgnoreAttribute]
		public bool Valve15 { get { return Mask.GetBit(14); } set { Mask = Mask.SetBit(14, value); } }
		[XmlIgnoreAttribute]
		public bool Valve16 { get { return Mask.GetBit(15); } set { Mask = Mask.SetBit(15, value); } }
		[XmlIgnoreAttribute]
		public bool Valve17 { get { return Mask.GetBit(16); } set { Mask = Mask.SetBit(16, value); } }
		[XmlIgnoreAttribute]
		public bool Valve18 { get { return Mask.GetBit(17); } set { Mask = Mask.SetBit(17, value); } }
		[XmlIgnoreAttribute]
		public bool Valve19 { get { return Mask.GetBit(18); } set { Mask = Mask.SetBit(18, value); } }
		[XmlIgnoreAttribute]
		public bool Valve20 { get { return Mask.GetBit(19); } set { Mask = Mask.SetBit(19, value); } }
		[XmlIgnoreAttribute]
		public bool Valve21 { get { return Mask.GetBit(20); } set { Mask = Mask.SetBit(20, value); } }
		[XmlIgnoreAttribute]
		public bool Valve22 { get { return Mask.GetBit(21); } set { Mask = Mask.SetBit(21, value); } }
		[XmlIgnoreAttribute]
		public bool Valve23 { get { return Mask.GetBit(22); } set { Mask = Mask.SetBit(22, value); } }
		[XmlIgnoreAttribute]
		public bool Valve24 { get { return Mask.GetBit(23); } set { Mask = Mask.SetBit(23, value); } }
		[XmlIgnoreAttribute]
		public bool Valve25 { get { return Mask.GetBit(24); } set { Mask = Mask.SetBit(24, value); } }
		[XmlIgnoreAttribute]
		public bool Valve26 { get { return Mask.GetBit(25); } set { Mask = Mask.SetBit(25, value); } }
		[XmlIgnoreAttribute]
		public bool Valve27 { get { return Mask.GetBit(26); } set { Mask = Mask.SetBit(26, value); } }
		[XmlIgnoreAttribute]
		public bool Valve28 { get { return Mask.GetBit(27); } set { Mask = Mask.SetBit(27, value); } }
		[XmlIgnoreAttribute]
		public bool Valve29 { get { return Mask.GetBit(28); } set { Mask = Mask.SetBit(28, value); } }
		[XmlIgnoreAttribute]
		public bool Valve30 { get { return Mask.GetBit(29); } set { Mask = Mask.SetBit(29, value); } }
		[XmlIgnoreAttribute]
		public bool Valve31 { get { return Mask.GetBit(30); } set { Mask = Mask.SetBit(30, value); } }
		[XmlIgnoreAttribute]
		public bool Valve32 { get { return Mask.GetBit(31); } set { Mask = Mask.SetBit(31, value); } }


		public override bool Equals(object obj)
		{

			if (obj == null || !(obj is BTValveProfile))
				return false;

			var vp = obj as BTValveProfile;
			return (ID == vp.ID && Mask == vp.Mask);
		}

		public override int GetHashCode()
		{
			return base.GetHashCode();
		}

		public static bool operator ==(BTValveProfile vp1, BTValveProfile vp2) { return (object)vp1 != null && (object)vp2 != null && vp1.Equals(vp2); }
		public static bool operator !=(BTValveProfile vp1, BTValveProfile vp2) { return !((object)vp1 != null && (object)vp2 != null && vp1.Equals(vp2)); }


		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			Debug.Assert(rspParams.Count == 2, "rspParams.Count == 2");

			try
			{
				ID = (BTProfileID)Enum.Parse(typeof(BTProfileID), rspParams[(int)ValveProfileField.ID]);
				Mask = Convert.ToUInt32(rspParams[(int)ValveProfileField.Mask]);
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting parameter list to BTValveProfile.", ex);
			}
		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			try
			{
				return new List<string>
			               	{
			               		Convert.ToString((int)ID),
			               		Convert.ToString(Mask)
			               	};
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting BTValveProfile to parameter list.", ex);
			}
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			if (len != 9)
				throw new Exception("BTVolumeSetting.HydrateFromBinary: Buffer Size Error.");

			ID = (BTProfileID)btBuf[offset++];
			Mask = 0;
			for (var i = 0; i < 8; i++)
			{
				// message supports 64 valve/pump, current BT only supports 32
				Mask <<= 8;
				Mask |= btBuf[offset++];
			}

		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			throw new NotImplementedException();
		}

		public override string ToString()
		{
			return String.Format("{0} Profile: 0x{1:x8}({1}) ", ID, Mask);
		}

		public string ToString(string format, IFormatProvider formatProvider)
		{
			if (formatProvider != null)
			{
				ICustomFormatter fmt = formatProvider.GetFormat(GetType()) as ICustomFormatter;
				if (fmt != null)
					return fmt.Format(format, this, formatProvider);
			}

			var sb = new StringBuilder();
			var split = format.Split(new[] { ',' });
			// no format option other than what ToString provides 
			switch (split[0])
			{
			case "bin":
				sb.AppendFormat("{0} Profile: ", ID);
				int bitsToDisplay;
				if (split.Length < 2 || int.TryParse(split[1], out bitsToDisplay))
					bitsToDisplay = 16;
				for (int i = (bitsToDisplay / 4) - 1; i >= 0; i--)
				{
					sb.Append(GetNibble(Mask, i) + " ");
				}
				return sb.ToString();

			case "G": return ToString();
			default: return ToString();
			}
		}

		private static string GetNibble(UInt64 mask, int nibbleNumber)
		{
			mask >>= nibbleNumber * 4;
			switch (mask & 0xf)
			{
			case 0: return "0000";
			case 1: return "0001";
			case 2: return "0010";
			case 3: return "0011";
			case 4: return "0100";
			case 5: return "0101";
			case 6: return "0110";
			case 7: return "0111";
			case 8: return "1000";
			case 9: return "1001";
			case 10: return "1010";
			case 11: return "1011";
			case 12: return "1100";
			case 13: return "1101";
			case 14: return "1110";
			case 15: return "1111";
			}
			return "";
		}
	}

	[SerializableAttribute]
	public class BTVesselCalibration : IFormattable, IBTDataClass
	{
		public static readonly int NumberOfCalibrationPoints = 10;

		public BTVesselID ID { get; set; }

		private BTCalibrationPoint[] _btCalibrationPoints = new BTCalibrationPoint[NumberOfCalibrationPoints];
		public BTCalibrationPoint[] CalibrationPoints { get { return _btCalibrationPoints; } set { _btCalibrationPoints = value; } }

		public BTVesselCalibration()
		{
			for (int i = 0; i < _btCalibrationPoints.Length; i++)
			{
				_btCalibrationPoints[i] = new BTCalibrationPoint(i + 1);
			}
		}

		[XmlIgnoreAttribute]
		public BTCalibrationPoint CalibrationPoint0 { get { return _btCalibrationPoints[0]; } set { _btCalibrationPoints[0] = value; } }
		[XmlIgnoreAttribute]
		public BTCalibrationPoint CalibrationPoint1 { get { return _btCalibrationPoints[1]; } set { _btCalibrationPoints[1] = value; } }
		[XmlIgnoreAttribute]
		public BTCalibrationPoint CalibrationPoint2 { get { return _btCalibrationPoints[2]; } set { _btCalibrationPoints[2] = value; } }
		[XmlIgnoreAttribute]
		public BTCalibrationPoint CalibrationPoint3 { get { return _btCalibrationPoints[3]; } set { _btCalibrationPoints[3] = value; } }
		[XmlIgnoreAttribute]
		public BTCalibrationPoint CalibrationPoint4 { get { return _btCalibrationPoints[4]; } set { _btCalibrationPoints[4] = value; } }
		[XmlIgnoreAttribute]
		public BTCalibrationPoint CalibrationPoint5 { get { return _btCalibrationPoints[5]; } set { _btCalibrationPoints[5] = value; } }
		[XmlIgnoreAttribute]
		public BTCalibrationPoint CalibrationPoint6 { get { return _btCalibrationPoints[6]; } set { _btCalibrationPoints[6] = value; } }
		[XmlIgnoreAttribute]
		public BTCalibrationPoint CalibrationPoint7 { get { return _btCalibrationPoints[7]; } set { _btCalibrationPoints[7] = value; } }
		[XmlIgnoreAttribute]
		public BTCalibrationPoint CalibrationPoint8 { get { return _btCalibrationPoints[8]; } set { _btCalibrationPoints[8] = value; } }
		[XmlIgnoreAttribute]
		public BTCalibrationPoint CalibrationPoint9 { get { return _btCalibrationPoints[9]; } set { _btCalibrationPoints[9] = value; } }


		public override bool Equals(object obj)
		{

			if (obj == null || !(obj is BTVesselCalibration))
				return false;

			var vc = obj as BTVesselCalibration;
			if (ID != vc.ID)
				return false;

			for (var i = 0; i < CalibrationPoints.Length; i++)
				if (CalibrationPoints[i] != vc.CalibrationPoints[i])
					return false;

			return true;
			//return !CalibrationPoints.Where((t, i) => t != vc.CalibrationPoints[i]).Any();
		}

		public override int GetHashCode()
		{
			return base.GetHashCode();
		}

		public static bool operator ==(BTVesselCalibration vc1, BTVesselCalibration vc2) { return vc1.Equals(vc2); }
		public static bool operator !=(BTVesselCalibration vc1, BTVesselCalibration vc2) { return !vc1.Equals(vc2); }



		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			Debug.Assert(rspParams.Count == 21, "rspParams.Count == 21");

			try
			{
				ID = (BTVesselID)(Convert.ToDecimal(rspParams[0]));
				for (int i = 0; i < _btCalibrationPoints.Length; i++)
				{
					_btCalibrationPoints[i] = new BTCalibrationPoint(i);
					_btCalibrationPoints[i].HydrateFromParamList(version, rspParams.GetRange(i * 2 + 1, 2));
				}
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting parameter list to BTVesselCalibration.", ex);
			}
		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			try
			{
				var rspList = new List<string> { Convert.ToString((int)ID) };
				foreach (var point in _btCalibrationPoints)
					rspList.AddRange(point.EmitToParamsList(version));
				return rspList;
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting BTVesselCalibration to parameter list.", ex);
			}
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			if (len != 61)
				throw new Exception("BTVolumeSetting.HydrateFromBinary: Buffer Size Error.");

			ID = (BTVesselID)btBuf[offset++];

			for (var i = 0; i < 10; i++)
			{
				var vol = (btBuf[offset++] << 24) |
						  (btBuf[offset++] << 16) |
						  (btBuf[offset++] << 8)  |
						  (btBuf[offset++] << 0);
				var dVol = (decimal)vol / 1000;

				var val = (btBuf[offset++] << 8) |
						  (btBuf[offset++] << 0);

				_btCalibrationPoints[i] = new BTCalibrationPoint() { PointID = i, Volume = dVol, Value = val };
			}
		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			throw new NotImplementedException();
		}

		public override string ToString()
		{
			var sb = new StringBuilder();
			sb.AppendFormat("{0} Calibration: ", ID);
			if (CalibrationPoint0.IsEmpty)
			{
				sb.Append("<none>");
			}
			else
			{
				for (int i = 0; i < NumberOfCalibrationPoints; i++)
				{
					if (_btCalibrationPoints[i].IsEmpty)
						break;
					sb.AppendFormat("{0}: {1}; ", i, _btCalibrationPoints[i]);
				}
			}
			return sb.ToString();
		}

		public string ToString(string format, IFormatProvider formatProvider)
		{
			if (formatProvider != null)
			{
				ICustomFormatter fmt = formatProvider.GetFormat(GetType()) as ICustomFormatter;
				if (fmt != null)
					return fmt.Format(format, this, formatProvider);
			}

			// no format option other than what ToString provides 
			switch (format)
			{
			case "G": return ToString();
			default: return ToString();
			}
		}

	}

	[SerializableAttribute]
	public class BTCalibrationPoint : IFormattable, IBTDataClass
	{
		public int PointID { get; set; }
		public decimal Volume { get; set; }
		public decimal Value { get; set; }

		public bool IsEmpty { get { return Volume == 0.0m && Value == 0; } }

		public BTCalibrationPoint() { }

		public BTCalibrationPoint(int id) { PointID = id; }


		public override bool Equals(object obj)
		{

			if (obj == null || !(obj is BTCalibrationPoint))
				return false;

			var vcp = obj as BTCalibrationPoint;

			return (PointID == vcp.PointID && Volume == vcp.Volume && Value == vcp.Value);
		}

		public override int GetHashCode()
		{
			return base.GetHashCode();
		}

		public static bool operator ==(BTCalibrationPoint vcp1, BTCalibrationPoint vcp2) { return vcp1.Equals(vcp2); }
		public static bool operator !=(BTCalibrationPoint vcp1, BTCalibrationPoint vcp2) { return !vcp1.Equals(vcp2); }


		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			Debug.Assert(rspParams.Count == 2, "rspParams.Count == 2");
			try
			{
				Volume = Convert.ToDecimal(rspParams[0]) / 1000m;
				Value = Convert.ToDecimal(rspParams[1]);
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting parameter list to BTCalibrationPoint.", ex);
			}
		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			try
			{
				return new List<string>
			               	{
			               		Convert.ToString(Volume * 1000m),
			               		Convert.ToString(Value)
			               	};
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting BTCalibrationPoint to parameter list.", ex);
			}
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			throw new NotImplementedException();
		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			throw new NotImplementedException();
		}

		public override string ToString()
		{
			return String.Format("{0:n3}({1})", Volume, Value);
		}

		public string ToString(string format, IFormatProvider formatProvider)
		{
			if (formatProvider != null)
			{
				ICustomFormatter fmt = formatProvider.GetFormat(GetType()) as ICustomFormatter;
				if (fmt != null)
					return fmt.Format(format, this, formatProvider);
			}

			// no format option other than what ToString provides 
			switch (format)
			{
			case "G": return ToString();
			default: return ToString();
			}
		}

	}


	public enum TSLocation
	{
		HLT,
		Mash,
		Kettle,
		H2OIn,
		H2OOut,
		BeerOut,
		Aux1,
		Aux2,
		Aux3,

		Undefined = -1
	}

	public class TSAddress : IFormattable, IBTDataClass
	{
		public TSLocation Location { get; set; }
		public byte[] Address { get; set; }

		public TSAddress(TSLocation tsLocation)
		{
			Location = tsLocation;
			Address = new byte[8];
		}

		public TSAddress(TSLocation tsLocation, ulong address) : this(tsLocation)
		{
			for (var i = 7; i >= 0; i--)
			{
				Address[i] = (byte)(address & 0xff);
				address >>= 8;
			}
		}

		public override bool Equals(object obj)
		{

			if (obj == null || !(obj is TSAddress))
				return false;

			var ts1 = obj as TSAddress;
			if (Location != ts1.Location)
				return false;

			return !Address.Where((t, i) => t != ts1.Address[i]).Any();
		}

		public override int GetHashCode()
		{
			return base.GetHashCode();
		}

		public static bool operator ==(TSAddress ts1, TSAddress ts2) { return ts1.Equals(ts2); }
		public static bool operator !=(TSAddress ts1, TSAddress ts2) { return !ts1.Equals(ts2); }

		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			Debug.Assert(rspParams.Count == 9, "rspParams.Count == 9");
			try
			{
				Location = (TSLocation)int.Parse(rspParams[0]);
				for (var i = 0; i < 8; i++)
					Address[i] = byte.Parse(rspParams[i + 1]);
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting parameter list to Temp Sensor Address.", ex);
			}
		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			var paramList = new List<string>();
			try
			{
				paramList.Add(((int)Location).ToString());
				for (var i = 0; i < 8; i++)
					paramList.Add(Address[i].ToString());
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting Temp Sensor Address to parameter list.", ex);
			}
			return paramList;
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			if (len != 9)
				throw new Exception("TSAddress.HydrateFromBinary: Buffer Size Error.");

			Location = (TSLocation)btBuf[offset++];
			for (var i = 0; i < 8; i++)
				Address[i] = btBuf[offset++];
		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			throw new NotImplementedException();
		}

		public override string ToString()
		{
			return String.Format("TS Address for {0}:{1:x2}.{2:x2}.{3:x2}.{4:x2}.{5:x2}.{6:x2}.{7:x2}.{8:x2}",
								 Location, Address[0], Address[1], Address[2], Address[3],
								 Address[4], Address[5], Address[6], Address[7]);
		}

		public string ToString(string format, IFormatProvider formatProvider)
		{
			if (formatProvider != null)
			{
				ICustomFormatter fmt = formatProvider.GetFormat(GetType()) as ICustomFormatter;
				if (fmt != null)
					return fmt.Format(format, this, formatProvider);
			}

			// no format option other than what ToString provides 
			switch (format)
			{
			case "G": return ToString();
			default: return ToString();
			}
		}

	}

	public class BTValveState : IFormattable, IBTDataClass
	{
		public UInt64 Mask { get; set; }
		public UInt64 State { get; set; }

		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			throw new NotImplementedException();
		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			return new List<string>
			{
				Mask.ToString(),
				State.ToString(),
			};
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			throw new NotImplementedException();
		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			var uiVal = Mask;
			for (var i = 7; i >= 0; i++)
			{
				cmdBuf[offset + i] = (byte)(uiVal & 0xff);
				uiVal >>= 8;
			}
			offset += 8;

			uiVal = State;
			for (var i = 7; i >= 0; i++)
			{
				cmdBuf[offset + i] = (byte)(uiVal & 0xff);
				uiVal >>= 8;
			}
			return 16;
		}

		public override string ToString()
		{
			return String.Format("Valve Mask: 0x{0:X8}, Valve State: 0x{1:X8}", Mask, State);
		}

		public string ToString(string format, IFormatProvider formatProvider)
		{
			if (formatProvider != null)
			{
				ICustomFormatter fmt = formatProvider.GetFormat(GetType()) as ICustomFormatter;
				if (fmt != null)
					return fmt.Format(format, this, formatProvider);
			}

			// no format option other than what ToString provides 
			switch (format)
			{
			case "G": return ToString();
			default: return ToString();
			}
		}

	}


	public class GenericDecimal : IBTDataClass
	{
		private byte _byteCount = 1;
		public byte ByteCount
		{
			get { return _byteCount; }
			set
			{
				Debug.Assert(value >= 0 && value <= 8, "byteCount >= 0 && byteCount <= 8");
				_byteCount = value;
			}
		}

		private byte _scaleFactor = 1;
		public byte ScaleFactor
		{
			get { return _scaleFactor; }
			set
			{
				Debug.Assert(value != 0, "scaleFactor != 0");
				_scaleFactor = value;
			}
		}

		private bool _hasUnits;
		public bool HasUnits
		{
			get { return _hasUnits; }
			set { _hasUnits = value; }
		}

		public decimal Value { get; set; }
		public BTUnits Units { get; set; }

		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			Debug.Assert(rspParams.Count == (_hasUnits ? 2 : 1), "rspParams.Count == 1/2");
			try
			{
				var iVal = int.Parse(rspParams[0]);
				Value = (decimal)iVal / ScaleFactor;
				if (HasUnits)
					Units = (BTUnits)(Convert.ToInt32(rspParams[1]));
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting parameter list to Generic Decimal.", ex);
			}
		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			try
			{
				int iVal = (int)(Value * ScaleFactor);
				return new List<string>
				{
					iVal.ToString()
				};
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting Generic Decimal to parameter list.", ex);
			}
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			if (len != ByteCount)
				throw new Exception("GenericDecimal.HydrateFromBinary: Buffer Size Error.");

			Int64 iVal = 0;
			for (var i = ByteCount - 1; i >= 0; i--)
			{
				iVal <<= 8;
				iVal += btBuf[offset++];
			}

			Value = (decimal)iVal / ScaleFactor;
		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			// scale the value
			int iVal = (int)(Value * ScaleFactor);

			//put bytes in buffer in reverse order
			for (var i = ByteCount - 1; i >= 0; i--)
			{
				cmdBuf[offset + i] = (byte)(iVal & 0xff);
				iVal >>= 8;
			}
			return ByteCount;
		}

	}

	public class GenericBoolean : IBTDataClass
	{
		public bool Value { get; set; }

		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			Debug.Assert(rspParams.Count == 1, "rspParams.Count == 1");
			Value = rspParams[0] != "0";
		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			return new List<string> { Value ? "1" : "0" };
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			Value = btBuf[offset] != 0;
		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			cmdBuf[offset] = (byte)(Value ? 1 : 0);
			return 1;
		}

	}

	public enum BTBrewStep
	{
		Fill,
		Delay,
		Preheat,
		GrainIn,
		Refill,
		DoughIn,
		AcidRest,
		ProteinRest,
		Sacch1Rest,
		Sacch2Rest,
		MashOut,
		MashHold,
		Sparge,
		Boil,
		Chill
	}

	public class BT_EEPROM : IFormattable, IBTDataClass
	{
		public const int EEPROM_SIZE = 2048;

		public byte[] Data = new byte[EEPROM_SIZE];

		private int _address;
		public int Address
		{
			get { return _address; }
			set
			{
				if (value < 0) _address = 0;
				else if (value > EEPROM_SIZE - 1) _address = EEPROM_SIZE-1;
				else _address = value;
			}
		}
		private int _byteCount;

		public int ByteCount
		{
			get { return _byteCount; }
			set
			{
				if (value < 0) _byteCount = 0;
				else if (value > EEPROM_SIZE) _byteCount = EEPROM_SIZE;
				else _byteCount = value;
			}
		}

		public BT_EEPROM()
		{
			Data = new byte[2048];
		}

		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			int checksum = 0;

			UInt16 address;
			if (!UInt16.TryParse(rspParams[0], NumberStyles.HexNumber, null, out address))
				throw new Exception();
			checksum += address.MSB();
			checksum += address.LSB();
			Address = address;

			UInt16 dataLen;
			if (!UInt16.TryParse(rspParams[1], NumberStyles.HexNumber, null, out dataLen))
				throw new Exception();
			checksum += dataLen & 0xff;
			ByteCount = dataLen;

			// parse data
			byte btVal;
			var paramIndex = 1;
			for (var offset = 0; offset < ByteCount; offset++)
			{
				if (offset % 8 == 0)
					paramIndex++;

				var byteIndex = 2 * (offset % 8);
				if (!byte.TryParse(rspParams[paramIndex].Substring(byteIndex, 2), NumberStyles.HexNumber, null, out btVal))
					throw new Exception();
				Data[address++] = btVal;
				checksum += btVal;
			}

			// parse checksum
			paramIndex++;
			if (!byte.TryParse(rspParams[paramIndex], NumberStyles.HexNumber, null, out btVal))
				throw new Exception();
			checksum += btVal;
			checksum &= 0xff;
			if (checksum != 0)
				throw new Exception();
		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			if (ByteCount > 255)
				throw new ArgumentOutOfRangeException("ByteCount");

			byte byteCount = (byte)ByteCount;

			var rspList = new List<string>();
			byte checksum = 0;

			rspList.Add(String.Format("{0:X4}", Address));
			checksum += Address.Byte1();
			checksum += Address.Byte0();

			rspList.Add(String.Format("{0:X2}", ByteCount));
			checksum += byteCount;

			var sb = new StringBuilder(16);
			for (var i = 0; i < ByteCount; i++)
			{
				if (sb.Length == 16)
				{
					rspList.Add(sb.ToString());
					sb.Length = 0;
				}
				sb.AppendFormat("{0:X2}", Data[Address + i]);
				checksum += Data[Address + i];
			}
			rspList.Add(sb.ToString());

			checksum = (byte)(~checksum + 1);
			rspList.Add(String.Format("{0:X2}", checksum));

			return rspList;
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			throw new NotImplementedException();
		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			throw new NotImplementedException();
		}

		public string ToString(string format, IFormatProvider formatProvider)
		{
			throw new NotImplementedException();
		}

		public StringBuilder HexDump()
		{
			var sb = new StringBuilder();
			var startAddress = Address & 0xfffffff0;
			var endAddress = (Address + ByteCount - 1) | 0xf;
			sb.Append("addr   0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f\n");
			sb.Append("----- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --");
			for (var i = startAddress; i <= endAddress; i++)
			{
				if ((i % 16) == 0)
				{
					sb.Append('\n');
					sb.AppendFormat("{0:X4}: ", i);
				}
				if (i < Address || i >= Address + ByteCount)
					sb.AppendFormat("   ");
				else
					sb.AppendFormat("{0:X2} ", Data[i]);
			}

			return sb;
		}

		public void SaveToFile(string fileName)
		{
			using (StreamWriter sw = new StreamWriter(fileName))
			{
				byte recSize = 16;

				var sb = new StringBuilder();
				byte checksum = 0;
				for (UInt16 address = 0; address < 2048; address++)
				{
					if (address % recSize == 0)
					{
						// Calculate and write the checksum field
						if (address != 0)
						{
							checksum = (byte)(~checksum + 1);
							sb.AppendFormat("{0:X2}", checksum);
							sw.WriteLine(sb.ToString());
							sb.Length = 0;
						}

						// Write the start code, data count, Address, and type fields 
						sb.AppendFormat(":{0:X2}{1:X4}00", recSize, address);
						checksum = recSize;
						checksum += address.MSB();
						checksum += address.LSB();
					}

					sb.AppendFormat("{0:X2}", Data[address]);
					checksum += Data[address];
				}
				checksum = (byte)(~checksum + 1);
				sb.AppendFormat("{0:X2}", checksum);
				sw.WriteLine(sb.ToString());
			}

		}

		public void LoadFromIntelHexFile(string fileName)
		{
			using (StreamReader sr = new StreamReader(fileName))
			{
				string strRec;
				while ((strRec = sr.ReadLine()) != null)
				{
					// Size check for start code, count, Address, and type fields 
					if (strRec.Length < 9)
						throw new ArgumentException("Input string too short.");

					// Check the for colon start code 
					if (strRec[0] != ':')
						throw new ArgumentException("Input string does not start with ';'");

					// Get the count 
					UInt16 count;
					if (!UInt16.TryParse(strRec.Substring(1, 2), NumberStyles.HexNumber, null, out count))
						throw new ArgumentException("Unable to parse Length field");
					byte checksum = (byte)count;


					// Get the Address
					UInt16 address;
					if (!UInt16.TryParse(strRec.Substring(3, 4), NumberStyles.HexNumber, null, out address))
						throw new ArgumentException("Unable to parse Address field");
					checksum += address.MSB();
					checksum += address.LSB();

					// Copy the record type field
					byte type;
					if (!byte.TryParse(strRec.Substring(7, 1), NumberStyles.HexNumber, null, out type) || type < 0 || type > 5)
						throw new ArgumentException("Unable to parse Type field");
					checksum += type;
					if (type != 0)
						continue;

					// Size check for start code, count, Address, type, data and checksum fields 
					if (strRec.Length < 11 + count * 2)
						throw new ArgumentException("Record length does not match Length field");

					// Loop through each ascii hex byte of the data field, pull it out into hexBuff,
					//   convert it and store the result in the data buffer of the Intel Hex record 
					byte btVal;
					for (var i = 0; i < count; i++)
					{
						// Times two i because every byte is represented by two ascii hex characters 
						if (!byte.TryParse(strRec.Substring(9 + 2 * i, 2), NumberStyles.HexNumber, null, out btVal))
							throw new ArgumentException("Unable to parse Data");
						Data[address + i] = btVal;
						checksum += btVal;
					}

					// Copy the ascii hex encoding of the checksum field into hexBuff, convert it to a usable integer 
					if (!byte.TryParse(strRec.Substring(9 + count * 2, 2), NumberStyles.HexNumber, null, out btVal))
						throw new ArgumentException("Unable to parse Checksum");
					checksum += btVal;

					if (checksum != 0)
						throw new ArgumentException("Checksum error");
				}

			}

		}



	}


	[XmlRoot("dictionary")]
	public class SerializableDictionary<TKey, TValue>
			: Dictionary<TKey, TValue>, IXmlSerializable
	{
		#region IXmlSerializable Members

		public System.Xml.Schema.XmlSchema GetSchema()
		{
			return null;
		}

		public void ReadXml(System.Xml.XmlReader reader)
		{
			XmlSerializer keySerializer = new XmlSerializer(typeof(TKey));
			XmlSerializer valueSerializer = new XmlSerializer(typeof(TValue));

			bool wasEmpty = reader.IsEmptyElement;
			reader.Read();

			if (wasEmpty)
				return;

			while (reader.NodeType != System.Xml.XmlNodeType.EndElement)
			{
				reader.ReadStartElement("item");

				reader.ReadStartElement("key");
				TKey key = (TKey)keySerializer.Deserialize(reader);
				reader.ReadEndElement();

				reader.ReadStartElement("value");
				TValue value = (TValue)valueSerializer.Deserialize(reader);
				reader.ReadEndElement();

				Add(key, value);

				reader.ReadEndElement();
				reader.MoveToContent();
			}
			reader.ReadEndElement();
		}

		public void WriteXml(System.Xml.XmlWriter writer)
		{
			XmlSerializer keySerializer = new XmlSerializer(typeof(TKey));
			XmlSerializer valueSerializer = new XmlSerializer(typeof(TValue));

			foreach (TKey key in Keys)
			{
				writer.WriteStartElement("item");

				writer.WriteStartElement("key");
				keySerializer.Serialize(writer, key);
				writer.WriteEndElement();

				writer.WriteStartElement("value");
				TValue value = this[key];
				valueSerializer.Serialize(writer, value);
				writer.WriteEndElement();

				writer.WriteEndElement();
			}
		}

		#endregion

	}

}

