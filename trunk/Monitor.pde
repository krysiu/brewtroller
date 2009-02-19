void doMon() {
  char buf[6];
  float tempHLT = 0;
  float tempMash = 0;
  float tempKettle = 0;
  int tempCFCH2OIn = 0;
  int tempCFCH2OOut = 0;
  int tempCFCBeerOut = 0;
  char sTempUnit[2] = "C";
  unsigned long convStart = 0;
  unsigned long hltCycleStart;
  unsigned long mashCycleStart;
  unsigned long kettleCycleStart;
  boolean hltHeatStatus = 0;
  boolean mashHeatStatus = 0;
  boolean kettleHeatStatus = 0;

  if (hltPIDEnabled) {
    hltPID.SetIOLimits(0, 255, 0, hltPIDCycle * 1000);
    hltPIDOutput = 0;
    hltCycleStart = millis();
  }
  if (mashPIDEnabled) {
    mashPID.SetIOLimits(0, 255, 0, mashPIDCycle * 1000);
    mashPIDOutput = 0;
    mashCycleStart = millis();
  }
  if (kettlePIDEnabled) {
    kettlePID.SetIOLimits(0, 255, 0, kettlePIDCycle * 1000);
    kettlePIDOutput = 0;
    kettleCycleStart = millis();
  }
  
  if (tempUnit == TEMPF) strcpy(sTempUnit, "F");
  encMin = 0;
  encMax = 2;
  encCount = 0;
  int lastCount = 1;
  
  while (1) {
    if (enterStatus == 2) {
      enterStatus = 0;
      if (confirmExit()) {
          resetOutputs();
          return;
      } else {
        encCount = lastCount;
        lastCount += 1;
      }
    }
    if (enterStatus == 1) {
      enterStatus = 0;
      if (alarmStatus) {
        setAlarm(0);
      } else {
        //Pop-Up Menu
        char monMenu[11][20] = {
          "Set HLT Temp       ",
          "Clear HLT Temp     ",
          "Set Mash Temp      ",
          "Clear Mash Temp    ",
          "Set Kettle Temp    ",
          "Clear Kettle Temp  ",
          "Set Timer          ",
          "Pause Timer        ",
          "Clear Timer        ",
          "Close Menu         ",
          "Quit Brew Monitor  "
        };
        boolean inMenu = 1;
        while(inMenu) {
          char unit[2] = "C"; if (tempUnit) strcpy(unit, "F");
          switch (scrollMenu("Brew Monitor Menu   ", monMenu, 11)) {
            case 0:
              {
                byte defHLTTemp = 180;
                if (!tempUnit) defHLTTemp = defHLTTemp * 5 / 9 + 32;
                if (hltSetpoint > 0) hltSetpoint = getValue("Enter HLT Temp:", hltSetpoint, 0, 255, unit);
                else hltSetpoint = getValue("Enter HLT Temp:", defHLTTemp, 0, 255, unit);
              }
              inMenu = 0;
              break;
            case 1: hltSetpoint = 0; inMenu = 0; break; 
            case 2:
              {
                byte defMashTemp = 152;
                if (!tempUnit) defMashTemp = defMashTemp * 5 / 9 + 32;
                if (mashSetpoint > 0) mashSetpoint = getValue("Enter Mash Temp:", mashSetpoint, 0, 255, unit);
                else mashSetpoint = getValue("Enter Mash Temp:", defMashTemp, 0, 255, unit);
              }
              inMenu = 0;
              break;
            case 3: mashSetpoint = 0; inMenu = 0; break; 
            case 4:
              {
                byte defKettleTemp = 212;
                if (!tempUnit) defKettleTemp = defKettleTemp * 5 / 9 + 32;
                if (kettleSetpoint > 0) kettleSetpoint = getValue("Enter Kettle Temp:", kettleSetpoint, 0, 255, unit);
                else kettleSetpoint = getValue("Enter Kettle Temp:", defKettleTemp, 0, 255, unit);
              }
              inMenu = 0;
              break;
            case 5: kettleSetpoint = 0; inMenu = 0; break; 
            case 6:
              int newMins;
              newMins = getTimerValue("Enter Timer Value:", timerValue/60000);
              if (newMins > 0) {
                setTimer(newMins);
                inMenu = 0;
              }
              break;
            case 7:
              pauseTimer();
              inMenu = 0;
              break;
            case 8:
              clearTimer();
              inMenu = 0;
              break;
            case 10:
              if (confirmExit()) {
                resetOutputs();
                return;
              } else break;
            default:
              inMenu = 0;
              break;
          }
        }
        encMin = 0;
        encMax = 2;
        encCount = lastCount;
        lastCount += 1;
      }
    }
    char buf[6];
    switch (encCount) {
      case 0:
        if (encCount != lastCount) {
          clearLCD();
          printLCD(0,0,"Brew Monitor  (Mash)");
          printLCD(2,0,"    HLT[   ]:       ");
          printLCD(3,0,"   Mash[   ]:       ");
          printLCD(2, 19, sTempUnit);
          printLCD(3, 19, sTempUnit);
          lastCount = encCount;
          timerLastWrite = 0;
        }
        if (tempHLT == -1) printLCD(2, 14, "-----");
        else {
          ftoa(tempHLT, buf, 1);
          printLCDPad(2, 14, buf, 5, ' ');
        }
        if (tempMash == -1) printLCD(3, 14, "-----");
        else {
          ftoa(tempMash, buf, 1);
          printLCDPad(3, 14, buf, 5, ' ');
        }
        if (hltPIDEnabled) {
          byte pct = hltPIDOutput / hltPIDCycle / 10;
          printLCDPad(2, 8, itoa(pct, buf, 10), 3, ' ');
        } else if (hltHeatStatus) printLCD(2, 8, " On"); else printLCD(2, 8, "Off"); 
        if (mashPIDEnabled) {
          byte pct = mashPIDOutput / mashPIDCycle / 10;
          printLCDPad(3, 8, itoa(pct, buf, 10), 3, ' ');
        } else if (mashHeatStatus) printLCD(3, 8, " On"); else printLCD(3, 8, "Off"); 
        break;
      case 1:
        if (encCount != lastCount) {
          clearLCD();
          printLCD(0,0,"Brew Monitor  (Boil)");
          printLCD(3,0," Kettle[   ]:       ");
          printLCD(3, 19, sTempUnit);
          lastCount = encCount;
          timerLastWrite = 0;
        }
        if (tempKettle == -1) printLCD(3, 14, "-----");
        else {
          ftoa(tempKettle, buf, 1);
          printLCDPad(3, 14, buf, 5, ' ');
        }
        if (kettlePIDEnabled) {
          byte pct = kettlePIDOutput / kettlePIDCycle / 10;
          printLCDPad(3, 8, itoa(pct, buf, 10), 3, ' ');
        } else if (kettleHeatStatus) printLCD(3, 8, " On"); else printLCD(3, 8, "Off");
        break;
      case 2:
        if (encCount != lastCount) {
          clearLCD();
          printLCD(0,0,"Brew Monitor (Chill)");
          printLCD(1,0,"            In   Out");
          printLCD(2,0,"     Beer:          ");
          printLCD(3,0,"      H2O:          ");
          printLCD(2, 14, sTempUnit);
          printLCD(2, 19, sTempUnit);
          printLCD(3, 14, sTempUnit);
          printLCD(3, 19, sTempUnit);
          lastCount = encCount;
          timerLastWrite = 0;
        }
        if (tempKettle == -1) printLCD(2, 11, "---"); else printLCDPad(2, 11, itoa(tempKettle, buf, 10), 3, ' ');
        if (tempCFCBeerOut == -1) printLCD(2, 16, "---"); else printLCDPad(2, 16, itoa(tempCFCBeerOut, buf, 10), 3, ' ');
        if (tempCFCH2OIn == -1) printLCD(3, 11, "---"); else printLCDPad(3, 11, itoa(tempCFCH2OIn, buf, 10), 3, ' ');
        if (tempCFCH2OOut == -1) printLCD(3, 16, "---"); else printLCDPad(3, 16, itoa(tempCFCH2OOut, buf, 10), 3, ' ');
        break;
    }
    printTimer(1,0);

    if (convStart == 0) {
      convertAll();
      convStart = millis();
    } else if (millis() - convStart >= 750) {
      tempHLT = read_temp(tempUnit, tsHLT);
      tempMash = read_temp(tempUnit, tsMash);
      tempKettle = read_temp(tempUnit, tsKettle);
      tempCFCH2OIn = read_temp(tempUnit, tsCFCH2OIn);
      tempCFCH2OOut = read_temp(tempUnit, tsCFCH2OOut);
      tempCFCBeerOut = read_temp(tempUnit, tsCFCBeerOut);
      convStart = 0;
    }
    if (hltPIDEnabled) {
      if (tempHLT == -1) {
        hltPID.SetMode(MANUAL);
        hltPIDOutput = 0;
      } else {
        hltPID.SetMode(AUTO);
        hltPIDInput = tempHLT;
        hltPID.Compute();
      }
      if (millis() - hltCycleStart > hltPIDCycle * 1000) hltCycleStart += hltPIDCycle * 1000;
      if (hltPIDOutput > millis() - hltCycleStart) digitalWrite(HLTHEAT_PIN, HIGH);
      else digitalWrite(HLTHEAT_PIN, LOW);
    } else {
      if (hltHeatStatus) {
        if (tempHLT == -1 || tempHLT >= hltSetpoint) {
          digitalWrite(HLTHEAT_PIN, LOW);
          hltHeatStatus = 0;
        }
      } else { 
        if (tempHLT != -1 && (float)(hltSetpoint - tempHLT) >= (float) hltHysteresis / 10.0) {
          digitalWrite(HLTHEAT_PIN, HIGH);
          hltHeatStatus = 1;
        }
      }
    }
    if (mashPIDEnabled) {
      if (tempMash == -1) {
        mashPID.SetMode(MANUAL);
        mashPIDOutput = 0;
      } else {
        mashPID.SetMode(AUTO);
        mashPIDInput = tempMash;
        mashPID.Compute();
      }
      if(millis() - mashCycleStart > mashPIDCycle * 1000) mashCycleStart += mashPIDCycle * 1000;
      if(mashPIDOutput > millis() - mashCycleStart) digitalWrite(MASHHEAT_PIN, HIGH);
      else digitalWrite(MASHHEAT_PIN, LOW);
    } else {
      if (mashHeatStatus) {
        if (tempMash == -1 || tempMash >= mashSetpoint) {
          digitalWrite(MASHHEAT_PIN, LOW);
          mashHeatStatus = 0;
        }
      } else { 
        if (tempMash != -1 && (float) (mashSetpoint - tempMash) >= (float) mashHysteresis / 10.0) {
          digitalWrite(MASHHEAT_PIN, HIGH);
          mashHeatStatus = 1;
        }
      }
    }
    if (kettlePIDEnabled) {
      if (tempKettle == -1) {
        kettlePID.SetMode(MANUAL);
        kettlePIDOutput = 0;
      } else {
        kettlePID.SetMode(AUTO);
        kettlePIDInput = tempKettle;
        kettlePID.Compute();
      }
      if(millis() - kettleCycleStart > kettlePIDCycle * 1000) kettleCycleStart += kettlePIDCycle * 1000;
      if(kettlePIDOutput > millis() - kettleCycleStart) digitalWrite(KETTLEHEAT_PIN, HIGH);
      else digitalWrite(KETTLEHEAT_PIN, LOW);
    } else {
      if (kettleHeatStatus) {
        if (tempKettle == -1 || tempKettle >= kettleSetpoint) {
          digitalWrite(KETTLEHEAT_PIN, LOW);
          kettleHeatStatus = 0;
        }
      } else { 
        if (tempKettle != -1 && (float) (kettleSetpoint - tempKettle) >= (float) kettleHysteresis / 10.0) {
          digitalWrite(KETTLEHEAT_PIN, HIGH);
          kettleHeatStatus = 1;
        }
      }
    }
  }
}
