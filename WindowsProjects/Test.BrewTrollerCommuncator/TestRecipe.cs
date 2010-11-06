using NUnit.Framework;
using BrewTrollerCommunicator;


namespace Test.BrewTrollerCommuncator
{
	[TestFixture]
	public class TestRecipe
	{

		BTCommunicator _btCom;

		public TestRecipe()
		{
			_btCom = new BTCommunicator(); 
		}

		// run before all test have run
		[TestFixtureSetUp]
		public void Setup()
		{
			_btCom.Connect("COM10,115200,N,8,1");
			_btCom.ComRetries = 1;
			Assert.IsTrue(_btCom.IsConnected);
			Assert.AreEqual(_btCom.Version.ComType, BTComType.ASCII);
			Assert.AreEqual(_btCom.Version.ComSchema, 1);
			Assert.AreEqual(_btCom.Version.BuildNumber, 604, "Build number is not correct.");
			Assert.AreEqual(_btCom.Version.Version, "2.1");
		}

		// run after all test have run
		[TestFixtureTearDown]
		public void FixtureTearDown()
		{
			_btCom.Disconnect();
			Assert.IsFalse(_btCom.IsConnected);
		}

		// run before each test
		[SetUp]
		public void SetUp()
		{

		}

		// run after each test
		[TearDown]
		public void TearDown()
		{
		}

		[TestCase(0)]
		[TestCase(1)]
		[TestCase(2)]
		[TestCase(3)]
		[TestCase(4)]
		[TestCase(5)]
		[TestCase(6)]
		[TestCase(7)]
		[TestCase(8)]
		[TestCase(9)]
		[TestCase(10)]
		[TestCase(11)]
		[TestCase(12)]
		[TestCase(13)]
		[TestCase(14)]
		[TestCase(15)]
		[TestCase(16)]
		[TestCase(17)]
		[TestCase(18)]
		[TestCase(19)]
		public void RecipeGetSet(int slot)
		{
			var saveRecipe = _btCom.GetRecipe(slot);
			
			var setRecipe = CreateTestRecipe(slot, _btCom.Version.Units); 
			_btCom.SetRecipe(setRecipe);
			var getRecipe = _btCom.GetRecipe(slot);

			_btCom.SetRecipe(saveRecipe);
			var restoreRecipe = _btCom.GetRecipe(slot);

		}

		private BTRecipe CreateTestRecipe(int slot, BTUnits units)
		{
			var recipe = new BTRecipe(units);
			recipe.Name = "NUnit Test Recipe";

			recipe.PreHeat.step_time.Value = 10;
			recipe.PreHeat.step_temperature.Value = 120;
			recipe.DoughIn.step_time.Value = 11;
			recipe.DoughIn.step_temperature.Value = 130;
			recipe.AcidRest.step_time.Value = 12;
			recipe.AcidRest.step_temperature.Value = 140;
			recipe.ProteinRest.step_time.Value = 13;
			recipe.ProteinRest.step_temperature.Value = 150;
			recipe.Sacch1Rest.step_time.Value = 14;
			recipe.Sacch1Rest.step_temperature.Value = 160;
			recipe.Sacch2Rest.step_time.Value = 15;
			recipe.Sacch2Rest.step_temperature.Value = 170;
			recipe.MashOut.step_time.Value = 16;
			recipe.MashOut.step_temperature.Value = 180;

			recipe.SpargeTemp.Value = 150;
			recipe.HLTSetpoint.Value = 121;
			recipe.MashHeatSource = BTVesselID.HLT;
			recipe.MashRatio = 1.05m;
			recipe.BatchVolume.Value = 65.5m;
			recipe.GrainWeight.Value = 2.34m;
			recipe.BoilTime.Value = 63;
			recipe.PitchTemp.Value = 144;
			recipe.Additions = 0x55;

			return recipe;
		}

	}
}
