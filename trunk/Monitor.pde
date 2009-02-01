void doMon()
{
  clearLCD();
  float tempHLT, tempMash, tempKettle;
  char sTempUnit[2] = "C";
  if (tempUnit == TEMPF) strcpy(sTempUnit, "F");
  
  printLCD(0,0,"Monitor Mode");
  printLCD(1,0,"   HLT:");
  printLCD(2,0,"  Mash:");
  printLCD(3,0,"Kettle:");
  for (int i=0; i < 3; i++) printLCD(i+1, 13, sTempUnit);
  while (1) {
    if (enterStatus == 2) {
        enterStatus = 0;
        return;
    }
    char buf[6];
    tempHLT = get_temp(tempUnit, tsHLT);
    tempMash = get_temp(tempUnit, tsMash);
    tempKettle = get_temp(tempUnit, tsKettle);
    
    ftoa(tempHLT, buf, 1);
    printLCDPad(1, 8, buf, 5, ' ');
    
    ftoa(tempMash, buf, 1);
    printLCDPad(2, 8, buf, 5, ' ');
    
    ftoa(tempKettle, buf, 1);
    printLCDPad(3, 8, buf, 5, ' ');
  }
}
