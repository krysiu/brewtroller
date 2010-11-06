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
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using BeerXMLSupportLibrary;


namespace BrewTrollerCommunicator
{
	/// <summary> BrewTroller Recipe </summary>
	/// <remarks>
	/// A BrewTroller Recipe contains the values needed by the BrewTroller to control a 
	/// brewing cycle. BTRecipe is basically a wrapper for a BeerXML v2.7 recipe. For
	/// more information on the BeerXML v2 standard see www.beerxml.com.
	/// 
	/// The underlying BeerXML object in a BTRecipe contains much more information that
	/// required by the BT. This information can be exposed or not as determined by the 
	/// features of the program that is using this library.
	/// 
	/// All of the fields required by the BT are exposed directly in a BTRecipe object
	/// as properties. Get and Set operation on these properties access the proper 
	/// value in the underlying XML object.
	/// </remarks>
	/// 
	public class BTRecipe : IFormattable, IBTDataClass
	{
		// Underlying BeerXML recipe object.
		// 
		public RecipeType Xml { get; set; }

		[XmlIgnore]
		public int Slot { get; set; }

		public BTUnits Units { get; set; }

		public string Name
		{
			get { return Xml.name; }
			set { Xml.name = value; }
		}

		public enum MashStepID
		{
			PreHeat,
			DoughIn,
			AcidRest,
			ProteinRest,
			Sacch1Rest,
			Sacch2Rest,
			MashOut
		}

		public MashStepType PreHeat
		{
			get { return Xml.mash.mash_steps[(int)MashStepID.PreHeat]; }
			set { Xml.mash.mash_steps[(int)MashStepID.PreHeat] = value; }
		}
		public MashStepType DoughIn
		{
			get { return Xml.mash.mash_steps[(int)MashStepID.DoughIn]; }
			set { Xml.mash.mash_steps[(int)MashStepID.DoughIn] = value; }
		}
		public MashStepType AcidRest
		{
			get { return Xml.mash.mash_steps[(int)MashStepID.AcidRest]; }
			set { Xml.mash.mash_steps[(int)MashStepID.AcidRest] = value; }
		}
		public MashStepType ProteinRest
		{
			get { return Xml.mash.mash_steps[(int)MashStepID.ProteinRest]; }
			set { Xml.mash.mash_steps[(int)MashStepID.ProteinRest] = value; }
		}
		public MashStepType Sacch1Rest
		{
			get { return Xml.mash.mash_steps[(int)MashStepID.Sacch1Rest]; }
			set { Xml.mash.mash_steps[(int)MashStepID.Sacch1Rest] = value; }
		}
		public MashStepType Sacch2Rest
		{
			get { return Xml.mash.mash_steps[(int)MashStepID.Sacch2Rest]; }
			set { Xml.mash.mash_steps[(int)MashStepID.Sacch2Rest] = value; }
		}
		public MashStepType MashOut
		{
			get { return Xml.mash.mash_steps[(int)MashStepID.MashOut]; }
			set { Xml.mash.mash_steps[(int)MashStepID.MashOut] = value; }
		}

		// mapped to mash.sparge_temperature 
		public TemperatureType SpargeTemp
		{
			get { return Xml.mash.sparge_temperature; }
			set { Xml.mash.sparge_temperature = value; }
		}

		// mapped the to temperature of the PreHeat Mash Step
		public TemperatureType HLTSetpoint
		{
			get { return Xml.mash.mash_steps[(int)MashStepID.PreHeat].step_temperature; }
			set { Xml.mash.mash_steps[(int)MashStepID.PreHeat].step_temperature = value; }
		}

		// ToDo: figure out where to persist this value
		// mapped the to water-grain ratio of the DoughIn step
		public BTVesselID MashHeatSource { get; set; }

		// mapped the to water-grain ratio of the DoughIn step
		public decimal MashRatio
		{
			get { return Xml.mash.mash_steps[(int)MashStepID.DoughIn].water_grain_ratio; }
			set { Xml.mash.mash_steps[(int)MashStepID.DoughIn].water_grain_ratio = value; }
		}

		public VolumeType BatchVolume
		{
			get { return Xml.batch_size; }
			set { Xml.batch_size = value; }
		}

		public MassType GrainWeight
		{
			get { return Xml.ingredients.grain_bill[0].amount; }
			set { Xml.ingredients.grain_bill[0].amount = value; }
		}

