void assignSensor() {
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
      break;
    case 1:
      break;
    case 2:
      break;
    case 3:
      break;
    case 4:
      break;    
    case 5:
      break;
    default:
      return;    
  }

  printLCD(2, 1, "XXXXXXXXXXXXXXXX");
  char choices[2][19] = {
    "     Scan Bus     ",
    "       Exit       "};
  if (getChoice(choices, 2, 3) == 0) {
    clearLCD();
    
  }
}
