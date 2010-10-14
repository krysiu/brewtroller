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
using System.Xml.Linq;

namespace BeerXMLSupportLibrary
{
	public class BeerXmlV1
	{
		public static List<Message> Messages = new List<Message>();

		public static beer_xml Load(XDocument v1XmlDocument)
		{
			var beerXmlV2 = new beer_xml();

			List<RecipeType> recipeList = new List<RecipeType>();

			var nameList = GetRecipeNames(v1XmlDocument);
			foreach (string recipeName in nameList)
			{
				RecipeType xmlRecipe = new RecipeType();
				if (ImportV1BeerXml(beerXmlV2, v1XmlDocument, recipeName, xmlRecipe))
					recipeList.Add(xmlRecipe);
			}

			var xmlRecipes = new beer_xmlRecipes();
			xmlRecipes.recipe = recipeList.ToArray();

			beerXmlV2.Item = xmlRecipes;

			return beerXmlV2;
		}

		public static List<string> GetRecipeNames(XDocument v1XmlDocument)
		{
			var nameList = new List<string>();

			try
			{
				var query = from recipe in v1XmlDocument.Descendants("RECIPE")
										select recipe.Element("NAME").Value;

				foreach (var recipeName in query)
					nameList.Add(recipeName);
			}
			catch (Exception)
			{
				return null;
			}

			return nameList;
		}

		public static bool ImportV1BeerXml(beer_xml beerXMLv2, XDocument v1XmlDocument, string recipeName, RecipeType beerXmlRecipe)
		{
			// find the selected recipe
			var qryRecipe = from rcp in v1XmlDocument.Descendants("RECIPE")
											where rcp.Element("NAME").Value == recipeName
											select rcp;
			XElement xmlRecipe = qryRecipe.First();

			if (xmlRecipe == null)
				return false;

			ImportBasicRecipeInfo(beerXMLv2, xmlRecipe, beerXmlRecipe);

			// get the ingredients

			beerXmlRecipe.ingredients = new RecipeTypeIngredients();

			ImportFermentables(beerXMLv2, xmlRecipe, beerXmlRecipe);
			ImportHops(beerXMLv2, xmlRecipe, beerXmlRecipe);
			ImportMiscs(beerXMLv2, xmlRecipe, beerXmlRecipe);
			ImportYeasts(beerXMLv2, xmlRecipe, beerXmlRecipe);
			ImportWaters(beerXMLv2, xmlRecipe, beerXmlRecipe);
			ImportMashProcedure(beerXMLv2, xmlRecipe, beerXmlRecipe);


			return true;
		}
    