		public TimeType BoilTime
		{
			get { return Xml.boil_time; }
			set { Xml.boil_time = value; }
		}

		// mapped the to temperature of the primary fermentation stage
		public TemperatureType PitchTemp
		{
			get { return Xml.fermentation_stages.primary.temperature; }
			set { Xml.fermentation_stages.primary.temperature = value; }
		}

		public UInt32 Additions { get; set; }

		private readonly SortedList<MashStepID, MashStepType> _mashSteps;
		public SortedList<MashStepID, MashStepType> MashSteps { get { return _mashSteps; } }

		public bool AdditionStart { get { return Additions.GetBit(0); } set { Additions = Additions.SetBit(0, value); } }
		public bool Addition105 { get { return Additions.GetBit(1); } set { Additions = Additions.SetBit(1, value); } }
		public bool Addition90 { get { return Additions.GetBit(2); } set { Additions = Additions.SetBit(2, value); } }
		public bool Addition75 { get { return Additions.GetBit(3); } set { Additions = Additions.SetBit(3, value); } }
		public bool Addition60 { get { return Additions.GetBit(4); } set { Additions = Additions.SetBit(4, value); } }
		public bool Addition45 { get { return Additions.GetBit(5); } set { Additions = Additions.SetBit(5, value); } }
		public bool Addition30 { get { return Additions.GetBit(6); } set { Additions = Additions.SetBit(6, value); } }
		public bool Addition20 { get { return Additions.GetBit(7); } set { Additions = Additions.SetBit(7, value); } }
		public bool Addition15 { get { return Additions.GetBit(8); } set { Additions = Additions.SetBit(8, value); } }
		public bool Addition10 { get { return Additions.GetBit(9); } set { Additions = Additions.SetBit(9, value); } }
		public bool Addition5 { get { return Additions.GetBit(10); } set { Additions = Additions.SetBit(10, value); } }
		public bool Addition0 { get { return Additions.GetBit(11); } set { Additions = Additions.SetBit(11, value); } }
		public bool AdditionMisc { get { return Additions.GetBit(12); } set { Additions = Additions.SetBit(12, value); } }

		public bool NoAdditionsActiveExcludingMisc { get { return (Additions & ~(1 << 12)) == 0; } }
		public bool IsMetric { get { return Units == BTUnits.Metric; } }
		public bool IsBTRecipe { get { return Xml.notes.StartsWith(BTRecipeID); } }
		public const string BTRecipeID = "BrewTroller 3.3 Recipe";


		/// <summary> Construct a BTRecipe </summary>
		/// 
		public BTRecipe(BTUnits units)
		{
			Units = units;
			Xml = new RecipeType();
			InitializeXml();
			_mashSteps = new SortedList<MashStepID, MashStepType> 
			{ 
				{MashStepID.PreHeat, PreHeat},
				{MashStepID.DoughIn, DoughIn},
				{MashStepID.AcidRest, AcidRest}, 
				{MashStepID.ProteinRest, ProteinRest}, 
				{MashStepID.Sacch1Rest, Sacch1Rest}, 
				{MashStepID.Sacch2Rest, Sacch2Rest}, 
				{MashStepID.MashOut, MashOut}
			};
		}

		/// <summary> Construct a BTRecipe object from an BeerXML recipe </summary>
		/// 
		public BTRecipe(RecipeType recipe)
		{
			Xml = recipe;
			Units = (BatchVolume != null && BatchVolume.volume == VolumeUnitType.l) ? BTUnits.Metric : BTUnits.US;
			_mashSteps = new SortedList<MashStepID, MashStepType> 
			{ 
				{MashStepID.PreHeat, PreHeat},
				{MashStepID.DoughIn, DoughIn},
				{MashStepID.AcidRest, AcidRest}, 
				{MashStepID.ProteinRest, ProteinRest}, 
				{MashStepID.Sacch1Rest, Sacch1Rest}, 
				{MashStepID.Sacch2Rest, Sacch2Rest}, 
				{MashStepID.MashOut, MashOut}
			};
		}



		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			Debug.Assert(rspParams.Count == 23, "rspParams.Count == 23");

