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

//#define Win32SerialPort	// Use Win32 Interop Serial Driver (future option)
#define CRC_256EntryTable	// CRC Method - CRC_Algorithm(slowest, low memory), CRC_256EntryTable(fastest, high memory), or CRC_16EntryTable(in the middle)

using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Ports;
using System.Diagnostics;
using System.Linq;
using System.Text;

namespace BrewTrollerCommunicator
{
	#region Enums

	public enum BTCommand
	{
		// Configuration

		GetVersion,
		Reset,
		InitEEPROM,
		GetEEPROM,
		SetEEPROM,
		GetAlarm,
		SetAlarm,
		ScanTempSensors,

		GetRecipe,
		SetRecipe,
		GetCalcVols,
		GetCalcTemps,
		GetLogStatus,
		SetLogStatus,
		GetLog,

		GetBoilTemp,
		GetBoilPower,
		GetDelayTime,
		GetEvapRate,
		GetGrainTemp,
		GetHeatOutputConfig,
		GetTempSensorAddr,
		GetValveProfile,
		GetVesselCalib,
		GetVolumnSetting,

		SetBoilTemp,
		SetBoilPower,
		SetDelayTime,
		SetEvapRate,
		SetHeatOutputConfig,
		SetGrainTemp,
		SetTempSensorAddr,
		SetValveProfile,
		SetVesselCalib,
		SetVolumeSetting,

		StepAdvance,
		StepExit,
		StepInit,
		SetAutoValve,
		SetSetpoint,
		SetTimerStatus,
		SetTimerValue,
		SetValveState,
		SetValvePreference,

		LogStepProg,
		LogTimer,
		LogVolume,
		LogTemp,
		LogSteam,
		LogHeatPower,
		LogHeatSetpoint,
		LogAutoValve,
		LogValveBits,
		LogValvePref

	}

	public enum BTComType
	{
		Unknown		= -1,		// Unknown protocol
		ASCII		= 0,		// original ASCII protocol
		BTNic		= 1,		// Non-Broadcasting, Single Byte Command ASCII protocol
		Binary		= 2,		// binary 
		Simulator	= 255,		// Simulator protocol (WCF??)
	}

	# endregion

	[Serializable]
	public class BTComException : Exception
	{
		public BTComException() { }
		public BTComException(string message) : base(message) { }
		public BTComException(string message, Exception inner) : base(message, inner) { }
		protected BTComException(
			System.Runtime.Serialization.SerializationInfo info,
			System.Runtime.Serialization.StreamingContext context)
			: base(info, context) { }

		public string TxD { get; set; }
		public string RxD { get; set; }
		public TimeSpan TimeStamp { get; set; }
	}

	public class BTComError
	{
		public string TxD { get; set; }
		public string RxD { get; set; }
		public string ErrorMessage { get; set; }
	}

	public class BTComMessage
	{
		public enum MsgDir
		{
			ToBT,
			FromBT
		}

		public MsgDir Direction { get; set; }
		public string Text { get; set; }
	}


	public partial class BTCommunicator : IBTCommunicator, IDisposable
	{
		// ASCII characters
		private const byte NUL = 0x00;
		private const byte ACK = 0x06;
		private const byte NAK = 0x15;

		private int CmdRspField
		{
			get
			{
				Debug.Assert(Version.ComType != BTComType.Unknown, "Version.ComType != BTComType.Unknown");
				switch (Version.ComType)
				{
				case BTComType.ASCII: return 2;
				case BTComType.BTNic: return 1;
				case BTComType.Binary: return 0;
				//case BTComType.Simulator: return -1;
				default: throw new Exception("Internal Error. Invalid BTComType.");
				}
			}
		}

		private int FirstRspParam 
		{
			get
			{
				Debug.Assert(Version.ComType != BTComType.Unknown, "Version.ComType != BTComType.Unknown");
				switch (Version.ComType)
				{
				case BTComType.ASCII: return 3;
				case BTComType.BTNic: return 2;
				case BTComType.Binary: return 1;
				//case BTComType.Simulator: return -1;
				default: throw new Exception("Internal Error. Invalid BTComType.");
				}
			}
		}

		// Binary protocol fields
		private const byte BinaryLenField = 1;
		private const byte BinaryErrorField = 1;
		private const byte BinaryDataField = 2;


		#region Properties

		public bool LogEnabled { get; set; }
		public List<BTComMessage> BTComLog { get; set; }

		public string ComLogFile { get; set; }
		public string ErrorLogFile { get; set; }

		public string TxD { get; private set; }
		public string RxD { get; private set; }

		public TimeSpan TimeStamp { get; private set; }

		public string ConnectionString { get; private set; }
		public string PortName { get; private set; }
		public int BaudRate { get; private set; }
		public Parity Parity { get; private set; }
		public int DataBits { get; private set; }
		public StopBits StopBits { get; private set; }
		public int ComRetries
		{
			get { return _comRetries; }
			set
			{
				if (value < 1)
					_comRetries = 1;
				else if (value > 5)
					_comRetries = 5;
				else
					_comRetries = value;
			}
		}

		public BTVersion Version { get { return _btVersion; } }
		public int ComSchema { get { return _btVersion.ComSchema; } }
		public bool IsConnected { get { return _connected; } }

		#endregion

		private enum BTResponse
		{
			// Internal values, never returned by BrewTroller
			None,
			Error,
			UnknownResponse,

			// System response values
			OK,
			BadParam,
			FieldOverflow,
			MessageOverflow,
			UnknowCommand,

			BoilTemp,
			BoilPower,
			ConfigVersion,	//????
			EEPROM,
			EvapRate,
			LogStatus,
			OutputSettings,
			Recipe,
			TempSensorAddr,
			TempSensorScan,
			ValveConfig,
			VesselCalib,
			VolumeSetting,

			LogData,
			GrainTemp,
			DelayTime,
			CalcVols,
			CalcTemps,

			AlarmState,
			AutoValveState,
			SetpointValue,
			SteamPressure,
			ProgramStep,
			TempValue,
			TimerState,
			ValvesState,
			ActiveVlvProfile,
			VolumeValue,

			SoftReset,
			Version,
		}

		private enum BTComDataDir
		{
			None,
			ToBT,
			FromBT,
			Both
		}

		private class BTCmdInfo
		{
			public string ASCIICommand { get; private set; }
			public BTResponse Response { get; private set; }
			public byte BinaryCommand { get; private set; }
			public string BTNicCommand { get; private set; }
			private BTComDataDir Direction { get; set; }
			public int Timeout { get; private set; }