		private static void ImportBasicRecipeInfo(beer_xml beerXMLv2, XElement xmlRecipe, RecipeType xmlBeerRecipe)
		{
			string str;

			xmlBeerRecipe.name = GetXmlString(xmlRecipe, "NAME", true);

			str = GetXmlString(xmlRecipe, "TYPE", true);
			switch (str.RemoveBlanks().ToLower().Trim())
			{
				case "extract":
					xmlBeerRecipe.type = RecipeTypeType.extract;
					break;
				case "partialmash":
					xmlBeerRecipe.type = RecipeTypeType.partialmash;
					break;
				case "allgrain":
					xmlBeerRecipe.type = RecipeTypeType.allgrain;
					break;
				default:
					Messages.Add(new Message
					{
						Type = MessageType.Error,
						Text = String.Format("Required String element '{0}' is missing.", "TYPE")
					});
					break;
			}

			xmlBeerRecipe.author = GetXmlString(xmlRecipe, "BREWER", true);
			xmlBeerRecipe.coauthor = GetXmlString(xmlRecipe, "ASST_BREWER", false);
			xmlBeerRecipe.created = GetXmlString(xmlRecipe, "DATE", false);
			xmlBeerRecipe.batch_size = GetXmlVolumeType(xmlRecipe, "BATCH_SIZE", true, VolumeUnitType.l);
			xmlBeerRecipe.boil_size = GetXmlVolumeType(xmlRecipe, "BOIL_SIZE", true, VolumeUnitType.l);
			xmlBeerRecipe.boil_time = GetXmlTimeType(xmlRecipe, "BOIL_TIME", true, TimeUnitType.min);

			if (IsEfficiencyRequired(xmlBeerRecipe.type))
			{
				xmlBeerRecipe.efficiencySpecified = xmlRecipe.Element("EFFICIENCY") != null;
				if (xmlBeerRecipe.efficiencySpecified)
					xmlBeerRecipe.efficiency = GetXmlDecimal(xmlRecipe, "EFFICIENCY", true);
				else
				{
					Messages.Add(new Message
					{
						Type = MessageType.Error,
						Text = String.Format("Required String element '{0}' is missing.", "TYPE")
					});
				}
			}

			ImportStyle(beerXMLv2, xmlRecipe, xmlBeerRecipe);

			xmlBeerRecipe.notes = GetXmlString(xmlRecipe, "NOTES", false);
			xmlBeerRecipe.original_gravity = GetXmlDensityType(xmlRecipe, "OG", false, DensityUnitType.sg);
			xmlBeerRecipe.final_gravity = GetXmlDensityType(xmlRecipe, "FG", false, DensityUnitType.sg);

			xmlBeerRecipe.alcohol_by_volumeSpecified = xmlRecipe.Element("ABV") != null;
			if (xmlBeerRecipe.alcohol_by_volumeSpecified)
			{
				xmlBeerRecipe.alcohol_by_volume = GetXmlPercentage(xmlRecipe, "ABV", false);
			}

			string ibuMethod = GetXmlString(xmlRecipe, "IBU_METHOD", false);
			if (!String.IsNullOrEmpty(ibuMethod))
			{
				var ibuValue = GetXmlString(xmlRecipe, "IBU", false);
				if (!ibuValue.IsNullOrEmpty())
					xmlBeerRecipe.ibu_estimate = GetXmlIbuEstimateType(ibuValue + " " + ibuMethod, "IBU", IBUMethodType.Rager);
			}

			xmlBeerRecipe.color_estimate = GetXmlColorType(xmlRecipe, "EST_COLOR", false, ColorUnitType.SRM);

			xmlBeerRecipe.carbonationSpecified = xmlRecipe.Element("CARBONATION") != null;
			if (xmlBeerRecipe.carbonationSpecified)
			{
				xmlBeerRecipe.carbonation = GetXmlDecimal(xmlRecipe, "CARBONATION", true);
			}

			if (xmlRecipe.Element("PRIMARY_AGE") != null)
			{
				if (xmlBeerRecipe.fermentation_stages == null)
					xmlBeerRecipe.fermentation_stages = new RecipeTypeFermentation_stages();
				xmlBeerRecipe.fermentation_stages.primary = new FermentationStageType();
				xmlBeerRecipe.fermentation_stages.primary.aging = GetXmlTimeType(xmlRecipe, "PRIMARY_AGE", true, TimeUnitType.day);
				xmlBeerRecipe.fermentation_stages.primary.temperature = GetXmlTemperatureType(xmlRecipe, "PRIMARY_TEMP", true,
																																											TemperatureUnitType.C);
			}
			if (xmlRecipe.Element("SECONDARY_AGE") != null)
			{
				if (xmlBeerRecipe.fermentation_stages == null)
					xmlBeerRecipe.fermentation_stages = new RecipeTypeFermentation_stages();
				xmlBeerRecipe.fermentation_stages.secondary = new FermentationStageType();
				xmlBeerRecipe.fermentation_stages.secondary.aging = GetXmlTimeType(xmlRecipe, "SECONDARY_AGE", true,
																																					 TimeUnitType.day);
				xmlBeerRecipe.fermentation_stages.secondary.temperature = GetXmlTemperatureType(xmlRecipe, "SECONDARY_TEMP", true,
																																												TemperatureUnitType.C);
			}
			if (xmlRecipe.Element("TERTIARY_AGE") != null)
			{
				if (xmlBeerRecipe.fermentation_stages == null)
					xmlBeerRecipe.fermentation_stages = new RecipeTypeFermentation_stages();
				xmlBeerRecipe.fermentation_stages.tertiary = new FermentationStageType();
				xmlBeerRecipe.fermentation_stages.tertiary.aging = GetXmlTimeType(xmlRecipe, "TERTIARY_AGE", true, TimeUnitType.day);
				xmlBeerRecipe.fermentation_stages.tertiary.temperature = GetXmlTemperatureType(xmlRecipe, "TERTIARY_TEMP", true,
																																											 TemperatureUnitType.C);
			}
			if (xmlRecipe.Element("AGE") != null)
			{
				if (xmlBeerRecipe.fermentation_stages == null)
					xmlBeerRecipe.fermentation_stages = new RecipeTypeFermentation_stages();
				xmlBeerRecipe.fermentation_stages.conditioning = new FermentationStageType();
				xmlBeerRecipe.fermentation_stages.conditioning.aging = GetXmlTimeType(xmlRecipe, "AGE", true, TimeUnitType.day);
				xmlBeerRecipe.fermentation_stages.conditioning.temperature = GetXmlTemperatureType(xmlRecipe, "AGE_TEMP", true,
																																													 TemperatureUnitType.C);
			}
			ValidateFementationStages(xmlBeerRecipe.fermentation_stages);

			if (xmlRecipe.Element("TASTE_NOTES") != null)
			{
				xmlBeerRecipe.taste = new RecipeTypeTaste();
				xmlBeerRecipe.taste.notes = GetXmlString(xmlRecipe, "TASTE_NOTES", true);
				xmlBeerRecipe.taste.rating = GetXmlDecimal(xmlRecipe, "TASTE_RATING", true);
			}

			str = GetXmlString(xmlRecipe, "CALORIES", false);
			if (!str.IsNullOrEmpty())
			{
				str = str.Replace("cal/pint", null).Replace("calories/pint", null).ToLower().Trim();
				decimal decVal;
				xmlBeerRecipe.calories_per_pintSpecified = Decimal.TryParse(str, out decVal);
				if (xmlBeerRecipe.calories_per_pintSpecified)
				{
					xmlBeerRecipe.calories_per_pint = decVal;
				}
			}
		}

