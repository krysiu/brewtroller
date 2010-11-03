/*  
  BTnic - BrewTroller Web Service Gateway

  sock.h - socket management functions

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

#ifndef _SOCKUTILS_H
#define _SOCKUTILS_H

#include "globals.h"
#ifdef LOG
#  include "log.h"
#endif
#include "cfg.h"

#define BACKLOG 5

/* Socket buffers size */
#define SOCKBUFSIZE 512

int sock_set_blkmode(int sd, int blkmode);
int sock_create(int blkmode);

#ifdef IPC_UNIX_SOCKETS
int sock_create_server(char *sockAddr, int blkmode);
int sock_accept(int server_sd, struct sockaddr_un *rmt_addr, int blkmode);
#else
int sock_create_server(char *server_ip, unsigned short server_port, int blkmode);
int sock_accept(int server_sd, struct sockaddr_in *rmt_addr, int blkmode);
#endif

#endif