			public BTCmdInfo(string cmdASCII, BTResponse rsp, byte cmdBinary, string cmdBTNic, BTComDataDir direction, int timeout)
			{
				ASCIICommand = cmdASCII;
				Response = rsp;
				BinaryCommand = cmdBinary;
				BTNicCommand = cmdBTNic;
				Direction = direction;
				Timeout = timeout;
			}

			public bool IsSetData { get { return Direction == BTComDataDir.ToBT || Direction == BTComDataDir.Both; } }
			public bool IsGetData { get { return Direction == BTComDataDir.FromBT || Direction == BTComDataDir.Both; } }

		}



		private readonly BTVersion _btVersion = new BTVersion();

		private bool _connected;

#if Win32SerialPort
		private Win32SerialPort _serialPort;
#else
		private SerialPort _serialPort;
#endif

		private BTComType ComType { get { return _btVersion.ComType; } set { _btVersion.ComType = value; } }

		private SortedList<BTCommand, BTCmdInfo> _btCmdList;
		private SortedList<string, BTResponse> _btRspList;

		private readonly List<BTComException> _btComErrorLog;

		private int _retryCount;
		private int _comRetries = 3;

		private readonly byte[] _cmdBuf = new byte[256];
		private readonly byte[] _rspBuf = new byte[256];
		private int _bytesRead;

		/// <summary> Constructor </summary>
		/// 
		public BTCommunicator()
		{
			InitializeCmdRspLists();

			BTComLog = new List<BTComMessage>();
			_btComErrorLog = new List<BTComException>();
		}


		/// <summary> Parse ConnectionString </summary>
		/// 
		private bool ParseConnectionString(string connectionString)
		{
			if (connectionString.IsNullOrEmpty())
				return false;

			ConnectionString = String.Empty;
			PortName = String.Empty;

			var split = connectionString.Split(new[] { ',' });

			var bRate = 9600;
			if (split.Length >= 1)
			{
				if (!int.TryParse(split[1], out bRate))
					return false;
			}

			var pVal = Parity.None;
			if (split.Length > 2)
			{
				switch (split[2].ToUpper())
				{
				case "N": pVal = Parity.None; break;
				case "O": pVal = Parity.Odd; break;
				case "E": pVal = Parity.Even; break;
				case "M": pVal = Parity.Mark; break;
				case "S": pVal = Parity.Space; break;
				default:
					return false;
				}
			}

			var dBits = 8;
			if (split.Length > 3)
			{
				if (!int.TryParse(split[3], out dBits))
					return false;
			}

			var sbVal = StopBits.One;
			if (split.Length > 4)
			{
				switch (split[4].ToUpper())
				{
				case "0": sbVal = StopBits.None; break;
				case "1": sbVal = StopBits.One; break;
				case "2": sbVal = StopBits.Two; break;
				case "1.5": sbVal = StopBits.OnePointFive; break;
				default:
					return false;
				}
			}

			if (split.Length > 5)
			{
				if (!int.TryParse(split[5], out _comRetries))
					return false;
			}

			ConnectionString = connectionString;
			PortName = split[0];
			BaudRate = bRate;
			Parity = pVal;
			DataBits = dBits;
			StopBits = sbVal;

			return true;
		}


		#region Com Errors

		public BTComException NewBTComException(string message)
		{
			BTComException ex = new BTComException(message) { TxD = TxD, RxD = RxD, TimeStamp = TimeStamp };
			LogComError(ex);
			return ex;
		}

		public BTComException NewBTComException(string message, Exception inner)
		{
			BTComException ex = new BTComException(message, inner) { TxD = TxD, RxD = RxD, TimeStamp = TimeStamp };
			LogComError(ex);
			return ex;
		}

		public BTComException NewBTComException(BTComException ex)
		{
			ex.TxD = TxD;
			ex.RxD = RxD;
			ex.TimeStamp = TimeStamp;
			LogComError(ex);
			return ex;
		}

		private void LogComError(BTComException ex)
		{
			_btComErrorLog.Add(ex);
			if (ErrorLogFile.IsNullOrEmpty())
				return;

			using (TextWriter tw = new StreamWriter(ErrorLogFile, true))
			{
				try
				{
					if (_retryCount == ComRetries - 1)
						tw.WriteLine("");
					tw.WriteLine("  TxD: {0}", ex.TxD);
					tw.WriteLine("  RxD: {0}", ex.RxD);
					if (ex.InnerException != null)
						tw.WriteLine("  Inner: {0}", ex.InnerException.Message);
				}
				catch
				{
				}
				finally
				{
					tw.Close();
				}
			}
		}

		#endregion


		#region Send/Recive/Error Log

		private void LogMessage(string message, BTComMessage.MsgDir direction)
		{
			if (BTComLog != null && LogEnabled)
				BTComLog.Add(new BTComMessage { Text = message, Direction = direction });

			if (ComLogFile.IsNullOrEmpty())
				return;

			using (TextWriter tw = new StreamWriter(ComLogFile, true))
			{
				try
				{
					tw.WriteLine(message);
				}
				catch (Exception)
				{
				}
				finally
				{
					tw.Close();
				}
			}
		}

		public void ClearLog()
		{
			if (BTComLog != null && LogEnabled)
			{
				BTComLog.Clear();
			}

			if (File.Exists(ComLogFile))
				File.Delete(ComLogFile);
		}

		#endregion


		private void Clean()
		{
			_serialPort.DiscardInBuffer();
			_serialPort.DiscardOutBuffer();

			TxD = String.Empty;
			RxD = String.Empty;
			TimeStamp = TimeSpan.FromMilliseconds(0);
		}

		private void OpenComPort()
		{
			try
			{
#if Win32SerialPort
				_serialPort = new Win32SerialPort(PortName, BaudRate, Parity, DataBits, StopBits);
#else
				_serialPort = new SerialPort(PortName, BaudRate, Parity, DataBits, StopBits);
#endif

				_serialPort.Open();
				_serialPort.ReadTimeout = 500;
				//_SerialPort.DataReceived += CommDataRecievedEvent;
			}
			catch (Exception)
			{
				if (_serialPort != null)
					_serialPort.Dispose();
				throw;
			}
		}