		private static void ImportStyle(beer_xml beerXMLv2, XElement xmlRecipe, RecipeType xmlBeerRecipe)
		{
			string str;

			var qry = from xmlElements in xmlRecipe.Descendants("STYLE")
								select xmlElements;

			if (qry.Count() > 0)
			{
				var xmlElement = qry.First();
				xmlBeerRecipe.style = new RecipeStyleType();

				xmlBeerRecipe.style.name = GetXmlString(xmlElement, "NAME", true);
				xmlBeerRecipe.style.category = GetXmlString(xmlElement, "CATEGORY", true);
				xmlBeerRecipe.style.category_number = GetXmlString(xmlElement, "CATEGORY_NUMBER", true);
				xmlBeerRecipe.style.style_letter = GetXmlString(xmlElement, "STYLE_LETTER", true);
				xmlBeerRecipe.style.style_guide = GetXmlString(xmlElement, "STYLE_GUIDE", true);

				str = GetXmlString(xmlElement, "TYPE", true);
				switch (str.RemoveBlanks().ToLower().Trim())
				{
					case "lager":
						xmlBeerRecipe.style.type = StyleCategories.lager;
						break;
					case "ale":
						xmlBeerRecipe.style.type = StyleCategories.ale;
						break;
					case "mead":
						xmlBeerRecipe.style.type = StyleCategories.mead;
						break;
					case "wheat":
						xmlBeerRecipe.style.type = StyleCategories.wheat;
						break;
					case "mixed":
						xmlBeerRecipe.style.type = StyleCategories.mixed;
						break;
					case "cider":
						xmlBeerRecipe.style.type = StyleCategories.cider;
						break;
					default:
						Messages.Add(new Message
						{
							Type = MessageType.Error,
							Text = String.Format("Required String element '{0}' is missing.", "STYLE")
						});
						break;
				}
			}
		}

		private static void ImportFermentables(beer_xml beerXMLv2, XElement xmlRecipe, RecipeType xmlBeerRecipe)
		{
			string str;
			var fermList = new List<FermentableAdditionTypeAddition>();

			var qry = from xmlElements in xmlRecipe.Descendants("FERMENTABLE")
								select xmlElements;

			if (qry.Count() == 0)
			{
				Messages.Add(new Message { Type = MessageType.Error, Text = "No Fermentables found in input file." });
				return;
			}

			foreach (var xmlElement in qry)
			{
				var xmlBeerFermentable = new FermentableAdditionTypeAddition();

				xmlBeerFermentable.name = GetXmlString(xmlElement, "NAME", true);

				str = GetXmlString(xmlElement, "TYPE", true);
				switch (str.RemoveBlanks().ToLower().Trim())
				{
					case "adjunct":
						xmlBeerFermentable.type = FermentableBaseType.adjunct;
						break;
					case "dryextract":
						xmlBeerFermentable.type = FermentableBaseType.dryextract;
						break;
					case "extract":
						xmlBeerFermentable.type = FermentableBaseType.extract;
						break;
					case "grain":
						xmlBeerFermentable.type = FermentableBaseType.grain;
						break;
					case "sugar":
						xmlBeerFermentable.type = FermentableBaseType.sugar;
						break;
					default:
						Messages.Add(new Message
						{
							Type = MessageType.Error,
							Text = String.Format("Required String element '{0}' is missing.", "FERMENTABLE")
						});
						break;
				}

				xmlBeerFermentable.color = GetXmlColorType(xmlElement, "COLOR", true, ColorUnitType.L);

				xmlBeerFermentable.origin = GetXmlString(xmlElement, "ORIGIN", false);
				xmlBeerFermentable.supplier = GetXmlString(xmlElement, "SUPPLIER", false);

				xmlBeerFermentable.amount = GetXmlMassType(xmlElement, "AMOUNT", true, MassUnitType.kg);

				xmlBeerFermentable.add_after_boilSpecified = xmlElement.Element("ADD_AFTER_BOIL") != null;
				if (xmlBeerFermentable.add_after_boilSpecified)
					xmlBeerFermentable.add_after_boil = GetXmlBoolean(xmlElement, "ADD_AFTER_BOIL", true);

				fermList.Add(xmlBeerFermentable);
			}

			xmlBeerRecipe.ingredients.grain_bill = fermList.ToArray();
		}

