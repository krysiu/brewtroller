using NUnit.Framework;
using BrewTrollerCommunicator;


namespace Test.BrewTrollerCommuncator
{
	[TestFixture]
	//[Ignore]
	public class TestConnectDisconnect
	{

		BTCommunicator _btCom;

		public TestConnectDisconnect()
		{
			_btCom = new BTCommunicator(); 
		}

		// run before all test have run
		[TestFixtureSetUp]
		public void Setup()
		{

		}

		// run after all test have run
		[TestFixtureTearDown]
		public void FixtureTearDown()
		{

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

		[Test]
		public void Connect()
		{
			_btCom.Connect(BTTestConfig.BT_CONNECTION_STRING);
			Assert.IsTrue(_btCom.IsConnected);
			Assert.AreEqual(_btCom.Version.ComType, BTTestConfig.BT_COMM_TYPE);
			Assert.AreEqual(_btCom.Version.ComSchema, BTTestConfig.BT_COMM_SCHEMA);
			Assert.AreEqual(_btCom.Version.BuildNumber, BTTestConfig.BT_BUILD_NUMBER, "Build number is not correct.");
			Assert.AreEqual(_btCom.Version.Version, BTTestConfig.BT_VERSION);
		}

		[Test]
		public void Disconnect()
		{
			_btCom.Disconnect();
			Assert.IsFalse(_btCom.IsConnected);
		}

	}
}