		/// <summary> Send a command string to BrewTroller </summary>
		/// <param name="cmdStr"> Properly formatted BrewTroller command string</param>
		/// <returns> Response string </returns>
		public void SendBTCommand(string cmdStr)
		{
			Clean();

			if (cmdStr == null)
			{
				throw new ArgumentNullException("cmdStr");
			}

			if (!_serialPort.IsOpen)
			{
				throw NewBTComException(String.Format("Serial Port {0} is not open.", _serialPort.PortName));
			}

			try
			{
				_serialPort.DiscardInBuffer();
				_serialPort.DiscardOutBuffer();

				// trim and log command string
				TxD = cmdStr.Trim();
				LogMessage(TxD, BTComMessage.MsgDir.ToBT);

				if (TxD.IndexOfAny(new[] { ',' }) == -1)
				{
					// no parameters, add trailing tab
					TxD += '\t';
				}
				else
				{
					// has parameters, replace ',' with tabs
					TxD = TxD.Replace(",", "\t");
				}

				// make sure all upper case
				TxD = TxD.ToUpper();

				// send to BT
				_serialPort.Write(TxD + "\r");
			}
			catch (TimeoutException ex)
			{
				throw NewBTComException(String.Format("Timeout while writing to Port {0}.", _serialPort.PortName), ex);
			}
		}

		/// <summary> Get a response string from the BrewTroller </summary>
		/// 
		public string GetBTResponse(int timeout)
		{
			try
			{
				_serialPort.ReadTimeout = timeout;
				// get BT response
				RxD = _serialPort.ReadLine();

				// remove trailing return and newline
				RxD = RxD.Replace("\r", null);
				RxD = RxD.Replace("\n", null);

				// replace tabs with commas
				RxD = RxD.Replace("\t", ",");
				if (RxD[RxD.Length - 1] == ',')
					RxD = RxD.Substring(0, RxD.Length - 1);

				// log response
				LogMessage(RxD, BTComMessage.MsgDir.FromBT);
			}
			catch (BTComException)
			{
				throw;
			}
			catch (Exception ex)	// Timeout, IOException, UnauthorizedAccessException
			{
				throw NewBTComException(String.Format("Exception while reading from Port {0}.", _serialPort.PortName), ex);
			}

			// return response
			return RxD;
		}


		/// <summary> Process a BrewTroller Command </summary>
		/// <remarks>
		/// Send a command to the BT and wait for a response. Based on the schema of the BT the command will 
		/// be send using an ASCII protocol or a binary protocol. The _cmdList and _rspList Lists are used
		/// to determine how to process the command. The _cmdList contains a CmdInfo object for every BT command
		/// which provides the following:
		/// 
		///   - ASCII command string - string that is sent out when using the ASCII protocol
		///   - BTRespons - expected response for ASCII command
		///   - Binary command byte - byte that is sent out when using the Binary protocol
		///   - Direction of data - Indication of data direction - Get's are FromBT & Set's are ToBT
		///   - Timeout - Time to wait for response before generating a timeout exception
		///   - Response - The expected response 
		///   
		/// </remarks>
		/// <param name="btCommand"> BT Command </param>
		/// <param name="btStructure"> Object that implements the IBTDataClass interface </param>
		/// <param name="selector"></param>
		private BTResponse ProcessBTCommand(BTCommand btCommand, IBTDataClass btStructure, List<int> selector)
		{
			var response = BTResponse.OK;
			_retryCount = ComRetries;
			while (_retryCount > 0)
			{
				try
				{
					switch (ComType )
					{
					case BTComType.ASCII:
						response = ProcessBTCommandASCII(btCommand, btStructure, selector);
						break;
					case BTComType.Binary:
						response = ProcessBTCommandBinary(btCommand, btStructure, selector);
						break;
					case BTComType.BTNic:
						response = ProcessBTCommandASCII(btCommand, btStructure, selector);
						break;
					default:
						throw new BTComException("Unknown BT communication protocol.");
					}
					_retryCount = 0;
				}
				catch (Exception)
				{
					if (--_retryCount == 0)
						throw;
				}
			}
			return response;
		}


		/// <summary> ASCII Command Processing </summary>
		/// 
		private BTResponse ProcessBTCommandASCII(BTCommand btCommand, IBTDataClass btStructure, List<int> selector)
		{
			var cmdInfo = _btCmdList[btCommand];

			if (!_serialPort.IsOpen)
			{
				throw NewBTComException(String.Format("Serial Port {0} is not open.", _serialPort.PortName), null);
			}

			var cmdParams = new List<string>();
			var rspParams = new List<string>();

			try
			{
				if (selector != null)
				{
					cmdParams.AddRange(selector.Select(id => id.ToString()));
				}

				if (_btCmdList[btCommand].IsSetData)
				{
					cmdParams.AddRange(btStructure.EmitToParamsList(Version));
				}

				Clean();

				// build up command string using comma separators 
				StringBuilder sb = new StringBuilder();
				if (Version.ComType == BTComType.ASCII)
					sb.Append(cmdInfo.ASCIICommand);
				else
					sb.Append(cmdInfo.BTNicCommand);

				foreach (var param in cmdParams)
				{
					sb.Append(",");
					sb.Append(param);
				}

				// append trailing tab after command if there are no parameters
				if (cmdParams.Count == 0 && Version.ComType == BTComType.ASCII)
				{
					sb.Append(",");
				}

				// log the command string
				TxD = sb.ToString();
				LogMessage(TxD, BTComMessage.MsgDir.ToBT);

				// replace commas with tabs, add return, and send to BT
				_serialPort.Write(TxD.Replace(",", "\t"));
				_serialPort.Write("\r");
			}
			catch (BTComException)
			{
				throw;
			}
			catch (Exception ex)
			{
				throw NewBTComException(String.Format("Timeout while writing to Port {0}.", _serialPort.PortName), ex);
			}

			try
			{
				// read the response
				_serialPort.ReadTimeout = cmdInfo.Timeout;
				RxD = _serialPort.ReadLine();

				// remove the trailing return and newline
				RxD = RxD.Replace("\r", null);
				RxD = RxD.Replace("\n", null);
				// replace tabs with commas and remove trailing comma if present
				RxD = RxD.Replace("\t", ",");
				if (RxD[RxD.Length - 1] == ',')
					RxD = RxD.Substring(0, RxD.Length - 1);

				// log the receive message
				LogMessage(RxD, BTComMessage.MsgDir.FromBT);
				//. ****************************************************************
				//if (btCommand == BTCommand.SetEEPROM)
				//    return BTResponse.OK;
				//. ****************************************************************

				// split the response string
				var rspSplit = RxD.Split(',');

				// move parameters to rspParams list
				for (var i = FirstRspParam; i < rspSplit.Length; i++)
					rspParams.Add(rspSplit[i]);

				// try to parse the timestamp (first element in response array)
				long timeStampMsec;
				if (!long.TryParse(rspSplit[0], out timeStampMsec))
				{
					throw NewBTComException(String.Format("Error parsing BrewTroller _timeStamp field ({0}).", rspSplit[0]));
				}
				TimeStamp = TimeSpan.FromMilliseconds(timeStampMsec);

				switch (Version.ComType)
				{
				case BTComType.ASCII:
					// try to parse the response results
					if (!_btRspList.ContainsKey(rspSplit[CmdRspField]))
					{
						throw NewBTComException(String.Format("Invalid Response Token - '{0}'.", rspSplit[FirstRspParam]));
					}

					var btRsp = _btRspList[rspSplit[CmdRspField]];
					if (btRsp != cmdInfo.Response)
					{
						throw NewBTComException(String.Format("Incorrect Response Value - Expected '{0}', received '{1},{2}'.",
													GetResponseToken(cmdInfo.Response),
													rspSplit[FirstRspParam], rspSplit[FirstRspParam + 1]));
					}
					break;

				case BTComType.BTNic:
					if (rspSplit[CmdRspField] != cmdInfo.BTNicCommand)
					{
						switch (rspSplit[CmdRspField])
						{
						case "!":
							throw NewBTComException(String.Format("BT rejected the '{0}' command.",
													cmdInfo.BTNicCommand));
						case "#":
							throw NewBTComException(String.Format("BT rejected a parameter on the '{0}' command.",
													cmdInfo.BTNicCommand));
						case "*":
							throw NewBTComException(String.Format("BT indicated there was a CRC error on the '{0}' command.",
													cmdInfo.BTNicCommand));
						default:
							throw NewBTComException(String.Format("Incorrect Response Value - Expected '{0}', received '{1}'.",
													cmdInfo.BTNicCommand,
													rspSplit[CmdRspField]));
						}	
					}
					break;
				}
			}
			catch (BTComException)
			{
				throw;
			}
			catch (KeyNotFoundException)
			{
				throw;
			}
			catch (Exception ex)	// Timeout, IOException, UnauthorizedAccessException
			{
				//. ****************************************************************
				//if (btCommand == BTCommand.SetEEPROM)
				//    return BTResponse.OK;
				//. ****************************************************************
				throw NewBTComException(String.Format("Exception while reading from Port {0}.", _serialPort.PortName), ex);
			}

			if (_btCmdList[btCommand].IsGetData)
			{
				btStructure.HydrateFromParamList(Version, rspParams);
			}


			return BTResponse.OK;
		}

