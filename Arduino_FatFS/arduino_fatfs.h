/*
 * 
 * Arduino Wrapper Function Library for Petit FatFs
 * 
 * FatFs - http://elm-chan.org/fsw/ff/00index_e.html
 * by ChanN
 * 
 * Original Petit_fatfs Wrapper Functions by Frank Zhao, Adapted to fatfs by Devon Dallmann
 * 
 */

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// note that if you are going to use this class as part of another class rather than invoking this as a singluar object its self
// you must change all the function calls in Arduino_fatfs.cpp that call functions IN Arduino_fatfs.cpp to this->Foo or else 
// you may confuse the compiler and cause it to call the wrong function for the wrong object. The same must happen
// for all references to fil_obj (aka this->fil_obj)
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
	FIL fil_obj;
	int CursorLoc;

  public:
    FF();
    // note that all the write and print functions force a sync to the SD card before returning, thus a close file is never neaded
    int begin(byte, byte, byte);              // pass in the pin # to use for CS on the MMC interface for the SD card, the card detect pin, and the write protect pin (last two currently not used)
	int open(char *, boolean, boolean);       // open a file for this object into fil_obj pointed to by the passed in string, if the file does not exist or any directory in the string does not exist, they will be created
	                                            // the first boolean is weather the file is to be write protected or not, TRUE is write protect (read only) FALSE is leave as is. 
	                                            // the second boolean defines whether the file should be created if it doesnt exist. TRUE for create, FALSE for not
	int read(unsigned char *, DWORD, DWORD);   // read into char * from file in fil_obj, DWORD bytes from offset from start of file DWORD
	int read(unsigned char *, DWORD);          // same but read from current R/W pointer in fil_obj
	int print(unsigned char *);           // take in a " " string and print it at the current cursor in file fil_obj
	int print_P(unsigned char *);        // take in a " " string in program memory and print it at the current cursor in fil_obj
	int print_P(int *);                    // print the integer to file in fil_obj starting at the current cursor as a string of the integer
	int print_P(unsigned int *);                    // print the integer to file in fil_obj starting at the current cursor as a string of the integer
	int print(int);                    // print the integer to file in fil_obj starting at the current cursor as a string of the integer
	int print(unsigned int);           // same but unsigned
	int println(unsigned char *);         // take ing a " " string and print it at the current cursor as a string with an EOL into file fil_obj
	int println(int);                  // same as print(int) but with an EOL added
	int println(unsigned int);         // same as print(unsigned int) but with an EOL added
	int readln(unsigned char *, DWORD);        // read a line from file in fil_obj starting at the current cursor and going until DWORD bytes has been read or you reach EOL into buffer pointed to by the char pointer
	int set_cursor(DWORD);           // set the cursor location
	int write(unsigned char *, DWORD, DWORD);   // write from location pointed to by char pointer into file fil_obj starting at DWORD for DWORD bytes
	int write(unsigned char *, DWORD);          // write from location pointed to by char pointer itno file fil_obj starting at the current R/W pointer for DWORD bytes
	int get_file_info(FILINFO *, char *);     // return the file info into the structure pointed to by the FILINFO pointer 
	void SetTimerFunction(unsigned int (*)(void)); // takes a function pointer that points to a function who returns int and has no arguments and assigns it to a function pointer of the same type to be called when we want to get the current time
	
};

extern FF FFS;

#endif

