/*  
  BTnic - BrewTroller Web Service Gateway

  cfg.h - configuration data structure

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

#ifndef _CFG_H
#define _CFG_H

#include "globals.h"
#include "log.h"
#include "tty.h"
#include "conn.h"

#ifdef IPC_UNIX_SOCKETS
    #define CLI_PERM    S_IRWXU | S_IRWXG | S_IRWXO
    #define CLI_PATH    "/tmp/btsock"
#else
    #define DEFAULT_SERVERPORT 502
#endif

#define CFGPATH "/etc/btnic.conf"

/* Global configuration storage structure */
typedef struct
{
#ifdef LOG
  /* debug level */
  char dbglvl;
  /* log file name */
  char logname[INTBUFSIZE + 1];
#endif
  /* tty port name */
  char ttyport[INTBUFSIZE + 1];
  /* tty speed */
  int ttyspeed;
  /* trx control type (0 - ADDC, 1 - by RTS) */
  int trxcntl;
#ifdef IPC_UNIX_SOCKETS
  /* Socket Address */
  char serveraddr[INTBUFSIZE + 1];
#else
  /* TCP server port number */
  int serverport;
#endif
  /* maximum number of connections */
  int maxconn;
  /* number of tries of request in case timeout (0 - no tries attempted) */
  int maxtry;
  /* staled connection timeout (in sec) */
  int conntimeout;
  /* inter-request pause (in msec) */
  unsigned long rqstpause;
  /* response waiting time (in msec) */
  unsigned long respwait;
  /* inter-byte response pause (in usec) */
  unsigned long resppause;
} cfg_t;

/* Prototypes */
extern cfg_t cfg;
void cfg_init(void);
int cfg_load(char *cfgname);

#endif /* _CFG_H */ 
