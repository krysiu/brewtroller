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


namespace BrewTrollerCommunicator
{
	[SerializableAttribute]
	public class BTVersion : IFormattable, IBTDataClass
	{
		public int MajorVersion { get; set; }
		public int MinorVersion { get; set; }
		public int BuildNumber { get; set; }
		public BTComType ComType { get; set; }
		public int ComSchema { get; set; }
		public BTUnits Units { get; set; }

		public BTVersion()
		{
			MajorVersion = 0;
			MinorVersion = 0;
			BuildNumber = 0;
			ComType = BTComType.Unknown;
			ComSchema = 0;
			Units = BTUnits.Unknown;
		}

		public string Version { get { return String.Format("{0}.{1}", MajorVersion, MinorVersion); } }

		public void HydrateFromParamList(int schema, List<string> rspParams)
		{
			var iVal = 0;

			switch (rspParams.Count)
			{
			case 2:
				{
					// version
					var verSplit = rspParams[0].Split(new[] { '.' });
					if (verSplit.Length > 0)
						int.TryParse(verSplit[0], out iVal);
					MajorVersion = iVal;
					if (verSplit.Length > 1)
						int.TryParse(verSplit[1], out iVal);
					MinorVersion = iVal;

					// build
					int.TryParse(rspParams[1], out iVal);
					BuildNumber = iVal;

					ComType = BTComType.ASCII;
					ComSchema = 0;
					Units = BTUnits.Unknown;
				}
				break;
			case 4:
				{
					// version
					var verSplit = rspParams[0].Split(new[] { '.' });
					if (verSplit.Length > 0)
						int.TryParse(verSplit[0], out iVal);
					MajorVersion = iVal;
					if (verSplit.Length > 1)
						int.TryParse(verSplit[1], out iVal);
					MinorVersion = iVal;

					// build
					int.TryParse(rspParams[1], out iVal);
					BuildNumber = iVal;

					// schema
					int.TryParse(rspParams[2], out iVal);
					ComSchema = iVal;

					int.TryParse(rspParams[3], out iVal);
					Units = (BTUnits)iVal;

				}
				break;
			default:
				ComType = BTComType.Unknown;
				break;
			}

			// ComType
			if (ComSchema < 10)
			{
				ComType = BTComType.ASCII;
			}
			else if (ComSchema >= 10 && ComSchema < 19)
			{
				ComType = BTComType.Binary;
			}
			else if (ComSchema >= 20 && ComSchema < 29)
			{
				ComType = BTComType.BTNic;
			}
			else
			{
				ComType = BTComType.Unknown;
			}

		}

		public List<string> EmitToParamsList(int schema)
		{
			throw new NotImplementedException();
		}

		public void HydrateFromBinary(int schema, byte[] btBuf, int offset, int len)
		{
			if (len != 6)
				throw new Exception("BTVersion.HydrateFromBinary: Buffer Size Error.");

			ComType = BTComType.Binary;

			MajorVersion = btBuf[offset++];
			MinorVersion = btBuf[offset++];
			BuildNumber = btBuf[offset++] + (btBuf[offset++] << 8);
			ComSchema = btBuf[offset++];
			Units = (BTUnits)btBuf[offset++];
		}

		public byte EmitToBinary(int schema, byte[] cmdBuf, byte offset)
		{
			throw new NotImplementedException();
		}

		public override string ToString()
		{
			return String.Format("BT Version: {0}; Build: {1}; Com Type: {2}; Schema: {3}; Units: {4}",
							Version, BuildNumber, ComType, ComSchema, Units);
		}

		public string ToString(string format, IFormatProvider formatProvider)
		{
			switch (format)
			{
			case "G":	return ToString();
			default:	return ToString();
			}
		}

	}

}

