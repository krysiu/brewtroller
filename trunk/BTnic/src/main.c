/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*  
  BTnic - BrewTroller Web Service Gateway

  main.c - main module

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


#include "globals.h"
#include "string.h"
#include "errno.h"
#include "cfg.h"
#include "tty.h"
#include "sock.h"
#include "conn.h"
#include "queue.h"
#include "sig.h"
#ifdef LOG
#  include "log.h"
#endif

extern char logfullname[];
int isdaemon = TRUE;
void usage(char *exename);


/* Server socket */
int server_sd = -1;
/* TTY related data storage variable */
ttydata_t tty;
/* Connections queue descriptor */
queue_t queue;

#if 0
#ifndef HAVE_DAEMON
#include <fcntl.h>
#include <unistd.h>

/* 
 System function daemon() replacement based on FreeBSD implementation.
 Original source file CVS tag:
 $FreeBSD: src/lib/libc/gen/daemon.c,v 1.3 2000/01/27 23:06:14 jasone Exp $
*/

int
daemon(nochdir, noclose)
  int nochdir, noclose;
{
  int fd;

  switch (fork()) {
    case -1:
      return (-1);
    case 0:
      break;
    default:
      _exit(0);
  }

  if (setsid() == -1)
    return (-1);

  if (!nochdir)
    (void)chdir("/");

  if (!noclose && (fd = _open("/dev/null", O_RDWR, 0)) != -1) {
    (void)dup2(fd, STDIN_FILENO);
    (void)dup2(fd, STDOUT_FILENO);
    (void)dup2(fd, STDERR_FILENO);
    if (fd > 2)
      (void)_close(fd);
  }
  return (0);
}
#endif
#endif

void
usage(char *exename)
{
  printf("%s-%s Copyright (C) 2010 Open Source Control Systems, Inc.\n\n"
	 "Usage: %s [-h] [-d] [-v level] [-L name] [-p name] [-s value] [-P number]\n"
   "             [-C number] [-N number] [-R value] [-W value] [-T value]\n\n"
	 "  -h             this help\n"
	 "  -d             don't daemonize\n"
#ifdef LOG
#ifdef DEBUG
   "  -v<level>      set log level (0-9, default %d, 0 - errors only)\n"
#else
   "  -v<level>      set log level (0-2, default %d, 0 - errors only)\n"
#endif
   "  -L<name>       set log file name (default %s%s, \n"
   "                 value '-' forces log data output to STDOUT only\n"
   "                 if '-d' switch was given)\n"
#endif
	 "  -p<name>       set serial port device name (default %s)\n"
	 "  -s<value>      set serial port speed (default %d)\n"
#ifdef TRXCTL
	 "  -t             force RTS RS-485 transmitting/receiving control\n"
#endif
#ifndef IPC_UNIX_SOCKETS
   "  -P<number>     set TCP server port number (default %d)\n"
#endif
   "  -C<number>     set maximum number of simultaneous connections\n"
   "                 (1-128, default %d)\n"
   "  -N<number>     set maximum number of request retries\n"
   "                 (0-15, default %d, 0 - without retries)\n"
   "  -R<value>      set pause between requests in milliseconds\n"
   "                 (1-10000, default %lu)\n"
   "  -W<value>      set response wait time in milliseconds\n"
   "                 (1-10000, default %lu)\n"
   "  -T<value>      set connection timeout value in seconds\n"
   "                 (0-1000, default %d, 0 - no timeout)"
   "\n", PACKAGE, VERSION, exename,
#ifdef LOG
      cfg.dbglvl, LOGPATH, LOGNAME,
#endif
      cfg.ttyport, cfg.ttyspeed,
#ifndef IPC_UNIX_SOCKETS
      cfg.serverport,
#endif
       cfg.maxconn, cfg.maxtry, cfg.rqstpause, cfg.respwait, cfg.conntimeout);
  exit(0);
}

