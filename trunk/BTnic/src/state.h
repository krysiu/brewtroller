/*  
  BTnic - BrewTroller Web Service Gateway

  state.h - state management functions

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

#ifndef _STATE_H
#define _STATE_H

#include "globals.h"
#include "conn.h"
#include "tty.h"
#include "queue.h"
#include "cfg.h"
#ifdef LOG
#  include "log.h"
#endif

/* prototypes */
conn_t *state_conn_search(queue_t *queue, conn_t *conn, int state);
void state_conn_set(conn_t *conn, int state);
void state_tty_set(ttydata_t *mod, int state);

#endif /* _STATE_H */
