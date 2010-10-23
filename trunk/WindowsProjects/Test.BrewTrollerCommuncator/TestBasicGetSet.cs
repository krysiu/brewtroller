using System;
using BrewTrollerCommunicator;
using NUnit.Framework;

namespace Test.BrewTrollerCommuncator
{
	[TestFixture]
	class TestBasicGetSet
	{
		BTCommunicator _btCom;

		public TestBasicGetSet()
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
			Assert.AreEqual(_btCom.Version.ComType, BTComType.BTNic);
			Assert.AreEqual(_btCom.Version.ComSchema, 0);
			Assert.AreEqual(_btCom.Version.BuildNumber, 574, "Build number is not correct.");
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

		[TestCase(true)]
		//[TestCase(false)]
		public void Alarm(bool setAlarm)
		{
			var saveAlarm = _btCom.GetAlarm();

			_btCom.SetAlarm(setAlarm);
			var getAlarm = _btCom.GetAlarm();
			Assert.AreEqual(setAlarm, getAlarm, "Get Alarm value does not equal Set Alarm value.");

			// sleep for 4 seconds so the alarm can be heard
			if (setAlarm)
				System.Threading.Thread.Sleep(4000);

			_btCom.SetAlarm(saveAlarm);
			var restoreAlarm = _btCom.GetAlarm();
			Assert.AreEqual(setAlarm, getAlarm, "Restore Alarm value does not equal Save Alarm value.");

		}

		[TestCase(212)]
		[TestCase(215)]
		[TestCase(208)]
		[TestCase(200)]
		public void BoilTemp(int temp)
		{
			_btCom.SetBoilTemp(temp);
			var val = _btCom.GetBoilTemp();
			Assert.AreEqual(temp, val, "Boil Temperature: Get value not equal to Set value.");
		}


		[TestCase(100)]
		[TestCase(95)]
		[TestCase(85)]
		public void BoilPower(int power)
		{
			_btCom.SetBoilPower(power);
			var val = _btCom.GetBoilPower();
			Assert.AreEqual(power, val, "Boil Power: Get value not equal to Set value.");
		}


		[TestCase(0)]
		[TestCase(1)]
		[TestCase(10)]
		[TestCase(100)]
		public void CycleStartDelay(int time)
		{
			_btCom.SetDelayTime(time);
			var val = _btCom.GetDelayTime();
			Assert.AreEqual(time, val, "Cycle Start Delay: Get value not equal to Set value.");
		}


		[TestCase(0)]
		[TestCase(10)]
		[TestCase(55)]
		[TestCase(111)]
		public void GrainTemp(int temp)
		{
			_btCom.SetGrainTemp(temp);
			var val = _btCom.GetGrainTemp();
			Assert.AreEqual(temp, val, "Boil Temperature: Get value not equal to Set value.");
		}


		[TestCase(0)]
		[TestCase(1)]
		[TestCase(2)]
		[TestCase(20)]
		// 0-20% are valid values
		public void EvaporationRate(int rate)
		{
			_btCom.SetEvapRate(rate);
			var val = _btCom.GetEvapRate();
			Assert.AreEqual(rate, val, "Evaporation Rate: Get value not equal to Set value.");
		}


