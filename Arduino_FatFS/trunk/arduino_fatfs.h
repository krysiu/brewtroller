/*
 * 
 * Arduino Wrapper Function Library for Petit FatFs
 * 
 * FatFs - http://elm-chan.org/fsw/ff/00index_e.html
 * by ChanN
 * 
 * Original Petit_fatfs Wrapper Functions by Frank Zhao, Adapted to fatfs by Matt Reba
 * 
 */


#ifndef FF_h
#define FF_h

extern "C" {

#include "integer.h"
#include "ff.h"

}

#include "WProgram.h"

class FF
{
  private:
    static FATFS fatfs_obj;
	static FIL fil_obj[3];
	const char log_file_dir[8]; 
	const char web_page_dir[8];

  public:
    FF();

    int begin(byte);
//	void buffer_mode();
//	void stream_mode();
	int open_file(char *, byte);
	int create_file(FILINFO *, char *, byte);
	int read_file(char *, DWORD, UINT, UINT *, byte);
	int write_file(char *, DWORD, UINT, UINT *, byte);
	int get_file_info(FILINFO *, char *);
	const char * get_html_dir(void);
	const char * get_logs_dir(void);
	
//	int lseek_file(int);
//	int open_dir(DIR *, char *);
//	int read_dir(DIR *, FILINFO *);
};

extern FF FFS;

#endif