			try
			{
				// skip recipe slot
				var index = 1;

				Name = rspParams[index++].Trim();

				DoughIn.step_time = NewTimeType(Convert.ToDecimal(rspParams[index++]), TimeUnitType.min);
				DoughIn.step_temperature = NewTemperatureType(Convert.ToDecimal(rspParams[index++]), IsMetric);
				AcidRest.step_time = NewTimeType(Convert.ToDecimal(rspParams[index++]), TimeUnitType.min);
				AcidRest.step_temperature = NewTemperatureType(Convert.ToDecimal(rspParams[index++]), IsMetric);
				ProteinRest.step_time = NewTimeType(Convert.ToDecimal(rspParams[index++]), TimeUnitType.min);
				ProteinRest.step_temperature = NewTemperatureType(Convert.ToDecimal(rspParams[index++]), IsMetric);
				Sacch1Rest.step_time = NewTimeType(Convert.ToDecimal(rspParams[index++]), TimeUnitType.min);
				Sacch1Rest.step_temperature = NewTemperatureType(Convert.ToDecimal(rspParams[index++]), IsMetric);
				Sacch2Rest.step_time = NewTimeType(Convert.ToDecimal(rspParams[index++]), TimeUnitType.min);
				Sacch2Rest.step_temperature = NewTemperatureType(Convert.ToDecimal(rspParams[index++]), IsMetric);
				MashOut.step_time = NewTimeType(Convert.ToDecimal(rspParams[index++]), TimeUnitType.min);
				MashOut.step_temperature = NewTemperatureType(Convert.ToDecimal(rspParams[index++]), IsMetric);

				SpargeTemp = NewTemperatureType(Convert.ToDecimal(rspParams[index++]), IsMetric);
				HLTSetpoint = NewTemperatureType(Convert.ToDecimal(rspParams[index++]), IsMetric);
				BatchVolume = NewVolumeType(Convert.ToDecimal(rspParams[index++]) / 1000, IsMetric);
				GrainWeight = NewMassType(Convert.ToDecimal(rspParams[index++]), IsMetric);
				BoilTime = NewTimeType(Convert.ToDecimal(rspParams[index++]), TimeUnitType.min);
				MashRatio = Convert.ToDecimal(rspParams[index++]) / 100;
				PitchTemp = NewTemperatureType(Convert.ToDecimal(rspParams[index++]), IsMetric);
				Additions = Convert.ToUInt32(rspParams[index++]);
				if (!version.IsAsciiSchema0)
					MashHeatSource = (BTVesselID)(Convert.ToInt32(rspParams[index++]));
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting parameter list to BTRecipe.", ex);
			}
		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			List<string> paramsList;
			try
			{
				paramsList = new List<string>
       			{
       				Convert.ToString(Slot),									// 1
       				Name,													// 2
       				Convert.ToString(DoughIn.step_temperature.Value),		// 3
       				Convert.ToString(DoughIn.step_time.Value),				// 4
       				Convert.ToString(AcidRest.step_temperature.Value),		// 5
       				Convert.ToString(AcidRest.step_time.Value),				// 6
       				Convert.ToString(ProteinRest.step_temperature.Value),	// 7
       				Convert.ToString(ProteinRest.step_time.Value),			// 8
       				Convert.ToString(Sacch1Rest.step_temperature.Value),	// 9
       				Convert.ToString(Sacch1Rest.step_time.Value),			// 10
       				Convert.ToString(Sacch2Rest.step_temperature.Value),	// 11
       				Convert.ToString(Sacch2Rest.step_time.Value),			// 12
       				Convert.ToString(MashOut.step_temperature.Value),		// 13
       				Convert.ToString(MashOut.step_time.Value),				// 14

       				Convert.ToString(SpargeTemp.Value),						// 15
       				Convert.ToString(HLTSetpoint.Value),					// 16
       				Convert.ToString(BatchVolume.Value * 1000),				// 17
       				Convert.ToString(GrainWeight.Value),					// 18
       				Convert.ToString(BoilTime.Value),						// 19
       				Convert.ToString(MashRatio * 100),						// 20
       				Convert.ToString(PitchTemp.Value),						// 21
       				Convert.ToString(Additions)								// 22
       				//Convert.ToString((int)Units)							// 23 not sent as command parameter, #define configured in BT
		       	};

				if (!version.IsAsciiSchema0)
					paramsList.Add(Convert.ToString((int)MashHeatSource));
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting BTRecipe to parameter list.", ex);
			}
			return paramsList;
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			var index = offset;
			if (len != 52)
				throw new Exception("BTRecipe.HydrateFromBinary: Buffer Size Error.");

