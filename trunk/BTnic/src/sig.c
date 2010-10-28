/*  
  BTnic - BrewTroller Web Service Gateway

  sig.c - signal handling functions

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
 
#include "sig.h"
#include "tty.h"

/* signal flag */
volatile sig_atomic_t sig_flag = 0;

/* internal prototypes */
void sig_bus(int signum);
void sig_segv(int signum);
void sig_handler(int signum);

/*
 * Signal handler initialization
 * Return: none
 */
void
sig_init(void)
{
  struct sigaction sa;
  
  sa.sa_flags = 0;

  sigemptyset(&sa.sa_mask);
  sigaddset(&sa.sa_mask, SIGSEGV);
  sigaddset(&sa.sa_mask, SIGBUS);
  sigaddset(&sa.sa_mask, SIGTERM);
  sigaddset(&sa.sa_mask, SIGHUP);
  sigaddset(&sa.sa_mask, SIGINT);
  sigaddset(&sa.sa_mask, SIGPIPE);
  sigaddset(&sa.sa_mask, SIGCHLD);
  sigaddset(&sa.sa_mask, SIGALRM);
  sigaddset(&sa.sa_mask, SIGUSR1);
  sigaddset(&sa.sa_mask, SIGUSR2);

  sa.sa_handler = sig_segv;
  sigaction(SIGSEGV, &sa, NULL);

  sa.sa_handler = sig_bus;
  sigaction(SIGBUS, &sa, NULL);

  sa.sa_handler = sig_handler;
  sigaction(SIGTERM, &sa, NULL);

  sa.sa_handler = sig_handler;
  sigaction(SIGHUP, &sa, NULL);

  sa.sa_handler = sig_handler;
  sigaction(SIGINT, &sa, NULL);

  sa.sa_handler = SIG_IGN;
  sigaction(SIGPIPE, &sa, NULL);

  sa.sa_handler = SIG_IGN;
  sigaction(SIGCHLD, &sa, NULL);

  sa.sa_handler = SIG_IGN;
  sigaction(SIGALRM, &sa, NULL);

  sa.sa_handler = SIG_IGN;
  sigaction(SIGUSR1, &sa, NULL);

  sa.sa_handler = SIG_IGN;
  sigaction(SIGUSR2, &sa, NULL);
}

/*
 * SIGSEGV signal handler
 */
void
sig_segv(int signum)
{
#ifndef SAFESIG
  signum = signum; /* prevent compiler warning */
  fprintf(stderr, "caught SIGSEGV, dumping core...");
  fclose(stderr);
#endif
  abort();
}

/*
 * SIGBUS signal handler
 */
void
sig_bus(int signum)
{
#ifndef SAFESIG
  signum = signum; /* prevent compiler warning */
  fprintf(stderr, "caught SIGBUS, dumping core...");
  fclose(stderr);
#endif
  abort();
}

/*
 * Unignored signals handler
 */
void
sig_handler(int signum)
{
#ifndef SAFESIG
  tty_sighup();
#endif
  sig_flag = signum;
}

/*
 * Signal action execution
 */
void
sig_exec(void)
{
#ifdef LOG
  static char *signames[] = { 
    "", "HUP", "INT", "QUIT", "ILL", "TRAP", "IOT", "BUS", "FPE",
    "KILL", "USR1", "SEGV", "USR2", "PIPE", "ALRM", "TERM" };
  log(2, "Terminated by signal: SIG%s", signames[sig_flag]);
#endif
  /* cleanup */
#ifdef IPC_UNIX_SOCKETS
  unlink(cfg.serveraddr);
#endif
  exit(1);
}