		/// <summary> Binary Command Processing </summary>
		/// 
		private BTResponse ProcessBTCommandBinary(BTCommand btCommand, IBTDataClass btStructure, List<int> selector)
		{
			var cmdInfo = _btCmdList[btCommand];

			if (cmdInfo.BinaryCommand == 0xff)
				throw new Exception(String.Format("{0} not yet implemented.", btCommand));

			_cmdBuf[CmdRspField] = cmdInfo.BinaryCommand;
			// send command
			//
			try
			{
				_cmdBuf[BinaryLenField] = 0;

				if (selector != null)
				{
					_cmdBuf[BinaryLenField] = (byte)selector.Count;
					foreach (var id in selector)
						_cmdBuf[BinaryDataField] = (byte)id;
				}
				
				if (_btCmdList[btCommand].IsSetData)
				{
					_cmdBuf[BinaryLenField] += btStructure.EmitToBinary(Version, _cmdBuf, (byte)(BinaryDataField + _cmdBuf[BinaryLenField]));
				}

				var cmdBufLen = _cmdBuf[BinaryLenField] + 2;

				_serialPort.Write(_cmdBuf, 0, cmdBufLen);
				var crc = CalculateCRC(_cmdBuf, 0, cmdBufLen);
				var crcBuf = new[] { crc.LSB(), crc.MSB() };
				_serialPort.Write(crcBuf, 0, 2);
			}
			catch (BTComException)
			{
				throw;
			}
			catch (Exception ex)
			{
				throw NewBTComException(String.Format("Timeout while writing to Port {0}.", _serialPort.PortName), ex);
			}

			// wait for response
			//
			try
			{
				_serialPort.ReadTimeout = cmdInfo.Timeout;

				ReadBytes(_rspBuf, 0, 2);
				if (_rspBuf[CmdRspField] != _cmdBuf[CmdRspField])
				{
					if (_rspBuf[CmdRspField] == (_cmdBuf[CmdRspField] | 0x80))
						throw NewBTComException(String.Format("BT returned an {0} error code.", _rspBuf[BinaryErrorField]));
					else
						throw NewBTComException(String.Format("Reflected Command is invalid: expected:{0:x}, actual:{1:x}", _cmdBuf[CmdRspField], _rspBuf[CmdRspField]));

				}

				int rspParamsLen = _rspBuf[BinaryLenField];
				// get remaining bytes, including CRC
				ReadBytes(_rspBuf, BinaryDataField, rspParamsLen + 2);
				// check CRC including rsp, len, & CRC
				if (!CheckCRC(_rspBuf, 0, rspParamsLen + 4))
					throw NewBTComException(String.Format("CRC error on '{0}' command.", btCommand));

				// ToDo: Handle error responses

				if (cmdInfo.IsGetData)
				{
					btStructure.HydrateFromBinary(Version, _rspBuf, BinaryDataField, rspParamsLen);
				}

			}
			catch (Exception ex)	// Timeout, IOException, UnauthorizedAccessException
			{
				throw NewBTComException(String.Format("Exception while reading from Port {0}.", _serialPort.PortName), ex);
			}


			return BTResponse.OK;

		}