			// recipe slot
			Slot = btBuf[index++];

			// recipe units
			Units = (BTUnits)btBuf[index++];

			// name
			byte[] nameArray = new byte[BTConfig.RecipeNameSize];
			int i;
			for (i = 0; i < BTConfig.RecipeNameSize; i++)
			{
				nameArray[i] = btBuf[index++];
				if (nameArray[i] < 0x20)
					nameArray[i] = (byte)' ';
			}
			Debug.Assert(btBuf[index] == 0, "btBuf[index] == 0");
			index++;
			ASCIIEncoding encoder = new ASCIIEncoding();
			Name = encoder.GetString(nameArray).Trim();

			// mash steps DoughIn, Acid Rest, Protein Rest, Sacch1 Rest, Sacch2 Rest, Mash Out
			//		PreHeat is handled separately
			foreach (var mashStep in MashSteps.Where(mashStep => mashStep.Key != MashStepID.PreHeat))
			{
				mashStep.Value.step_temperature =
					new TemperatureType
						{
							Value = btBuf[index++],
							degrees = Units == BTUnits.US ? TemperatureUnitType.F
							          	: TemperatureUnitType.C
						};

				mashStep.Value.step_time =
					new TimeType { Value = btBuf[index++], duration = TimeUnitType.min };
			}

			// mash heat source
			MashHeatSource = (BTVesselID)btBuf[index++];

			// sparge temp
			SpargeTemp = new TemperatureType
			{
				Value = btBuf[index++],
				degrees = Units == BTUnits.US
								   ? TemperatureUnitType.F
								   : TemperatureUnitType.C
			};

			// pitch temp
			PitchTemp = new TemperatureType
			{
				Value = btBuf[index++],
				degrees = Units == BTUnits.US
								   ? TemperatureUnitType.F
								   : TemperatureUnitType.C
			};

			// HLT Setpoint
			HLTSetpoint = new TemperatureType
			{
				Value = btBuf[index++],
				degrees = Units == BTUnits.US
								  ? TemperatureUnitType.F
								  : TemperatureUnitType.C
			};

			// batch volume
			decimal dVal = (btBuf[index++] << 24) |
							(btBuf[index++] << 16) |
							(btBuf[index++] << 8) |
							(btBuf[index++] << 0);
			BatchVolume = new VolumeType
			{
				Value = dVal / 1000,
				volume = Units == BTUnits.US
								   ? VolumeUnitType.gal
								   : VolumeUnitType.l
			};

			// grain weight
			dVal = (btBuf[index++] << 24) |
					(btBuf[index++] << 16) |
					(btBuf[index++] << 8) |
					(btBuf[index++] << 0);
			GrainWeight = new MassType
			{
				Value = dVal / 1000,
				mass = (Units == BTUnits.US)
								? MassUnitType.lb
								: MassUnitType.kg
			};
			// boil time
			BoilTime = new TimeType
			{
				Value = (btBuf[index++] << 8) |
						(btBuf[index++] << 0),
				duration = TimeUnitType.min
			};

			// mash ratio
			dVal = (btBuf[index++] << 8) |
					(btBuf[index++] << 0);
			MashRatio = dVal / 100;

			// boil additions
			Additions = (UInt16)((btBuf[index++] << 8) +
								 (btBuf[index++] << 0));

			Debug.Assert(index == offset + len, "index == offset + len");
		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			var index = offset;

			// units
			cmdBuf[index++] = (byte)Units;

			// name
			ASCIIEncoding encoder = new ASCIIEncoding();
			var nameBuf = encoder.GetBytes(Name);
			for (var i = 0; i < 19; i++)
			{
				if (i < nameBuf.Length)
					cmdBuf[index++] = nameBuf[i];
				else
					cmdBuf[index++] = (byte)' ';
			}
			cmdBuf[index++] = 0;

			// mash steps (PreHeat get sent separately)
			foreach (var mashStep in MashSteps.Where(mashStep => mashStep.Key != MashStepID.PreHeat))
			{
				cmdBuf[index++] = (byte)mashStep.Value.step_temperature.Value;
				cmdBuf[index++] = (byte)mashStep.Value.step_time.Value;
			}

