/*  
  BTnic - BrewTroller Web Service Gateway

  conn.c - communication handling

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

#include "conn.h"
#include "queue.h"
#include "state.h"

/* global variables */
extern int server_sd;
extern queue_t queue;
extern ttydata_t tty;
extern cfg_t cfg;

conn_t *actconn; /* last active connection */
int max_sd; /* major descriptor in the select() sets */

void conn_tty_start(ttydata_t *tty, conn_t *conn);
ssize_t conn_read(int d, void *buf, size_t nbytes);
ssize_t conn_write(int d, void *buf, size_t nbytes);
int conn_select(int nfds, 
                fd_set *readfds, fd_set *writefds, fd_set *exceptfds,
                struct timeval *timeout);

#define FD_MSET(d, s) do { FD_SET(d, s); max_sd = MAX(d, max_sd); } while (0);

/*
 * Connections startup initialization
 * Parameters: none
 * Return: RC_OK in case of success, RC_ERR otherwise
 */
int
conn_init(void)
{
  /* tty device initialization */
#ifdef  TRXCTL
  tty_init(&tty, cfg.ttyport, cfg.ttyspeed, cfg.trxcntl);
#else
  tty_init(&tty, cfg.ttyport, cfg.ttyspeed);
#endif
  if (tty_open(&tty) != RC_OK)
  {
#ifdef LOG
    log(0, "conn_init():"
           " can't open tty device %s (%s)",
           cfg.ttyport, strerror(errno));
#endif
    return RC_ERR;
  }
  state_tty_set(&tty, TTY_READY);
  
  /* create server socket */
  if ((server_sd =
#ifdef IPC_UNIX_SOCKETS
         sock_create_server(cfg.serveraddr, TRUE)) < 0)
#else
         sock_create_server("", cfg.serverport, TRUE)) < 0)
#endif
  {
#ifdef LOG
    log(0, "conn_init():"
           " can't create listen() socket (%s)",
           strerror(errno));
#endif
    return RC_ERR;
  }
  
  /* connections queue initialization */
  queue_init(&queue);
  
  return RC_OK;
}

/*
 * Open new client connection
 * Parameters: none
 * Return: none
 */
void
conn_open(void)
{
  int sd;
  conn_t *newconn;
#ifdef IPC_UNIX_SOCKETS
  struct sockaddr_un rmt_addr;
#else
  struct sockaddr_in rmt_addr;
#endif  
  if ((sd = sock_accept(server_sd, &rmt_addr, TRUE)) == RC_ERR)
  { /* error in conn_accept() */
#ifdef LOG
    log(0, "conn_open(): error in accept() (%s)", strerror(errno));
#endif
    return;
  }
#ifdef LOG
  log(2, "conn_open(): accepting connection from %s",
#ifdef IPC_UNIX_SOCKETS
         rmt_addr.sun_path);
#else
         inet_ntoa(rmt_addr.sin_addr));
#endif
#endif
  /* compare descriptor of connection with FD_SETSIZE */
  if (sd >= FD_SETSIZE)
  {
#ifdef LOG
    log(1, "conn_open(): FD_SETSIZE limit reached,"
           " connection from %s will be dropped",
#ifdef IPC_UNIX_SOCKETS
          rmt_addr.sun_path);
#else
          inet_ntoa(rmt_addr.sin_addr));
#endif
#endif
    close(sd);
    return;
  }
  /* check current number of connections */
  if (queue.len == cfg.maxconn)
  {
#ifdef LOG
    log(1, "conn_open(): number of connections limit reached,"
           " connection from %s will be dropped",
#ifdef IPC_UNIX_SOCKETS
           rmt_addr.sun_path);
#else
           inet_ntoa(rmt_addr.sin_addr));
#endif
#endif
    close(sd);
    return;
  }
  /* enqueue connection */
  newconn = queue_new_elem(&queue);
  newconn->sd = sd;
#ifdef IPC_UNIX_SOCKETS
  memcpy((void *) &newconn->sockaddr, &rmt_addr, sizeof(struct sockaddr_un));
#else
  memcpy((void *) &newconn->sockaddr, &rmt_addr, sizeof(struct sockaddr_in));
#endif
  state_conn_set(newconn, CONN_RQST);
}

/*
 * Close client connection
 * Parameters: CONN - ptr to connection to close
 * Return: pointer to next queue element
 */
conn_t *
conn_close(conn_t *conn)
{
  conn_t *nextconn;
#ifdef LOG
  log(2, "conn_close(): closing connection from %s",
#ifdef IPC_UNIX_SOCKETS
         conn->sockaddr.sun_path);
#else
         inet_ntoa(conn->sockaddr.sin_addr));
