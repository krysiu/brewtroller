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
using System.Text;

namespace BrewTrollerCommunicator
{
	public static class ExtensionMethods
	{
		public static bool IsNullOrEmpty(this string value)
		{
			return string.IsNullOrEmpty(value);
		}

		public static bool GetBit(this UInt32 value, int bitNumber)
		{
			UInt32 mask = (UInt32)(1 << bitNumber);
			return (value & mask) != 0;
		}

		public static UInt32 SetBit(this UInt32 value, int bitNumber, bool bVal)
		{
			UInt32 mask = (UInt32)(1 << bitNumber);
			return  (bVal) ? value | mask : value & ~mask;
		}

		public static bool GetBit(this UInt64 value, int bitNumber)
		{
			UInt64 mask = (UInt64)(1 << bitNumber);
			return (value & mask) != 0;
		}

		public static UInt64 SetBit(this UInt64 value, int bitNumber, bool bVal)
		{
			UInt64 mask = (UInt64)(1 << bitNumber);
			return (bVal) ? value | mask : value & ~mask;
		}

		public static bool Contains(this StringBuilder sb, int offset, string value)
		{
			if (value.IsNullOrEmpty() || sb.Length == 0)
				return false;

			var match = false;
			for (var i = offset; i <= sb.Length - value.Length; i++)
			{
				//if (Match(sb, i, value))
				//  return true;

				for (var j = 0; j < value.Length; j++)
				{
					match = sb[j + i] == value[j];
					if (!match)
						break;
				}
				if (match)
					break;
			}
			return match;
		}

		public static byte LSB(this UInt16 iVal) { return (byte)((iVal >> 0) & 0xff); }
		public static byte MSB(this UInt16 iVal) { return (byte)((iVal >> 8) & 0xff); }

		public static byte LSB(this Int16 iVal) { return (byte)((iVal >> 0) & 0xff); }
		public static byte MSB(this Int16 iVal) { return (byte)((iVal >> 8) & 0xff); }

		public static byte Byte0(this UInt32 iVal) { return (byte)((iVal >> 0) & 0xff); }
		public static byte Byte1(this UInt32 iVal) { return (byte)((iVal >>  8) & 0xff); }
		public static byte Byte2(this UInt32 iVal) { return (byte)((iVal >> 16) & 0xff); }
		public static byte Byte3(this UInt32 iVal) { return (byte)((iVal >> 24) & 0xff); }

		public static byte Byte0(this Int32 iVal) { return (byte)((iVal >> 0) & 0xff); }
		public static byte Byte1(this Int32 iVal) { return (byte)((iVal >> 8) & 0xff); }
		public static byte Byte2(this Int32 iVal) { return (byte)((iVal >> 16) & 0xff); }
		public static byte Byte3(this Int32 iVal) { return (byte)((iVal >> 24) & 0xff); }

	}

}