			// mash heat source
			cmdBuf[index++] = (byte)MashHeatSource;

			// Sparge Temp
			cmdBuf[index++] = (byte)SpargeTemp.Value;

			// Pitch Temp
			cmdBuf[index++] = (byte)PitchTemp.Value;

			// HLT Setpoint
			cmdBuf[index++] = (byte)HLTSetpoint.Value;


			// Batch Volume
			UInt32 uiVal = (UInt32)(BatchVolume.Value * 1000);
			cmdBuf[index++] = uiVal.Byte3();
			cmdBuf[index++] = uiVal.Byte2();
			cmdBuf[index++] = uiVal.Byte1();
			cmdBuf[index++] = uiVal.Byte0();

			// Grain Weight
			uiVal = (UInt32)(BatchVolume.Value * 1000);
			cmdBuf[index++] = uiVal.Byte3();
			cmdBuf[index++] = uiVal.Byte2();
			cmdBuf[index++] = uiVal.Byte1();
			cmdBuf[index++] = uiVal.Byte0();

			// Boil Time
			uiVal = (UInt32)(BoilTime.Value);
			cmdBuf[index++] = uiVal.Byte1();
			cmdBuf[index++] = uiVal.Byte0();

			// Mash Ratio
			uiVal = (UInt32)(MashRatio);
			cmdBuf[index++] = uiVal.Byte1();
			cmdBuf[index++] = uiVal.Byte0();

			// Boil Adds
			uiVal = Additions;
			cmdBuf[index++] = uiVal.Byte1();
			cmdBuf[index++] = uiVal.Byte0();

			return (byte)(index - offset);
		}



		private void InitializeXml()
		{
			// ToDo: Figure out how to deal with units before we have connected to the BT
			// ToDo: How do units get initialized when reading from an XML file
			var units = BTUnits.US;

			// recipe information
			//
			Xml.name = String.Empty;
			Xml.type = RecipeTypeType.allgrain;
			Xml.author = String.Empty;
			Xml.coauthor = String.Empty;
			Xml.created = DateTime.Now.ToString();
			Xml.batch_size = NewVolumeType(0.0m, false);
			Xml.boil_size = NewVolumeType(0.0m, false);
			Xml.boil_time = NewTimeType(0.0m, TimeUnitType.min);
			Xml.efficiency = 0.0m;
			Xml.efficiencySpecified = false;
			Xml.style = new RecipeStyleType
			{
				name = String.Empty,
				category = String.Empty,
				category_number = "0",
				style_letter = String.Empty,
				style_guide = String.Empty,
				type = StyleCategories.ale
			};
			Xml.ingredients = new RecipeTypeIngredients();
			Xml.mash = new MashProcedureType();
			Xml.notes = BTRecipeID;
			Xml.original_gravity = NewDenisityType(0.0m, DensityUnitType.sg);
			Xml.final_gravity = NewDenisityType(0.0m, DensityUnitType.sg);
			Xml.alcohol_by_volume = 0.0m;
			Xml.alcohol_by_volumeSpecified = false;
			Xml.ibu_estimate = NewIBUEstimateType(0m, IBUMethodType.Tinseth);
			Xml.color_estimate = NewColorType(0m, ColorUnitType.L);
			Xml.carbonationSpecified = false;
			Xml.fermentation_stages = new RecipeTypeFermentation_stages();
			Xml.taste = new RecipeTypeTaste { notes = String.Empty, rating = 0.0m };
			Xml.calories_per_pint = 0.0m;
			Xml.calories_per_pintSpecified = false;

			// mash information
			//
			Xml.mash.name = String.Empty;
			Xml.mash.grain_temperature = NewTemperatureType(0.0m, false);
			Xml.mash.sparge_temperature = NewTemperatureType(0.0m, false);
			Xml.mash.pHSpecified = false;
			Xml.mash.notes = String.Empty;

			// mash steps
			//
			Xml.mash.mash_steps = GetMashSteps(Units);

			// ingredents.hop_bill & ingredents.adjuncts
			//
			// 19	public UInt32 Additions { get; set; }
			Xml.ingredients.hop_bill = GetHopsAdditions(units);
			Xml.ingredients.adjuncts = GetMiscAddition(units);

			// ingredents.grain_bill
			//
			// 20	public decimal GrainWeight { get; set; }
			Xml.ingredients.grain_bill = GetGrainBill(units);

			// fermentation_stages.primary
			//
			// 21	public decimal PitchTemp { get; set; }
			Xml.fermentation_stages.primary = new FermentationStageType
			{
				aging = NewTimeType(0, TimeUnitType.min),
				temperature = NewTemperatureType(0, false)
			};
			Xml.fermentation_stages.secondary = null;
			Xml.fermentation_stages.tertiary = null;
			Xml.fermentation_stages.conditioning = null;

			// 22	public decimal MashRatio { get; set; }
			// 23	public decimal HLTSetpoint { get; set; }


		}

