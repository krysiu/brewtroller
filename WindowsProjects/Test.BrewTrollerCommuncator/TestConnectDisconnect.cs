using NUnit.Framework;
using BrewTrollerCommunicator;


namespace Test.BrewTrollerCommuncator
{
	[TestFixture]
	[Ignore]
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
			_btCom.Connect("COM10,115200,N,8,1");
			Assert.IsTrue(_btCom.IsConnected);
			Assert.AreEqual(_btCom.Version.ComType, BTComType.BTNic);
			Assert.AreEqual(_btCom.Version.ComSchema, 20);
			Assert.AreEqual(_btCom.Version.BuildNumber, 574, "Build number is not correct.");
			Assert.AreEqual(_btCom.Version.Version,"2.1");
		}

		[Test]
		public void Disconnect()
		{
			_btCom.Disconnect();
			Assert.IsFalse(_btCom.IsConnected);
		}

	}
}
