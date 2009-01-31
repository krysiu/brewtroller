void assignSensor() {
  byte *addr;
  char dispTitle[12];
  clearLCD();
  printLCD(0, 0, "Assign Temp Sensor");
  char sensors[7][19] = {
    "  Hot Liquor Tank ",
    "      Mash Tun    ",
    "    Brew Kettle   ",
    "  Chiller H2O In  ",
    "  Chiller H2O Out ",
    " Chiller Beer Out ",
    "       Exit       "};
  switch (getChoice(sensors, 7, 1)) {
    case 0:
      addr = tsHLT;
      strcpy(dispTitle, "Hot Liquor  ");
      break;
    case 1:
      addr = tsMash;
      strcpy(dispTitle, "Mash        ");
      break;
    case 2:
      addr = tsKettle;
      strcpy(dispTitle, "Kettle      ");
      break;
    case 3:
      addr = tsCFCH2OIn;
      strcpy(dispTitle, "CFC H2O In  ");
      break;
    case 4:
      addr = tsCFCH2OOut;
      strcpy(dispTitle, "CFC H2O Out ");
      break;    
    case 5:
      addr = tsCFCBeerOut;
      strcpy(dispTitle, "CFC Beer Out");
      break;
    default:
      return;    
  }
  char buf[3];
  for (int i=0; i<8; i++) printLCDPad(2,i*2+2,itoa(addr[i], buf, 16), 2, '0');
  
  char choices[2][19] = {
    "     Scan Bus     ",
    "       Exit       "};
  if (getChoice(choices, 2, 3) == 0) {
    clearLCD();
    printLCD(0,0,"Assign: ");
    printLCD(0,8, dispTitle);
    printLCD(1,0,"Disconnect all other");
    printLCD(2,0,"  temp sensors now  ");
    char conExit[2][19] = {
      "     Continue     ",
      "       Exit       "};
    if (getChoice(conExit, 2, 3) == 0) {
      clearLCD();
      getDSAddr(addr);
      printLCD(0,0,"Assign: ");
      printLCD(0,8, dispTitle);
      printLCD(1,0,"Found address:");
      for (int i=0; i<8; i++) printLCDPad(2,i*2+2,itoa(addr[i], buf, 16), 2, '0');
      printLCD(3,0,">       Exit       <");
      while (enterStatus == 0) {
        delay(500);
      }
      enterStatus = 0;
    }
    
  }
}

void setTempUnit() {
  clearLCD();
  printLCD(0, 0, "Set Temperature Unit");
  char tempUnits[2][19] = {
    "     Celcius      ",
    "    Fahrenheit    "};
  if (getChoice(tempUnits, 2, 1, tempUnit)==0) tempUnit = TEMPC; else tempUnit = TEMPF;
}
