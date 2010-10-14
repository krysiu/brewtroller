/*
	Copyright (C) 2010, Tom Harkaway, TL Systems, LLC (tlsystems_AT_comcast_DOT_net)

	BTSerialComTester is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	BTSerialComTester is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with BTSerialComTester.  If not, see <http://www.gnu.org/licenses/>.
*/

using System;
using System.Collections.Generic;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using BrewTrollerCommunicator;
using BTSerialComTester.Properties;


namespace BTSerialComTester
{
	public partial class BTSerialComTester : Form
	{
		const string PortUnavailableSuffix = "***";
		const string UnconfiguredPort = "None";

		private readonly BTCommunicator _btCom;
		private bool _logEnabled;
		private bool _alarmState;

		public BTSerialComTester()
		{
			InitializeComponent();

			_btCom = new BTCommunicator
         		{
         			ErrorLogFile = Settings.Default.ErrorLogFile
         		};

			cboVessel.SelectedIndex = 0;
			cboTemps.SelectedIndex = 0;
			cboVolume.SelectedIndex = 0;
			cboProfile.SelectedIndex = 0;
			cboCalibration.SelectedIndex = 0;
			cboRecipeSlot.SelectedIndex = 0;

			UpdateUI();
		}

		private void BTComTest_Load(object sender, EventArgs e)
		{

			// create available port lists
			List<string> comPortList = new List<string>();
			comPortList.AddRange(System.IO.Ports.SerialPort.GetPortNames());

			// if primary port is not in the list, add it with the unavailable indicator
			string comPort = Settings.Default.LastComPort;
			if (comPort != UnconfiguredPort && !comPortList.Contains(comPort))
			{
				comPort = Settings.Default.LastComPort + PortUnavailableSuffix;
				comPortList.Add(comPort);
				//.lblComPortUnavailable.Visible = true;
			}

			// sort the com port lists
			comPortList.Sort();

			// add available/configured ports to the combo boxes
			foreach (string portName in comPortList)
			{
				cboComPorts.Items.Add(portName);
			}

			cboComPorts.SelectedIndex = 0;
			SetPortCombo(cboComPorts, comPort);


		}

		private static void SetPortCombo(ComboBox cbo, string currentValue)
		{
			if (currentValue == UnconfiguredPort)
				currentValue = "";

			if (!cbo.Items.Cast<object>().Any(item => (string) item == currentValue)) 
				return;
			cbo.SelectedItem = currentValue;
			return;
		}


		private void UpdateUI()
		{
			if (_btCom.IsConnected)
			{
				rtbResults.Text = String.Format("Successfully connected to BT using '{0}'.", cboComPorts.SelectedItem);
				lblMode.Text = _btCom.Version.ComType.ToString();
				lblSchema.Text = _btCom.Version.ComSchema.ToString();
				lblUnits.Text = _btCom.Version.Units.ToString();
				lblVersion.Text = _btCom.Version.Version;
				lblBuild.Text = _btCom.Version.BuildNumber.ToString();

				updnBoilPower.Enabled = _btCom.Version.ComSchema > 0;
				btnGetBoilPower.Enabled = _btCom.Version.ComSchema > 0;
				btnSetBoilPower.Enabled = _btCom.Version.ComSchema > 0;
				btnGetGrainTemp.Enabled = _btCom.Version.ComSchema > 0;
				btnSetGrainTemp.Enabled = _btCom.Version.ComSchema > 0;
				btnGetDelayTime.Enabled = _btCom.Version.ComSchema > 0;
				btnSetDelayTime.Enabled = _btCom.Version.ComSchema > 0;
				btnGetCalcVols.Enabled = _btCom.Version.ComSchema > 0;
				btnGetCalcTemps.Enabled = _btCom.Version.ComSchema > 0;
				btnSetAlarm.Enabled = _btCom.Version.ComSchema > 0;
				btnGetAlarm.Enabled = _btCom.Version.ComSchema > 0;
				btnLogging.Enabled = true;
				btnGetLog.Enabled = _btCom.Version.ComSchema > 0;
			}
			else
			{
				lblMode.BackColor = SystemColors.Control;
				lblMode.Text = String.Empty;
				lblUnits.Text = String.Empty;
				lblVersion.Text = String.Empty;
				lblBuild.Text = String.Empty;
			}

			grpGetCommands.Enabled = _btCom.IsConnected;
			grpSetCommands.Enabled = _btCom.IsConnected;
			grpPerfTest.Enabled = _btCom.IsConnected;

			grpEEPROM.Enabled = false; // _btCom.IsConnected;


		}


