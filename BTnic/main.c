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
#include "cfg.h"
#include "sig.h"
#include "tty.h"
#include "log.h"

void usage(char *execfile)
{
  printf("%s-%s Copyright (C) 2002, 2003 Open Source Control Systems, Inc.\n\n"
	"Usage: %s [-h] [-d] [-v level] [-L name] [-p name] [-s value] [-P number]\n"
	"             [-C number] [-N number] [-R value] [-W value] [-T value]\n\n"
	"  -v<level>      set log level (0-9, default %d, 0 - errors only)\n"
	"  -L<name>       set log file name (default %s%s, \n"
	"  -p<name>       set serial port device name (default %s)\n"
	"  -s<value>      set serial port speed (default %d)\n"
	"\n", PACKAGE, VERSION, execfile, cfg.dbglvl, LOGPATH, LOGNAME, cfg.ttyport, cfg.ttyspeed);
  exit(0);
}


int main(int argc, char *argv[])
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
  while ((rc = getopt(argc, argv, "v:L:p:s:")) != RC_ERR)
  {
    switch (rc)
    {
      case 'v':
        cfg.dbglvl = (char)strtol(optarg, NULL, 0);
        if (cfg.dbglvl < 0 || cfg.dbglvl > 9)
        { /* report about invalid log level */
          printf("%s: -v: invalid loglevel value"
                 " (%d, must be 0-9)\n", exename, cfg.dbglvl);
          exit(-1);
        }
        break;
      case 'L':
        if (*optarg != '/')
        { /* concatenate given log file name with default path */
          strncpy(cfg.logname, LOGPATH, INTBUFSIZE);
          strncat(cfg.logname, optarg,
                    INTBUFSIZE - strlen(cfg.logname));
        }
        else strncpy(cfg.logname, optarg, INTBUFSIZE);
        break;
      case 'p':
        if (*optarg != '/') 
        { /* concatenate given port name with default
             path to devices mountpoint */
          strncpy(cfg.ttyport, "/dev/", INTBUFSIZE);
          strncat(cfg.ttyport, optarg,
                  INTBUFSIZE - strlen(cfg.ttyport));
        }
        else strncpy(cfg.ttyport, optarg, INTBUFSIZE);
        break;
      case 's':
        cfg.ttyspeed = strtoul(optarg, NULL, 0);
        break;
      case else:
        usage(exename);
    }
  }

  if (log_init(cfg.logname) != RC_OK)
  {
    printf("%s: can't open logfile '%s' (%s), exiting...\n",
           exename,
           logfullname[0] ? logfullname : "no log name was given",
           strerror(errno));
    exit(-1);
  }
  log(2, "%s-%s started...", PACKAGE, VERSION);

  if (conn_init())
  {
    err = errno;
    log(2, "conn_init() failed, exiting...");
    exit(err);
  }

  conn_loop();
  err = errno;
  log(2, "%s-%s exited...", PACKAGE, VERSION);
  return (err);
}

}
