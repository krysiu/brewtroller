namespace BTSerialComTester
{
	partial class BTSerialComTester
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.btnConnect = new System.Windows.Forms.Button();
			this.btnGetVersion = new System.Windows.Forms.Button();
			this.grpGetCommands = new System.Windows.Forms.GroupBox();
			this.btnGetLogStatus = new System.Windows.Forms.Button();
			this.btnGetAlarm = new System.Windows.Forms.Button();
			this.btnGetLog = new System.Windows.Forms.Button();
			this.btnLogging = new System.Windows.Forms.Button();
			this.btnGetBoilPower = new System.Windows.Forms.Button();
			this.brpRecipe = new System.Windows.Forms.GroupBox();
			this.cboRecipeSlot = new System.Windows.Forms.ComboBox();
			this.btnGetCalcTemps = new System.Windows.Forms.Button();
			this.getRecipe = new System.Windows.Forms.Button();
			this.btnGetCalcVols = new System.Windows.Forms.Button();
			this.btnGetDelayTime = new System.Windows.Forms.Button();
			this.btnGetGrainTemp = new System.Windows.Forms.Button();
			this.btnGetVolume = new System.Windows.Forms.Button();
			this.cboVolume = new System.Windows.Forms.ComboBox();
			this.cboCalibration = new System.Windows.Forms.ComboBox();
			this.cboProfile = new System.Windows.Forms.ComboBox();
			this.btnGetCal = new System.Windows.Forms.Button();
			this.btnGetProfile = new System.Windows.Forms.Button();
			this.cboTemps = new System.Windows.Forms.ComboBox();
			this.btnGetTemps = new System.Windows.Forms.Button();
			this.btnGetPID = new System.Windows.Forms.Button();
			this.cboVessel = new System.Windows.Forms.ComboBox();
			this.btnGetEvap = new System.Windows.Forms.Button();
			this.btnGetBoilTemp = new System.Windows.Forms.Button();
			this.lblUnits = new System.Windows.Forms.Label();
			this.btnHelp = new System.Windows.Forms.Button();
			this.lblComType = new System.Windows.Forms.Label();
			this.cboComPorts = new System.Windows.Forms.ComboBox();
			this.grpSetCommands = new System.Windows.Forms.GroupBox();
			this.btnSetAlarm = new System.Windows.Forms.Button();
			this.btnSetBoilPower = new System.Windows.Forms.Button();
			this.lblGrainUnits = new System.Windows.Forms.Label();
			this.lblDelayUnits = new System.Windows.Forms.Label();
			this.updnDelayTime = new System.Windows.Forms.NumericUpDown();
			this.btnSetDelayTime = new System.Windows.Forms.Button();
			this.updnGrainTemp = new System.Windows.Forms.NumericUpDown();
			this.btnSetGrainTemp = new System.Windows.Forms.Button();
			this.lblEvapUnits = new System.Windows.Forms.Label();
			this.updnEvapRate = new System.Windows.Forms.NumericUpDown();
			this.btnSetEvapRate = new System.Windows.Forms.Button();
			this.lblBoilPowerUnits = new System.Windows.Forms.Label();
			this.lglDeg = new System.Windows.Forms.Label();
			this.updnBoilPower = new System.Windows.Forms.NumericUpDown();
			this.updnBoilTemp = new System.Windows.Forms.NumericUpDown();
			this.btnSetBoil = new System.Windows.Forms.Button();
			this.lblVerLbl = new System.Windows.Forms.Label();
			this.lblComTypeLbl = new System.Windows.Forms.Label();
			this.lblVersion = new System.Windows.Forms.Label();
			this.lblBuild = new System.Windows.Forms.Label();
			this.lblBuildLbl = new System.Windows.Forms.Label();
			this.lblUnitsLbl = new System.Windows.Forms.Label();
			this.lblSchema = new System.Windows.Forms.Label();
			this.lblSchemaLbl = new System.Windows.Forms.Label();
			this.grpPerfTest = new System.Windows.Forms.GroupBox();
			this.btnDisplayErrors = new System.Windows.Forms.Button();
			this.lblTestCountLbl = new System.Windows.Forms.Label();
			this.lblErrCount = new System.Windows.Forms.Label();
			this.lblCountlbl = new System.Windows.Forms.Label();
			this.tbErrorCount = new System.Windows.Forms.TextBox();
			this.tbCurrentCount = new System.Windows.Forms.TextBox();
			this.updnTestCount = new System.Windows.Forms.NumericUpDown();
			this.btnStartSpeedTest = new System.Windows.Forms.Button();
			this.rtbResults = new System.Windows.Forms.RichTextBox();
			this.lblAlarm = new System.Windows.Forms.Label();
			this.tabControl1 = new System.Windows.Forms.TabControl();
			this.tabTest = new System.Windows.Forms.TabPage();
			this.tabEEPROM = new System.Windows.Forms.TabPage();
			this.grpEEPROM = new System.Windows.Forms.GroupBox();
			this.chkHexWriteLength = new System.Windows.Forms.CheckBox();
			this.rtbEEPROM = new System.Windows.Forms.RichTextBox();
			this.updnWriteLengthEE = new System.Windows.Forms.NumericUpDown();
			this.txtDataEE = new System.Windows.Forms.TextBox();
			this.btnReadEE = new System.Windows.Forms.Button();
			this.btnInitializeEE = new System.Windows.Forms.Button();
			this.updnReadLengthEE = new System.Windows.Forms.NumericUpDown();
			this.chkHexReadLength = new System.Windows.Forms.CheckBox();
			this.updnReadAddressEE = new System.Windows.Forms.NumericUpDown();
			this.lblAddressEE = new System.Windows.Forms.Label();
			this.chkHexWriteAddress = new System.Windows.Forms.CheckBox();
			this.lblLengthEE = new System.Windows.Forms.Label();
			this.lblEEPROMData = new System.Windows.Forms.Label();
			this.chkHexReadAddress = new System.Windows.Forms.CheckBox();
			this.lblWriteAddress = new System.Windows.Forms.Label();
			this.btnWriteEEPROM = new System.Windows.Forms.Button();
			this.updnWriteAddressEE = new System.Windows.Forms.NumericUpDown();
			this.btnBackupEEPROM = new System.Windows.Forms.Button();
			this.btnRestoreEEPROM = new System.Windows.Forms.Button();
			this.tabLogging = new System.Windows.Forms.TabPage();
			this.grpConnect = new System.Windows.Forms.GroupBox();
			this.lblBTFW = new System.Windows.Forms.Label();
			this.lblCom = new System.Windows.Forms.Label();
			this.statusBar = new System.Windows.Forms.StatusStrip();
			this.tsStatus = new System.Windows.Forms.ToolStripStatusLabel();
			this.toolStripStatusLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
			this.grpGetCommands.SuspendLayout();
			this.brpRecipe.SuspendLayout();
			this.grpSetCommands.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)(this.updnDelayTime)).BeginInit();
			((System.ComponentModel.ISupportInitialize)(this.updnGrainTemp)).BeginInit();
			((System.ComponentModel.ISupportInitialize)(this.updnEvapRate)).BeginInit();
			((System.ComponentModel.ISupportInitialize)(this.updnBoilPower)).BeginInit();
			((System.ComponentModel.ISupportInitialize)(this.updnBoilTemp)).BeginInit();
			this.grpPerfTest.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)(this.updnTestCount)).BeginInit();
			this.tabControl1.SuspendLayout();
			this.tabTest.SuspendLayout();
			this.tabEEPROM.SuspendLayout();
			this.grpEEPROM.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)(this.updnWriteLengthEE)).BeginInit();
			((System.ComponentModel.ISupportInitialize)(this.updnReadLengthEE)).BeginInit();
			((System.ComponentModel.ISupportInitialize)(this.updnReadAddressEE)).BeginInit();
			((System.ComponentModel.ISupportInitialize)(this.updnWriteAddressEE)).BeginInit();
			this.grpConnect.SuspendLayout();
			this.statusBar.SuspendLayout();
			this.SuspendLayout();
			// 
			// btnConnect
			// 
			this.btnConnect.Location = new System.Drawing.Point(10, 11);
			this.btnConnect.Name = "btnConnect";
			this.btnConnect.Size = new System.Drawing.Size(111, 42);
			this.btnConnect.TabIndex = 0;
			this.btnConnect.Text = "Connect";
			this.btnConnect.UseVisualStyleBackColor = true;
			this.btnConnect.Click += new System.EventHandler(this.btnConnect_Click);
			// 
			// btnGetVersion
			// 
			this.btnGetVersion.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnGetVersion.Location = new System.Drawing.Point(16, 19);
			this.btnGetVersion.Name = "btnGetVersion";
			this.btnGetVersion.Size = new System.Drawing.Size(75, 23);
			this.btnGetVersion.TabIndex = 1;
			this.btnGetVersion.Text = "Version";
			this.btnGetVersion.UseVisualStyleBackColor = true;
			this.btnGetVersion.Click += new System.EventHandler(this.btnGetVersion_Click);
			// 
			// grpGetCommands
			// 
			this.grpGetCommands.Controls.Add(this.btnGetLogStatus);
			this.grpGetCommands.Controls.Add(this.btnGetAlarm);
			this.grpGetCommands.Controls.Add(this.btnGetLog);
			this.grpGetCommands.Controls.Add(this.btnLogging);
			this.grpGetCommands.Controls.Add(this.btnGetBoilPower);
			this.grpGetCommands.Controls.Add(this.brpRecipe);
			this.grpGetCommands.Controls.Add(this.btnGetDelayTime);
			this.grpGetCommands.Controls.Add(this.btnGetGrainTemp);
			this.grpGetCommands.Controls.Add(this.btnGetVolume);
			this.grpGetCommands.Controls.Add(this.cboVolume);
			this.grpGetCommands.Controls.Add(this.cboCalibration);
			this.grpGetCommands.Controls.Add(this.cboProfile);
			this.grpGetCommands.Controls.Add(this.btnGetCal);
			this.grpGetCommands.Controls.Add(this.btnGetProfile);
			this.grpGetCommands.Controls.Add(this.cboTemps);
			this.grpGetCommands.Controls.Add(this.btnGetTemps);
			this.grpGetCommands.Controls.Add(this.btnGetPID);
			this.grpGetCommands.Controls.Add(this.cboVessel);
			this.grpGetCommands.Controls.Add(this.btnGetEvap);
			this.grpGetCommands.Controls.Add(this.btnGetBoilTemp);
			this.grpGetCommands.Controls.Add(this.btnGetVersion);
			this.grpGetCommands.Enabled = false;
			this.grpGetCommands.Location = new System.Drawing.Point(6, 6);
			this.grpGetCommands.Name = "grpGetCommands";
			this.grpGetCommands.Size = new System.Drawing.Size(292, 302);
			this.grpGetCommands.TabIndex = 2;
			this.grpGetCommands.TabStop = false;
			this.grpGetCommands.Text = "BT Get Commands";
			// 
			// btnGetLogStatus
			// 
			this.btnGetLogStatus.Location = new System.Drawing.Point(200, 198);
			this.btnGetLogStatus.Name = "btnGetLogStatus";
			this.btnGetLogStatus.Size = new System.Drawing.Size(75, 23);
			this.btnGetLogStatus.TabIndex = 21;
			this.btnGetLogStatus.Text = "Log Status";
			this.btnGetLogStatus.UseVisualStyleBackColor = true;
			this.btnGetLogStatus.Click += new System.EventHandler(this.btnGetLogStatus_Click);
			// 
			// btnGetAlarm
			// 
			this.btnGetAlarm.Location = new System.Drawing.Point(200, 168);
			this.btnGetAlarm.Name = "btnGetAlarm";
			this.btnGetAlarm.Size = new System.Drawing.Size(75, 23);
			this.btnGetAlarm.TabIndex = 20;
			this.btnGetAlarm.Text = "Alarm";
			this.btnGetAlarm.UseVisualStyleBackColor = true;
			this.btnGetAlarm.Click += new System.EventHandler(this.btnGetAlarm_Click);
			// 
			// btnGetLog
			// 
			this.btnGetLog.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnGetLog.Location = new System.Drawing.Point(200, 257);
			this.btnGetLog.Name = "btnGetLog";
			this.btnGetLog.Size = new System.Drawing.Size(75, 23);
			this.btnGetLog.TabIndex = 19;
			this.btnGetLog.Text = "Get Log";
			this.btnGetLog.UseVisualStyleBackColor = true;
			this.btnGetLog.Click += new System.EventHandler(this.btnGetLog_Click);
			// 
			// btnLogging
			// 
			this.btnLogging.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnLogging.Enabled = false;
			this.btnLogging.Location = new System.Drawing.Point(200, 228);
			this.btnLogging.Name = "btnLogging";
			this.btnLogging.Size = new System.Drawing.Size(75, 23);
			this.btnLogging.TabIndex = 18;
			this.btnLogging.Text = "Logging On";
			this.btnLogging.UseVisualStyleBackColor = true;
			this.btnLogging.Click += new System.EventHandler(this.btnLog_Click);
			// 
			// btnGetBoilPower
			// 
			this.btnGetBoilPower.Location = new System.Drawing.Point(200, 51);
			this.btnGetBoilPower.Name = "btnGetBoilPower";
			this.btnGetBoilPower.Size = new System.Drawing.Size(75, 23);
			this.btnGetBoilPower.TabIndex = 17;
			this.btnGetBoilPower.Text = "Boil Pwr.";
			this.btnGetBoilPower.UseVisualStyleBackColor = true;
			this.btnGetBoilPower.Click += new System.EventHandler(this.btnGetBoilPower_Click);
			// 
			// brpRecipe
			// 
			this.brpRecipe.Controls.Add(this.cboRecipeSlot);
			this.brpRecipe.Controls.Add(this.btnGetCalcTemps);
			this.brpRecipe.Controls.Add(this.getRecipe);
			this.brpRecipe.Controls.Add(this.btnGetCalcVols);
			this.brpRecipe.Location = new System.Drawing.Point(16, 197);
			this.brpRecipe.Name = "brpRecipe";
			this.brpRecipe.Size = new System.Drawing.Size(178, 86);
			this.brpRecipe.TabIndex = 16;
			this.brpRecipe.TabStop = false;
			this.brpRecipe.Text = "Recipe";
			// 
			// cboRecipeSlot
			// 
			this.cboRecipeSlot.FormattingEnabled = true;
			this.cboRecipeSlot.Items.AddRange(new object[] {
            "0",
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "11",
            "12",
            "13",
            "14",
            "15",
            "16",
            "17",
            "18",
            "19"});
			this.cboRecipeSlot.Location = new System.Drawing.Point(8, 26);
			this.cboRecipeSlot.Name = "cboRecipeSlot";
			this.cboRecipeSlot.Size = new System.Drawing.Size(79, 21);
			this.cboRecipeSlot.TabIndex = 11;
			// 
			// btnGetCalcTemps
			// 
			this.btnGetCalcTemps.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnGetCalcTemps.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
			this.btnGetCalcTemps.Location = new System.Drawing.Point(97, 53);
			this.btnGetCalcTemps.Name = "btnGetCalcTemps";
			this.btnGetCalcTemps.Size = new System.Drawing.Size(75, 23);
			this.btnGetCalcTemps.TabIndex = 15;
			this.btnGetCalcTemps.Text = "Calc Temps";
			this.btnGetCalcTemps.UseVisualStyleBackColor = true;
			this.btnGetCalcTemps.Click += new System.EventHandler(this.btnGetCalcTemps_Click);
			// 
			// getRecipe
			// 
			this.getRecipe.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.getRecipe.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
			this.getRecipe.Location = new System.Drawing.Point(8, 53);
			this.getRecipe.Name = "getRecipe";
			this.getRecipe.Size = new System.Drawing.Size(75, 23);
			this.getRecipe.TabIndex = 9;
			this.getRecipe.Text = "Recipe";
			this.getRecipe.UseVisualStyleBackColor = true;
			this.getRecipe.Click += new System.EventHandler(this.btnGetRecipe_Click);
			// 
			// btnGetCalcVols
			// 
			this.btnGetCalcVols.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnGetCalcVols.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
			this.btnGetCalcVols.Location = new System.Drawing.Point(97, 24);
			this.btnGetCalcVols.Name = "btnGetCalcVols";
			this.btnGetCalcVols.Size = new System.Drawing.Size(75, 23);
			this.btnGetCalcVols.TabIndex = 14;
			this.btnGetCalcVols.Text = "Calc Vols";
			this.btnGetCalcVols.UseVisualStyleBackColor = true;
			this.btnGetCalcVols.Click += new System.EventHandler(this.btnGetCalcVols_Click);
			// 
			// btnGetDelayTime
			// 
			this.btnGetDelayTime.Location = new System.Drawing.Point(200, 139);
			this.btnGetDelayTime.Name = "btnGetDelayTime";
			this.btnGetDelayTime.Size = new System.Drawing.Size(75, 23);
			this.btnGetDelayTime.TabIndex = 13;
			this.btnGetDelayTime.Text = "Cycle Delay";
			this.btnGetDelayTime.UseVisualStyleBackColor = true;
			this.btnGetDelayTime.Click += new System.EventHandler(this.btnGetDelayTime_Click);
			// 
			// btnGetGrainTemp
			// 
			this.btnGetGrainTemp.Location = new System.Drawing.Point(200, 109);
			this.btnGetGrainTemp.Name = "btnGetGrainTemp";
			this.btnGetGrainTemp.Size = new System.Drawing.Size(75, 23);
			this.btnGetGrainTemp.TabIndex = 12;
			this.btnGetGrainTemp.Text = "Grain Temp.";
			this.btnGetGrainTemp.UseVisualStyleBackColor = true;
			this.btnGetGrainTemp.Click += new System.EventHandler(this.btnGetGrainTemp_Click);
			// 
			// btnGetVolume
			// 
			this.btnGetVolume.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
			this.btnGetVolume.Location = new System.Drawing.Point(16, 166);
			this.btnGetVolume.Name = "btnGetVolume";
			this.btnGetVolume.Size = new System.Drawing.Size(75, 23);
			this.btnGetVolume.TabIndex = 8;
			this.btnGetVolume.Text = "Vessel Vol.";
			this.btnGetVolume.UseVisualStyleBackColor = true;
			this.btnGetVolume.Click += new System.EventHandler(this.btnGetVolume_Click);
			// 
			// cboVolume
			// 
			this.cboVolume.FormattingEnabled = true;
			this.cboVolume.Items.AddRange(new object[] {
            "HLT",
            "Mash",
            "Kettle"});
			this.cboVolume.Location = new System.Drawing.Point(97, 168);
			this.cboVolume.Name = "cboVolume";
			this.cboVolume.Size = new System.Drawing.Size(79, 21);
			this.cboVolume.TabIndex = 10;
			// 
			// cboCalibration
			// 
			this.cboCalibration.FormattingEnabled = true;
			this.cboCalibration.Items.AddRange(new object[] {
            "HLT",
            "Mash",
            "Kettle"});
			this.cboCalibration.Location = new System.Drawing.Point(97, 139);
			this.cboCalibration.Name = "cboCalibration";
			this.cboCalibration.Size = new System.Drawing.Size(79, 21);
			this.cboCalibration.TabIndex = 9;
			// 
			// cboProfile
			// 
			this.cboProfile.FormattingEnabled = true;
			this.cboProfile.Items.AddRange(new object[] {
            "Fill HLT",
            "Fill Mash",
            "Add Grain",
            "Mash Heat",
            "Mash Idle",
            "Sparge In",
            "Sparge Out",
            "Boil Adds",
            "Chill H20",
            "Chill Beer",
            "Boil Recirc",
            "Drain"});
			this.cboProfile.Location = new System.Drawing.Point(97, 110);
			this.cboProfile.Name = "cboProfile";
			this.cboProfile.Size = new System.Drawing.Size(79, 21);
			this.cboProfile.TabIndex = 8;
			// 
			// btnGetCal
			// 
			this.btnGetCal.Location = new System.Drawing.Point(16, 137);
			this.btnGetCal.Name = "btnGetCal";
			this.btnGetCal.Size = new System.Drawing.Size(75, 23);
			this.btnGetCal.TabIndex = 7;
			this.btnGetCal.Text = "Vessel Calib.";
			this.btnGetCal.UseVisualStyleBackColor = true;
			this.btnGetCal.Click += new System.EventHandler(this.btnGetCal_Click);
			// 
			// btnGetProfile
			// 
			this.btnGetProfile.Location = new System.Drawing.Point(16, 108);
			this.btnGetProfile.Name = "btnGetProfile";
			this.btnGetProfile.Size = new System.Drawing.Size(75, 23);
			this.btnGetProfile.TabIndex = 6;
			this.btnGetProfile.Text = "Valve Profile";
			this.btnGetProfile.UseVisualStyleBackColor = true;
			this.btnGetProfile.Click += new System.EventHandler(this.btnGetProfile_Click);
			// 
			// cboTemps
			// 
			this.cboTemps.FormattingEnabled = true;
			this.cboTemps.Items.AddRange(new object[] {
            "HLT",
            "Mash",
            "Kettle",
            "H2O In",
            "H2O Out",
            "Beer Out",
            "Aux 1",
            "Aux 2",
            "Aux 3"});
			this.cboTemps.Location = new System.Drawing.Point(97, 81);
			this.cboTemps.Name = "cboTemps";
			this.cboTemps.Size = new System.Drawing.Size(79, 21);
			this.cboTemps.TabIndex = 6;
			// 
			// btnGetTemps
			// 
			this.btnGetTemps.Location = new System.Drawing.Point(16, 79);
			this.btnGetTemps.Name = "btnGetTemps";
			this.btnGetTemps.Size = new System.Drawing.Size(75, 23);
			this.btnGetTemps.TabIndex = 5;
			this.btnGetTemps.Text = "T/S Addr.";
			this.btnGetTemps.UseVisualStyleBackColor = true;
			this.btnGetTemps.Click += new System.EventHandler(this.btnGetTemps_Click);
			// 
			// btnGetPID
			// 
			this.btnGetPID.Location = new System.Drawing.Point(16, 50);
			this.btnGetPID.Name = "btnGetPID";
			this.btnGetPID.Size = new System.Drawing.Size(75, 23);
			this.btnGetPID.TabIndex = 4;
			this.btnGetPID.Text = "Heat Output";
			this.btnGetPID.UseVisualStyleBackColor = true;
			this.btnGetPID.Click += new System.EventHandler(this.btnGetPID_Click);
			// 
			// cboVessel
			// 
			this.cboVessel.FormattingEnabled = true;
			this.cboVessel.Items.AddRange(new object[] {
            "HLT",
            "Mash",
            "Kettle",
            "Steam"});
			this.cboVessel.Location = new System.Drawing.Point(97, 52);
			this.cboVessel.Name = "cboVessel";
			this.cboVessel.Size = new System.Drawing.Size(79, 21);
			this.cboVessel.TabIndex = 4;
			// 
			// btnGetEvap
			// 
			this.btnGetEvap.Location = new System.Drawing.Point(200, 80);
			this.btnGetEvap.Name = "btnGetEvap";
			this.btnGetEvap.Size = new System.Drawing.Size(75, 23);
			this.btnGetEvap.TabIndex = 3;
			this.btnGetEvap.Text = "Evap. Rate";
			this.btnGetEvap.UseVisualStyleBackColor = true;
			this.btnGetEvap.Click += new System.EventHandler(this.btnGetEvap_Click);
			// 
			// btnGetBoilTemp
			// 
			this.btnGetBoilTemp.AccessibleRole = System.Windows.Forms.AccessibleRole.None;
			this.btnGetBoilTemp.Location = new System.Drawing.Point(200, 22);
			this.btnGetBoilTemp.Name = "btnGetBoilTemp";
			this.btnGetBoilTemp.Size = new System.Drawing.Size(75, 23);
			this.btnGetBoilTemp.TabIndex = 2;
			this.btnGetBoilTemp.Text = "Boil Temp";
			this.btnGetBoilTemp.UseVisualStyleBackColor = true;
			this.btnGetBoilTemp.Click += new System.EventHandler(this.btnGetBoilTemp_Click);
			// 
			// lblUnits
			// 
			this.lblUnits.AutoSize = true;
			this.lblUnits.Location = new System.Drawing.Point(448, 23);
			this.lblUnits.Name = "lblUnits";
			this.lblUnits.Size = new System.Drawing.Size(29, 13);
			this.lblUnits.TabIndex = 12;
			this.lblUnits.Text = "units";
			// 
			// btnHelp
			// 
			this.btnHelp.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnHelp.Location = new System.Drawing.Point(538, 8);
			this.btnHelp.Name = "btnHelp";
			this.btnHelp.Size = new System.Drawing.Size(27, 23);
			this.btnHelp.TabIndex = 4;
			this.btnHelp.Text = "?";
			this.btnHelp.UseVisualStyleBackColor = true;
			this.btnHelp.Click += new System.EventHandler(this.btnHelp_Click);
			// 
			// lblComType
			// 
			this.lblComType.AutoSize = true;
			this.lblComType.BackColor = System.Drawing.SystemColors.Control;
			this.lblComType.Location = new System.Drawing.Point(261, 28);
			this.lblComType.Name = "lblComType";
			this.lblComType.Size = new System.Drawing.Size(33, 13);
			this.lblComType.TabIndex = 5;
			this.lblComType.Text = "mode";
			// 
			// cboComPorts
			// 
			this.cboComPorts.FormattingEnabled = true;
			this.cboComPorts.Location = new System.Drawing.Point(127, 23);
			this.cboComPorts.Name = "cboComPorts";
			this.cboComPorts.Size = new System.Drawing.Size(83, 21);
			this.cboComPorts.TabIndex = 6;
			this.cboComPorts.SelectedIndexChanged += new System.EventHandler(this.cboComPorts_SelectedIndexChanged);
			// 
			// grpSetCommands
			// 
			this.grpSetCommands.Controls.Add(this.btnSetAlarm);
			this.grpSetCommands.Controls.Add(this.btnSetBoilPower);
			this.grpSetCommands.Controls.Add(this.lblGrainUnits);
			this.grpSetCommands.Controls.Add(this.lblDelayUnits);
			this.grpSetCommands.Controls.Add(this.updnDelayTime);
			this.grpSetCommands.Controls.Add(this.btnSetDelayTime);
			this.grpSetCommands.Controls.Add(this.updnGrainTemp);
			this.grpSetCommands.Controls.Add(this.btnSetGrainTemp);
			this.grpSetCommands.Controls.Add(this.lblEvapUnits);
			this.grpSetCommands.Controls.Add(this.updnEvapRate);
			this.grpSetCommands.Controls.Add(this.btnSetEvapRate);
			this.grpSetCommands.Controls.Add(this.lblBoilPowerUnits);
			this.grpSetCommands.Controls.Add(this.lglDeg);
			this.grpSetCommands.Controls.Add(this.updnBoilPower);
			this.grpSetCommands.Controls.Add(this.updnBoilTemp);
			this.grpSetCommands.Controls.Add(this.btnSetBoil);
			this.grpSetCommands.Location = new System.Drawing.Point(309, 7);
			this.grpSetCommands.Name = "grpSetCommands";
			this.grpSetCommands.Size = new System.Drawing.Size(210, 193);
			this.grpSetCommands.TabIndex = 7;
			this.grpSetCommands.TabStop = false;
			this.grpSetCommands.Text = "BT Set Commands";
			// 
			// btnSetAlarm
			// 
			this.btnSetAlarm.Location = new System.Drawing.Point(9, 164);
			this.btnSetAlarm.Name = "btnSetAlarm";
			this.btnSetAlarm.Size = new System.Drawing.Size(75, 23);
			this.btnSetAlarm.TabIndex = 21;
			this.btnSetAlarm.Text = "Set Alarm";
			this.btnSetAlarm.UseVisualStyleBackColor = true;
			this.btnSetAlarm.Click += new System.EventHandler(this.btnSetAlarm_Click);
			// 
			// btnSetBoilPower
			// 
			this.btnSetBoilPower.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnSetBoilPower.Location = new System.Drawing.Point(8, 48);
			this.btnSetBoilPower.Name = "btnSetBoilPower";
			this.btnSetBoilPower.Size = new System.Drawing.Size(75, 23);
			this.btnSetBoilPower.TabIndex = 16;
			this.btnSetBoilPower.Text = "Boil Pwr.";
			this.btnSetBoilPower.UseVisualStyleBackColor = true;
			this.btnSetBoilPower.Click += new System.EventHandler(this.btnSetBoilPower_Click);
			// 
			// lblGrainUnits
			// 
			this.lblGrainUnits.AutoSize = true;
			this.lblGrainUnits.Location = new System.Drawing.Point(142, 111);
			this.lblGrainUnits.Name = "lblGrainUnits";
			this.lblGrainUnits.Size = new System.Drawing.Size(30, 13);
			this.lblGrainUnits.TabIndex = 15;
			this.lblGrainUnits.Text = "Deg.";
			// 
			// lblDelayUnits
			// 
			this.lblDelayUnits.AutoSize = true;
			this.lblDelayUnits.Location = new System.Drawing.Point(142, 141);
			this.lblDelayUnits.Name = "lblDelayUnits";
			this.lblDelayUnits.Size = new System.Drawing.Size(27, 13);
			this.lblDelayUnits.TabIndex = 14;
			this.lblDelayUnits.Text = "Min.";
			// 
			// updnDelayTime
			// 
			this.updnDelayTime.Location = new System.Drawing.Point(93, 137);
			this.updnDelayTime.Maximum = new decimal(new int[] {
            1439,
            0,
            0,
            0});
			this.updnDelayTime.Name = "updnDelayTime";
			this.updnDelayTime.Size = new System.Drawing.Size(47, 20);
			this.updnDelayTime.TabIndex = 13;
			this.updnDelayTime.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
			this.updnDelayTime.UpDownAlign = System.Windows.Forms.LeftRightAlignment.Left;
			// 
			// btnSetDelayTime
			// 
			this.btnSetDelayTime.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnSetDelayTime.Location = new System.Drawing.Point(8, 135);
			this.btnSetDelayTime.Name = "btnSetDelayTime";
			this.btnSetDelayTime.Size = new System.Drawing.Size(75, 23);
			this.btnSetDelayTime.TabIndex = 12;
			this.btnSetDelayTime.Text = "Cycle Delay";
			this.btnSetDelayTime.UseVisualStyleBackColor = true;
			this.btnSetDelayTime.Click += new System.EventHandler(this.btnSetDelayTime_Click);
			// 
			// updnGrainTemp
			// 
			this.updnGrainTemp.Location = new System.Drawing.Point(93, 107);
			this.updnGrainTemp.Maximum = new decimal(new int[] {
            150,
            0,
            0,
            0});
			this.updnGrainTemp.Name = "updnGrainTemp";
			this.updnGrainTemp.Size = new System.Drawing.Size(47, 20);
			this.updnGrainTemp.TabIndex = 11;
			this.updnGrainTemp.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
			this.updnGrainTemp.UpDownAlign = System.Windows.Forms.LeftRightAlignment.Left;
			this.updnGrainTemp.Value = new decimal(new int[] {
            75,
            0,
            0,
            0});
			// 
			// btnSetGrainTemp
			// 
			this.btnSetGrainTemp.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnSetGrainTemp.Location = new System.Drawing.Point(8, 106);
			this.btnSetGrainTemp.Name = "btnSetGrainTemp";
			this.btnSetGrainTemp.Size = new System.Drawing.Size(75, 23);
			this.btnSetGrainTemp.TabIndex = 10;
			this.btnSetGrainTemp.Text = "Grain Temp.";
			this.btnSetGrainTemp.UseVisualStyleBackColor = true;
			this.btnSetGrainTemp.Click += new System.EventHandler(this.btnSetGrainTemp_Click);
			// 
			// lblEvapUnits
			// 
			this.lblEvapUnits.AutoSize = true;
			this.lblEvapUnits.Location = new System.Drawing.Point(142, 82);
			this.lblEvapUnits.Name = "lblEvapUnits";
			this.lblEvapUnits.Size = new System.Drawing.Size(15, 13);
			this.lblEvapUnits.TabIndex = 9;
			this.lblEvapUnits.Text = "%";
			// 
			// updnEvapRate
			// 
			this.updnEvapRate.Location = new System.Drawing.Point(93, 78);
			this.updnEvapRate.Maximum = new decimal(new int[] {
            10,
            0,
            0,
            0});
			this.updnEvapRate.Name = "updnEvapRate";
			this.updnEvapRate.Size = new System.Drawing.Size(47, 20);
			this.updnEvapRate.TabIndex = 8;
			this.updnEvapRate.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
			this.updnEvapRate.UpDownAlign = System.Windows.Forms.LeftRightAlignment.Left;
			this.updnEvapRate.Value = new decimal(new int[] {
            3,
            0,
            0,
            0});
			// 
			// btnSetEvapRate
			// 
			this.btnSetEvapRate.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnSetEvapRate.Location = new System.Drawing.Point(8, 77);
			this.btnSetEvapRate.Name = "btnSetEvapRate";
			this.btnSetEvapRate.Size = new System.Drawing.Size(75, 23);
			this.btnSetEvapRate.TabIndex = 7;
			this.btnSetEvapRate.Text = "Evap. Rate";
			this.btnSetEvapRate.UseVisualStyleBackColor = true;
			this.btnSetEvapRate.Click += new System.EventHandler(this.btnSetEvapRate_Click_1);
			// 
			// lblBoilPowerUnits
			// 
			this.lblBoilPowerUnits.AutoSize = true;
			this.lblBoilPowerUnits.Location = new System.Drawing.Point(142, 51);
			this.lblBoilPowerUnits.Name = "lblBoilPowerUnits";
			this.lblBoilPowerUnits.Size = new System.Drawing.Size(15, 13);
			this.lblBoilPowerUnits.TabIndex = 6;
			this.lblBoilPowerUnits.Text = "%";
			// 
			// lglDeg
			// 
			this.lglDeg.AutoSize = true;
			this.lglDeg.Location = new System.Drawing.Point(142, 24);
			this.lglDeg.Name = "lglDeg";
			this.lglDeg.Size = new System.Drawing.Size(30, 13);
			this.lglDeg.TabIndex = 5;
			this.lglDeg.Text = "Deg.";
			// 
			// updnBoilPower
			// 
			this.updnBoilPower.Location = new System.Drawing.Point(93, 49);
			this.updnBoilPower.Name = "updnBoilPower";
			this.updnBoilPower.Size = new System.Drawing.Size(47, 20);
			this.updnBoilPower.TabIndex = 4;
			this.updnBoilPower.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
			this.updnBoilPower.UpDownAlign = System.Windows.Forms.LeftRightAlignment.Left;
			this.updnBoilPower.Value = new decimal(new int[] {
            95,
            0,
            0,
            0});
			// 
			// updnBoilTemp
			// 
			this.updnBoilTemp.Location = new System.Drawing.Point(93, 20);
			this.updnBoilTemp.Maximum = new decimal(new int[] {
            215,
            0,
            0,
            0});
			this.updnBoilTemp.Minimum = new decimal(new int[] {
            160,
            0,
            0,
            0});
			this.updnBoilTemp.Name = "updnBoilTemp";
			this.updnBoilTemp.Size = new System.Drawing.Size(47, 20);
			this.updnBoilTemp.TabIndex = 3;
			this.updnBoilTemp.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
			this.updnBoilTemp.UpDownAlign = System.Windows.Forms.LeftRightAlignment.Left;
			this.updnBoilTemp.Value = new decimal(new int[] {
            210,
            0,
            0,
            0});
			// 
			// btnSetBoil
			// 
			this.btnSetBoil.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnSetBoil.Location = new System.Drawing.Point(8, 19);
			this.btnSetBoil.Name = "btnSetBoil";
			this.btnSetBoil.Size = new System.Drawing.Size(75, 23);
			this.btnSetBoil.TabIndex = 2;
			this.btnSetBoil.Text = "Boil Temp";
			this.btnSetBoil.UseVisualStyleBackColor = true;
			this.btnSetBoil.Click += new System.EventHandler(this.btnSetBoilTemp_Click);
			// 
			// lblVerLbl
			// 
			this.lblVerLbl.AutoSize = true;
			this.lblVerLbl.BackColor = System.Drawing.SystemColors.Control;
			this.lblVerLbl.Location = new System.Drawing.Point(326, 28);
			this.lblVerLbl.Name = "lblVerLbl";
			this.lblVerLbl.Size = new System.Drawing.Size(29, 13);
			this.lblVerLbl.TabIndex = 8;
			this.lblVerLbl.Text = "Ver.:";
			// 
			// lblComTypeLbl
			// 
			this.lblComTypeLbl.AutoSize = true;
			this.lblComTypeLbl.Location = new System.Drawing.Point(226, 28);
			this.lblComTypeLbl.Name = "lblComTypeLbl";
			this.lblComTypeLbl.Size = new System.Drawing.Size(34, 13);
			this.lblComTypeLbl.TabIndex = 9;
			this.lblComTypeLbl.Text = "Type:";
			// 
			// lblVersion
			// 
			this.lblVersion.AutoSize = true;
			this.lblVersion.BackColor = System.Drawing.SystemColors.Control;
			this.lblVersion.Location = new System.Drawing.Point(354, 28);
			this.lblVersion.Name = "lblVersion";
			this.lblVersion.Size = new System.Drawing.Size(23, 13);
			this.lblVersion.TabIndex = 10;
			this.lblVersion.Text = "Ver";
			// 
			// lblBuild
			// 
			this.lblBuild.AutoSize = true;
			this.lblBuild.BackColor = System.Drawing.SystemColors.Control;
			this.lblBuild.Location = new System.Drawing.Point(354, 43);
			this.lblBuild.Name = "lblBuild";
			this.lblBuild.Size = new System.Drawing.Size(29, 13);
			this.lblBuild.TabIndex = 12;
			this.lblBuild.Text = "build";
			// 
			// lblBuildLbl
			// 
			this.lblBuildLbl.AutoSize = true;
			this.lblBuildLbl.BackColor = System.Drawing.SystemColors.Control;
			this.lblBuildLbl.Location = new System.Drawing.Point(323, 43);
			this.lblBuildLbl.Name = "lblBuildLbl";
			this.lblBuildLbl.Size = new System.Drawing.Size(33, 13);
			this.lblBuildLbl.TabIndex = 11;
			this.lblBuildLbl.Text = "Build:";
			// 
			// lblUnitsLbl
			// 
			this.lblUnitsLbl.AutoSize = true;
			this.lblUnitsLbl.BackColor = System.Drawing.SystemColors.Control;
			this.lblUnitsLbl.Location = new System.Drawing.Point(412, 23);
			this.lblUnitsLbl.Name = "lblUnitsLbl";
			this.lblUnitsLbl.Size = new System.Drawing.Size(34, 13);
			this.lblUnitsLbl.TabIndex = 13;
			this.lblUnitsLbl.Text = "Units:";
			// 
			// lblSchema
			// 
			this.lblSchema.AutoSize = true;
			this.lblSchema.Location = new System.Drawing.Point(262, 43);
			this.lblSchema.Name = "lblSchema";
			this.lblSchema.Size = new System.Drawing.Size(44, 13);
			this.lblSchema.TabIndex = 14;
			this.lblSchema.Text = "schema";
			// 
			// lblSchemaLbl
			// 
			this.lblSchemaLbl.AutoSize = true;
			this.lblSchemaLbl.BackColor = System.Drawing.SystemColors.Control;
			this.lblSchemaLbl.Location = new System.Drawing.Point(215, 43);
			this.lblSchemaLbl.Name = "lblSchemaLbl";
			this.lblSchemaLbl.Size = new System.Drawing.Size(49, 13);
			this.lblSchemaLbl.TabIndex = 15;
			this.lblSchemaLbl.Text = "Schema:";
			// 
			// grpPerfTest
			// 
			this.grpPerfTest.Controls.Add(this.btnDisplayErrors);
			this.grpPerfTest.Controls.Add(this.lblTestCountLbl);
			this.grpPerfTest.Controls.Add(this.lblErrCount);
			this.grpPerfTest.Controls.Add(this.lblCountlbl);
			this.grpPerfTest.Controls.Add(this.tbErrorCount);
			this.grpPerfTest.Controls.Add(this.tbCurrentCount);
			this.grpPerfTest.Controls.Add(this.updnTestCount);
			this.grpPerfTest.Controls.Add(this.btnStartSpeedTest);
			this.grpPerfTest.Location = new System.Drawing.Point(310, 207);
			this.grpPerfTest.Name = "grpPerfTest";
			this.grpPerfTest.Size = new System.Drawing.Size(210, 101);
			this.grpPerfTest.TabIndex = 16;
			this.grpPerfTest.TabStop = false;
			this.grpPerfTest.Text = "Continuous Test";
			// 
			// btnDisplayErrors
			// 
			this.btnDisplayErrors.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnDisplayErrors.Location = new System.Drawing.Point(117, 59);
			this.btnDisplayErrors.Name = "btnDisplayErrors";
			this.btnDisplayErrors.Size = new System.Drawing.Size(75, 22);
			this.btnDisplayErrors.TabIndex = 21;
			this.btnDisplayErrors.Text = "Show Errors";
			this.btnDisplayErrors.UseVisualStyleBackColor = true;
			this.btnDisplayErrors.Click += new System.EventHandler(this.btnDisplayErrors_Click);
			// 
			// lblTestCountLbl
			// 
			this.lblTestCountLbl.AutoSize = true;
			this.lblTestCountLbl.BackColor = System.Drawing.SystemColors.Control;
			this.lblTestCountLbl.Location = new System.Drawing.Point(6, 16);
			this.lblTestCountLbl.Name = "lblTestCountLbl";
			this.lblTestCountLbl.Size = new System.Drawing.Size(59, 13);
			this.lblTestCountLbl.TabIndex = 20;
			this.lblTestCountLbl.Text = "Test Count";
			// 
			// lblErrCount
			// 
			this.lblErrCount.AutoSize = true;
			this.lblErrCount.BackColor = System.Drawing.SystemColors.Control;
			this.lblErrCount.Location = new System.Drawing.Point(142, 15);
			this.lblErrCount.Name = "lblErrCount";
			this.lblErrCount.Size = new System.Drawing.Size(34, 13);
			this.lblErrCount.TabIndex = 19;
			this.lblErrCount.Text = "Errors";
			// 
			// lblCountlbl
			// 
			this.lblCountlbl.AutoSize = true;
			this.lblCountlbl.BackColor = System.Drawing.SystemColors.Control;
			this.lblCountlbl.Location = new System.Drawing.Point(73, 16);
			this.lblCountlbl.Name = "lblCountlbl";
			this.lblCountlbl.Size = new System.Drawing.Size(35, 13);
			this.lblCountlbl.TabIndex = 18;
			this.lblCountlbl.Text = "Count";
			// 
			// tbErrorCount
			// 
			this.tbErrorCount.Location = new System.Drawing.Point(132, 32);
			this.tbErrorCount.Name = "tbErrorCount";
			this.tbErrorCount.Size = new System.Drawing.Size(51, 20);
			this.tbErrorCount.TabIndex = 17;
			// 
			// tbCurrentCount
			// 
			this.tbCurrentCount.Location = new System.Drawing.Point(76, 32);
			this.tbCurrentCount.Name = "tbCurrentCount";
			this.tbCurrentCount.Size = new System.Drawing.Size(50, 20);
			this.tbCurrentCount.TabIndex = 16;
			// 
			// updnTestCount
			// 
			this.updnTestCount.Increment = new decimal(new int[] {
            10,
            0,
            0,
            0});
			this.updnTestCount.Location = new System.Drawing.Point(9, 33);
			this.updnTestCount.Maximum = new decimal(new int[] {
            10000,
            0,
            0,
            0});
			this.updnTestCount.Name = "updnTestCount";
			this.updnTestCount.Size = new System.Drawing.Size(56, 20);
			this.updnTestCount.TabIndex = 15;
			this.updnTestCount.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
			this.updnTestCount.UpDownAlign = System.Windows.Forms.LeftRightAlignment.Left;
			this.updnTestCount.Value = new decimal(new int[] {
            10,
            0,
            0,
            0});
			// 
			// btnStartSpeedTest
			// 
			this.btnStartSpeedTest.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnStartSpeedTest.Location = new System.Drawing.Point(9, 59);
			this.btnStartSpeedTest.Name = "btnStartSpeedTest";
			this.btnStartSpeedTest.Size = new System.Drawing.Size(75, 21);
			this.btnStartSpeedTest.TabIndex = 14;
			this.btnStartSpeedTest.Text = "Start Test";
			this.btnStartSpeedTest.UseVisualStyleBackColor = true;
			this.btnStartSpeedTest.Click += new System.EventHandler(this.btnStartSpeedTest_Click);
			// 
			// rtbResults
			// 
			this.rtbResults.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
						| System.Windows.Forms.AnchorStyles.Left)
						| System.Windows.Forms.AnchorStyles.Right)));
			this.rtbResults.Font = new System.Drawing.Font("Consolas", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.rtbResults.Location = new System.Drawing.Point(5, 313);
			this.rtbResults.Name = "rtbResults";
			this.rtbResults.ReadOnly = true;
			this.rtbResults.Size = new System.Drawing.Size(529, 176);
			this.rtbResults.TabIndex = 3;
			this.rtbResults.Text = "";
			// 
			// lblAlarm
			// 
			this.lblAlarm.BackColor = System.Drawing.Color.Red;
			this.lblAlarm.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.lblAlarm.Location = new System.Drawing.Point(407, 39);
			this.lblAlarm.Name = "lblAlarm";
			this.lblAlarm.Size = new System.Drawing.Size(74, 20);
			this.lblAlarm.TabIndex = 17;
			this.lblAlarm.Text = "Alarm!";
			this.lblAlarm.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
			this.lblAlarm.Visible = false;
			// 
			// tabControl1
			// 
			this.tabControl1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
						| System.Windows.Forms.AnchorStyles.Left)
						| System.Windows.Forms.AnchorStyles.Right)));
			this.tabControl1.Controls.Add(this.tabTest);
			this.tabControl1.Controls.Add(this.tabEEPROM);
			this.tabControl1.Controls.Add(this.tabLogging);
			this.tabControl1.Location = new System.Drawing.Point(12, 71);
			this.tabControl1.Name = "tabControl1";
			this.tabControl1.SelectedIndex = 0;
			this.tabControl1.Size = new System.Drawing.Size(545, 518);
			this.tabControl1.TabIndex = 18;
			// 
			// tabTest
			// 
			this.tabTest.BackColor = System.Drawing.SystemColors.Control;
			this.tabTest.Controls.Add(this.grpGetCommands);
			this.tabTest.Controls.Add(this.grpSetCommands);
			this.tabTest.Controls.Add(this.rtbResults);
			this.tabTest.Controls.Add(this.grpPerfTest);
			this.tabTest.Location = new System.Drawing.Point(4, 22);
			this.tabTest.Name = "tabTest";
			this.tabTest.Padding = new System.Windows.Forms.Padding(3);
			this.tabTest.Size = new System.Drawing.Size(537, 492);
			this.tabTest.TabIndex = 0;
			this.tabTest.Text = "Basic Function";
			// 
			// tabEEPROM
			// 
			this.tabEEPROM.BackColor = System.Drawing.SystemColors.Control;
			this.tabEEPROM.Controls.Add(this.grpEEPROM);
			this.tabEEPROM.Location = new System.Drawing.Point(4, 22);
			this.tabEEPROM.Name = "tabEEPROM";
			this.tabEEPROM.Padding = new System.Windows.Forms.Padding(3);
			this.tabEEPROM.Size = new System.Drawing.Size(537, 492);
			this.tabEEPROM.TabIndex = 1;
			this.tabEEPROM.Text = "EEPROM";
			// 
			// grpEEPROM
			// 
			this.grpEEPROM.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
						| System.Windows.Forms.AnchorStyles.Right)));
			this.grpEEPROM.Controls.Add(this.chkHexWriteLength);
			this.grpEEPROM.Controls.Add(this.rtbEEPROM);
			this.grpEEPROM.Controls.Add(this.updnWriteLengthEE);
			this.grpEEPROM.Controls.Add(this.txtDataEE);
			this.grpEEPROM.Controls.Add(this.btnReadEE);
			this.grpEEPROM.Controls.Add(this.btnInitializeEE);
			this.grpEEPROM.Controls.Add(this.updnReadLengthEE);
			this.grpEEPROM.Controls.Add(this.chkHexReadLength);
			this.grpEEPROM.Controls.Add(this.updnReadAddressEE);
			this.grpEEPROM.Controls.Add(this.lblAddressEE);
			this.grpEEPROM.Controls.Add(this.chkHexWriteAddress);
			this.grpEEPROM.Controls.Add(this.lblLengthEE);
			this.grpEEPROM.Controls.Add(this.lblEEPROMData);
			this.grpEEPROM.Controls.Add(this.chkHexReadAddress);
			this.grpEEPROM.Controls.Add(this.lblWriteAddress);
			this.grpEEPROM.Controls.Add(this.btnWriteEEPROM);
			this.grpEEPROM.Controls.Add(this.updnWriteAddressEE);
			this.grpEEPROM.Controls.Add(this.btnBackupEEPROM);
			this.grpEEPROM.Controls.Add(this.btnRestoreEEPROM);
			this.grpEEPROM.Location = new System.Drawing.Point(6, 1);
			this.grpEEPROM.Name = "grpEEPROM";
			this.grpEEPROM.Size = new System.Drawing.Size(519, 610);
			this.grpEEPROM.TabIndex = 18;
			this.grpEEPROM.TabStop = false;
			// 
			// chkHexWriteLength
			// 
			this.chkHexWriteLength.AutoSize = true;
			this.chkHexWriteLength.Location = new System.Drawing.Point(341, 91);
			this.chkHexWriteLength.Name = "chkHexWriteLength";
			this.chkHexWriteLength.Size = new System.Drawing.Size(45, 17);
			this.chkHexWriteLength.TabIndex = 20;
			this.chkHexWriteLength.Text = "Hex";
			this.chkHexWriteLength.UseVisualStyleBackColor = true;
			this.chkHexWriteLength.CheckedChanged += new System.EventHandler(this.chkHexWriteLength_CheckedChanged);
			// 
			// rtbEEPROM
			// 
			this.rtbEEPROM.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
						| System.Windows.Forms.AnchorStyles.Right)));
			this.rtbEEPROM.Font = new System.Drawing.Font("Courier New", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.rtbEEPROM.Location = new System.Drawing.Point(0, 120);
			this.rtbEEPROM.Name = "rtbEEPROM";
			this.rtbEEPROM.Size = new System.Drawing.Size(514, 365);
			this.rtbEEPROM.TabIndex = 6;
			this.rtbEEPROM.Text = "";
			// 
			// updnWriteLengthEE
			// 
			this.updnWriteLengthEE.Hexadecimal = true;
			this.updnWriteLengthEE.Location = new System.Drawing.Point(341, 69);
			this.updnWriteLengthEE.Maximum = new decimal(new int[] {
            2048,
            0,
            0,
            0});
			this.updnWriteLengthEE.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
			this.updnWriteLengthEE.Name = "updnWriteLengthEE";
			this.updnWriteLengthEE.Size = new System.Drawing.Size(53, 20);
			this.updnWriteLengthEE.TabIndex = 19;
			this.updnWriteLengthEE.Value = new decimal(new int[] {
            8,
            0,
            0,
            0});
			this.updnWriteLengthEE.ValueChanged += new System.EventHandler(this.updnWriteLengthEE_ValueChanged);
			// 
			// txtDataEE
			// 
			this.txtDataEE.Location = new System.Drawing.Point(231, 70);
			this.txtDataEE.Name = "txtDataEE";
			this.txtDataEE.Size = new System.Drawing.Size(104, 20);
			this.txtDataEE.TabIndex = 18;
			// 
			// btnReadEE
			// 
			this.btnReadEE.Location = new System.Drawing.Point(6, 23);
			this.btnReadEE.Name = "btnReadEE";
			this.btnReadEE.Size = new System.Drawing.Size(75, 23);
			this.btnReadEE.TabIndex = 0;
			this.btnReadEE.Text = "Read";
			this.btnReadEE.UseVisualStyleBackColor = true;
			this.btnReadEE.Click += new System.EventHandler(this.btnReadEEPROM_Click);
			// 
			// btnInitializeEE
			// 
			this.btnInitializeEE.Location = new System.Drawing.Point(429, 21);
			this.btnInitializeEE.Name = "btnInitializeEE";
			this.btnInitializeEE.Size = new System.Drawing.Size(75, 23);
			this.btnInitializeEE.TabIndex = 17;
			this.btnInitializeEE.Text = "Initialize";
			this.btnInitializeEE.UseVisualStyleBackColor = true;
			this.btnInitializeEE.Click += new System.EventHandler(this.btnInitializeEEPROM_Click);
			// 
			// updnReadLengthEE
			// 
			this.updnReadLengthEE.Location = new System.Drawing.Point(231, 26);
			this.updnReadLengthEE.Maximum = new decimal(new int[] {
            2048,
            0,
            0,
            0});
			this.updnReadLengthEE.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
			this.updnReadLengthEE.Name = "updnReadLengthEE";
			this.updnReadLengthEE.Size = new System.Drawing.Size(53, 20);
			this.updnReadLengthEE.TabIndex = 1;
			this.updnReadLengthEE.Value = new decimal(new int[] {
            8,
            0,
            0,
            0});
			// 
			// chkHexReadLength
			// 
			this.chkHexReadLength.AutoSize = true;
			this.chkHexReadLength.Location = new System.Drawing.Point(290, 27);
			this.chkHexReadLength.Name = "chkHexReadLength";
			this.chkHexReadLength.Size = new System.Drawing.Size(45, 17);
			this.chkHexReadLength.TabIndex = 16;
			this.chkHexReadLength.Text = "Hex";
			this.chkHexReadLength.UseVisualStyleBackColor = true;
			this.chkHexReadLength.CheckedChanged += new System.EventHandler(this.chkHexReadCount_CheckedChanged);
			// 
			// updnReadAddressEE
			// 
			this.updnReadAddressEE.Location = new System.Drawing.Point(99, 26);
			this.updnReadAddressEE.Maximum = new decimal(new int[] {
            2047,
            0,
            0,
            0});
			this.updnReadAddressEE.Name = "updnReadAddressEE";
			this.updnReadAddressEE.Size = new System.Drawing.Size(71, 20);
			this.updnReadAddressEE.TabIndex = 2;
			// 
			// lblAddressEE
			// 
			this.lblAddressEE.AutoSize = true;
			this.lblAddressEE.Location = new System.Drawing.Point(96, 10);
			this.lblAddressEE.Name = "lblAddressEE";
			this.lblAddressEE.Size = new System.Drawing.Size(45, 13);
			this.lblAddressEE.TabIndex = 3;
			this.lblAddressEE.Text = "Address";
			// 
			// chkHexWriteAddress
			// 
			this.chkHexWriteAddress.AutoSize = true;
			this.chkHexWriteAddress.Location = new System.Drawing.Point(176, 72);
			this.chkHexWriteAddress.Name = "chkHexWriteAddress";
			this.chkHexWriteAddress.Size = new System.Drawing.Size(45, 17);
			this.chkHexWriteAddress.TabIndex = 14;
			this.chkHexWriteAddress.Text = "Hex";
			this.chkHexWriteAddress.UseVisualStyleBackColor = true;
			this.chkHexWriteAddress.CheckedChanged += new System.EventHandler(this.chkHexWriteAddress_CheckedChanged);
			// 
			// lblLengthEE
			// 
			this.lblLengthEE.AutoSize = true;
			this.lblLengthEE.Location = new System.Drawing.Point(228, 10);
			this.lblLengthEE.Name = "lblLengthEE";
			this.lblLengthEE.Size = new System.Drawing.Size(40, 13);
			this.lblLengthEE.TabIndex = 4;
			this.lblLengthEE.Text = "Length";
			// 
			// lblEEPROMData
			// 
			this.lblEEPROMData.AutoSize = true;
			this.lblEEPROMData.Location = new System.Drawing.Point(228, 56);
			this.lblEEPROMData.Name = "lblEEPROMData";
			this.lblEEPROMData.Size = new System.Drawing.Size(50, 13);
			this.lblEEPROMData.TabIndex = 13;
			this.lblEEPROMData.Text = "Data (0x)";
			// 
			// chkHexReadAddress
			// 
			this.chkHexReadAddress.AutoSize = true;
			this.chkHexReadAddress.Location = new System.Drawing.Point(176, 27);
			this.chkHexReadAddress.Name = "chkHexReadAddress";
			this.chkHexReadAddress.Size = new System.Drawing.Size(45, 17);
			this.chkHexReadAddress.TabIndex = 5;
			this.chkHexReadAddress.Text = "Hex";
			this.chkHexReadAddress.UseVisualStyleBackColor = true;
			this.chkHexReadAddress.CheckedChanged += new System.EventHandler(this.chkHexReadAddress_CheckedChanged);
			// 
			// lblWriteAddress
			// 
			this.lblWriteAddress.AutoSize = true;
			this.lblWriteAddress.Location = new System.Drawing.Point(97, 53);
			this.lblWriteAddress.Name = "lblWriteAddress";
			this.lblWriteAddress.Size = new System.Drawing.Size(45, 13);
			this.lblWriteAddress.TabIndex = 12;
			this.lblWriteAddress.Text = "Address";
			// 
			// btnWriteEEPROM
			// 
			this.btnWriteEEPROM.Location = new System.Drawing.Point(6, 66);
			this.btnWriteEEPROM.Name = "btnWriteEEPROM";
			this.btnWriteEEPROM.Size = new System.Drawing.Size(75, 23);
			this.btnWriteEEPROM.TabIndex = 7;
			this.btnWriteEEPROM.Text = "Write";
			this.btnWriteEEPROM.UseVisualStyleBackColor = true;
			this.btnWriteEEPROM.Click += new System.EventHandler(this.btnWriteEEPROM_Click);
			// 
			// updnWriteAddressEE
			// 
			this.updnWriteAddressEE.Location = new System.Drawing.Point(99, 69);
			this.updnWriteAddressEE.Maximum = new decimal(new int[] {
            2047,
            0,
            0,
            0});
			this.updnWriteAddressEE.Name = "updnWriteAddressEE";
			this.updnWriteAddressEE.Size = new System.Drawing.Size(71, 20);
			this.updnWriteAddressEE.TabIndex = 11;
			// 
			// btnBackupEEPROM
			// 
			this.btnBackupEEPROM.Location = new System.Drawing.Point(429, 54);
			this.btnBackupEEPROM.Name = "btnBackupEEPROM";
			this.btnBackupEEPROM.Size = new System.Drawing.Size(75, 23);
			this.btnBackupEEPROM.TabIndex = 8;
			this.btnBackupEEPROM.Text = "Backup";
			this.btnBackupEEPROM.UseVisualStyleBackColor = true;
			this.btnBackupEEPROM.Click += new System.EventHandler(this.btnBackupEEPROM_Click);
			// 
			// btnRestoreEEPROM
			// 
			this.btnRestoreEEPROM.Location = new System.Drawing.Point(429, 87);
			this.btnRestoreEEPROM.Name = "btnRestoreEEPROM";
			this.btnRestoreEEPROM.Size = new System.Drawing.Size(75, 23);
			this.btnRestoreEEPROM.TabIndex = 9;
			this.btnRestoreEEPROM.Text = "Restore";
			this.btnRestoreEEPROM.UseVisualStyleBackColor = true;
			this.btnRestoreEEPROM.Click += new System.EventHandler(this.btnRestoreEEPROM_Click);
			// 
			// tabLogging
			// 
			this.tabLogging.BackColor = System.Drawing.SystemColors.Control;
			this.tabLogging.Location = new System.Drawing.Point(4, 22);
			this.tabLogging.Name = "tabLogging";
			this.tabLogging.Size = new System.Drawing.Size(537, 492);
			this.tabLogging.TabIndex = 2;
			this.tabLogging.Text = "Logging";
			// 
			// grpConnect
			// 
			this.grpConnect.Controls.Add(this.lblBTFW);
			this.grpConnect.Controls.Add(this.lblCom);
			this.grpConnect.Controls.Add(this.btnConnect);
			this.grpConnect.Controls.Add(this.lblAlarm);
			this.grpConnect.Controls.Add(this.lblComType);
			this.grpConnect.Controls.Add(this.lblSchema);
			this.grpConnect.Controls.Add(this.cboComPorts);
			this.grpConnect.Controls.Add(this.lblSchemaLbl);
			this.grpConnect.Controls.Add(this.lblVerLbl);
			this.grpConnect.Controls.Add(this.lblUnits);
			this.grpConnect.Controls.Add(this.lblComTypeLbl);
			this.grpConnect.Controls.Add(this.lblUnitsLbl);
			this.grpConnect.Controls.Add(this.lblVersion);
			this.grpConnect.Controls.Add(this.lblBuild);
			this.grpConnect.Controls.Add(this.lblBuildLbl);
			this.grpConnect.Location = new System.Drawing.Point(12, 1);
			this.grpConnect.Name = "grpConnect";
			this.grpConnect.Size = new System.Drawing.Size(514, 64);
			this.grpConnect.TabIndex = 19;
			this.grpConnect.TabStop = false;
			// 
			// lblBTFW
			// 
			this.lblBTFW.AutoSize = true;
			this.lblBTFW.BackColor = System.Drawing.SystemColors.Control;
			this.lblBTFW.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.lblBTFW.ForeColor = System.Drawing.Color.Maroon;
			this.lblBTFW.Location = new System.Drawing.Point(327, 12);
			this.lblBTFW.Name = "lblBTFW";
			this.lblBTFW.Size = new System.Drawing.Size(47, 13);
			this.lblBTFW.TabIndex = 19;
			this.lblBTFW.Text = "BT S/W";
			// 
			// lblCom
			// 
			this.lblCom.AutoSize = true;
			this.lblCom.BackColor = System.Drawing.SystemColors.Control;
			this.lblCom.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.lblCom.ForeColor = System.Drawing.Color.Maroon;
			this.lblCom.Location = new System.Drawing.Point(217, 11);
			this.lblCom.Name = "lblCom";
			this.lblCom.Size = new System.Drawing.Size(79, 13);
			this.lblCom.TabIndex = 18;
			this.lblCom.Text = "Communication";
			// 
			// statusBar
			// 
			this.statusBar.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.tsStatus,
            this.toolStripStatusLabel1});
			this.statusBar.Location = new System.Drawing.Point(5, 592);
			this.statusBar.Name = "statusBar";
			this.statusBar.Size = new System.Drawing.Size(561, 22);
			this.statusBar.TabIndex = 20;
			this.statusBar.Text = "statusStrip1";
			// 
			// tsStatus
			// 
			this.tsStatus.Name = "tsStatus";
			this.tsStatus.Size = new System.Drawing.Size(0, 17);
			// 
			// toolStripStatusLabel1
			// 
			this.toolStripStatusLabel1.Name = "toolStripStatusLabel1";
			this.toolStripStatusLabel1.Size = new System.Drawing.Size(35, 17);
			this.toolStripStatusLabel1.Text = "Done";
			// 
			// BTSerialComTester
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(571, 619);
			this.Controls.Add(this.statusBar);
			this.Controls.Add(this.btnHelp);
			this.Controls.Add(this.grpConnect);
			this.Controls.Add(this.tabControl1);
			this.HelpButton = true;
			this.Name = "BTSerialComTester";
			this.Padding = new System.Windows.Forms.Padding(5);
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
			this.Text = "BrewTroller Serial Com Tester";
			this.Load += new System.EventHandler(this.BTComTest_Load);
			this.grpGetCommands.ResumeLayout(false);
			this.brpRecipe.ResumeLayout(false);
			this.grpSetCommands.ResumeLayout(false);
			this.grpSetCommands.PerformLayout();
			((System.ComponentModel.ISupportInitialize)(this.updnDelayTime)).EndInit();
			((System.ComponentModel.ISupportInitialize)(this.updnGrainTemp)).EndInit();
			((System.ComponentModel.ISupportInitialize)(this.updnEvapRate)).EndInit();
			((System.ComponentModel.ISupportInitialize)(this.updnBoilPower)).EndInit();
			((System.ComponentModel.ISupportInitialize)(this.updnBoilTemp)).EndInit();
			this.grpPerfTest.ResumeLayout(false);
			this.grpPerfTest.PerformLayout();
			((System.ComponentModel.ISupportInitialize)(this.updnTestCount)).EndInit();
			this.tabControl1.ResumeLayout(false);
			this.tabTest.ResumeLayout(false);
			this.tabEEPROM.ResumeLayout(false);
			this.grpEEPROM.ResumeLayout(false);
			this.grpEEPROM.PerformLayout();
			((System.ComponentModel.ISupportInitialize)(this.updnWriteLengthEE)).EndInit();
			((System.ComponentModel.ISupportInitialize)(this.updnReadLengthEE)).EndInit();
			((System.ComponentModel.ISupportInitialize)(this.updnReadAddressEE)).EndInit();
			((System.ComponentModel.ISupportInitialize)(this.updnWriteAddressEE)).EndInit();
			this.grpConnect.ResumeLayout(false);
			this.grpConnect.PerformLayout();
			this.statusBar.ResumeLayout(false);
			this.statusBar.PerformLayout();
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.Button btnConnect;
		private System.Windows.Forms.Button btnGetVersion;
		private System.Windows.Forms.GroupBox grpGetCommands;
		private System.Windows.Forms.Button btnGetEvap;
		private System.Windows.Forms.Button btnGetBoilTemp;
		private System.Windows.Forms.Button btnGetPID;
		private System.Windows.Forms.ComboBox cboVessel;
		private System.Windows.Forms.ComboBox cboTemps;
		private System.Windows.Forms.Button btnGetTemps;
		private System.Windows.Forms.Button btnGetCal;
		private System.Windows.Forms.Button btnGetProfile;
		private System.Windows.Forms.Button btnGetVolume;
		private System.Windows.Forms.ComboBox cboVolume;
		private System.Windows.Forms.ComboBox cboCalibration;
		private System.Windows.Forms.ComboBox cboProfile;
		private System.Windows.Forms.Button getRecipe;
		private System.Windows.Forms.ComboBox cboRecipeSlot;
		private System.Windows.Forms.Button btnHelp;
		private System.Windows.Forms.Label lblComType;
		private System.Windows.Forms.ComboBox cboComPorts;
		private System.Windows.Forms.Label lblUnits;
		private System.Windows.Forms.GroupBox grpSetCommands;
		private System.Windows.Forms.Label lblBoilPowerUnits;
		private System.Windows.Forms.Label lglDeg;
		private System.Windows.Forms.NumericUpDown updnBoilPower;
		private System.Windows.Forms.NumericUpDown updnBoilTemp;
		private System.Windows.Forms.Button btnSetBoil;
		private System.Windows.Forms.Label lblEvapUnits;
		private System.Windows.Forms.NumericUpDown updnEvapRate;
		private System.Windows.Forms.Button btnSetEvapRate;
		private System.Windows.Forms.Label lblVerLbl;
		private System.Windows.Forms.Label lblComTypeLbl;
		private System.Windows.Forms.Label lblVersion;
		private System.Windows.Forms.Label lblBuild;
		private System.Windows.Forms.Label lblBuildLbl;
		private System.Windows.Forms.Label lblUnitsLbl;
		private System.Windows.Forms.Button btnGetDelayTime;
		private System.Windows.Forms.Button btnGetGrainTemp;
		private System.Windows.Forms.Label lblGrainUnits;
		private System.Windows.Forms.Label lblDelayUnits;
		private System.Windows.Forms.NumericUpDown updnDelayTime;
		private System.Windows.Forms.Button btnSetDelayTime;
		private System.Windows.Forms.NumericUpDown updnGrainTemp;
		private System.Windows.Forms.Button btnSetGrainTemp;
		private System.Windows.Forms.Button btnGetCalcVols;
		private System.Windows.Forms.GroupBox brpRecipe;
		private System.Windows.Forms.Button btnGetCalcTemps;
		private System.Windows.Forms.Button btnGetBoilPower;
		private System.Windows.Forms.Button btnSetBoilPower;
		private System.Windows.Forms.Button btnLogging;
		private System.Windows.Forms.Button btnGetLog;
		private System.Windows.Forms.Label lblSchema;
		private System.Windows.Forms.Label lblSchemaLbl;
		private System.Windows.Forms.GroupBox grpPerfTest;
		private System.Windows.Forms.NumericUpDown updnTestCount;
		private System.Windows.Forms.Button btnStartSpeedTest;
		private System.Windows.Forms.Label lblErrCount;
		private System.Windows.Forms.Label lblCountlbl;
		private System.Windows.Forms.TextBox tbErrorCount;
		private System.Windows.Forms.TextBox tbCurrentCount;
		private System.Windows.Forms.Label lblTestCountLbl;
		private System.Windows.Forms.Button btnDisplayErrors;
		private System.Windows.Forms.Button btnSetAlarm;
		private System.Windows.Forms.RichTextBox rtbResults;
		private System.Windows.Forms.Button btnGetAlarm;
		private System.Windows.Forms.Label lblAlarm;
		private System.Windows.Forms.TabControl tabControl1;
		private System.Windows.Forms.TabPage tabTest;
		private System.Windows.Forms.TabPage tabEEPROM;
		private System.Windows.Forms.GroupBox grpConnect;
		private System.Windows.Forms.TabPage tabLogging;
		private System.Windows.Forms.Label lblLengthEE;
		private System.Windows.Forms.Label lblAddressEE;
		private System.Windows.Forms.NumericUpDown updnReadAddressEE;
		private System.Windows.Forms.NumericUpDown updnReadLengthEE;
		private System.Windows.Forms.Button btnReadEE;
		private System.Windows.Forms.CheckBox chkHexReadAddress;
		private System.Windows.Forms.RichTextBox rtbEEPROM;
		private System.Windows.Forms.Button btnRestoreEEPROM;
		private System.Windows.Forms.Button btnBackupEEPROM;
		private System.Windows.Forms.Button btnWriteEEPROM;
		private System.Windows.Forms.Label lblEEPROMData;
		private System.Windows.Forms.Label lblWriteAddress;
		private System.Windows.Forms.NumericUpDown updnWriteAddressEE;
		private System.Windows.Forms.CheckBox chkHexReadLength;
		private System.Windows.Forms.CheckBox chkHexWriteAddress;
		private System.Windows.Forms.GroupBox grpEEPROM;
		private System.Windows.Forms.Button btnInitializeEE;
		private System.Windows.Forms.TextBox txtDataEE;
		private System.Windows.Forms.StatusStrip statusBar;
		private System.Windows.Forms.ToolStripStatusLabel tsStatus;
		private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel1;
		private System.Windows.Forms.NumericUpDown updnWriteLengthEE;
		private System.Windows.Forms.CheckBox chkHexWriteLength;
		private System.Windows.Forms.Button btnGetLogStatus;
		private System.Windows.Forms.Label lblCom;
		private System.Windows.Forms.Label lblBTFW;
	}
}

