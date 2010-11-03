/*  
  BTnic - BrewTroller Web Service Gateway

  sock.c - socket management functions

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

#include "sock.h"

/*
 * Bring i/o descriptor SD to BLKMODE (if non-zero - socket is nonblocking)
 *
 * Return: RC_ERR if there some errors
 */
int 
sock_set_blkmode(int sd, int blkmode)
{
  int flags;

  flags = fcntl(sd, F_GETFL);
  if (flags == -1) return -1;

  flags = blkmode ? (flags | O_NONBLOCK) : (flags & ~O_NONBLOCK);
  flags = fcntl(sd, F_SETFL, flags);

  return flags;
}

/*
 * Create new socket in BLKMODE mode (if non-zero - socket is nonblocking)
 *
 * Return: socket descriptor, otherwise RC_ERR if there some errors
 */
int 
sock_create(int blkmode)
{
  int sock;

  if ((sock =
#ifdef IPC_UNIX_SOCKETS
         socket(PF_UNIX, SOCK_STREAM, 0)) == -1)
#else
         socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) == -1)
#endif
  {
#ifdef LOG
    log(0, "sock_create(): unable to create socket (%s)",
        strerror(errno));
#endif
    return RC_ERR;
  }

  /* set socket to desired blocking mode */
  if (sock_set_blkmode(sock, blkmode) == -1)
  {
#ifdef LOG
    log(0, "sock_create(): unable to set "
           "server socket to nonblocking (%s)",
           strerror(errno));
#endif
    return RC_ERR;
  }

  return sock;
}

/*
 * Create new server socket with SERVER_PORT, SERVER_IP -
 * port and address to bind the socket,
 * BLKMODE - blocking mode (if non-zero - socket is nonblocking)
 *
 * Return: socket descriptor, otherwise RC_ERR if there some errors
 */
#ifdef IPC_UNIX_SOCKETS
int sock_create_server(char *sockAddr, int blkmode)
#else /* TCP Server Setup */
int sock_create_server(char *server_ip, unsigned short server_port, int blkmode)
#endif
{
#ifdef IPC_UNIX_SOCKETS
  struct sockaddr_un server_sockaddr;
#else
  struct sockaddr_in server_sockaddr;
#endif  
  int sock_opt = 1;
  int server_s;

  /* create socket in desired blocking mode */
  server_s = sock_create(blkmode);
  if (server_s < 0) return server_s;

  /* set to close socket on exec() */
  if (fcntl(server_s, F_SETFD, 1) == -1)
  {
#ifdef LOG
    log(0, "sock_create_server():"
           " can't set close-on-exec on socket (%s)",
           strerror(errno));
#endif
    return RC_ERR;
  }

  /* ajust socket rx and tx buffer sizes */
  sock_opt = SOCKBUFSIZE;
  if ((setsockopt(server_s, SOL_SOCKET,
                  SO_SNDBUF, (void *)&sock_opt,
		          sizeof(sock_opt)) == -1) ||
      (setsockopt(server_s, SOL_SOCKET,
                  SO_RCVBUF, (void *)&sock_opt,
		          sizeof(sock_opt)) == -1))
  {
#ifdef LOG
    log(0, "sock_create_server():"
           " can't set socket TRX buffers sizes (%s)",
           strerror(errno));
#endif
    return RC_ERR;
  }

#ifdef IPC_UNIX_SOCKETS
  memset(&server_sockaddr, 0, sizeof(server_sockaddr));
  server_sockaddr.sun_family = AF_UNIX;
  strcpy(server_sockaddr.sun_path, sockAddr);
#else 
  /* TCP Server Setup */
  memset(&server_sockaddr, 0, sizeof(server_sockaddr));
  server_sockaddr.sin_family = AF_INET;

  if (server_ip != NULL)
    inet_aton(server_ip, &server_sockaddr.sin_addr);
  else
    server_sockaddr.sin_addr.s_addr = htonl(INADDR_ANY);

  server_sockaddr.sin_port = htons(server_port);
#endif

  if (bind(server_s, (struct sockaddr *) & server_sockaddr,
	   sizeof(server_sockaddr)) == -1)
  {
#ifdef LOG
    log(0, "sock_create_server():"
           " unable to bind() socket (%s)",
           strerror(errno));
#endif
    return RC_ERR;
  }
#ifdef IPC_UNIX_SOCKETS
    chmod(server_sockaddr.sun_path, CLI_PERM);
#endif

  /* let's listen */
  if (listen(server_s, BACKLOG) == -1)
  {
#ifdef LOG
    log(0, "sock_create_server():"
           " unable to listen() on socket (%s)",
           strerror(errno));
#endif
    exit(errno);
  }
  return server_s;
}



/*
 * Accept connection from SERVER_SD - server socket descriptor
 * and create socket in BLKMODE blocking mode
 * (if non-zero - socket is nonblocking)
 *
 * Return: socket descriptor, otherwise RC_ERR if there some errors;
 *         RMT_ADDR - ptr to connection info structure
 */
int 
#ifdef IPC_UNIX_SOCKETS
sock_accept(int server_sd, struct sockaddr_un *rmt_addr, int blkmode)
#else
sock_accept(int server_sd, struct sockaddr_in *rmt_addr, int blkmode)
#endif
{ 
  int sd, sock_opt = SOCKBUFSIZE;

#ifdef IPC_UNIX_SOCKETS
  int rmt_len = sizeof(struct sockaddr_un);
#else
  int rmt_len = sizeof(struct sockaddr_in);
#endif
  
  sd = accept(server_sd, (struct sockaddr *) rmt_addr,
              (socklen_t *) &rmt_len);
  if (sd == -1)
  {
    if (errno != EAGAIN && errno != EWOULDBLOCK)
      /* some errors caused */
#ifdef LOG
      log(0, "sock_accept(): error in accept() (%s)", strerror(errno));
#endif
    return RC_ERR;
  }
  /* tune socket */
  if (sock_set_blkmode(sd, blkmode) == RC_ERR)
  {
#ifdef LOG
    log(0, "sock_accept(): can't set socket blocking mode (%s)", 
           strerror(errno));
#endif
    close(sd);
    return RC_ERR;
  }
  /* ajust socket rx and tx buffer sizes */
  if ((setsockopt(sd, SOL_SOCKET,
                  SO_SNDBUF, (void *)&sock_opt,
		          sizeof(sock_opt)) == -1) ||
      (setsockopt(sd, SOL_SOCKET,
                  SO_RCVBUF, (void *)&sock_opt,
		          sizeof(sock_opt)) == -1))
  {
#ifdef LOG
    log(0, "sock_accept():"
           " can't set socket TRX buffer sizes (%s)",
           strerror(errno));
#endif
    return RC_ERR;
  }
  return sd;
}