		/// <summary> ASCII Command Processing </summary>
		/// 
		private BTResponse ProcessBTCommandBTNic(BTCommand btCommand, IBTDataClass btStructure, List<int> selector)
		{
			var cmdInfo = _btCmdList[btCommand];

			if (!_serialPort.IsOpen)
			{
				throw NewBTComException(String.Format("Serial Port {0} is not open.", _serialPort.PortName), null);
			}

			var cmdParams = new List<string>();
			var rspParams = new List<string>();

			try
			{
				if (selector != null)
				{
					cmdParams.AddRange(selector.Select(id => id.ToString()));
				}

				if (_btCmdList[btCommand].IsSetData)
				{
					cmdParams = btStructure.EmitToParamsList(Version);
				}

				Clean();

				// build up command string using comma separators 
				StringBuilder sb = new StringBuilder(cmdInfo.ASCIICommand);
				foreach (var param in cmdParams)
				{
					sb.Append(",");
					sb.Append(param);
				}

				// append trailing tab after command if there are no parameters
				if (cmdParams.Count == 0)
				{
					sb.Append(",");
				}

				// log the command string
				TxD = sb.ToString();
				LogMessage(TxD, BTComMessage.MsgDir.ToBT);

				// replace commas with tabs, add return, and send to BT
				_serialPort.Write(TxD.Replace(",", "\t"));
				_serialPort.Write("\r");
			}
			catch (BTComException)
			{
				throw;
			}
			catch (Exception ex)
			{
				throw NewBTComException(String.Format("Timeout while writing to Port {0}.", _serialPort.PortName), ex);
			}

			try
			{
				// read the response
				_serialPort.ReadTimeout = cmdInfo.Timeout;
				RxD = _serialPort.ReadLine();

				// remove the trailing return and newline
				RxD = RxD.Replace("\r", null);
				RxD = RxD.Replace("\n", null);
				// replace tabs with commas and remove trailing comma if present
				RxD = RxD.Replace("\t", ",");
				if (RxD[RxD.Length - 1] == ',')
					RxD = RxD.Substring(0, RxD.Length - 1);

				// log the receive message
				LogMessage(RxD, BTComMessage.MsgDir.FromBT);
				//. ****************************************************************
				if (btCommand == BTCommand.SetEEPROM)
					return BTResponse.OK;
				//. ****************************************************************

				// split the response string
				var rspSplit = RxD.Split(',');

				// move parameters to rspParams list
				for (var i = FirstRspParam + 1; i < rspSplit.Length; i++)
					rspParams.Add(rspSplit[i]);

				// try to parse the timestamp (first element in response array)
				long timeStampMsec;
				if (!long.TryParse(rspSplit[0], out timeStampMsec))
				{
					throw NewBTComException(String.Format("Error parsing BrewTroller _timeStamp field ({0}).", rspSplit[0]));
				}
				TimeStamp = TimeSpan.FromMilliseconds(timeStampMsec);

				// try to parse the response results
				if (!_btRspList.ContainsKey(rspSplit[FirstRspParam]))
				{
					throw NewBTComException(String.Format("Invalid Response Token - '{0}'.", rspSplit[FirstRspParam]));
				}

				var btRsp = _btRspList[rspSplit[FirstRspParam]];
				if (btRsp != cmdInfo.Response)
				{
					throw NewBTComException(String.Format("Incorrect Response Value - Expected '{0}', received '{1},{2}'.",
												GetResponseToken(cmdInfo.Response),
																								rspSplit[FirstRspParam], rspSplit[FirstRspParam + 1]));
				}
			}
			catch (BTComException)
			{
				throw;
			}
			catch (KeyNotFoundException)
			{
				throw;
			}
			catch (Exception ex)	// Timeout, IOException, UnauthorizedAccessException
			{
				//. ****************************************************************
				if (btCommand == BTCommand.SetEEPROM)
					return BTResponse.OK;
				//. ****************************************************************
				throw NewBTComException(String.Format("Exception while reading from Port {0}.", _serialPort.PortName), ex);
			}

			if (_btCmdList[btCommand].IsGetData)
			{
				btStructure.HydrateFromParamList(Version, rspParams);
			}


			return BTResponse.OK;
		}



		/// <summary> read n bytes from the serial port </summary>
		///
		private void ReadBytes(byte[] buf, int offset, int count)
		{
			Debug.Assert(buf.Length >= offset + count, "buf.Length >= offset + count");

			_bytesRead = 0;
			for (_bytesRead = 0; _bytesRead < count; _bytesRead++)
				buf[offset + _bytesRead] = (byte)_serialPort.ReadByte();
		}

		/// <summary> write n bytes to the serial port </summary>
		///
		private void WriteBytes(byte[] buf, int offset, int count)
		{
			Debug.Assert(buf.Length >= offset + count, "buf.Length >= offset + count");
			_serialPort.Write(buf, offset, count);
		}

		private string GetResponseToken(BTResponse btResponse)
		{
			var idx = _btRspList.IndexOfValue(btResponse);
			return (idx < 0) ? String.Empty : _btRspList.Keys[idx];
		}


		#region CRC

		//
		// good article: http://www.lammertbies.nl/comm/info/crc-calculation.html
		// this implementation: http://darkridge.com/~jpr5/archive/alg/node191.html
		//


		/// <summary> Check for valid CRC </summary>
		/// <param name="buf">byte array with data</param>
		/// <param name="offset">starting offset into buffer</param>
		/// <param name="len">length of data to check, including CRC bytes</param>
		private static bool CheckCRC(byte[] buf, int offset, int len)
		{
			return CalculateCRC(buf, offset, len) == 0;
		}

#if CRC_Algorithm

    /// <summary> Brute force CRC algorithm </summary>
    ///	
    static UInt16 CalculateCRC(byte[] buf, int offset, int length)
    {
      //	algorithm found on Internet by Tommy P.
      //		#define CRC_16  0xa001  /*CRC-16 polynomial (used by modbus)*/ 
      //		uint16 crc_16(uint8 *ptr, int len) 
      //		{ 
      //			int i;    /*count through bitshifts */ 
      //			uint16 crc = 0xffff;  /*initialize crc to 0xffff for modbus */ 
      //			while (len--) 
      //			{ 
      //				crc^=*ptr++; 
      //				i=8; 
      //				do 
      //				{ 
      //					crc = (uint16)((crc & 1) ? crc >> 1^CRC_16 : crc>>1); 
      //				} while (--i); 
      //			} 
      //			return crc; 
      //		}

      const ushort crc16 = 0xa001;
      UInt16 crc = 0xffff;			// initialize crc to 0xffff for Modbus
      for (int i = 0; i < length; i++)
      {
        crc ^= buf[offset + i];
        for (int j = 0; j < 8; j++)
          crc = (UInt16)(((crc & 1) == 1) ? (crc >> 1) ^ crc16 : crc >> 1);
      }
      return crc;
    }


#elif CRC_256EntryTable

		/// <summary> 256 entry Table driven CRC algorithm </summary>
		///	
		private static UInt16 CalculateCRC(byte[] buf, int offset, int length)
		{
			//	algorithm found on Internet by Tom H.
			UInt16 crc = 0xffff;
			while (length-- > 0)
			{
				byte btVal = (byte)(buf[offset++] ^ crc);
				crc = (UInt16)(crc >> 8);
				crc = (UInt16)(crc ^ CRCTable[btVal]);
			}
			return crc;
		}

