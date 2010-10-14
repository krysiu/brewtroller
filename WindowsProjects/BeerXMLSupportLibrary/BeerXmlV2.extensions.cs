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
using System.Xml.Serialization;
using System.IO;

namespace BeerXMLSupportLibrary
{
	public partial class beer_xml
	{
		public beer_xml()
		{
			Item = new beer_xmlRecipes();
		}

		public beer_xml (beer_xml beerXml)
		{
			version = beerXml.version;
			Item = beerXml.Item;
		}

		/// <summary> Save beer_xml to a file </summary>
		/// <param name="filePath">Fully qualified file name</param>
		/// 
		public virtual void Save(string filePath)
		{
			version = 2.07m;

			XmlSerializer serializer = new XmlSerializer(typeof(beer_xml));

			// Write the XML file.
			if (!filePath.ToLower().EndsWith(".xml"))
				filePath += ".xml";
			Stream writer = new FileStream(filePath, FileMode.Create);

			// Deserialize the content of the file into a new beer_xml object.
			serializer.Serialize(writer, this);

			writer.Close();
		}

		/// <summary> Load beer_xml from a file </summary>
		/// <param name="filePath">Fully qualified file name</param>
		/// 
		public virtual void Load(string filePath)
		{
			XmlSerializer serializer = new XmlSerializer(typeof(beer_xml));

			// Deserialize the content of the file into a object.
			StreamReader reader = new StreamReader(filePath);
			beer_xml xmlRecipe = (beer_xml)serializer.Deserialize(reader);
			reader.Close();

			version = xmlRecipe.version;
			Item = xmlRecipe.Item;
		}

		public virtual RecipeType GetXmlRecipe(int index)
		{
			return ((beer_xmlRecipes)Item).recipe[index];
		}
	}

	public partial class RecipeType
	{
		public DateTime? DateCreated
		{
			get
			{
				DateTime dtVal;
				if (DateTime.TryParse(created, out dtVal))
					return dtVal;
				else
					return null;
			}
			set {
				created = value.HasValue ? value.Value.ToString("MMMM d, yyyy") 
										 : String.Empty;
			}
		}

	//  public BindingList<string> RecipeTypeList = new BindingList<string> { "Extract", "Partial Mash", "All Grain" };
	//  public int RecipeTypeIndex
	//  {
	//    get { return (int)type; }
	//    set { type = (RecipeTypeType)value; }
	//  }

	//  public List<string> IBUMethodTypeList = new List<string> { "Rager", "Tinseth", "Garetz", "Other" };
	//  public List<string> StyleCategoryList = new List<string> { "Lager", "Ale", "Mead", "Wheat", "Mixed", "Cider" };
	//  public List<string> ColorUnitTypeList = new List<string> { "Specific Gravity", "Plato" };

	//  public List<string> TempUnitTypeList = new List<string> { "C", "F" };
	//  public List<string> TimeUnitTypeList = new List<string> { "Second", "Minute", "Hour", "Day", "Week", "Month", "Year" };
	//  public List<string> VolumeUnitTypeList = new List<string> { "mL", "L", "Teaspoon", "Tablespoon", "Ounce", "Cup", "Pint", "Quart", "Gallon", "Barrel" };
	//  public List<string> MassUnitTypeList = new List<string> { "mg", "g", "kg", "Pounds", "Ounce" };
	//  public List<string> DenisityMassUnitTypeList = new List<string> { "mg", "g", "kg", "Pounds", "Ounce" };

	}

  // ToDo: Add IFormatable to xml types


	public partial class TemperatureType
	{
		private const char DegreeSymbol = (char)176;
		
		public override string ToString()
		{
			return String.Format("{0}{1} {2}", Value, DegreeSymbol, degrees);
		}
	}

	public partial class VolumeType
	{
		public override string ToString()
		{
			return Value + " " + volume;
		}
	}

	public partial class DensityType
	{
		public override string ToString()
		{
			return Value + " " + density;
		}
	}

	public partial class MassType
	{
		public override string ToString()
		{
			return Value + " " + mass;
		}
	}

	public partial class TimeType
	{
		public override string ToString()
		{
			return Value + " " + duration;
		}
	}

	public partial class IBUEstimateType
	{
		public override string ToString()
		{
			return Value + " " + method;
		}
	}

	public partial class ColorType
	{
		public override string ToString()
		{
			return Value + " " + scale;
		}
	}

	public partial class StyleType
	{
		public override string ToString()
		{
			return String.Format("{0}: {1}({2}; {3}, {4}, {5}", name, category, category_number, style_letter, style_guide, type);
		}
	}

}