		private static void ImportHops(beer_xml beerXMLv2, XElement xmlRecipe, RecipeType xmlBeerRecipe)
		{
			var qry = from hops in xmlRecipe.Descendants("HOP")
								select hops;

			if (qry.Count() == 0)
			{
				Messages.Add(new Message { Type = MessageType.Error, Text = "No Hops found in input file." });
				return;
			}

			var hopsList = new List<HopAdditionTypeAddition>();

			string str;

			foreach (var xmlElement in qry)
			{
				var xmlBeerHop = new HopAdditionTypeAddition();

				xmlBeerHop.name = GetXmlString(xmlElement, "NAME", true);
				xmlBeerHop.origin = GetXmlString(xmlElement, "ORIGIN", false);
				xmlBeerHop.alpha_acid_units = GetXmlDecimal(xmlElement, "ALPHA", true);

				xmlBeerHop.beta_acid_unitsSpecified = xmlElement.Element("BETA") != null;
				if (xmlBeerHop.beta_acid_unitsSpecified)
					xmlBeerHop.beta_acid_units = GetXmlDecimal(xmlElement, "BETA", true);

				if (xmlElement.Element("FORM") != null)
				{
					str = GetXmlString(xmlElement, "FORM", true);
					switch (str.RemoveBlanks().ToLower().Trim())
					{
						case "leaf":
							xmlBeerHop.form = HopAdditionTypeAdditionForm.leaf;
							break;
						case "pellet":
							xmlBeerHop.form = HopAdditionTypeAdditionForm.pellet;
							break;
						case "plug":
							xmlBeerHop.form = HopAdditionTypeAdditionForm.plug;
							break;
						default:
							Messages.Add(new Message
							{
								Type = MessageType.Error,
								Text = String.Format("Required String element '{0}' is missing.", "FORM")
							});
							break;
					}
				}
				//else
				//{
				//  xmlBeerHop.form = null;
				//}

				str = GetXmlString(xmlElement, "USE", true);
				switch (str.RemoveBlanks().ToLower().Trim())
				{
					case "boil":
						xmlBeerHop.use = HopAdditionTypeAdditionUse.boil;
						break;
					case "dryhop":
						xmlBeerHop.use = HopAdditionTypeAdditionUse.dryhop;
						break;
					case "firstwort":
						xmlBeerHop.use = HopAdditionTypeAdditionUse.firstwort;
						break;
					case "hopback":
						xmlBeerHop.use = HopAdditionTypeAdditionUse.hopback;
						break;
					case "mash":
						xmlBeerHop.use = HopAdditionTypeAdditionUse.mash;
						break;
					case "continuousboiladdition":
						xmlBeerHop.use = HopAdditionTypeAdditionUse.continuousboiladdition;
						break;
					default:
						Messages.Add(new Message
						{
							Type = MessageType.Error,
							Text = String.Format("Required String element '{0}' is missing.", "USE")
						});
						break;
				}

				xmlBeerHop.amount = GetXmlMassType(xmlElement, "AMOUNT", true, MassUnitType.kg);
				xmlBeerHop.time = GetXmlTimeType(xmlElement, "TIME", true, TimeUnitType.min);

				hopsList.Add(xmlBeerHop);
			}

			xmlBeerRecipe.ingredients.hop_bill = hopsList.ToArray();
		}

		private static void ImportMiscs(beer_xml beerXMLv2, XElement xmlRecipe, RecipeType xmlBeerRecipe)
		{
			var qry = from xmlElements in xmlRecipe.Descendants("MISC")
								select xmlElements;

			if (qry.Count() == 0)
			{
				Messages.Add(new Message { Type = MessageType.Error, Text = "No Yeasts found in input file." });
				return;
			}

			string str;
			List<MiscellaneousAdditionTypeAddition> miscList = new List<MiscellaneousAdditionTypeAddition>();

			foreach (var xmlElement in qry)
			{
				var xmlBeerMisc = new MiscellaneousAdditionTypeAddition();

				xmlBeerMisc.name = GetXmlString(xmlElement, "NAME", true);

				str = GetXmlString(xmlElement, "TYPE", true);
				switch (str.RemoveBlanks().ToLower().Trim())
				{
					case "spice":
						xmlBeerMisc.type = MiscellaneousBaseType.spice;
						break;
					case "fining":
						xmlBeerMisc.type = MiscellaneousBaseType.fining;
						break;
					case "wateragent":
						xmlBeerMisc.type = MiscellaneousBaseType.wateragent;
						break;
					case "herb":
						xmlBeerMisc.type = MiscellaneousBaseType.herb;
						break;
					case "fruit":
						xmlBeerMisc.type = MiscellaneousBaseType.fruit;
						break;
					case "flavor":
						xmlBeerMisc.type = MiscellaneousBaseType.flavor;
						break;
					case "other":
						xmlBeerMisc.type = MiscellaneousBaseType.other;
						break;
					default:
						Messages.Add(new Message
						{
							Type = MessageType.Error,
							Text = String.Format("Required String element '{0}' is missing.", "FORM")
						});
						break;
				}
				str = GetXmlString(xmlElement, "USE", true);
				switch (str.RemoveBlanks().ToLower().Trim())
				{
					case "boil":
						xmlBeerMisc.use = MiscellaneousBaseUse.boil;
						break;
					case "mash":
						xmlBeerMisc.use = MiscellaneousBaseUse.mash;
						break;
					case "secondary":
						xmlBeerMisc.use = MiscellaneousBaseUse.secondary;
						break;
					case "bottling":
						xmlBeerMisc.use = MiscellaneousBaseUse.bottling;
						break;
					default:
						Messages.Add(new Message
						{
							Type = MessageType.Error,
							Text = String.Format("Required String element '{0}' is missing.", "TYPE")
						});
						break;
				}

				if (GetXmlBoolean(xmlElement, "AMOUNT_IS_WEIGHT", false))
					xmlBeerMisc.Item = GetXmlMassType(xmlElement, "AMOUNT", true, MassUnitType.kg);
				else
					xmlBeerMisc.Item = GetXmlVolumeType(xmlElement, "AMOUNT", true, VolumeUnitType.l);

				xmlBeerMisc.time = GetXmlTimeType(xmlElement, "TIME", true, TimeUnitType.min);

				miscList.Add(xmlBeerMisc);
			}

			xmlBeerRecipe.ingredients.adjuncts = miscList.ToArray();
		}

