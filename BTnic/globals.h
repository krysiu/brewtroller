/*  
  BTnic - BrewTroller Web Service Gateway

  globals.h - global variables

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

#ifndef _GLOBALS_H
#define _GLOBALS_H

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <signal.h>
#include <fcntl.h>
#ifdef HAVE_LIBUTIL
#  include <libutil.h>
#endif

/* Useful min/max macroses  */
#define MAX(a, b) ( (a > b) ? a : b )
#define MIN(a, b) ( (a < b) ? a : b )

/* Boolean constants */
#define FALSE 0
#define TRUE  !FALSE

/* Constants */
#define RC_OK       0
#define RC_ERR     -1
#define RC_BREAK   -2
#define RC_TIMEOUT -3
#define RC_AOPEN   -4
#define RC_ACLOSE  -5

/* Internal string buffers size */
#if defined(PATH_MAX)
#  define INTBUFSIZE PATH_MAX
#else
#  define INTBUFSIZE 1023
#endif

#endif
