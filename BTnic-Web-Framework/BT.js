if (typeof BrewTroller == "undefined" || !BrewTroller) {
    /* BrewTroller global namespace object */
	var BrewTroller = {};
	BrewTroller.Version = "1.0";
	BrewTroller.dataURL = '/cgi-bin/btcgi';
	
	/* Top-Level Methods */
        BrewTroller.attachClass = function (className) {
		var objList = YAHOO.util.Dom.getElementsByClassName(className);
		for (var i = 0; i < objList.length; i++) {
			//To Do: Attach properly
			BrewTroller.renderObject(objList[i]);
		}
	}

	/* Executes the renderFunc of a given node passing to it the node reference itself */
	BrewTroller.renderObject = function (node) { eval(node.renderFunc + '(node);');	}

	/* Returns the data stored in the data object linked in the 'dataObj' attribute of a specified node */
	BrewTroller.getData = function (node) { return eval(node.dataObj); }

	/* BrewTroller Data Namespace */
	BrewTroller.Data = function () {

		/* DataObject Class */
		var DataObject = function () {
			/* DataObject Class Public Properties*/
			this.json = {};

			/* DataObject Class Public Methods */
			this.attachGetCmd = function (cmdCode) {
				getCmdStr = arguments[0];
				if (arguments.length > 1) { 
					for (var i = 1; i < arguments.length; i++) getCmdStr += '&' + arguments[i];
				}
			}

			this.attachSetCmd = function (cmdCode) {
				setCmdStr = arguments[0];
				if (arguments.length > 1) { 
					for (var i = 1; i < arguments.length; i++) setCmdStr += '&' + arguments[i];
				}			
			}

			this.toString = function () { return this.json[2]; }

			this.updateData = function() {
				if (typeof getCmdStr == "undefined") return 1;
				var sURL = BrewTroller.dataURL + '?' + getCmdStr;
				YAHOO.util.Connect.asyncRequest('GET', sURL, { success:this.getSuccess, failure: this.asyncFail });
			}

			this.set = function () {
				//To Do: Send Command (One or more params)
				if (typeof setCmdStr == "undefined") return 1;
				if (arguments.length < 1) return;
				var sURL = BrewTroller.dataURL + '?' + setCmdStr;
				for (var i = 0; i < arguments.length; i++) sURL += '&' + arguments[i];
				YAHOO.util.Connect.asyncRequest('GET', sURL, { success:this.setSuccess, failure: this.asyncFail });
			}

			this.asyncFail = function (o) {
				if(o.responseText !== undefined){ alert("asyncRequest Failed:\n" + o.status + " " + o.statusText + '\n\n' + o.responseText); }
			}

			this.getSuccess = function (o) {
				try { 
					this.json = YAHOO.lang.JSON.parse(o.responseText);
				} 
				catch (x) { 
					alert("JSON Parse Failed:\n" + o.responseText); 
					return; 
				}
				//To Do: Trigger Renderers for Active Nodes linked to DataObject
			
			}

			this.setSuccess = function (o) {
				this.updateData();
			}

			/* DataObject Class Private Properties */
			var getCmdStr;
			var setCmdStr;

			/* DataObject Class Private Methods */

		}

		/* Bitmask Object Class */
		var BitmaskObject = function (parent, bitmask) {
			var parent = parent;
			var bitmask = bitmask;
			this.toString = function () { if (parent & bitmask) return 1; else return 0; }
		}
	
		/* Subitem Object Class */
		var SubitemObject = function (parent, jsonIndex) {
			var parent = parent;
			var jsonIndex = jsonIndex;
			this.toString = function () { return parent[jsonIndex + 2]; }
		}
	
		var TempObject = function();
		BrewTroller.TempObject.prototype = new BrewTroller.DataObject();
		BrewTroller.TempObject.prototype.constructor = BrewTroller.TempObject;

		BrewTroller.Data.Temp = {};
		BrewTroller.Data.Temp.HLT = new BrewTroller.DataObject('q', 0);
		BrewTroller.Data.Temp.Mash = new BrewTroller.DataObject('q', 1);
		BrewTroller.Data.Temp.Kettle = new BrewTroller.DataObject('q', 2);
		BrewTroller.Data.Temp.H2O_In = new BrewTroller.DataObject('q', 3);
		BrewTroller.Data.Temp.H2O_Out = new BrewTroller.DataObject('q', 4);
		BrewTroller.Data.Temp.Beer_Out = new BrewTroller.DataObject('q', 5);
		BrewTroller.Data.Temp.AUX_1 = new BrewTroller.DataObject('q', 6);
		BrewTroller.Data.Temp.AUX_2 = new BrewTroller.DataObject('q', 7);
		BrewTroller.Data.Temp.AUX_3 = new BrewTroller.DataObject('q', 8);
	
		BrewTroller.Data.Volume = {};
		BrewTroller.Data.Volume.HLT = new BrewTroller.DataObject('p', 0);
		BrewTroller.Data.Volume.Mash = new BrewTroller.DataObject('p', 1);
		BrewTroller.Data.Volume.Kettle = new BrewTroller.DataObject('p', 2);
	
		BrewTroller.Data.Steam = new BrewTroller.DataObject('r');
	
		BrewTroller.Data.Timer = {};
		BrewTroller.Data.Timer.Mash = new BrewTroller.DataObject('o', 0);
		BrewTroller.Data.Timer.Boil = new BrewTroller.DataObject('o', 1);
	
		BrewTroller.Data.HeatPwr = {};
		BrewTroller.Data.HeatPwr.HLT = new BrewTroller.DataObject('s', 0);
		BrewTroller.Data.HeatPwr.Mash = new BrewTroller.DataObject('s', 1);
		BrewTroller.Data.HeatPwr.Kettle = new BrewTroller.DataObject('s', 2);
		BrewTroller.Data.HeatPwr.Steam = new BrewTroller.DataObject('s', 3);
	
		BrewTroller.Data.Setpoint = {};
		BrewTroller.Data.Setpoint.HLT = new BrewTroller.DataObject('t', 0);
		BrewTroller.Data.Setpoint.Mash = new BrewTroller.DataObject('t', 1);
		BrewTroller.Data.Setpoint.Kettle = new BrewTroller.DataObject('t', 2);
		BrewTroller.Data.Setpoint.Steam = new BrewTroller.DataObject('t', 3);
	
		BrewTroller.Data.AutoValve = new BrewTroller.DataObject('u');
		BrewTroller.Data.AutoValve.Fill = new BrewTroller.BitmaskObject(BrewTroller.Data.AutoValve, 1);
		BrewTroller.Data.AutoValve.Mash = new BrewTroller.BitmaskObject(BrewTroller.Data.AutoValve, 2);
		BrewTroller.Data.AutoValve.Sparge_In = new BrewTroller.BitmaskObject(BrewTroller.Data.AutoValve, 4);
		BrewTroller.Data.AutoValve.Sparge_Out = new BrewTroller.BitmaskObject(BrewTroller.Data.AutoValve, 8);
		BrewTroller.Data.AutoValve.Fly_Sparge = new BrewTroller.BitmaskObject(BrewTroller.Data.AutoValve, 16);
		BrewTroller.Data.AutoValve.Chill = new BrewTroller.BitmaskObject(BrewTroller.Data.AutoValve, 32);
		BrewTroller.Data.AutoValve.HLT = new BrewTroller.BitmaskObject(BrewTroller.Data.AutoValve, 64);
	
		BrewTroller.Data.ValveProfiles = new BrewTroller.DataObject('w');
		BrewTroller.Data.ValveProfiles.Fill_HLT = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 1);
		BrewTroller.Data.ValveProfiles.Fill_Mash = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 2);
		BrewTroller.Data.ValveProfiles.Add_Grain = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 4);
		BrewTroller.Data.ValveProfiles.Mash_Heat = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 8);
		BrewTroller.Data.ValveProfiles.Mash_Idle = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 16);
		BrewTroller.Data.ValveProfiles.Sparge_In = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 32);
		BrewTroller.Data.ValveProfiles.Sparge_Out = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 64);
		BrewTroller.Data.ValveProfiles.Hop_Add = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 128);
		BrewTroller.Data.ValveProfiles.Kettle_Lid = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 256);
		BrewTroller.Data.ValveProfiles.Chill_H2O = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 512);
		BrewTroller.Data.ValveProfiles.Chill_Beer = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 1024);
		BrewTroller.Data.ValveProfiles.Boil_Recirc = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 2048);
		BrewTroller.Data.ValveProfiles.Drain = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 4096);
		BrewTroller.Data.ValveProfiles.HLT_Heat = new BrewTroller.BitmaskObject(BrewTroller.Data.ValveProfiles, 8092);
	
		BrewTroller.Data.ValveBits = new BrewTroller.DataObject('v');
	
		BrewTroller.Data.StepProgram = new BrewTroller.DataObject('n');
		BrewTroller.Data.StepProgram.Fill = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 0);
		BrewTroller.Data.StepProgram.Delay = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 1);
		BrewTroller.Data.StepProgram.Preheat = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 2);
		BrewTroller.Data.StepProgram.Grain_In = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 3);
		BrewTroller.Data.StepProgram.Refill = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 4);
		BrewTroller.Data.StepProgram.Mash_DoughIn = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 5);
		BrewTroller.Data.StepProgram.Mash_Acid = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 6);
		BrewTroller.Data.StepProgram.Mash_Protein = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 7);
		BrewTroller.Data.StepProgram.Mash_Sacch = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 8);
		BrewTroller.Data.StepProgram.Mash_Sacch2 = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 9);
		BrewTroller.Data.StepProgram.Mash_Out = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 10);
		BrewTroller.Data.StepProgram.Mash_Hold = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 11);
		BrewTroller.Data.StepProgram.Sparge = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 12);
		BrewTroller.Data.StepProgram.Boil = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 13);
		BrewTroller.Data.StepProgram.Chill = new BrewTroller.SubitemObject(BrewTroller.Data.StepProgram, 14);
	}
	/* BrewTroller Command Namespace */
	BrewTroller.Command = {};
	
	
	/* BrewTroller Render Functions */
	BrewTroller.Renderers = {};
	
	BrewTroller.Renderers.Text = function (node) {
		node.innerText = BrewTroller.getData(node);
	}
	

	
}