		private static readonly UInt16[] CRCTable = {
		  0X0000, 0XC0C1, 0XC181, 0X0140, 0XC301, 0X03C0, 0X0280, 0XC241,
		  0XC601, 0X06C0, 0X0780, 0XC741, 0X0500, 0XC5C1, 0XC481, 0X0440,
		  0XCC01, 0X0CC0, 0X0D80, 0XCD41, 0X0F00, 0XCFC1, 0XCE81, 0X0E40,
		  0X0A00, 0XCAC1, 0XCB81, 0X0B40, 0XC901, 0X09C0, 0X0880, 0XC841,
		  0XD801, 0X18C0, 0X1980, 0XD941, 0X1B00, 0XDBC1, 0XDA81, 0X1A40,
		  0X1E00, 0XDEC1, 0XDF81, 0X1F40, 0XDD01, 0X1DC0, 0X1C80, 0XDC41,
		  0X1400, 0XD4C1, 0XD581, 0X1540, 0XD701, 0X17C0, 0X1680, 0XD641,
		  0XD201, 0X12C0, 0X1380, 0XD341, 0X1100, 0XD1C1, 0XD081, 0X1040,
		  0XF001, 0X30C0, 0X3180, 0XF141, 0X3300, 0XF3C1, 0XF281, 0X3240,
		  0X3600, 0XF6C1, 0XF781, 0X3740, 0XF501, 0X35C0, 0X3480, 0XF441,
		  0X3C00, 0XFCC1, 0XFD81, 0X3D40, 0XFF01, 0X3FC0, 0X3E80, 0XFE41,
		  0XFA01, 0X3AC0, 0X3B80, 0XFB41, 0X3900, 0XF9C1, 0XF881, 0X3840,
		  0X2800, 0XE8C1, 0XE981, 0X2940, 0XEB01, 0X2BC0, 0X2A80, 0XEA41,
		  0XEE01, 0X2EC0, 0X2F80, 0XEF41, 0X2D00, 0XEDC1, 0XEC81, 0X2C40,
		  0XE401, 0X24C0, 0X2580, 0XE541, 0X2700, 0XE7C1, 0XE681, 0X2640,
		  0X2200, 0XE2C1, 0XE381, 0X2340, 0XE101, 0X21C0, 0X2080, 0XE041,
		  0XA001, 0X60C0, 0X6180, 0XA141, 0X6300, 0XA3C1, 0XA281, 0X6240,
		  0X6600, 0XA6C1, 0XA781, 0X6740, 0XA501, 0X65C0, 0X6480, 0XA441,
		  0X6C00, 0XACC1, 0XAD81, 0X6D40, 0XAF01, 0X6FC0, 0X6E80, 0XAE41,
		  0XAA01, 0X6AC0, 0X6B80, 0XAB41, 0X6900, 0XA9C1, 0XA881, 0X6840,
		  0X7800, 0XB8C1, 0XB981, 0X7940, 0XBB01, 0X7BC0, 0X7A80, 0XBA41,
		  0XBE01, 0X7EC0, 0X7F80, 0XBF41, 0X7D00, 0XBDC1, 0XBC81, 0X7C40,
		  0XB401, 0X74C0, 0X7580, 0XB541, 0X7700, 0XB7C1, 0XB681, 0X7640,
		  0X7200, 0XB2C1, 0XB381, 0X7340, 0XB101, 0X71C0, 0X7080, 0XB041,
		  0X5000, 0X90C1, 0X9181, 0X5140, 0X9301, 0X53C0, 0X5280, 0X9241,
		  0X9601, 0X56C0, 0X5780, 0X9741, 0X5500, 0X95C1, 0X9481, 0X5440,
		  0X9C01, 0X5CC0, 0X5D80, 0X9D41, 0X5F00, 0X9FC1, 0X9E81, 0X5E40,
		  0X5A00, 0X9AC1, 0X9B81, 0X5B40, 0X9901, 0X59C0, 0X5880, 0X9841,
		  0X8801, 0X48C0, 0X4980, 0X8941, 0X4B00, 0X8BC1, 0X8A81, 0X4A40,
		  0X4E00, 0X8EC1, 0X8F81, 0X4F40, 0X8D01, 0X4DC0, 0X4C80, 0X8C41,
		  0X4400, 0X84C1, 0X8581, 0X4540, 0X8701, 0X47C0, 0X4680, 0X8641,
		  0X8201, 0X42C0, 0X4380, 0X8341, 0X4100, 0X81C1, 0X8081, 0X4040 
    };

#elif CRC_16EntryTable

    private UInt16 _bpCRC;
    private const UInt16 CRC16 = 0xa001;		// Modbus CRC-16 Polynomial

    UInt16 CalculateCRC(byte[] buf, int offset, int count)
    {
      _bpCRC = 0xffff;						// initialize crc to 0xffff for Modbus

      for (int i = 0; i < count; i++)
      {
        AddCRC(buf[offset + i]);
      }
      return _bpCRC;
    }

    //void addCRC(byte bVal)
    //{
    //  bpCRC ^= bVal;
    //  for (int i = 0; i < 8; i++)
    //  {
    //    byte lsb = (byte)(bpCRC & 0x0001);
    //    bpCRC >>= 1;
    //    if (lsb == 1)
    //      bpCRC ^= CRC_16;
    //  }
    //}

    void AddCRC(byte bVal)
    {
      /* compute checksum of lower four bits of bVal */
      ushort r = _crc16Table[_bpCRC & 0xF];
      _bpCRC = (UInt16)((_bpCRC >> 4) & 0x0FFF);
      _bpCRC = (UInt16)(_bpCRC ^ r ^ _crc16Table[bVal & 0xF]);

      /* now compute checksum of upper four bits of *p */
      r = _crc16Table[_bpCRC & 0xF];
      _bpCRC = (UInt16)((_bpCRC >> 4) & 0x0FFF);
      _bpCRC = (UInt16)(_bpCRC ^ r ^ _crc16Table[(bVal >> 4) & 0xF]);
    }

	  readonly UInt16[] _crc16Table = {
					0x0000, 0xCC01, 0xD801, 0x1400, 0xF001, 0x3C00, 0x2800, 0xE401,
					0xA001, 0x6C00, 0x7800, 0xB401, 0x5000, 0x9C01, 0x8801, 0x4400 };
#endif

		#endregion


		#region Initialization