		private void btnConnect_Click(object sender, EventArgs e)
		{
			if (_btCom.IsConnected)
			{
				_btCom.Disconnect();
			}
			else
			{
				Cursor = Cursors.WaitCursor;
				_btCom.ComRetries = 1;
				_btCom.Connect(Settings.Default.LastComPort + ",115200,N,8,1");
				Cursor = Cursors.Default;

				if (!_btCom.IsConnected)
				{
					rtbResults.ForeColor = Color.Red;
					rtbResults.Text = String.Format("Unable to connect to BT using '{0}'. Check cable and try again.", cboComPorts.SelectedItem);
					return;
				}
			}

			rtbResults.ForeColor = SystemColors.WindowText;

			grpGetCommands.Enabled = _btCom.IsConnected;
			grpSetCommands.Enabled = _btCom.IsConnected;

			btnConnect.Text = _btCom.IsConnected ? "Disconnect" : "Connect";

			UpdateUI();
		}

		private void btnGetVersion_Click(object sender, EventArgs e)
		{
			try
			{
				_btCom.GetVersion();
				rtbResults.Text = _btCom.Version.ToString();
				updnBoilPower.Enabled = _btCom.Version.ComSchema > 0;
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetBoilTemp_Click(object sender, EventArgs e)
		{
			try
			{
				var boilTemp = _btCom.GetBoilTemp();
				rtbResults.Text = String.Format("{0} F", boilTemp);
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetBoilPower_Click(object sender, EventArgs e)
		{
			try
			{
				var boilPower = _btCom.GetBoilPower();
				rtbResults.Text = String.Format("{0} %", boilPower);
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetCal_Click(object sender, EventArgs e)
		{
			try
			{
				var calibration = _btCom.GetVesselCalibration((BTVesselType)cboCalibration.SelectedIndex);
				rtbResults.Text = calibration.ToString();
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetEvap_Click(object sender, EventArgs e)
		{
			try
			{
				var evapRate = _btCom.GetEvapRate();
				rtbResults.Text = String.Format("{0:n2} %/hr.", evapRate * 100);
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetPID_Click(object sender, EventArgs e)
		{
			try
			{
				var pid = _btCom.GetHeatOutputConfig((BTHeatOutputID)cboVessel.SelectedIndex);
				rtbResults.Text = pid.ToString();
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetProfile_Click(object sender, EventArgs e)
		{
			try
			{
				var profile = _btCom.GetValveProfile((BTProfileID)cboProfile.SelectedIndex);
				rtbResults.Text = profile.ToString();
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetTemps_Click(object sender, EventArgs e)
		{
			try
			{
				var tsAddr = _btCom.GetTempSensorAddress((TSLocation)cboTemps.SelectedIndex);
				rtbResults.Text = tsAddr.ToString();
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetVolume_Click(object sender, EventArgs e)
		{
			try
			{
				var volume = _btCom.GetVolumeSetting((BTVesselType)cboVolume.SelectedIndex);
				rtbResults.Text = volume.ToString();
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetRecipe_Click(object sender, EventArgs e)
		{
			try
			{
				var recipe = _btCom.GetRecipe(cboRecipeSlot.SelectedIndex);
				rtbResults.Text = recipe.ToString("verbose", null);
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetCalcVols_Click(object sender, EventArgs e)
		{
			try
			{
				var calcVols = _btCom.GetCalcVols(cboRecipeSlot.SelectedIndex);
				rtbResults.Text = calcVols.ToString("verbose", null);
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetCalcTemps_Click(object sender, EventArgs e)
		{
			try
			{
				var calcTemps = _btCom.GetCalcTemps(cboRecipeSlot.SelectedIndex);
				rtbResults.Text = calcTemps.ToString("verbose", null);
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}


		private void btnGetGrainTemp_Click(object sender, EventArgs e)
		{
			try
			{
				var grainTemp = _btCom.GetGrainTemp();
				rtbResults.Text = String.Format("{0} F", grainTemp);
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetDelayTime_Click(object sender, EventArgs e)
		{
			try
			{
				var delayTime = _btCom.GetDelayTime();
				rtbResults.Text = String.Format("{0} min.", delayTime);
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}


		private void btnSetBoilTemp_Click(object sender, EventArgs e)
		{
			try
			{
				_btCom.SetBoilTemp(updnBoilTemp.Value);
				rtbResults.Text = String.Empty;
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnSetBoilPower_Click(object sender, EventArgs e)
		{
			try
			{
				_btCom.SetBoilPower(updnBoilPower.Value);
				rtbResults.Text = String.Empty;
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnSetEvapRate_Click_1(object sender, EventArgs e)
		{
			try
			{
				decimal evapRate = updnEvapRate.Value;
				_btCom.SetEvapRate(evapRate);
				rtbResults.Text = String.Empty;
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void setGrainTemp_Click(object sender, EventArgs e)
		{
			try
			{
				decimal grainTemp = updnGrainTemp.Value;
				_btCom.SetGrainTemp(grainTemp);
				rtbResults.Text = String.Empty;
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnSetDelayTime_Click(object sender, EventArgs e)
		{
			try
			{
				decimal delayTime = updnDelayTime.Value;
				_btCom.SetDelayTime(delayTime);
				rtbResults.Text = String.Empty;
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnGetAlarm_Click(object sender, EventArgs e)
		{
			try
			{
				_alarmState = _btCom.GetAlarm();
				rtbResults.Text = String.Format("Alarm is {0}!", _alarmState ? "On" : "Off");
				lblAlarm.Visible = _alarmState;
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnSetAlarm_Click(object sender, EventArgs e)
		{
			try
			{
				_btCom.SetAlarm(!_alarmState);
				btnGetAlarm_Click(null, null);
				btnSetAlarm.Text = _alarmState ? "Clear Alarm" : "Set Alarm";
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}




		private void btnHelp_Click(object sender, EventArgs e)
		{
			using (AboutBox aboutDlg = new AboutBox())
			{
				aboutDlg.ShowDialog();
			}
		}

		private void cboComPorts_SelectedIndexChanged(object sender, EventArgs e)
		{
			Settings.Default.LastComPort = cboComPorts.SelectedItem.ToString();
			Settings.Default.Save();
		}

		private void btnLog_Click(object sender, EventArgs e)
		{
			if (_logEnabled)
			{
				_btCom.SetLogStatus(false);
				btnLogging.Text = Resources.LogOn;
				btnLogging.BackColor = SystemColors.Control;
				_logEnabled = false;
			}
			else
			{
				_btCom.SetLogStatus(true);
				btnLogging.BackColor = Color.LightGreen;
				btnLogging.Text = Resources.LogOff;
				_logEnabled = true;
				try
				{
					var sb = new StringBuilder();
					while (true)
					{
						var btStr = _btCom.GetBTResponse(3000);
						sb.AppendFormat("{0}\n", btStr);
						if (!btStr.Contains("VLVPRF")) 
							continue;
						rtbResults.Text = sb.ToString();
						sb.Length = 0;
						Application.DoEvents();
					}
				}
				catch
				{

				}
			}
		}

		private void btnGetLog_Click(object sender, EventArgs e)
		{
			try
			{
				rtbResults.Text = _btCom.GetLog();
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void DisplayComError(Exception ex)
		{
			rtbResults.Text = ex.Message;
			tsStatus.Text = ex.Message;
			if (ex.InnerException != null)
			{
				rtbResults.Text += Resources.NewLinePlusSpace + ex.InnerException.Message;
				tsStatus.Text = ex.InnerException.Message;
			}
		}

		private void btnStartSpeedTest_Click(object sender, EventArgs e)
		{
			if (File.Exists(Settings.Default.ErrorLogFile))
				File.Delete(Settings.Default.ErrorLogFile);
			btnStartSpeedTest.BackColor = Color.LimeGreen;
			_btCom.ComRetries = 1;
			var errorCount = 0;
			tbErrorCount.Text = String.Empty;
			tbErrorCount.BackColor = SystemColors.Control;

			for (int i = 0; i < updnTestCount.Value; i++)
			{
				try
				{
					rtbResults.Text = _btCom.GetLog();
				}
				catch (Exception)
				{
					errorCount++;
					tbErrorCount.Text = errorCount.ToString();
					tbErrorCount.BackColor = Color.Red;
				}
				tbCurrentCount.Text = (i + 1).ToString();
				Application.DoEvents();
			}
			btnStartSpeedTest.BackColor = SystemColors.Control;
			_btCom.ComRetries = 3;
		}

		private void btnDisplayErrors_Click(object sender, EventArgs e)
		{
			using (TextReader tr = new StreamReader(Settings.Default.ErrorLogFile))
			{
				try
				{
					rtbResults.Text = tr.ReadToEnd();
				}
				catch
				{
				}
				finally
				{
					tr.Close();
				}
			}

		}

		BT_EEPROM _eePROM = new BT_EEPROM();

		private void btnReadEE_Click(object sender, EventArgs e)
		{
			try
			{
				UInt16 address = (UInt16)updnReadAddressEE.Value;
				int byteCount = (int)updnReadLengthEE.Value;
				_eePROM = _btCom.GetEEPROM(address, byteCount);
				rtbEEPROM.Text = _eePROM.HexDump().ToString();
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnWriteEEPROM_Click(object sender, EventArgs e)
		{
			ClearSts();
			_eePROM.Address = (UInt16)updnWriteAddressEE.Value;
			var strRec = txtDataEE.Text;
			if (strRec.Length %2 == 1)
				strRec = strRec.Substring(0, strRec.Length-1);
			_eePROM.ByteCount = strRec.Length/2;
			for (var i = 0; i < txtDataEE.Text.Length / 2; i++)
			{
				byte btVal;
				if (!byte.TryParse(strRec.Substring(i*2, 2), NumberStyles.HexNumber, null, out btVal))
					throw new ArgumentException("Unable to parse Data");
				_eePROM.Data[_eePROM.Address+i] = btVal;
			}
			try
			{
				_btCom.SetEEPROM(_eePROM);
				rtbEEPROM.Text = _eePROM.HexDump().ToString();
			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
			DoneSts();
		}

		private void ClearSts()
		{
			tsStatus.Text = String.Empty;
		}

		private void DoneSts()
		{
			tsStatus.Text = Resources.StatusBar_Done;
		}
		
		private void btnBackupEEPROM_Click(object sender, EventArgs e)
		{
			try
			{
				using (var dlg = new SaveFileDialog())
				{
					dlg.DefaultExt = "hex";
					dlg.Filter = Resources.IntelHexFileDescriptor;
					dlg.CheckFileExists = false;
					dlg.CheckPathExists = false;
					if (!Settings.Default.LastEEPromFile.IsNullOrEmpty() &&
						File.Exists(Settings.Default.LastEEPromFile))
					{
						dlg.InitialDirectory = Path.GetDirectoryName(Settings.Default.LastEEPromFile);
					}
	
					if (dlg.ShowDialog() == DialogResult.Cancel)
						return;

					Settings.Default.LastEEPromFile = dlg.FileName;
					Settings.Default.Save();
				}

				var eePROM = new BT_EEPROM();
				for (UInt16 i = 0; i < 2048; i += 64)
					_btCom.GetEEPROM(i, 64, eePROM);

				eePROM.Address = 0;
				eePROM.ByteCount = 2048;
				rtbEEPROM.Text = eePROM.HexDump().ToString();

				eePROM.SaveToFile(Settings.Default.LastEEPromFile);


			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void btnRestoreEEPROM_Click(object sender, EventArgs e)
		{
			try
			{
				using (var dlg = new OpenFileDialog())
				{
					dlg.DefaultExt = "hex";
					dlg.Filter = Resources.IntelHexFileDescriptor;
					dlg.CheckFileExists = false;
					dlg.CheckPathExists = false;
					if (!Settings.Default.LastEEPromFile.IsNullOrEmpty() &&
						File.Exists(Settings.Default.LastEEPromFile))
					{
						dlg.InitialDirectory = Path.GetDirectoryName(Settings.Default.LastEEPromFile);
					}

					if (dlg.ShowDialog() == DialogResult.Cancel)
						return;

					Settings.Default.LastEEPromFile = dlg.FileName;
					Settings.Default.Save();
				}

				var eeprom = new BT_EEPROM();
				eeprom.LoadFromIntelHexFile(Settings.Default.LastEEPromFile);

				for (UInt16 address = 0; address < 2048; address += 64)
				{
					eeprom.Address = address;
					eeprom.ByteCount = 64;
					_btCom.SetEEPROM(eeprom);
				}


			}
			catch (Exception ex)
			{
				DisplayComError(ex);
			}
		}

		private void chkHexReadAddress_CheckedChanged(object sender, EventArgs e)
		{
			updnReadAddressEE.Hexadecimal = chkHexReadAddress.Checked;
		}
		private void chkHexWriteAddress_CheckedChanged(object sender, EventArgs e)
		{
			updnWriteAddressEE.Hexadecimal = chkHexWriteAddress.Checked;
		}
		private void chkHexReadCount_CheckedChanged(object sender, EventArgs e)
		{
			updnReadLengthEE.Hexadecimal = chkHexReadLength.Checked;
		}
		private void chkHexWriteLength_CheckedChanged(object sender, EventArgs e)
		{
			updnWriteLengthEE.Hexadecimal = chkHexWriteLength.Checked;
		}

		private void btnInitializeEE_Click(object sender, EventArgs e)
		{
			var rslt = MessageBox.Show(Resources.WarningMsg_InitializeEE,
									   Resources.MsgBoxHeader_InitializeEEPROM, 
									   MessageBoxButtons.OKCancel, 
									   MessageBoxIcon.Warning);
			if (rslt == DialogResult.Cancel)
				return;

			_btCom.InitializeEEPROM();
		}

		//private void cboWriteLengthEE_SelectedIndexChanged(object sender, EventArgs e)
		//{
		//    switch (Convert.ToInt16(cboWriteLengthEE.SelectedItem))
		//    {
		//    case 1:
		//        txtDataEE.Text = "00";
		//        break;
		//    case 2:
		//        txtDataEE.Text = "0011";
		//        break;
		//    case 4:
		//        txtDataEE.Text = "00112233";
		//        break;
		//    case 8:
		//        txtDataEE.Text = "0011223344556677";
		//        break;
		//    case 16:
		//        txtDataEE.Text = "00112233445566778899aabbccddeeff";
		//        break;
		//    case 32:
		//        txtDataEE.Text = "00112233445566778899aabbccddeeff" +
		//                         "00112233445566778899aabbccddeeff";
		//        break;
		//    case 64:
		//        txtDataEE.Text = "00112233445566778899aabbccddeeff" +
		//                         "00112233445566778899aabbccddeeff" +
		//                         "00112233445566778899aabbccddeeff" +
		//                         "00112233445566778899aabbccddeeff";
		//        break;
		//    }
		//}

		private void updnWriteLengthEE_ValueChanged(object sender, EventArgs e)
		{
			var sb = new StringBuilder(128);
			const string hexChars = "0123456789abcdef";
			
			for (var i=0; i<updnWriteLengthEE.Value; i++)
			{
				sb.Append(hexChars[i % 16]);
				sb.Append(hexChars[i % 16]);
			}
			txtDataEE.Text = sb.ToString();
		}


	}



}