		private static void ImportYeasts(beer_xml beerXMLv2, XElement xmlRecipe, RecipeType xmlBeerRecipe)
		{
			var qry = from xmlElements in xmlRecipe.Descendants("YEAST")
								select xmlElements;

			if (qry.Count() == 0)
			{
				Messages.Add(new Message { Type = MessageType.Error, Text = "No Yeasts found in input file." });
				return;
			}

			var yeastList = new List<YeastAdditionTypeAddition>();

			string str;

			foreach (var xmlElement in qry)
			{
				var xmlBeerYeast = new YeastAdditionTypeAddition();

				xmlBeerYeast.name = GetXmlString(xmlElement, "NAME", true);

				str = GetXmlString(xmlElement, "FORM", true);
				switch (str.RemoveBlanks().ToLower().Trim())
				{
					case "liquid":
						xmlBeerYeast.form = CultureBaseForm.liquid;
						break;
					case "dry":
						xmlBeerYeast.form = CultureBaseForm.dry;
						break;
					case "slant":
						xmlBeerYeast.form = CultureBaseForm.slant;
						break;
					case "culture":
						xmlBeerYeast.form = CultureBaseForm.culture;
						break;
					default:
						Messages.Add(new Message
						{
							Type = MessageType.Error,
							Text = String.Format("Required String element '{0}' is missing.", "FORM")
						});
						break;
				}

				str = GetXmlString(xmlElement, "TYPE", true);
				switch (str.RemoveBlanks().ToLower().Trim())
				{
					case "ale":
						xmlBeerYeast.type = CultureBaseType.ale;
						break;
					case "lager":
						xmlBeerYeast.type = CultureBaseType.lager;
						break;
					case "wheat":
						xmlBeerYeast.type = CultureBaseType.wheat;
						break;
					case "wine":
						xmlBeerYeast.type = CultureBaseType.wine;
						break;
					case "champagne":
						xmlBeerYeast.type = CultureBaseType.champagne;
						break;
					default:
						Messages.Add(new Message
						{
							Type = MessageType.Error,
							Text = String.Format("Required String element '{0}' is missing.", "TYPE")
						});
						break;
				}

				xmlBeerYeast.laboratory = GetXmlString(xmlElement, "LABORATORY", false);
				xmlBeerYeast.product_id = GetXmlString(xmlElement, "PRODUCT_ID", false);

				if (GetXmlBoolean(xmlElement, "AMOUNT_IS_WEIGHT", false))
					xmlBeerYeast.Item = GetXmlMassType(xmlElement, "AMOUNT", false, MassUnitType.kg);
				else
					xmlBeerYeast.Item = GetXmlVolumeType(xmlElement, "AMOUNT", false, VolumeUnitType.l);

				xmlBeerYeast.times_cultured = GetXmlString(xmlElement, "TIMES_CULTURED", false);

				xmlBeerYeast.add_to_secondarySpecified = xmlElement.Element("ADD_TO_SECONDARY") != null;
				if (xmlBeerYeast.add_to_secondarySpecified)
					xmlBeerYeast.add_to_secondary = GetXmlBoolean(xmlElement, "ADD_TO_SECONDARY", true);

				yeastList.Add(xmlBeerYeast);
			}

			xmlBeerRecipe.ingredients.yeast_additions = yeastList.ToArray();
		}

		private static void ImportWaters(beer_xml beerXMLv2, XElement xmlRecipe, RecipeType xmlBeerRecipe)
		{
			var qry = from xmlElements in xmlRecipe.Descendants("WATER")
								select xmlElements;

			if (qry.Count() == 0)
			{
				Messages.Add(new Message { Type = MessageType.Error, Text = "No Waters found in input file." });
				return;
			}

			var waterList = new List<WaterAdditionTypeAddition>();

			foreach (var xmlElement in qry)
			{
				var xmlBeerWater = new WaterAdditionTypeAddition();

				xmlBeerWater.name = GetXmlString(xmlElement, "NAME", true);
				xmlBeerWater.calcium = GetXmlDecimal(xmlElement, "CALCIUM", true);
				xmlBeerWater.bicarbonate = GetXmlDecimal(xmlElement, "BICARBONATE", true);
				xmlBeerWater.sulfate = GetXmlDecimal(xmlElement, "SULFATE", true);
				xmlBeerWater.chloride = GetXmlDecimal(xmlElement, "CHLORIDE", true);
				xmlBeerWater.sodium = GetXmlDecimal(xmlElement, "SODIUM", true);
				xmlBeerWater.magnesium = GetXmlDecimal(xmlElement, "MAGNESIUM", true);
				xmlBeerWater.amount = GetXmlVolumeType(xmlElement, "AMOUNT", true, VolumeUnitType.l);

				waterList.Add(xmlBeerWater);
			}

			xmlBeerRecipe.ingredients.water_profile = waterList.ToArray();
		}

		private static void ImportMashProcedure(beer_xml beerXMLv2, XElement xmlRecipe, RecipeType xmlBeerRecipe)
		{
			var qry = from xmlElements in xmlRecipe.Descendants("MASH")
								select xmlElements;

			if (qry.Count() > 0)
			{
				var xmlElement = qry.First();
				var xmlBeerMashProcedure = new MashProcedureType();

				xmlBeerMashProcedure.name = GetXmlString(xmlElement, "NAME", true);
				xmlBeerMashProcedure.grain_temperature = GetXmlTemperatureType(xmlElement, "GRAIN_TEMP", true, TemperatureUnitType.C);
				xmlBeerMashProcedure.sparge_temperature = GetXmlTemperatureType(xmlElement, "SPARGE_TEMP", false,
																																				TemperatureUnitType.C);

				xmlBeerMashProcedure.pHSpecified = xmlElement.Element("PH") != null;
				if (xmlBeerMashProcedure.pHSpecified)
					xmlBeerMashProcedure.pH = GetXmlDecimal(xmlElement, "PH", true);

				xmlBeerMashProcedure.notes = GetXmlString(xmlElement, "NOTES", true);

				var mashStepList = ImportMashSteps(beerXMLv2, xmlElement);
				xmlBeerMashProcedure.mash_steps = mashStepList.ToArray();

				xmlBeerRecipe.mash = xmlBeerMashProcedure;
			}
		}