		private static MashStepType[] GetMashSteps(BTUnits units)
		{
			var mashSteps = new List<MashStepType>();

			foreach (var mashStepName in Enum.GetNames(typeof(MashStepID)))
			{
				var mashStep = new MashStepType
				{
					name = mashStepName,
					type = MashStepTypeType.infusion,
					infuse_amount = NewVolumeType(0.0m, units == BTUnits.Metric),
					step_temperature = NewTemperatureType(0.0m, units == BTUnits.Metric),
					step_time = NewTimeType(0.0m, TimeUnitType.min),
					ramp_time = NewTimeType(0.0m, TimeUnitType.min),
					end_temperature = NewTemperatureType(0.0m, units == BTUnits.Metric),
					description = String.Empty,
					water_grain_ratio = 0.0m,
					water_grain_ratioSpecified = mashStepName == MashStepID.DoughIn.ToString(),
					decoction_amount = NewVolumeType(0, units == BTUnits.Metric),
					infuse_temperature = NewTemperatureType(0, units == BTUnits.Metric),
				};
				mashSteps.Add(mashStep);
			}

			return mashSteps.ToArray();
		}

		private static HopAdditionTypeAddition[] GetHopsAdditions(BTUnits units)
		{
			var hopAdditionList = new List<HopAdditionTypeAddition>
			                      	{
    		NewHopAddition(9999, units),
    		NewHopAddition(105, units),
    		NewHopAddition(90, units),
    		NewHopAddition(75, units),
    		NewHopAddition(60, units),
    		NewHopAddition(45, units),
    		NewHopAddition(30, units),
    		NewHopAddition(20, units),
    		NewHopAddition(15, units),
    		NewHopAddition(10, units),
    		NewHopAddition(5, units),
    		NewHopAddition(0, units)
    	};

			return hopAdditionList.ToArray();
		}

		private static MiscellaneousAdditionTypeAddition[] GetMiscAddition(BTUnits units)
		{
			var miscAdditions = new MiscellaneousAdditionTypeAddition[1];
			miscAdditions[0] = new MiscellaneousAdditionTypeAddition
			{
				name = String.Empty,
				type = MiscellaneousBaseType.other,
				use = MiscellaneousBaseUse.boil,
				Item = NewMassType(0.0m, units == BTUnits.Metric),
				time = NewTimeType(0.0m, TimeUnitType.min)
			};

			return miscAdditions;
		}

		private static FermentableAdditionTypeAddition[] GetGrainBill(BTUnits units)
		{
			var grainBill = new FermentableAdditionTypeAddition[1];
			grainBill[0] = new FermentableAdditionTypeAddition
			{
				name = String.Empty,
				type = FermentableBaseType.grain,
				color = NewColorType(0, ColorUnitType.L),
				origin = String.Empty,
				supplier = String.Empty,
				amount = NewMassType(0, units == BTUnits.Metric),
				add_after_boil = false,
				add_after_boilSpecified = false
			};

			return grainBill;
		}


		private static HopAdditionTypeAddition NewHopAddition(int additionTime, BTUnits units)
		{
			return new HopAdditionTypeAddition
			{
				name = String.Empty,
				origin = String.Empty,
				alpha_acid_units = 0.0m,
				beta_acid_units = 0.00m,
				beta_acid_unitsSpecified = false,
				form = HopAdditionTypeAdditionForm.leaf,
				use = HopAdditionTypeAdditionUse.boil,
				amount = NewMassType(0.0m, units == BTUnits.Metric),
				time = NewTimeType(additionTime, TimeUnitType.min)
			};

		}

