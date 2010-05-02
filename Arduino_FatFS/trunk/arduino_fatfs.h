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
    static int MMC_CS;
    static void MMC_SELECT(void);
    static void MMC_DESELECT(void);
  public:
    FF();

//Added drv (byte) param - Matt Reba
    int begin(int, unsigned char (*)(void), void (*)(unsigned char), byte);
	void buffer_mode();
	void stream_mode();
	int open_file(char *);
	int read_file(void *, int, int *);
	int lseek_file(int);
	int open_dir(DIR *, char *);
	int read_dir(DIR *, FILINFO *);
};

extern FF FFS;

#endif

