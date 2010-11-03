/*  
  BTnic - BrewTroller Web Service Gateway

  state.c - state management functions

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

#include "state.h"

/*
 * Search for first client connection in state STATE
 * Parameters: CONN - ptr to queue element
 *             (if NULL - search from queue begin),
 *             QUEUE - ptr to the queue;
 * Return:     pointer to queue element
 *             or NULL if none found
 */
conn_t *
state_conn_search(queue_t *queue, conn_t *conn, int state)
{
  int len = queue->len;

  /* check for zero queue length */
  if (!queue->len) return NULL;

  if (conn == NULL)
    conn = queue->beg;
  else
    conn = queue_next_elem(queue, conn);
    
  while (len--)
  {
    if (conn->state == state)
      return conn;
    conn = queue_next_elem(queue, conn);
  }
  
  return NULL; /* none found */
}

/*
 * Set connection CONN to STATE
 */
void
state_conn_set(conn_t *conn, int state)
{
  switch (state)
  {
    case CONN_RQST:
      conn->ctr = 0;
      conn->len = 0;
#ifdef IPC_UNIX_SOCKETS
             log(5, "conn[%d]: state now is CONN_RQST", conn->sd);
#else
             log(5, "conn[%s]: state now is CONN_RQST", inet_ntoa(conn->sockaddr.sin_addr));
#endif
    break;
    case CONN_TTY:
      
#ifdef IPC_UNIX_SOCKETS
             log(5, "conn[%d]: state now is CONN_TTY", conn->sd);
#else
             log(5, "conn[%s]: state now is CONN_TTY", inet_ntoa(conn->sockaddr.sin_addr));
#endif
    break;
    case CONN_RESP:
      conn->ctr = 0;
#ifdef DEBUG
      
#ifdef IPC_UNIX_SOCKETS
             log(5, "conn[%d]: state now is CONN_RESP", conn->sd);
#else
             log(5, "conn[%s]: state now is CONN_RESP", inet_ntoa(conn->sockaddr.sin_addr));
#endif
#endif
      break;
    default:
      /* unknown state, exiting */
#ifdef DEBUG
      
#ifdef IPC_UNIX_SOCKETS
             log(5, "conn_set_state([%d]) - invalid state (%d)", conn->sd,
#else
             log(5, "conn_set_state([%s]) - invalid state (%d)", inet_ntoa(conn->sockaddr.sin_addr), 
#endif
                state);
#endif
      exit (-1);
  }
  conn->state = state;
  /* reset timeout value */
  conn->timeout = cfg.conntimeout;
}

/*
 * Set tty device to STATE
 */
void
state_tty_set(ttydata_t *mod, int state)
{
  switch (state)
  {
    case TTY_PAUSE:
      mod->trynum = 0;
      mod->timer = (unsigned long)cfg.rqstpause * 1000l;
#ifdef DEBUG
      log(5, "tty: state now is TTY_PAUSE");
#endif
      break;
    case TTY_READY:
      mod->trynum = 0;
      mod->timer = 0l;
#ifdef DEBUG
      log(5, "tty: state now is TTY_READY");
#endif
      break;
    case TTY_RQST:
      mod->ptrbuf = 0;
      mod->timer = 0l;
      mod->trynum = mod->trynum ? --mod->trynum : (unsigned)cfg.maxtry;
#ifdef DEBUG
      log(5, "tty: state now is TTY_RQST");
#endif
#ifndef NOSILENT
      tty_delay(DV(2, cfg.ttyspeed));
#endif
      break;
    case TTY_RESP:
      mod->ptrbuf = 0;
      /* XXX need real recv length? */
      mod->rxlen = 0;
      mod->timer = cfg.respwait * 1000l + DV(mod->txlen, mod->speed);
#ifdef DEBUG
      log(5, "tty: state now is TTY_RESP");
#endif
      break;
    default:
      /* unknown state, exiting */
#ifdef DEBUG
      log(5, "tty_set_state() - invalid state (%d)", state);
#endif
      exit (-1);
  }
  mod->state = state;
}
