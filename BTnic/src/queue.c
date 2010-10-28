/*  
  BTnic - BrewTroller Web Service Gateway

  queue.c - queue management functions

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
#include "queue.h"

/*
 * Queue structure initialization
 */
void
queue_init(queue_t *queue)
{
  queue->beg = NULL;
  queue->end = NULL;
  queue->len = 0;
}

/*
 * Add new element to queue
 */
conn_t *
queue_new_elem(queue_t *queue)
{
  conn_t *newconn = (conn_t *)malloc(sizeof(conn_t));
  if (!newconn)
  { /* Aborting program execution */
#ifdef LOG
    log(0, "queue_new_elem(): out of memory for new element (%s)",
           strerror(errno));
#endif
    exit(errno);
  }
  newconn->next = NULL;
  if ((newconn->prev = queue->end) != NULL)
    queue->end->next = newconn;
  else /* we add first element */
    queue->beg = newconn;
  queue->end = newconn;
  queue->len++;
#ifdef DEBUG
  log(5, "queue_new_elem(): length now is %d", queue->len);
#endif
  return newconn;
}

/*
 * Remove element from queue
 */
void
queue_delete_elem(queue_t *queue, conn_t *conn)
{
  if (queue->len <= 0)
  { /* queue is empty */
#ifdef LOG
    log(1, "queue_delete_elem(): queue empty!");
#endif
    return;
  }
  if (conn->prev == NULL)
  { /* deleting first element */
    if ((queue->beg = queue->beg->next) != NULL)
      queue->beg->prev = NULL;
  }
  else 
    conn->prev->next = conn->next;
  if (conn->next == NULL)
  { /* deleting last element */
    if ((queue->end = queue->end->prev) != NULL)
      queue->end->next = NULL;
  }
  else
    conn->next->prev = conn->prev;
  queue->len--;
  free((void *)conn);
#ifdef DEBUG  
  log(5, "queue_delete_elem(): length now is %d", queue->len);
#endif
  return;
}

/*
 * Obtain pointer to next element in the QUEUE (with wrapping)
 * Parameters: CONN - pointer to current queue element
 * Return: pointer to next queue element
 */
conn_t *
queue_next_elem(queue_t *queue, conn_t *conn)
{
  return (conn->next == NULL) ? queue->beg : conn->next;
}