int
main(int argc, char *argv[])
{
  int err = 0, rc;
  char *exename;
  
  sig_init();
  cfg_init();

  if ((exename = strrchr(argv[0], '/')) == NULL)
    exename = argv[0];
  else
    exename++;
    
  /* command line argument list parsing */
  while ((rc = getopt(argc, argv,
               "dh"
#ifdef TRXCTL
               "t"
#endif
#ifdef LOG
               "v:L:"
#endif
               "p:s:P:C:N:R:W:T:")) != RC_ERR)
  {
    switch (rc)
    {
      case '?':
        exit(-1);
      case 'd':
        isdaemon = FALSE;
        break;
#ifdef TRXCTL
      case 't':
        cfg.trxcntl = TRX_RTS;
        break;
#endif
#ifdef LOG
      case 'v':
        cfg.dbglvl = (char)strtol(optarg, NULL, 0);
#  ifdef DEBUG
        if (cfg.dbglvl < 0 || cfg.dbglvl > 9)
        { /* report about invalid log level */
          printf("%s: -v: invalid loglevel value"
                 " (%d, must be 0-9)\n", exename, cfg.dbglvl);
#  else
        if (cfg.dbglvl < 0 || cfg.dbglvl > 9)
        { /* report about invalid log level */
          printf("%s: -v: invalid loglevel value"
                 " (%d, must be 0-2)\n", exename, cfg.dbglvl);
#  endif
          exit(-1);
        }
        break;
      case 'L':
        if (*optarg != '/')
        {
          if (*optarg == '-')
          {
            if (isdaemon)
            {
               printf("%s: -L: '-' value is valid only if "
                      "-d switch was given\n", exename);
               exit(-1);
            }
            /* logfile isn't needed, doing all output to STDOUT */
            *cfg.logname = '\0';
          }
          else
          { /* concatenate given log file name with default path */
            strncpy(cfg.logname, LOGPATH, INTBUFSIZE);
            strncat(cfg.logname, optarg,
                    INTBUFSIZE - strlen(cfg.logname));
          }
        }
        else strncpy(cfg.logname, optarg, INTBUFSIZE);
        break;
#endif
      case 'p':
        if (*optarg != '/') 
        { /* concatenate given port name with default path to devices mountpoint */
          strncpy(cfg.ttyport, "/dev/", INTBUFSIZE);
          strncat(cfg.ttyport, optarg,
                  INTBUFSIZE - strlen(cfg.ttyport));
        }
        else strncpy(cfg.ttyport, optarg, INTBUFSIZE);
        break;
      case 's':
        cfg.ttyspeed = strtoul(optarg, NULL, 0);
        break;
#ifndef IPC_UNIX_SOCKETS
      case 'P':
        cfg.serverport = strtoul(optarg, NULL, 0);
        break;
#endif
      case 'C':
        cfg.maxconn = strtoul(optarg, NULL, 0);
        if (cfg.maxconn < 1 || cfg.maxconn > 128)
        { /* report about invalid max conn number */
          printf("%s: -C: invalid maxconn value"
                 " (%d, must be 1-128)\n", exename, cfg.maxconn);
          exit(-1);
        }
        break;
      case 'N':
        cfg.maxtry = strtoul(optarg, NULL, 0);
        if (cfg.maxtry > 15)
        { /* report about invalid max try number */
          printf("%s: -N: invalid maxtry value"
                 " (%d, must be 0-15)\n", exename, cfg.maxtry);
          exit(-1);
        }
        break;
      case 'R':
        cfg.rqstpause = strtoul(optarg, NULL, 0);
        if (cfg.rqstpause < 1 || cfg.rqstpause > 10000)
        { /* report about invalid rqst pause value */
          printf("%s: -R: invalid inter-request pause value"
                 " (%lu, must be 1-10000)\n", exename, cfg.rqstpause);
          exit(-1);
        }
        break;
      case 'W':
        cfg.respwait = strtoul(optarg, NULL, 0);
        if (cfg.respwait < 1 || cfg.respwait > 10000)
        { /* report about invalid resp wait value */
          printf("%s: -W: invalid response wait time value"
                 " (%lu, must be 1-10000)\n", exename, cfg.respwait);
          exit(-1);
        }
        break;
      case 'T':
        cfg.conntimeout = strtoul(optarg, NULL, 0);
        if (cfg.conntimeout > 1000)
        { /* report about invalid conn timeout value */
          printf("%s: -T: invalid conn timeout value"
                 " (%d, must be 1-1000)\n", exename, cfg.conntimeout);
          exit(-1);
        }
        break;
      case 'h':
        usage(exename);
    }
  }

#ifdef LOG
  if (log_init(cfg.logname) != RC_OK)
  {
    printf("%s: can't open logfile '%s' (%s), exiting...\n",
           exename,
           logfullname[0] ? logfullname : "no log name was given",
           strerror(errno));
    exit(-1);
  }
  log(2, "%s-%s started...", PACKAGE, VERSION);
#endif

  if (conn_init())
  {
#ifdef LOG
    err = errno;
    log(2, "conn_init() failed, exiting...");
#endif
    exit(err);
  }

  /* go or not to daemon mode? */
  if (isdaemon && (rc = daemon(TRUE, FALSE)))
  {
#ifdef LOG
    log(0, "Can't be daemonized (%s), exiting...", strerror(errno));
#endif
    exit(rc);
  }

  conn_loop();
  err = errno;
#ifdef LOG
  log(2, "%s-%s exited...", PACKAGE, VERSION);
#endif
  return (err);
}