		private static DensityType NewDenisityType(decimal value, DensityUnitType densityType)
		{
			return new DensityType
			{
				Value = value,
				density = densityType
			};
		}

		private static MassType NewMassType(decimal value, bool metric)
		{
			return new MassType
			{
				Value = value,
				mass = metric ? MassUnitType.kg : MassUnitType.lb
			};
		}

		private static VolumeType NewVolumeType(decimal value, bool metric)
		{
			return new VolumeType
			{
				Value = value,
				volume = metric ? VolumeUnitType.l : VolumeUnitType.gal
			};
		}

		private static TemperatureType NewTemperatureType(decimal value, bool metric)
		{
			return new TemperatureType
			{
				Value = value,
				degrees = metric ? TemperatureUnitType.C : TemperatureUnitType.F
			};
		}

		private static TimeType NewTimeType(decimal value, TimeUnitType units)
		{
			return new TimeType
			{
				Value = value,
				duration = units
			};
		}

		private static IBUEstimateType NewIBUEstimateType(decimal value, IBUMethodType ibuMethod)
		{
			return new IBUEstimateType
			{
				Value = value,
				method = ibuMethod
			};
		}

		private static ColorType NewColorType(decimal value, ColorUnitType colorUnits)
		{
			return new ColorType
			{
				Value = value,
				scale = colorUnits
			};
		}

		private static RecipeStyleType NewRecipeStyleType()
		{
			return new RecipeStyleType
			{
				name = String.Empty,
				category = String.Empty,
				category_number = "0",
				style_letter = String.Empty,
				style_guide = String.Empty,
				type = StyleCategories.ale
			};
		}

		private static RecipeTypeTaste NewRecipeTypeTaste()
		{
			return new RecipeTypeTaste
			{
				notes = String.Empty,
				rating = 0m
			};
		}


