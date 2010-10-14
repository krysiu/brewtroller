/*
	Copyright (C) 2010, Tom Harkaway, TL Systems, LLC (tlsystems_AT_comcast_DOT_net)

	BeerXMLSupportLibrary is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	BeerXMLSupportLibrary is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with BTSerialComTester.  If not, see <http://www.gnu.org/licenses/>.
*/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using System.IO;

namespace BeerXMLSupportLibrary
{
	public enum MessageType
	{
		Information,
		Warning,
		Error
	}

	public class Message
	{
		public MessageType Type { get; set; }
		public string Text { get; set; }
	}

	public static class ExensionMethods
	{
		public static XElement LoadElementFromString(this XElement element, string xmlTex)
		{
			using (TextReader tr = new StringReader(xmlTex))
			{
				element = XElement.Load(tr);
			}

			return element;
		}

		public static bool IsNullOrEmpty(this string str)
		{
			return String.IsNullOrEmpty(str);
		}

		public static bool IsNumeric(this string str)
		{
			UInt64 ulVal;
			return UInt64.TryParse(str, out ulVal);
		}

		public static string RemoveBlanks(this IEnumerable<char> str)
		{
			StringBuilder sb = new StringBuilder();
			foreach (char ch in str)
			{
				if (ch != ' ')
					sb.Append(ch);
			}
			return sb.ToString();
		}

		public static string RemoveNumericChars(this IEnumerable<char> str)
		{
			StringBuilder sb = new StringBuilder();
			const string numericChars = "0123456789.+- ";
			foreach (char ch in str)
			{
				if (!numericChars.Contains(ch))
					sb.Append(ch);
			}
			return sb.ToString();
		}

		public static string ParseOffUnits(this string str)
		{
			const string numericChars = "0123456789.+- ";
			for (int i = 0; i < str.Length; i++)
			{
				if (numericChars.Contains(str[i]))
					continue;

				return str.Substring(i).Trim();
			}
			return String.Empty;
		}

	}

}
