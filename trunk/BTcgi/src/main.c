/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * main.c
 * Copyright (C) Matt Reba 2010 <matt@brewtroller.com>
 * 
 * BTcgi is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * BTcgi is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/time.h>

#define SERVER_ADDRESS "/tmp/btsock"
#define BUFFER_SIZE 1024
#define RESPONSE_TIMEOUT 5000 /* 5000 ms */

void getCmd(char*);
char x2c(char*);
void unescape_url(char*);
void error(int, char*);
void error_d(int, char*, char*);

int main()
{
	int i, n, sockfd, servlen;
	char buffer[BUFFER_SIZE];
	struct sockaddr_un  serv_addr;
	struct timeval tstart, tnow;
	
	getCmd(buffer);
	if (buffer[0] == '\0')
		error(400, "Missing Command");
	

	bzero((char *)&serv_addr,sizeof(serv_addr));
	serv_addr.sun_family = AF_UNIX;
	strcpy(serv_addr.sun_path, SERVER_ADDRESS);
	servlen = strlen(serv_addr.sun_path) + sizeof(serv_addr.sun_family);
	if ((sockfd = socket(AF_UNIX, SOCK_STREAM | SOCK_NONBLOCK, 0)) < 0)
	   error(500, "Unable to create socket");
	if (connect(sockfd, (struct sockaddr *) &serv_addr, servlen) < 0)
	   error(500, "Unable to connect to socket");
	write(sockfd,buffer,strlen(buffer));
	(void)gettimeofday(&tstart, NULL); 
	n = 0;
	while (n < BUFFER_SIZE) {
		i = read(sockfd,buffer + n, BUFFER_SIZE - n);
		if (i > 0) {
			n += i;
			if (buffer[n - 1] == '\n') break;
			buffer[n] = '\0'; /* Append String Term */
		}
		(void)gettimeofday(&tnow, NULL);
		if ((tnow.tv_sec * 1000 + tnow.tv_usec / 1000) - (tstart.tv_sec * 1000 + tstart.tv_usec / 1000) >= RESPONSE_TIMEOUT)
			error_d(500, "Response Timeout", buffer);
	}
	close(sockfd);
	
	if (n == BUFFER_SIZE)
		error(500, "Response Overflow");
	
	char *cmdField = strchr(buffer, '\t');
	if (cmdField == NULL)
		error(500, "Unexpected Response");
	cmdField++;
	if (strchr(cmdField, '\t') == NULL)
		error(500, "Missing Data");
	if (cmdField[0] == '!')
		error(400, "Invalid Command");
	if (cmdField[0] == '#')
		error(400, "Parameter Count Mismatch");
	
	printf("Content-Type: application/json; charset=utf-8\nExpires: 0\n\n");
	printf("[\"");

	for (i=0; i < n; i++) {
		if (buffer[i] == '\t') printf("\",\"");
		else if (buffer[i] == '\r') { /* Do nothing */ }
		else if (buffer[i] == '\n') { printf("\"]\n"); break; }
		else putchar(buffer[i]);
	}
	return(0);
}

void getCmd(char *cmdText) {
	if (strcmp(getenv("REQUEST_METHOD"), "GET"))
		error(400, "Invalid REQUEST_METHOD");
	char *qs;
	qs = getenv("QUERY_STRING");
	
	if(qs == NULL)
		error(400, "Missing QUERY_STRING");
	int i;
    for (i=0; qs[i]; i++) {
		 /** Change all plusses back to spaces. **/
		if (qs[i] == '+') qs[i] = ' ';
		 /** Change & to TAB **/
		else if (qs[i] == '&') qs[i] = '\t';
	}
	unescape_url(qs);
	strcpy(cmdText, qs);
	strcat(cmdText, "\r");
}

char x2c(char *what) {
   register char digit;

   digit = (what[0] >= 'A' ? ((what[0] & 0xdf) - 'A')+10 : (what[0] - '0'));
   digit *= 16;
   digit += (what[1] >= 'A' ? ((what[1] & 0xdf) - 'A')+10 : (what[1] - '0'));
   return(digit);
}

/** Reduce any %xx escape sequences to the characters they represent. **/
void unescape_url(char *url) {
    register int i,j;

    for(i=0,j=0; url[j]; ++i,++j) {
        if((url[i] = url[j]) == '%') {
            url[i] = x2c(&url[j+1]) ;
            j+= 2 ;
        }
    }
    url[i] = '\0' ;
}

void error(int errCode, char *errDesc) {	error_d(errCode, errDesc, ""); }

void error_d(int errCode, char *errDesc, char *msg)
{
	printf("Status: %d %s\n", errCode, errDesc);
	printf("Content-Type: text/html; charset=UTF-8;\nExpires: 0\r\n\r\n");
	printf("%s", msg);
    exit(errCode);
}