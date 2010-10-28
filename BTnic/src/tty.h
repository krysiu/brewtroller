/*  
  BTnic - BrewTroller Web Service Gateway

  tty.h - tty communication functions

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

#ifndef _TTY_H
#define _TTY_H

#include "globals.h"
#include "cfg.h"

/*
 * Delay value calculation macros  
 */
#define	DV(x, y) (x * 10000000l / y)

/*
 * Default tty port parameters
 */
#if defined (__CYGWIN__)
#  define DEFAULT_PORT "/dev/COM1"
#elif defined (__linux__)
#  define DEFAULT_PORT "/dev/ttyUSB0"
#else
#  define DEFAULT_PORT "/dev/cuaa0"
#endif

#define DEFAULT_SPEED 115200
#define DEFAULT_BSPEED B115200

/*
 * Maximum tty buffer size
 */
#define TTY_BUFSIZE 256

/* 
 * TRX control types
 */
#ifdef  TRX_CTL
#  define TRX_ADDC 0
#  define TRX_RTS  !TRX_ADDC
#endif

/*
 * TTY device FSM states
 */
#define TTY_PAUSE 0
#define TTY_READY 1
#define TTY_RQST  2
#define TTY_RESP  3
 
/*
 * TTY related data storage structure
 */
typedef struct
{
  int fd;                       /* tty file descriptor */
  int speed;                    /* serial port speed */
  char *port;                   /* serial port device name */
#ifdef TRXCTL
  int trxcntl;                  /* trx control type (0 - ADDC, RTS otherwise) */
#endif
  struct termios tios;          /* working termios structure */
  struct termios savedtios;     /* saved termios structure */
  int state;                    /* current state */
  unsigned int trynum;             /* try counter */
  unsigned long timer;          /* time tracking variable */
  unsigned int txlen;           /* tx data length */
  unsigned int rxlen;           /* rx data length */
  unsigned char ptrbuf;         /* ptr in the buffer */
  unsigned char txbuf[TTY_BUFSIZE]; /* transmitting buffer */
  unsigned char rxbuf[TTY_BUFSIZE]; /* receiving buffer */
} ttydata_t;

/* prototypes */
void tty_sighup(void);
#ifdef TRXCTL
void tty_init(ttydata_t *mod, char *port, int speed, int trxcntl);
#else
void tty_init(ttydata_t *mod, char *port, int speed);
#endif
int tty_open(ttydata_t *mod);
int tty_set_attr(ttydata_t *mod);
speed_t tty_transpeed(int speed);
int tty_cooked(ttydata_t *mod);
int tty_close(ttydata_t *mod);
void tty_set_rts(int fd);
void tty_clr_rts(int fd);
void tty_delay(int usec);

#endif /* _TTY_H */
