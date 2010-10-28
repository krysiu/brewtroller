/*  
  BTnic - BrewTroller Web Service Gateway

  log.c - logging functions

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

#include "log.h"

#ifdef LOG
#include "cfg.h"

/* log file full name */
char logfullname[INTBUFSIZE + 1];

int 
log_init(char *logname)
{
  FILE *logfile;
  int maxlen = INTBUFSIZE;

  /* checking log file name */
  if (*logname == '/')
    strncpy(logfullname, logname, maxlen);
  else 
  {
    if (!*logname)
    {
      /* logfile isn't needed */
      *logfullname = '\0';
      return RC_OK;
    }
    /* append default log path */
    strncpy(logfullname, LOGPATH, maxlen);
    maxlen -= strlen(logfullname);
    strncat(logfullname, logname, maxlen);
  }

  logfile = fopen(logfullname, "at");
  if (logfile)
  {
    fclose(logfile);
    return RC_OK;
  }
  return RC_ERR;
}

/* Append message STRING to log file LOGNAME */
int 
log_app(char *logname, char *string)
{
  FILE *logfile;
  logfile = fopen(logname, "at");
  if (logfile)
  {
    fputs(string, logfile);
    fclose(logfile);
    return RC_OK;
  }
  return RC_ERR;
}

/* Put message with format FMT with errorlevel LEVEL to log file */
void 
log(int level, char *fmt, ...)
{
#ifdef HRDATE
  time_t tt;
  struct tm *t;
#else
  struct timeval tv;
#endif
  va_list args;
  int strsize = 0;
  static char str[INTBUFSIZE + 1] = {0}, *p;

  if (level > cfg.dbglvl) return;
#ifdef HRDATE
  tt = time(NULL);
  t = localtime(&tt);
  strsize += strftime(str, 32, "%d %b %Y %H:%M:%S ", t);
#else
  (void)gettimeofday(&tv, NULL);
  strsize += snprintf(str, 32, "%06lu:%06lu ", tv.tv_sec, tv.tv_usec);
#endif
  va_start(args, fmt);
  p = str + strsize;
  strsize += vsnprintf(p, INTBUFSIZE - strsize, fmt, args);
  va_end(args);
  strcpy(str + strsize++, "\n");
  if (!isdaemon) printf("%s", str);
  if (*logfullname == '\0') return;
  log_app(logfullname, str);
}
#endif
