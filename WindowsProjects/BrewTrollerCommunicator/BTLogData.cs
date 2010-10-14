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
	public class BTLogData : IFormattable, IBTDataClass
	{

		public BTLogData()
		{
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
			return;
		}

		public byte EmitToBinary(int schema, byte[] cmdBuf, byte offset)
		{
			throw new NotImplementedException();
		}

		public override string ToString()
		{
			return String.Format("BT Log Data: ");
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

