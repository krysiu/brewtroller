using BrewTrollerCommunicator;
namespace Test.BrewTrollerCommuncator
{
    public static class BTTestConfig
    {
        internal const string BT_CONNECTION_STRING = "COM6,115200,N,8,1";
        internal const BTComType BT_COMM_TYPE = BTComType.ASCII;
        internal const int BT_COMM_SCHEMA = 1;
        internal const int BT_BUILD_NUMBER = 698;
        internal const string BT_VERSION = "2.3";
    }
}