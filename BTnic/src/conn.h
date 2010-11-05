/*  
  BTnic - BrewTroller Web Service Gateway

  conn.h - communication handling

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
 
#ifndef _CONN_H
#define _CONN_H

#include "globals.h"
#include "cfg.h"
#include "sock.h"
#include "sig.h"
#ifdef LOG
#include "log.h"
#endif

/*
 * Default values 
 */
#define DEFAULT_MAXCONN 32
#define DEFAULT_MAXTRY 1
#define DEFAULT_RQSTPAUSE 1
#define DEFAULT_RESPWAIT 1000
#define DEFAULT_CONNTIMEOUT 60

#define BUFSIZE 256     /* size (in bytes) of data */

/*
 * Client connection FSM states
 */
#define CONN_RQST   0
#define CONN_TTY    1
#define CONN_RESP   2

/*
 * Client connection related data storage structure
 */
typedef struct conn_t
{
  struct conn_t *prev;  /* linked list previous connection */
  struct conn_t *next;  /* linked list next connection */
  int sd;               /* socket descriptor */
  int state;            /* current state */
  int timeout;          /* timeout value, secs */
#ifdef IPC_UNIX_SOCKETS
  struct sockaddr_un sockaddr; /* connection structure */
#else
  struct sockaddr_in sockaddr; /* connection structure */
#endif
  int ctr;              /* counter of data in the buffer */
  int len;              /* length of data in buffer */
  unsigned char buf[BUFSIZE];    /* data buffer */
} conn_t;

/* prototypes */
int conn_init(void);
void conn_loop(void);
void conn_open(void);
conn_t *conn_close(conn_t *conn);

#endif /* _CONN_H */
