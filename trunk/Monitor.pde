void doMon()
{
  clearLCD();
  int tempHLT, tempMash, tempKettle;
  char sTempUnit[2] = "C";
  if (tempUnit == TEMPF) strcpy(sTempUnit, "F");
  
  printLCD(0,0,"Monitor Mode");
  printLCD(1,0,"   HLT:");
  printLCD(2,0,"  Mash:");
  printLCD(3,0,"Kettle:");
  for (int i=0; i < 3; i++) printLCD(i+1, 11, sTempUnit);
  while (1) {
    if (enterStatus == 2) {
        enterStatus = 0;
        return;
    }
    char buf[4];
    tempHLT = get_temp(tempUnit, tsHLT);
    tempMash = get_temp(tempUnit, tsMash);
    tempKettle = get_temp(tempUnit, tsKettle);
    printLCDPad(1,8,itoa(tempHLT, buf, 10), 3, ' ');
    printLCDPad(2,8,itoa(tempMash, buf, 10), 3, ' ');
    printLCDPad(3,8,itoa(tempKettle, buf, 10), 3, ' ');
  }
}