		[TestCase(BTHeatOutputID.HLT, BTHeatMode.OnOff, 1, 0, 0, 0, 0)]
		[TestCase(BTHeatOutputID.HLT, BTHeatMode.OnOff, 2, 0, 0, 0, 1)]
		[TestCase(BTHeatOutputID.HLT, BTHeatMode.OnOff, 3, 0, 0, 0, 20)]
		[TestCase(BTHeatOutputID.Mash, BTHeatMode.OnOff, 4, 0, 0, 0, 0)]
		[TestCase(BTHeatOutputID.Mash, BTHeatMode.OnOff, 5, 0, 0, 0, 1)]
		[TestCase(BTHeatOutputID.Mash, BTHeatMode.OnOff, 6, 0, 0, 0, 20)]
		[TestCase(BTHeatOutputID.Kettle, BTHeatMode.OnOff, 7, 0, 0, 0, 0)]
		[TestCase(BTHeatOutputID.Kettle, BTHeatMode.OnOff, 8, 0, 0, 0, 1)]
		[TestCase(BTHeatOutputID.Kettle, BTHeatMode.OnOff, 9, 0, 0, 0, 20)]
		[TestCase(BTHeatOutputID.HLT, BTHeatMode.PID, 10, 1, 2, 3, 0)]
		[TestCase(BTHeatOutputID.HLT, BTHeatMode.PID, 11, 1, 2, 3, 5)]
		[TestCase(BTHeatOutputID.HLT, BTHeatMode.PID, 12, 10, 20, 30, 0)]
		[TestCase(BTHeatOutputID.HLT, BTHeatMode.PID, 13, 10, 20, 30, 5)]
		[TestCase(BTHeatOutputID.Mash, BTHeatMode.PID, 14, 11, 22, 33, 0)]
		[TestCase(BTHeatOutputID.Mash, BTHeatMode.PID, 15, 1, 2, 3, 5)]
		[TestCase(BTHeatOutputID.Mash, BTHeatMode.PID, 16, 10, 20, 30, 0)]
		[TestCase(BTHeatOutputID.Mash, BTHeatMode.PID, 17, 10, 20, 30, 5)]
		[TestCase(BTHeatOutputID.Kettle, BTHeatMode.PID, 18, 1, 2, 3, 0)]
		[TestCase(BTHeatOutputID.Kettle, BTHeatMode.PID, 19, 1, 2, 3, 5)]
		[TestCase(BTHeatOutputID.Kettle, BTHeatMode.PID, 20, 10, 20, 30, 0)]
		[TestCase(BTHeatOutputID.Kettle, BTHeatMode.PID, 21, 10, 20, 30, 5)]
		public void HeatOutputSettings(BTHeatOutputID id, BTHeatMode mode, int cycleTime, int pGain, int iGain, int dGain, int hysteresis)
		{
			var tsCycleTime = TimeSpan.FromSeconds(cycleTime);
			var setConfig = new BTHeatOutputConfig
					{
						ID = id,
						Mode = mode,
						CycleTime = tsCycleTime,
						PGain = pGain,
						IGain = iGain,
						DGain = dGain,
						Hysteresis = hysteresis,
						SteamSensor = 0,
						SteamTarget = 0,
						SteamZero = 0
					};
			_btCom.SetHeatOutputConfig(id, setConfig);
			var getConfig = _btCom.GetHeatOutputConfig(id);
			Assert.AreEqual(setConfig.ID, getConfig.ID, "Heat Output Config: Get ID not equal to Set ID.");
			Assert.AreEqual(setConfig.Mode, getConfig.Mode, "Heat Output Config: Get Mode not equal to Set Mode.");
			Assert.AreEqual(setConfig.CycleTime, getConfig.CycleTime, "Heat Output Config: Get CycleTime not equal to Set CycleTime.");
			Assert.AreEqual(setConfig.PGain, getConfig.PGain, "Heat Output Config: Get PGain not equal to Set PGain.");
			Assert.AreEqual(setConfig.IGain, getConfig.IGain, "Heat Output Config: Get IGain not equal to Set IGain.");
			Assert.AreEqual(setConfig.DGain, getConfig.DGain, "Heat Output Config: Get DGain not equal to Set DGain.");
			Assert.AreEqual(setConfig.Hysteresis, getConfig.Hysteresis, "Heat Output Config: Get Hysteresis not equal to Set Hysteresis.");
		}


		[TestCase(TSLocation.HLT, (UInt64)0x0011223344556677)]
		[TestCase(TSLocation.Mash, (UInt64)0x0011223344556677)]
		[TestCase(TSLocation.Kettle, (UInt64)0x0011223344556677)]
		[TestCase(TSLocation.H2OIn, (UInt64)0x0011223344556677)]
		[TestCase(TSLocation.H2OOut, (UInt64)0x0011223344556677)]
		[TestCase(TSLocation.BeerOut, (UInt64)0x0011223344556677)]
		[TestCase(TSLocation.Aux1, (UInt64)0x0011223344556677)]
		[TestCase(TSLocation.Aux2, (UInt64)0x0011223344556677)]
		[TestCase(TSLocation.Aux3, (UInt64)0x0011223344556677)]
		public void TempSensor(TSLocation location, UInt64 address)
		{
			var tsAddress = new TSAddress(location, address);
			_btCom.SetTempSensorAddress(location, tsAddress);
			var val = _btCom.GetTempSensorAddress(location);
			Assert.AreEqual(tsAddress, val, "Heat Output Config: Get TSAddress not equal to Set TSAddress.");
		}