#endif
#endif
  /* close socket */
  close(conn->sd);
  /* get pointer to next element */
  nextconn = queue_next_elem(&queue, conn);
  /* dequeue connection */
  queue_delete_elem(&queue, conn);
  if (actconn == conn) actconn = nextconn;
  return nextconn;
}

/*
 * Start tty transaction
 * Parameters: TTY - ptr to tty structure, 
 *             CONN - ptr to active connection
 * Return: none
 */
void
conn_tty_start(ttydata_t *tty, conn_t *conn)
{
  (void)memcpy((void *)tty->txbuf, 
               (void *)(conn->buf),
               conn->ctr);
  tty->txlen = conn->ctr;
  state_tty_set(tty, TTY_RQST);
  actconn = conn;
}

/*
 * Read() wrapper. Read nomore BYTES from descriptor D in buffer BUF
 * Return: number of successfully readed bytes,
 *         RC_ERR in case of error.
 */
ssize_t
conn_read(int d, void *buf, size_t nbytes)
{
  int rc;
  do
  { /* trying read from descriptor while breaked by signals */ 
    rc = read(d, buf, nbytes);
  } while (rc == -1 && errno == EINTR);
  return (rc < 0) ? RC_ERR : rc;
}

/*
 * Write() wrapper. Write nomore BYTES to descriptor D from buffer BUF
 * Return: number of successfully written bytes,
 *         RC_ERR in case of error.
 */
ssize_t
conn_write(int d, void *buf, size_t nbytes)
{
  int rc;
  do
  { /* trying write to descriptor while breaked by signals */ 
    rc = write(d, buf, nbytes);
  } while (rc == -1 && errno == EINTR);
  return (rc < 0) ? RC_ERR : rc;
}

#if 0
/*
 * Select() wrapper with signal checking.
 * Return: number number of ready descriptors,
 *         RC_ERR in case of error.
 */
int
conn_select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds,
            struct timeval *timeout)
{
  int rc;
  do
  { /* trying to select() while breaked by signals */ 
    rc = select(nfds, readfds, writefds, exceptfds, timeout);
  } while (rc == -1 && errno == EINTR);
  return (rc < 0) ? RC_ERR : rc;
}
#endif

/*
 * Connections serving loop
 * Parameters: none
 * Return: none
 */