		private static List<MashStepType> ImportMashSteps(beer_xml beerXMLv2, XElement xmlRecipe)
		{
			var qry = from xmlElements in xmlRecipe.Descendants("MASH_STEP")
								select xmlElements;

			var mashStepList = new List<MashStepType>();

			if (qry.Count() == 0)
			{
				Messages.Add(new Message { Type = MessageType.Error, Text = "No Mash Steps found in input file." });
				return mashStepList;
			}

			string str;

			foreach (var xmlElement in qry)
			{
				var xmlMashStep = new MashStepType();

				xmlMashStep.name = GetXmlString(xmlElement, "NAME", true);

				str = GetXmlString(xmlElement, "TYPE", true);
				switch (str.RemoveBlanks().ToLower().Trim())
				{
					case "infusion":
						xmlMashStep.type = MashStepTypeType.infusion;
						break;
					case "temperature":
						xmlMashStep.type = MashStepTypeType.temperature;
						break;
					case "decoction":
						xmlMashStep.type = MashStepTypeType.decoction;
						break;
					default:
						Messages.Add(new Message
						{
							Type = MessageType.Error,
							Text = String.Format("Required String element '{0}' is missing.", "TYPE")
						});
						break;
				}

				if (xmlMashStep.type == MashStepTypeType.infusion)
					xmlMashStep.infuse_amount = GetXmlVolumeType(xmlElement, "INFUSE_AMOUNT", true, VolumeUnitType.l);
				else if (xmlMashStep.type == MashStepTypeType.temperature)
					xmlMashStep.infuse_amount = GetXmlVolumeType(xmlElement, "INFUSE_AMOUNT", false, VolumeUnitType.l);

				xmlMashStep.step_temperature = GetXmlTemperatureType(xmlElement, "STEP_TEMP", true, TemperatureUnitType.C);
				xmlMashStep.step_time = GetXmlTimeType(xmlElement, "STEP_TIME", true, TimeUnitType.min);
				xmlMashStep.ramp_time = GetXmlTimeType(xmlElement, "RAMP_TIME", true, TimeUnitType.min);
				xmlMashStep.end_temperature = GetXmlTemperatureType(xmlElement, "END_TEMP", true, TemperatureUnitType.C);

				xmlMashStep.description = GetXmlString(xmlElement, "DESCRIPTION", false);

				xmlMashStep.water_grain_ratioSpecified = xmlElement.Element("WATER_GRAIN_RATIO") != null;
				if (xmlMashStep.water_grain_ratioSpecified)
					xmlMashStep.water_grain_ratio = GetXmlDecimal(xmlElement, "WATER_GRAIN_RATIO", true);

				xmlMashStep.decoction_amount = GetXmlVolumeType(xmlElement, "DECOCTION_AMT", false, VolumeUnitType.l);
				xmlMashStep.infuse_temperature = GetXmlTemperatureType(xmlElement, "INFUSE_TEMP", false, TemperatureUnitType.C);

				mashStepList.Add(xmlMashStep);
			}

			return mashStepList;
		}


		public static string GetXmlString(XElement xmlElement, string name, bool required)
		{
			if (xmlElement.Element(name) == null)
			{
				if (required)
					Messages.Add(new Message
					              	{Type = MessageType.Error, Text = String.Format("Required String element '{0}' is missing.", name)});
				return null;
			}

			return xmlElement.Element(name).Value;
		}

		public static decimal GetXmlDecimal(XElement xmlElement, string name, bool required)
		{
			if (xmlElement.Element(name) == null)
			{
				if (required)
					Messages.Add(new Message
					              	{Type = MessageType.Error, Text = String.Format("Required decimal element '{0}' is missing.", name)});
				return 0m;
			}

			string str = xmlElement.Element(name).Value;
			decimal decVal;

			if (str.IsNullOrEmpty() || !Decimal.TryParse(str, out decVal))
			{
				Messages.Add(new Message
				              	{Type = MessageType.Error, Text = String.Format("Required decimal element '{0}' is invalid.", name)});
				return 0m;
			}

			return decVal;
		}

		public static bool GetXmlBoolean(XElement xmlElement, string name, bool required)
		{
			if (xmlElement.Element(name) == null)
			{
				if (required)
					Messages.Add(new Message
					              	{Type = MessageType.Error, Text = String.Format("Required Boolean element '{0}' is missing.", name)});
				return false;
			}

			string str = xmlElement.Element(name).Value;
			switch (str.RemoveBlanks().ToLower().Trim())
			{
				case "f":
				case "false":
					return false;
				case "t":
				case "true":
					return true;
				default:
					Messages.Add(new Message {Type = MessageType.Error, Text = String.Format("Invalid Boolean value '{0}'.", str)});
					break;
			}

			return false;
		}

