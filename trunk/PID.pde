void initPID() {
  if(hltPIDEnabled) {
    hltPID.SetIOLimits(0,1023,0,4000); //tell the PID to range the output from 0 to 4000 
    hltPIDOutput = 4000; //start the output at its max and let the PID adjust it from there
  }
  if(kettlePIDEnabled) {
    kettlePID.SetIOLimits(0,1023,0,4000); //tell the PID to range the output from 0 to 4000 
    kettlePIDOutput = 4000; //start the output at its max and let the PID adjust it from there
  }
  if(mashPIDEnabled) {
    mashPID.SetIOLimits(0,1023,0,4000); //tell the PID to range the output from 0 to 4000 
    mashPIDOutput = 4000; //start the output at its max and let the PID adjust it from there
  }
}

void setHLTTemp() {
}

void setMashTemp() {
}