		private void InitializeCmdRspLists()
		{
			// list of cmdInfo objects { ASCII command string, expected response, binary command, direction, timeout }
			//
			_btCmdList = new SortedList<BTCommand, BTCmdInfo>
    		{
				{BTCommand.GetVersion,			new BTCmdInfo("GET_VER",		BTResponse.Version,			0x10, "G",	BTComDataDir.FromBT,	1000) },
				{BTCommand.Reset,				new BTCmdInfo("RESET",			 BTResponse.OK,				0x11, "c",	BTComDataDir.None,		1000) },
				{BTCommand.InitEEPROM,			new BTCmdInfo("INIT_EEPROM",	BTResponse.OK,				0x12, "I",	BTComDataDir.None,	   10000) },
				{BTCommand.GetEEPROM,			new BTCmdInfo("GET_EEPROM",		BTResponse.EEPROM,			0x23, "~",	BTComDataDir.FromBT,	1000) },
				{BTCommand.SetEEPROM,			new BTCmdInfo("SET_EEPROM",		BTResponse.EEPROM,			0x14, "~",	BTComDataDir.Both,		10000) },
				{BTCommand.GetAlarm,			new BTCmdInfo("GET_ALARM",		BTResponse.AlarmState,		0x15, "e",	BTComDataDir.FromBT,	1000) },
				{BTCommand.SetAlarm,			new BTCmdInfo("SET_ALARM",		BTResponse.OK,				0x16, "V",	BTComDataDir.ToBT,		1000) },
				{BTCommand.ScanTempSensors,		new BTCmdInfo("SCAN_TS",		BTResponse.TempSensorScan,	0x17, "J",	BTComDataDir.FromBT,	1000) },

				{BTCommand.GetRecipe,			new BTCmdInfo("GET_PROG",		BTResponse.Recipe,			0x18, "E",	BTComDataDir.FromBT,	1000) },
				{BTCommand.SetRecipe,			new BTCmdInfo("SET_PROG",		BTResponse.Recipe,			0x19, "O",	BTComDataDir.ToBT,		1000) },
				{BTCommand.GetCalcTemps,		new BTCmdInfo("GET_CALCTEMPS",	BTResponse.CalcTemps,		0x1a, "l",	BTComDataDir.FromBT,	1000) },
				{BTCommand.GetCalcVols,			new BTCmdInfo("GET_CALCVOLS",	BTResponse.CalcVols,		0x1b, "m",	BTComDataDir.FromBT,	1000) },
				{BTCommand.GetLogStatus,  		new BTCmdInfo("GET_LOGSTATUS",  BTResponse.LogStatus,		0x1c, "~",	BTComDataDir.FromBT,	1000) },
				{BTCommand.SetLogStatus,		new BTCmdInfo("SET_LOGSTATUS",  BTResponse.OK,				0x1d, "~",	BTComDataDir.ToBT,		1000) },
				{BTCommand.GetLog,			    new BTCmdInfo("GET_LOG",		BTResponse.LogData,			0x1e, "~",	BTComDataDir.FromBT,	1000) },
                               
				{BTCommand.GetBoilTemp,			new BTCmdInfo("GET_BOIL",	    BTResponse.BoilTemp,		0x20, "A",	BTComDataDir.FromBT,	1000) },
				{BTCommand.GetBoilPower,		new BTCmdInfo("GET_BOILPWR",	BTResponse.BoilPower,		0x21, "f",	BTComDataDir.FromBT,	1000) },
				{BTCommand.GetDelayTime,		new BTCmdInfo("GET_DELAYTIME",	BTResponse.DelayTime,		0x22, "g",	BTComDataDir.FromBT,	1000) },
				{BTCommand.GetEvapRate,			new BTCmdInfo("GET_EVAP",		BTResponse.EvapRate,		0x23, "C",	BTComDataDir.FromBT,	1000) },
				{BTCommand.GetGrainTemp,		new BTCmdInfo("GET_GRAINTEMP",	BTResponse.GrainTemp,		0x24, "h",	BTComDataDir.FromBT,	1000) },
				{BTCommand.GetHeatOutputConfig,	new BTCmdInfo("GET_OSET",		BTResponse.OutputSettings,	0x25, "D",	BTComDataDir.FromBT,	1000) },
				{BTCommand.GetTempSensorAddr,	new BTCmdInfo("GET_TS",		    BTResponse.TempSensorAddr,	0x26, "F",	BTComDataDir.FromBT,	1000) },
				{BTCommand.GetValveProfile,		new BTCmdInfo("GET_VLVCFG",		BTResponse.ValveConfig,		0x27, "d",	BTComDataDir.FromBT,	1000) },
				{BTCommand.GetVesselCalib,		new BTCmdInfo("GET_CAL",	    BTResponse.VesselCalib,		0x28, "B",	BTComDataDir.FromBT,	1500) },
				{BTCommand.GetVolumnSetting,	new BTCmdInfo("GET_VSET",		BTResponse.VolumeSetting,	0x29, "H",	BTComDataDir.FromBT,	1000) },

				{BTCommand.SetBoilTemp,			new BTCmdInfo("SET_BOIL",		BTResponse.BoilTemp,		0x30, "K",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetBoilPower,		new BTCmdInfo("SET_BOILPWR",	BTResponse.BoilPower,		0x31, "i",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetDelayTime,		new BTCmdInfo("SET_DELAYTIME",	BTResponse.DelayTime,		0x32, "j",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetEvapRate,			new BTCmdInfo("SET_EVAP",		BTResponse.EvapRate,		0x33, "M",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetGrainTemp,		new BTCmdInfo("SET_GRAINTEMP",	BTResponse.GrainTemp,		0x34, "k",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetHeatOutputConfig,	new BTCmdInfo("SET_OSET",		BTResponse.OutputSettings,	0x35, "N",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetTempSensorAddr,	new BTCmdInfo("SET_TS",		    BTResponse.TempSensorAddr,  0x36, "P",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetValveProfile,		new BTCmdInfo("SET_VLVCFG",		BTResponse.ValveConfig,     0x37, "Q",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetVesselCalib,		new BTCmdInfo("SET_CAL",		BTResponse.VesselCalib,     0x38, "L",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetVolumeSetting,	new BTCmdInfo("SET_VSET",		BTResponse.VolumeSetting,   0x39, "R",	BTComDataDir.ToBT,	1000) },


				{BTCommand.StepAdvance,			new BTCmdInfo("ADV_STEP",		BTResponse.OK, 0x40, "S",	BTComDataDir.None,	1000) },
				{BTCommand.StepExit,			new BTCmdInfo("EXIT_STEP",		BTResponse.OK, 0x41, "T",	BTComDataDir.None,	1000) },
				{BTCommand.StepInit,			new BTCmdInfo("INIT_STEP",		BTResponse.OK, 0x42, "U",	BTComDataDir.None,	1000) },
				{BTCommand.SetAutoValve,		new BTCmdInfo("SET_AUTOVLV",	BTResponse.OK, 0x43, "W",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetSetpoint,			new BTCmdInfo("SET_SETPOINT",	BTResponse.OK, 0x44, "X",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetTimerStatus,		new BTCmdInfo("SET_TIMERSTATUS",BTResponse.OK, 0x45, "Y",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetTimerValue,		new BTCmdInfo("SETTIMERVALUE",	BTResponse.OK, 0x46, "Z",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetValveState,		new BTCmdInfo("SET_VLV",		BTResponse.OK, 0x47, "a",	BTComDataDir.ToBT,	1000) },
				{BTCommand.SetValvePreference,	new BTCmdInfo("SET_VLVPRF",		BTResponse.OK, 0x48, "b",	BTComDataDir.ToBT,	1000) },

				{BTCommand.LogStepProg,			new BTCmdInfo("",	BTResponse.Error,	0x48, "n",	BTComDataDir.FromBT,	1000) },
				{BTCommand.LogTimer,			new BTCmdInfo("",	BTResponse.Error,	0x48, "o",	BTComDataDir.FromBT,	1000) },
				{BTCommand.LogVolume,			new BTCmdInfo("",	BTResponse.Error,	0x48, "p",	BTComDataDir.FromBT,	1000) },
				{BTCommand.LogTemp,				new BTCmdInfo("",	BTResponse.Error,	0x48, "q",	BTComDataDir.FromBT,	1000) },
				{BTCommand.LogSteam,			new BTCmdInfo("",	BTResponse.Error,	0x48, "r",	BTComDataDir.FromBT,	1000) },
				{BTCommand.LogHeatPower,		new BTCmdInfo("",	BTResponse.Error,	0x48, "s",	BTComDataDir.FromBT,	1000) },
				{BTCommand.LogHeatSetpoint,		new BTCmdInfo("",	BTResponse.Error,	0x48, "t",	BTComDataDir.FromBT,	1000) },
				{BTCommand.LogAutoValve,		new BTCmdInfo("",	BTResponse.Error,	0x48, "u",	BTComDataDir.FromBT,	1000) },
				{BTCommand.LogValveBits,		new BTCmdInfo("",	BTResponse.Error,	0x48, "v",	BTComDataDir.FromBT,	1000) },
				{BTCommand.LogValvePref,		new BTCmdInfo("",	BTResponse.Error,	0x48, "w",	BTComDataDir.FromBT,	1000) }
			};
			// verify that all BTResponses have been assigned a keyword
			Debug.Assert(_btCmdList.Count == Enum.GetNames(typeof(BTCommand)).Length, "_btCmdList.Count == Enum.GetNames(typeof(BTCommand)).Length");


			_btRspList = new SortedList<string, BTResponse>
    		{
				{"None",			BTResponse.None},
				{"Error",			BTResponse.Error},
				{"UnknownResponse",	BTResponse.UnknownResponse},

				{"OK",				BTResponse.OK},
				{"BAD_PARAM",		BTResponse.BadParam},
				{"FIELD_OVERFLOW",	BTResponse.FieldOverflow},
				{"MSG_OVERFLOW",	BTResponse.MessageOverflow},
				{"UNKNOWN_CMD",		BTResponse.UnknowCommand},

				{"BOIL_TEMP",		BTResponse.BoilTemp},
				{"BOIL_PWR",		BTResponse.BoilPower},
				{"????",			BTResponse.ConfigVersion},		// ?????
				{"EVAP_RATE",		BTResponse.EvapRate},
				{"EEPROM",			BTResponse.EEPROM},
				{"LOG_STATUS",		BTResponse.LogStatus},

				{"OUTPUT_SET",		BTResponse.OutputSettings},
				{"PROG_SET",		BTResponse.Recipe},
				{"TS_ADDR",			BTResponse.TempSensorAddr},
				{"TS_SCAN",			BTResponse.TempSensorScan},
				{"VLV_CONFIG",		BTResponse.ValveConfig},
				{"VOL_CALIB",		BTResponse.VesselCalib},
				{"VOL_SET",			BTResponse.VolumeSetting},

				{"GRAIN_TEMP",      BTResponse.GrainTemp},
				{"DELAY_TIME",      BTResponse.DelayTime},
				{"CALC_VOLS",       BTResponse.CalcVols},
				{"CALC_TEMPS",      BTResponse.CalcTemps},
				{"LOG_DATA",        BTResponse.LogData},

				{"ALARM",			BTResponse.AlarmState},
				{"AUTOVLV",			BTResponse.AutoValveState},
				{"SETPOINT",		BTResponse.SetpointValue},
				{"STEAM",			BTResponse.SteamPressure},
				{"STEPPRG",			BTResponse.ProgramStep},
				{"TEMP",			BTResponse.TempValue},
				{"TIMER",			BTResponse.TimerState},
				{"VLVBITS",			BTResponse.ValvesState},
				{"VLVPRF",			BTResponse.ActiveVlvProfile},
				{"VOL",				BTResponse.VolumeValue},

				{"SOFT_RESET",		BTResponse.SoftReset},
				{"VER",				BTResponse.Version}
			};
			// verify that all BTResponses have been assigned a keyword
			Debug.Assert(_btRspList.Count == Enum.GetNames(typeof(BTResponse)).Length, "_btRspList.Count == Enum.GetNames(typeof(BTResponse)).Length");
		}

		#endregion


		#region Dispose

		private bool _alreadyDisposed;


		/// <summary> Finalizer </summary>
		/// <remarks>
		/// Call the virtual Dispose method.
		/// </remarks>
		~BTCommunicator()
		{
			Dispose(false);
		}

		/// <summary> Implementation of IDisposable </summary>
		/// <remarks>
		/// 1. Call the virtual Dispose method.
		/// 2. Suppress Finalization.</remarks>
		public void Dispose()
		{
			Dispose(true);
			GC.SuppressFinalize(this);
		}

		/// <summary> Virtual Dispose method </summary>
		protected virtual void Dispose(bool isDisposing)
		{
			// don't dispose more than once
			if (_alreadyDisposed)
				return;

			if (isDisposing)
			{
				// free managed resources
				if (_serialPort != null)
					_serialPort.Dispose();
			}

			// free unmanaged resources


			//set disposed flag
			_alreadyDisposed = true;
		}

		#endregion
	}

}
