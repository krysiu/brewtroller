/*  
  BTnic - BrewTroller Web Service Gateway

  cfg.c - configuration data structure

  Copyright (C)2010 Open Source Control Systems, Inc.

  Based on source from:
  * OpenMODBUS/TCP to RS-232/485 MODBUS RTU gateway
  * Copyright (c) 2002-2003, Victor Antonovich (avmlink@vlink.ru)

    This file is part of BrewTroller.

    BrewTroller is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    BrewTroller is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with BrewTroller.  If not, see <http://www.gnu.org/licenses/>.

BrewTroller - Open Source Brewing Computer
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com
*/


#include "cfg.h"

/* Global configuration storage variable */
cfg_t cfg;

/*
 * Setting up config defaults
 */
void 
cfg_init(void)
{
#ifdef LOG
  cfg.dbglvl = 2;
  strncpy(cfg.logname, LOGNAME, INTBUFSIZE);
#endif
  strncpy(cfg.ttyport, DEFAULT_PORT, INTBUFSIZE);
  cfg.ttyspeed = DEFAULT_SPEED;
#ifdef  TRXCTL
  cfg.trxcntl = TRX_ADDC;
#endif
#ifdef IPC_UNIX_SOCKETS
  strncpy(cfg.serveraddr, CLI_PATH, INTBUFSIZE);
#else
  cfg.serverport = DEFAULT_SERVERPORT;
#endif
  cfg.maxconn = DEFAULT_MAXCONN;
  cfg.maxtry = DEFAULT_MAXTRY;
  cfg.rqstpause = DEFAULT_RQSTPAUSE;
  cfg.respwait = DEFAULT_RESPWAIT;
  cfg.resppause = DV(3, cfg.ttyspeed);
  cfg.conntimeout = DEFAULT_CONNTIMEOUT;
}

int get_val(char *cfgline, char *keyTest, char *destVal) {
    int linelen = strcspn(cfgline, "\n\r");
    int keylen = strlen(keyTest);
    if (strncmp(cfgline, keyTest, keylen) != 0) return 0;
    destVal[0] = '\0';
    strncat(destVal, cfgline + keylen, linelen - keylen);
    return 1;
}

int cfg_load(char *cfgname) {
  FILE *cfgfile;
  char cfgline[INTBUFSIZE + 1], 
    strval[INTBUFSIZE + 1];
    
  cfgfile = fopen(cfgname, "r");
  if (!cfgfile) return RC_ERR;
  
  while(fgets(cfgline, INTBUFSIZE + 1, cfgfile) != NULL) {
     if (get_val(cfgline, "dbglvl=", strval)) cfg.dbglvl = (char) atoi(strval);
     (void) get_val(cfgline, "logname=", cfg.logname);
     (void) get_val(cfgline, "ttyport=", cfg.ttyport);

    #ifdef IPC_UNIX_SOCKETS
     (void) get_val(cfgline, "sockpath=", cfg.serveraddr);
    #else
      if (get_val(cfgline, "serverport=", strval)) cfg.serverport = atoi(strval);
    #endif
      if (get_val(cfgline, "ttyspeed=", strval)) cfg.ttyspeed = atoi(strval);
      if (get_val(cfgline, "maxconn=", strval)) cfg.maxconn = atoi(strval);
      if (get_val(cfgline, "maxtry=", strval)) cfg.maxtry = atoi(strval);
      if (get_val(cfgline, "rqstpause=", strval)) cfg.rqstpause = strtoul(strval, NULL, 10);
      if (get_val(cfgline, "respwait=", strval)) cfg.respwait = strtoul(strval, NULL, 10);
      if (get_val(cfgline, "resppause=", strval)) cfg.resppause = strtoul(strval, NULL, 10);
      if (get_val(cfgline, "conntimeout=", strval)) cfg.conntimeout = atoi(strval);
  }
  fclose(cfgfile);
  return RC_OK;
}