		[TestCase(BTProfileID.FillHLT,		(UInt64)0x10000001)]
		[TestCase(BTProfileID.FillMash,		(UInt64)0x08000002)]
		[TestCase(BTProfileID.AddGrain,		(UInt64)0x04000004)]
		[TestCase(BTProfileID.MashHeat,		(UInt64)0x02000008)]
		[TestCase(BTProfileID.MashIdle,		(UInt64)0x01000010)]
		[TestCase(BTProfileID.SpargeIn,		(UInt64)0x00800020)]
		[TestCase(BTProfileID.SpargeOut,	(UInt64)0x00400040)]
		[TestCase(BTProfileID.BoilAdds,		(UInt64)0x00200080)]
		[TestCase(BTProfileID.KettleLid,	(UInt64)0x00100100)]
		[TestCase(BTProfileID.ChillH2O,		(UInt64)0x00080200)]
		[TestCase(BTProfileID.ChillBeer,	(UInt64)0x00040400)]
		[TestCase(BTProfileID.BoilRecirc,	(UInt64)0x00020800)]
		[TestCase(BTProfileID.Drain,		(UInt64)0x00011000)]
		public void ValveProfile(BTProfileID profileID, UInt64 mask)
		{
			// Current version of the BT only support 32-bit profiles

			var saveProfile = _btCom.GetValveProfile(profileID);

			var setProfile = new BTValveProfile { ID = profileID, Mask = mask };
			_btCom.SetValveProfile(profileID, setProfile);

			var getProfile = _btCom.GetValveProfile(profileID);
			Assert.AreEqual(setProfile, getProfile, "Get ValveProfile does not match Set ValveProfile");

			var restoreProfile = _btCom.GetValveProfile(profileID);
			Assert.AreEqual(restoreProfile, saveProfile, "Save ValveProfile does not match Restore ValveProfile");
		}


		[TestCase(BTHeatOutputID.HLT)]
		[TestCase(BTHeatOutputID.Mash)]
		[TestCase(BTHeatOutputID.Kettle)]
		public void VesselCalibration(BTVesselType id)
		{
			var saveCalib = _btCom.GetVesselCalibration(id);

			var setCalib = new BTVesselCalibration
			{
				VesselType = id,
				CalibrationPoint0 = new BTCalibrationPoint { PointID = 0, Volume = 0, Value = 0 },
				CalibrationPoint1 = new BTCalibrationPoint { PointID = 1, Volume = 100, Value = 230 },
				CalibrationPoint2 = new BTCalibrationPoint { PointID = 2, Volume = 200, Value = 654 },
				CalibrationPoint3 = new BTCalibrationPoint { PointID = 3, Volume = 300, Value = 1234 },
				CalibrationPoint4 = new BTCalibrationPoint { PointID = 4, Volume = 400, Value = 1456 },
				CalibrationPoint5 = new BTCalibrationPoint { PointID = 5, Volume = 500, Value = 1999 },
				CalibrationPoint6 = new BTCalibrationPoint { PointID = 6, Volume = 600, Value = 2798 },
				CalibrationPoint7 = new BTCalibrationPoint { PointID = 7, Volume = 700, Value = 3298 },
				CalibrationPoint8 = new BTCalibrationPoint { PointID = 8, Volume = 800, Value = 4023 },
				CalibrationPoint9 = new BTCalibrationPoint { PointID = 9, Volume = 1000, Value = 4095 },
			};
			_btCom.SetVesselCalibration(id, setCalib);

			var getCalib = _btCom.GetVesselCalibration(id);
			Assert.AreEqual(setCalib, getCalib);

			_btCom.SetVesselCalibration(saveCalib.VesselType, saveCalib);
			var restoreCalib = _btCom.GetVesselCalibration(id);
			Assert.AreEqual(saveCalib, restoreCalib);

		}

		[TestCase(BTVesselType.HLT, 100, 0.5)]
		[TestCase(BTVesselType.HLT, 10, 1.5)]
		[TestCase(BTVesselType.Mash, 1000, 10.54)]
		[TestCase(BTVesselType.Mash, 50, 15.5)]
		[TestCase(BTVesselType.Kettle, 47.6, 0.5)]
		[TestCase(BTVesselType.Kettle, 100, 1.5)]
		public void VesselVolume(BTVesselType id, double capacity, double deadspace)
		{
			var saveVolume = _btCom.GetVolumeSetting(id);

			var setVolume = new BTVolumeSetting
			{
				VesselType = id,
				Capacity = (decimal)capacity,
				DeadSpace = (decimal)deadspace
			};
			_btCom.SetVolumeSetting(id, setVolume);

			var getVolume = _btCom.GetVolumeSetting(id);
			Assert.AreEqual(setVolume, getVolume);

			_btCom.SetVolumeSetting(id, saveVolume);
			var restoreVolume = _btCom.GetVolumeSetting(id);
			Assert.AreEqual(saveVolume, restoreVolume);

		}


	}
}