void
conn_loop(void)
{
  int rc, max_sd, len, min_timeout;
  fd_set sdsetrd, sdsetwr;
  struct timeval ts, tts, t_out;
  unsigned long tval, tout_sec, tout = 0ul;
  conn_t *curconn = NULL;

  while (TRUE)
  {
    /* check for the signals */
    if (sig_flag) sig_exec();
      
    /* update FD_SETs */
    FD_ZERO(&sdsetrd);
    max_sd = server_sd;
    FD_MSET(server_sd, &sdsetrd);
    FD_ZERO(&sdsetwr);

    /* update FD_SETs by TCP connections */
    len = queue.len;
    curconn = queue.beg;
    min_timeout = cfg.conntimeout;
    while (len--)
    {
      switch (curconn->state)
      {
        case CONN_RQST:
          FD_MSET(curconn->sd, &sdsetrd);
          break;
        case CONN_RESP:
          FD_MSET(curconn->sd, &sdsetwr);
          break;
      }
      min_timeout = MIN(min_timeout, curconn->timeout);
      curconn = queue_next_elem(&queue, curconn);
    }
    
    /* update FD_SETs by tty connection */
    FD_MSET(tty.fd, &sdsetrd);
    if (tty.state == TTY_RQST) FD_MSET(tty.fd, &sdsetwr);

    if (tty.timer)
    { /* tty.timer is non-zero in TTY_PAUSE, TTY_RESP states */
      t_out.tv_sec = tty.timer / 1000000ul;
      t_out.tv_usec = tty.timer % 1000000ul;
    }
    else
    { 
      t_out.tv_usec = 0ul;
      if (cfg.conntimeout)
        t_out.tv_sec = min_timeout; /* minor timeout value */
      else 
        t_out.tv_sec = 10ul; /* XXX default timeout value */
    }

    (void)gettimeofday(&ts, NULL); /* make timestamp */
 
#ifdef DEBUG
    log(7, "conn_loop(): select(): max_sd = %d, t_out = %06lu:%06lu ", 
           max_sd, t_out.tv_sec, t_out.tv_usec);
#endif

    rc = select(max_sd + 1, &sdsetrd, &sdsetwr, NULL, &t_out);

    if (rc < 0)
    { /* some error caused while select() */
      if (errno == EINTR) continue; /* process signals */
      /* unrecoverable error in select(), exiting */
#ifdef LOG
      log(0, "conn_loop(): error in select() (%s)", strerror(errno));
#endif
      break;
    }

    /* calculating elapsed time */    
    (void)gettimeofday(&tts, NULL);
    tval = 1000000ul * (tts.tv_sec - ts.tv_sec) +
                       (tts.tv_usec - ts.tv_usec);
    
    /* modify tty timer */
    if (tty.timer)
    { /* tty timer is active */
      if (tty.timer <= tval)
        switch (tty.state)
        { /* timer expired */
          case TTY_PAUSE:
            /* inter-request pause elapsed */
            /* looking for connections in CONN_TTY state */
            curconn = state_conn_search(&queue, actconn, CONN_TTY);
            if (curconn != NULL)
              conn_tty_start(&tty, curconn);
            else
              state_tty_set(&tty, TTY_READY);
            break;
          case TTY_RESP:
            /* checking for received data */
            if (FD_ISSET(tty.fd, &sdsetrd)) break;
            /* response timeout handling */
            if (!tty.ptrbuf)
            {/* there no bytes received */
#ifdef DEBUG
              log(5, "tty: response timeout", tty.ptrbuf);
#endif
              if (!tty.trynum)
              {
                /* TODO: TTY REQUEST TIMEOUT EXCEPTION */

              }
              else
              { /* retry request */
#ifdef DEBUG
                log(5, "tty: attempt to retry request (%u of %u)",
                       cfg.maxtry - tty.trynum + 1, cfg.maxtry);
#endif
                state_tty_set(&tty, TTY_RQST);
                break;
              }
            }
            else 
            { /* some data received */
#ifdef DEBUG
            log(5, "tty: response read (total %d bytes)", tty.ptrbuf);
#endif
              if (*(tty.rxbuf + tty.ptrbuf - 1) == '\n') /* TODO: CRC Check on tty response */
              {
#ifdef DEBUG
                log(5, "tty: response is correct");
#endif
                /* received response is correct, make conn response */
                (void)memcpy((void *)(actconn->buf), 
                  (void *)tty.rxbuf,
                  tty.ptrbuf);
              }
              else
              {
                /* received response is incomplete or CRC failed */
#ifdef DEBUG
                log(5, "tty: response is incorrect");
#endif
                if (!tty.trynum)
                {
                  /* TODO: TTY RESPONSE CRC EXCEPTION */
                }
                else
                { /* retry request */
#ifdef DEBUG
                  log(5, "tty: attempt to retry request (%u of %u)",
                         cfg.maxtry - tty.trynum + 1, cfg.maxtry);
#endif
                  state_tty_set(&tty, TTY_RQST);
                  break;
                }
              }
            }
            /* switch connection to response state */
            state_conn_set(actconn, CONN_RESP);
            /* make inter-request pause */
            state_tty_set(&tty, TTY_PAUSE);
            break;
        }
      else tty.timer -= tval;
    }
    
    if (cfg.conntimeout)
    { /* expire staled connections */
      tout += tval;
      tout_sec = tout / 1000000ul;
      if (tout_sec)
      { /* at least one second elapsed, check for staled connections */
        len = queue.len;
        curconn = queue.beg;
        while (len--)
        {
          curconn->timeout -= tout_sec;
          if (curconn->timeout <= 0)
          { /* timeout expired */
            if (curconn->state == CONN_TTY)
            { /* deadlock in CONN_TTY state, exiting */
#ifdef LOG
              log(0, "conn[%s]: state CONN_TTY deadlock, exiting!",
#ifdef IPC_UNIX_SOCKETS
                     curconn->sockaddr.sun_path);
#else
                     inet_ntoa(curconn->sockaddr.sin_addr));
#endif
#endif
              exit (-1);
            }
            /* purge connection */
#ifdef LOG
            log(2, "conn[%s]: timeout, closing connection",
#ifdef IPC_UNIX_SOCKETS
                     curconn->sockaddr.sun_path);
#else
                     inet_ntoa(curconn->sockaddr.sin_addr));
#endif
#endif
            curconn = conn_close(curconn);
            continue;
          }
          curconn = queue_next_elem(&queue, curconn);
        }
        tout = tout % 1000000ul;
      }
    }
    
    if (rc == 0)
      continue;	/* timeout caused, we will do select() again */

    /* checking for pending connections */
    if (FD_ISSET(server_sd, &sdsetrd)) conn_open();

    /* tty processing */
    if (tty.state == TTY_RQST)
      if (FD_ISSET(tty.fd, &sdsetwr))
      {
        rc = conn_write(tty.fd, tty.txbuf + tty.ptrbuf,
                        tty.txlen - tty.ptrbuf);
        if (rc <= 0)
        { /* error - we can't continue... */
#ifdef LOG
          log(0, "tty: error in write() (%s)", strerror(errno));
#endif
          break; /* exiting... */
        }
#ifdef DEBUG
        log(7, "tty: written %d bytes", rc);
#endif
        tty.ptrbuf += rc;
        if (tty.ptrbuf == tty.txlen)
        { /* request transmitting completed, switch to TTY_RESP */
#ifdef DEBUG
          log(7, "tty: request written (total %d bytes)", tty.txlen);
#endif
          state_tty_set(&tty, TTY_RESP);
        }
      }
    
    while (FD_ISSET(tty.fd, &sdsetrd))
    {
      if (tty.state == TTY_RESP)
      {
        /* Read one byte */
        rc = conn_read(tty.fd, tty.rxbuf + tty.ptrbuf, 1);
        if (rc <= 0)
        { /* error - we can't continue... */
#ifdef LOG
          log(0, "tty: error in read() (%s)", strerror(errno));
#endif
          break; /* exiting... */
        }
#ifdef DEBUG
          log(7, "tty read: %c", *(tty.rxbuf + tty.ptrbuf));
#endif
        tty.ptrbuf += rc;
        if (*(tty.rxbuf + tty.ptrbuf - 1) == '\n')
        { 
          tty.rxlen = tty.ptrbuf;

           /* received response is correct, make conn response */
                (void)memcpy((void *)(actconn->buf), 
                  (void *)tty.rxbuf,
                  tty.rxlen);
                  
          state_conn_set(actconn, CONN_RESP);
          /* make inter-request pause */
          state_tty_set(&tty, TTY_PAUSE);
          break;
        }
        else
          /* reset timer */
          tty.timer = cfg.respwait * 1000l;
      }
      else
      { /* drop unexpected tty data */
        if ((rc = conn_read(tty.fd, tty.rxbuf, BUFSIZE)) <= 0)
        { /* error - we can't continue... */
#ifdef LOG
          log(0, "tty: error in read() (%s)", strerror(errno));
#endif
          break; /* exiting... */
        }
#ifdef DEBUG
          log(7, "tty: dropped %d bytes", rc);
#endif
      }
    }
    
    /* processing data on the sockets */
    len = queue.len;
    curconn = queue.beg;
    while (len--)
    {
      switch (curconn->state)
      {
        case CONN_RQST:
          if (FD_ISSET(curconn->sd, &sdsetrd))
          {
            /* Read one byte at a time */
            rc = conn_read(curconn->sd, curconn->buf + curconn->ctr, 1);
#ifdef DEBUG
            log(7, "socket(%s) read: %c",
#ifdef IPC_UNIX_SOCKETS
                curconn->sockaddr.sun_path,
#else
                inet_ntoa(curconn->sockaddr.sin_addr),
#endif
                *(curconn->buf + curconn->ctr));
#endif
            if (rc <= 0)
            { /* error - drop this connection and go to next queue element */
              curconn = conn_close(curconn);
              break;
            }
            curconn->ctr += rc;
  #ifdef DEBUG
            log(7, "socket(%s) read: %d", 
#ifdef IPC_UNIX_SOCKETS
                curconn->sockaddr.sun_path,
#else
                inet_ntoa(curconn->sockaddr.sin_addr),
#endif            
            *(curconn->buf + curconn->ctr - 1));
  #endif          
            if (*(curconn->buf + curconn->ctr - 1) == '\r')
            { /* ### packet received completely ### */
              state_conn_set(curconn, CONN_TTY);
              if (tty.state == TTY_READY)
                conn_tty_start(&tty, curconn);
            }
          }
          curconn = queue_next_elem(&queue, curconn);
          break;
        case CONN_RESP:
          if (FD_ISSET(curconn->sd, &sdsetwr))
          {
            rc = conn_write(curconn->sd,
                            curconn->buf + curconn->ctr, tty.rxlen - curconn->ctr);
            if (rc <= 0)
            { /* error - drop this connection and go to next queue element */
              curconn = conn_close(curconn);
              break;
            }
            curconn->ctr += rc;
            if (curconn->ctr == (int)tty.rxlen)
              state_conn_set(curconn, CONN_RQST);
          }
          curconn = queue_next_elem(&queue, curconn);
          break;
      } /* switch (curconn->state) */
    } /* while (len--) */
  } /* while (TRUE) */
}