		public static decimal GetXmlPercentage(XElement xmlElement, string name, bool required)
		{
			if (xmlElement.Element(name) == null)
			{
				if (required)
					Messages.Add(new Message
					              	{
					              		Type = MessageType.Error,
					              		Text = String.Format("Required Percentage element '{0}' is missing.", name)
					              	});
				return 0;
			}

			string str = xmlElement.Element(name).Value.ToLower();
			str = str.Replace("%", null).Replace("percent", null).Trim();

			decimal decVal;

			if (str.IsNullOrEmpty() || !Decimal.TryParse(str, out decVal))
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Required Percentage element '{0}' is invalid.", name)
				              	});
				return 0m;
			}

			return decVal;
		}


		public static VolumeType GetXmlVolumeType(XElement xmlElement, string name, bool required, VolumeUnitType defaultUnits)
		{
			if (xmlElement.Element(name) == null)
			{
				if (required)
					Messages.Add(new Message
					              	{
					              		Type = MessageType.Error,
					              		Text = String.Format("Required VolumeType element '{0}' is missing.", name)
					              	});
				return null;
			}

			string str = xmlElement.Element(name).Value;
			decimal decVal;

			string strUnit = str.ParseOffUnits();
			if (strUnit != "mL" && strUnit != "L")
			{
				strUnit.ToLower();
				str = str.ToLower();
			}
			VolumeUnitType units = defaultUnits;
			try
			{
				// mL, ml, L, l, tsp, tbsp, ozfl, cup, pt, qt, gal, bbl, iozfl, ipt, iqt, igal,  ibbl, 
				if (!strUnit.IsNullOrEmpty())
					units = (VolumeUnitType) Enum.Parse(typeof (VolumeUnitType), strUnit);
			}
			catch
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid VolumeType '{0}' value or units is missing.", name)
				              	});
				return null;
			}
			if (!strUnit.IsNullOrEmpty())
				str = str.Replace(strUnit, null).Trim();

			if (str.IsNullOrEmpty() || !Decimal.TryParse(str, out decVal))
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid VolumeType '{0}' value or units is missing.", name)
				              	});
				return null;
			}

			return new VolumeType {volume = units, Value = decVal};
		}

		public static TimeType GetXmlTimeType(XElement xmlElement, string name, bool required, TimeUnitType defaultUnits)
		{
			if (xmlElement.Element(name) == null)
			{
				if (required)
					Messages.Add(new Message
					              	{
					              		Type = MessageType.Error,
					              		Text = String.Format("Required TimeType element '{0}' is missing.", name)
					              	});
				return null;
			}

			string str = xmlElement.Element(name).Value;
			decimal decVal;

			string strUnit = str.ParseOffUnits();
			TimeUnitType units = defaultUnits;
			try
			{
				// sec, min, hr, day, week, month, year, 
				if (!strUnit.IsNullOrEmpty())
					units = (TimeUnitType) Enum.Parse(typeof (TimeUnitType), strUnit);
			}
			catch
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid TimeType '{0}' value or units is missing.", name)
				              	});
				return null;
			}
			if (!strUnit.IsNullOrEmpty())
				str = str.Replace(strUnit, null).Trim();

			if (str.IsNullOrEmpty() || !Decimal.TryParse(str, out decVal))
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid TimeType '{0}' value or units is missing.", name)
				              	});
				return null;
			}

			return new TimeType {duration = units, Value = decVal};
		}

		public static DensityType GetXmlDensityType(XElement xmlElement, string name, bool required, DensityUnitType defaultUnits)
		{
			if (xmlElement.Element(name) == null)
			{
				if (required)
					Messages.Add(new Message
					              	{
					              		Type = MessageType.Error,
					              		Text = String.Format("Required DensityType element '{0}' is missing.", name)
					              	});
				return null;
			}

			string str = xmlElement.Element(name).Value;
			decimal decVal;

			string strUnit = str.ParseOffUnits();
			DensityUnitType units = defaultUnits;
			try
			{
				// sg, plato
				if (!strUnit.IsNullOrEmpty())
					units = (DensityUnitType) Enum.Parse(typeof (DensityUnitType), strUnit);
			}
			catch
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid DensityType '{0}' value or units is missing.", name)
				              	});
				return null;
			}
			if (!strUnit.IsNullOrEmpty())
				str = str.Replace(strUnit, null).Trim();

			if (str.IsNullOrEmpty() || !Decimal.TryParse(str, out decVal))
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid DensityType '{0}' value or units is missing.", name)
				              	});
				return null;
			}

			return new DensityType {density = units, Value = decVal};
		}

		public static TemperatureType GetXmlTemperatureType(XElement xmlElement, string name, bool required,
		                                             TemperatureUnitType defaultUnits)
		{
			if (xmlElement.Element(name) == null)
			{
				if (required)
					Messages.Add(new Message
					              	{Type = MessageType.Error, Text = String.Format("Required Double element '{0}' is missing.", name)});
				return null;
			}

			string str = xmlElement.Element(name).Value.ToUpper();
			decimal decVal;

			string strUnit = str.ParseOffUnits();
			TemperatureUnitType units = defaultUnits;
			try
			{
				// C, F
				if (!strUnit.IsNullOrEmpty())
					units = (TemperatureUnitType) Enum.Parse(typeof (TemperatureUnitType), strUnit);
			}
			catch
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid TemperatureType '{0}' value or units is missing.", name)
				              	});
				return null;
			}
			if (!strUnit.IsNullOrEmpty())
				str = str.Replace(strUnit, null).Trim();

			if (str.IsNullOrEmpty() || !Decimal.TryParse(str, out decVal))
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid TemperatureType '{0}' value or units is missing.", name)
				              	});
				return null;
			}

			return new TemperatureType {degrees = units, Value = decVal};
		}

		public static MassType GetXmlMassType(XElement xmlElement, string name, bool required, MassUnitType defaultUnits)
		{
			if (xmlElement.Element(name) == null)
			{
				if (required)
					Messages.Add(new Message
					              	{
					              		Type = MessageType.Error,
					              		Text = String.Format("Required MassType element '{0}' is missing.", name)
					              	});
				return null;
			}

			string str = xmlElement.Element(name).Value;
			decimal decVal;

			string strUnit = str.ParseOffUnits();
			MassUnitType units = defaultUnits;
			try
			{
				// mg, g, kg, lb, oz
				if (!strUnit.IsNullOrEmpty())
					units = (MassUnitType) Enum.Parse(typeof (MassUnitType), strUnit);
			}
			catch
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid MassType '{0}' value or units is missing.", name)
				              	});
				return null;
			}
			if (!strUnit.IsNullOrEmpty())
				str = str.Replace(strUnit, null).Trim();

			if (str.IsNullOrEmpty() || !Decimal.TryParse(str, out decVal))
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid MassType '{0}' value or units is missing.", name)
				              	});
				return null;
			}

			return new MassType {mass = units, Value = decVal};
		}

		public static ColorType GetXmlColorType(XElement xmlElement, string name, bool required, ColorUnitType defaultUnits)
		{
			if (xmlElement.Element(name) == null)
			{
				if (required)
					Messages.Add(new Message
					              	{
					              		Type = MessageType.Error,
					              		Text = String.Format("Required ColorType element '{0}' is missing.", name)
					              	});
				return null;
			}

			string str = xmlElement.Element(name).Value;
			decimal decVal;

			string strUnit = str.ParseOffUnits();
			ColorUnitType units = defaultUnits;
			try
			{
				// EBC, L, SRM
				if (!strUnit.IsNullOrEmpty())
					units = (ColorUnitType) Enum.Parse(typeof (ColorUnitType), strUnit);
			}
			catch
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid ColorType '{0}' value or units is missing.", name)
				              	});
				return null;
			}
			if (!strUnit.IsNullOrEmpty())
				str = str.Replace(strUnit, null).Trim();

			if (str.IsNullOrEmpty() || !Decimal.TryParse(str, out decVal))
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid ColorType '{0}' value or units is missing.", name)
				              	});
				return null;
			}

			return new ColorType {scale = units, Value = decVal};
		}

		public static IBUEstimateType GetXmlIbuEstimateType(XElement xmlElement, string name, bool required,
		                                             IBUMethodType defaultIbuMethod)
		{
			if (xmlElement.Element(name) == null)
			{
				if (required)
					Messages.Add(new Message
					              	{
					              		Type = MessageType.Error,
					              		Text = String.Format("Required IBUEstimateType element '{0}' is missing.", name)
					              	});
				return null;
			}

			string str = xmlElement.Element(name).Value ?? String.Empty;
			if (str.IsNullOrEmpty())
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid IBUEstimateType '{0}' value or units is missing.", name)
				              	});
				return null;
			}

			return GetXmlIbuEstimateType(str, name, defaultIbuMethod);
		}

		public static IBUEstimateType GetXmlIbuEstimateType(string ibuString, string name, IBUMethodType defaultIbuMethod)
		{
			string str = ibuString.Replace("IBU", null);

			decimal decVal;

			string strUnit = str.ParseOffUnits();
			IBUMethodType method = defaultIbuMethod;
			try
			{
				//	Rager, Tinseth, Garetz, Other
				if (!strUnit.IsNullOrEmpty())
					method = (IBUMethodType) Enum.Parse(typeof (IBUMethodType), strUnit);
			}
			catch
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid IBUEstimateType '{0}' value or units is missing.", name)
				              	});
				return null;
			}
			if (!strUnit.IsNullOrEmpty())
				str = str.Replace(strUnit, null).Trim();

			if (str.IsNullOrEmpty() || !Decimal.TryParse(str, out decVal))
			{
				Messages.Add(new Message
				              	{
				              		Type = MessageType.Error,
				              		Text = String.Format("Invalid IBUEstimateType '{0}' value or units is missing.", name)
				              	});
				return null;
			}

			return new IBUEstimateType {method = method, Value = decVal};
		}

		private static bool IsEfficiencyRequired(RecipeTypeType recipeType)
		{
			return recipeType == RecipeTypeType.partialmash ||
			       recipeType == RecipeTypeType.allgrain;
		}

		private static void ValidateFementationStages(RecipeTypeFermentation_stages stages)
		{
			if (stages == null)
				return;

			if (stages.primary.temperature == null || stages.primary.aging == null)
				stages.primary.aging = new TimeType {duration = TimeUnitType.day, Value = 0};

			if (stages.secondary.temperature == null || stages.secondary.aging == null)
				stages.secondary.aging = new TimeType {duration = TimeUnitType.day, Value = 0};

			if (stages.tertiary.temperature == null || stages.tertiary.aging == null)
				stages.tertiary.aging = new TimeType {duration = TimeUnitType.day, Value = 0};

			if (stages.conditioning.temperature == null || stages.conditioning.aging == null)
				stages.conditioning.aging = new TimeType {duration = TimeUnitType.day, Value = 0};
		}
	
	}

}
