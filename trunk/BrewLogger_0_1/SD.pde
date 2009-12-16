uint8_t sectorBuffer[512];

void initSD() {
  // some users have reported cards which won't initialise 1st time
  //
  int n = 0;
  while (mmc::initialize() != RES_OK) {
    if (++n == 10)
      error(1); //Couldn't initialise card
    delay(500);
  }

  if (!microfat2::initialize(sectorBuffer, &mmc::readSectors))
    error(2); //Couldn't initialise microfat

  // find the start sector and length of the data we'll be overwriting
  unsigned long sector, fileSize;

  if(!microfat2::locateFileStart(PSTR("DATA    TXT"), sector, fileSize))
    error(3); //Couldn't find data.txt on the card
  
  dp.initialize(sector, fileSize / 512, sectorBuffer, proxyWriter);
  memset(sectorBuffer, '.', 512);
}

// Proxy write function
// Use a proxi if:
//  > you need to adapt to a particular function's signature
//  > you want to do some processing on the buffer as it's written
//
uint8_t proxyWriter(const uint8_t* buffer, unsigned long sector, uint8_t count)
{
  // I could have just used this function to pass as the sector write...
  //
  uint8_t val = mmc::writeSectors(buffer, sector, count);

  // ... but I want to process the buffer after each write to the card!
  //
  if (dp.m_bufferIndex == 512)
  {
    // we've written a full buffer so clear it out ready for the next
    // writes - the device print variables will be updated after we return
    // from this function.
    //
    memset(sectorBuffer, '.', 512);
  }

  return val;
}