		public override string ToString()
		{
			return String.Format("Recipe {0}", Name);
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
			sb.AppendFormat("Name:         \"{0}\"\n", Name);
			sb.AppendFormat("Units:        {0}\n", Units);
			sb.AppendFormat("# Mash Steps: {0}\n", MashSteps.Count);
			sb.AppendFormat("Sparge Temp:  {0:N0} {1}\n", SpargeTemp.Value, SpargeTemp.degrees);
			sb.AppendFormat("Pitch Temp:   {0:N0} {1}\n", PitchTemp.Value, PitchTemp.degrees);
			sb.AppendFormat("Batch Volume: {0:N3} {1}\n", BatchVolume.Value, BatchVolume.volume);
			sb.AppendFormat("Mash Heat:    {0}\n", MashHeatSource);
			sb.AppendFormat("HLT SetPoint: {0:N0} {1}\n", HLTSetpoint.Value, HLTSetpoint.degrees);
			sb.AppendFormat("Grain Weight: {0:N3} {1}\n", GrainWeight.Value, GrainWeight.mass);
			sb.AppendFormat("Boil Time:    {0:N0} {1}\n", BoilTime.Value, BoilTime.duration);
			sb.AppendFormat("Mash Ratio:   {0:N2} / 1\n", MashRatio);
			sb.AppendFormat("Boil Adds:    0x{0:X4}\n", Additions);
			return sb.ToString();
		}

	}


	public class BTCalcVols : IFormattable, IBTDataClass
	{
		public int RecipeSlot { get; private set; }
		public BTUnits Units { get; set; }

		public VolumeType Grain { get; set; }
		public VolumeType GrainLoss { get; set; }
		public VolumeType Preboil { get; set; }
		public VolumeType Strike { get; set; }
		public VolumeType Sparge { get; set; }

		public BTCalcVols(BTUnits units)
		{
			Units = units;
		}

		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			Debug.Assert(rspParams.Count == 6, "rspParams.Count == 6");
			try
			{
				var index = 0;
				RecipeSlot = Convert.ToInt32(rspParams[index++]);
				var volUnits = (Units == BTUnits.US) ? VolumeUnitType.gal : VolumeUnitType.l;
				Grain = new VolumeType { Value = Convert.ToDecimal(rspParams[index++]) / 1000, volume = volUnits };
				GrainLoss = new VolumeType { Value = Convert.ToDecimal(rspParams[index++]) / 1000, volume = volUnits };
				Preboil = new VolumeType { Value = Convert.ToDecimal(rspParams[index++]) / 1000, volume = volUnits };
				Strike = new VolumeType { Value = Convert.ToDecimal(rspParams[index++]) / 1000, volume = volUnits };
				Sparge = new VolumeType { Value = Convert.ToDecimal(rspParams[index++]) / 1000, volume = volUnits };
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting parameter list to BTCalcVols.", ex);
			}
		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			throw new NotImplementedException();
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			var index = offset;
			var volUnits = (Units == BTUnits.US) ? VolumeUnitType.gal : VolumeUnitType.l;

			RecipeSlot = btBuf[index++];

			decimal dVal;
			dVal = (btBuf[index++] << 24) + (btBuf[index++] << 16) + (btBuf[index++] << 8) + (btBuf[index++] << 0);
			Grain = new VolumeType { Value = dVal / 1000, volume = volUnits };

			dVal = (btBuf[index++] << 24) + (btBuf[index++] << 16) + (btBuf[index++] << 8) + (btBuf[index++] << 0);
			GrainLoss = new VolumeType { Value = dVal / 1000, volume = volUnits };

			dVal = (btBuf[index++] << 24) + (btBuf[index++] << 16) + (btBuf[index++] << 8) + (btBuf[index++] << 0);
			Preboil = new VolumeType { Value = dVal / 1000, volume = volUnits };

			dVal = (btBuf[index++] << 24) + (btBuf[index++] << 16) + (btBuf[index++] << 8) + (btBuf[index++] << 0);
			Strike = new VolumeType { Value = dVal / 1000, volume = volUnits };

			dVal = (btBuf[index++] << 24) + (btBuf[index++] << 16) + (btBuf[index++] << 8) + (btBuf[index++] << 0);
			Sparge = new VolumeType { Value = dVal / 1000, volume = volUnits };
		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			throw new NotImplementedException();
		}

		public override string ToString()
		{
			return String.Format("CalcVols ({0}) Grain={1:n3}, GrainLoss={2:n3}, Preboil={3:n3}, Strike={4:n3}, Sparge={5:n3}",
								  Grain.volume, Grain.Value, GrainLoss.Value, Preboil.Value, Strike.Value, Sparge.Value);
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

	public class BTCalcTemps : IFormattable, IBTDataClass
	{
		public int RecipeSlot { get; private set; }
		public BTUnits Units { get; private set; }
		public TemperatureType Strike { get; set; }
		public TemperatureType FirstStep { get; set; }

		public BTCalcTemps(BTUnits units)
		{
			Units = units;
		}

		public void HydrateFromParamList(BTVersion version, List<string> rspParams)
		{
			Debug.Assert(rspParams.Count == 3, "rspParams.Count == 3");
			try
			{
				var index = 0;
				RecipeSlot = Convert.ToInt32(rspParams[index++]);
				var tempUnits = (Units == BTUnits.US) ? TemperatureUnitType.F : TemperatureUnitType.C;

				Strike = new TemperatureType { Value = Convert.ToDecimal(rspParams[index++]), degrees = tempUnits };
				FirstStep = new TemperatureType { Value = Convert.ToDecimal(rspParams[index++]), degrees = tempUnits };
			}
			catch (Exception ex)
			{
				throw new BTComException("Error converting parameter list to BTCalcTemps.", ex);
			}
		}

		public List<string> EmitToParamsList(BTVersion version)
		{
			throw new NotImplementedException();
		}

		public void HydrateFromBinary(BTVersion version, byte[] btBuf, int offset, int len)
		{
			var index = offset;
			RecipeSlot = btBuf[index++];
			var tempUnits = (Units == BTUnits.US) ? TemperatureUnitType.F : TemperatureUnitType.C;

			decimal dVal = btBuf[index++];
			Strike = new TemperatureType { Value = dVal, degrees = tempUnits };

			dVal = btBuf[index++];
			FirstStep = new TemperatureType { Value = dVal, degrees = tempUnits };

		}

		public byte EmitToBinary(BTVersion version, byte[] cmdBuf, byte offset)
		{
			throw new NotImplementedException();
		}

		public override string ToString()
		{
			return String.Format("CalcTemps ({0}) Strike={1}, FirstStep={2}",
								  Strike.degrees, Strike.Value, FirstStep.Value);
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

}

