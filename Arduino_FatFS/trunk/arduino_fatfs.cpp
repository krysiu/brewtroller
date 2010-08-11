/*
 * 
 * Arduino Wrapper Function Library for Petit FatFs
 * 
 * FatFs - http://elm-chan.org/fsw/ff/00index_e.html
 * by ChanN
 * 
 * 
 */

extern "C" {

#include <stdlib.h>
#include <string.h>
#include "diskio.h"
#include "ff.h"
#include "integer.h"
#include <avr/pgmspace.h>
}

#include "arduino_fatfs.h"


// ******************** note all paths must start with 0 for volume 0 (only volume supported) and use / slahes instead of \ for folder seperations 
// I.E. 0:/logs/log10.txt
// names must also be in 8.3 format LFN and unicode not supported, all files opened must have the complete path in the name passed in, there is no "current directory" open. 

//FATFS FF::fatfs_obj; // stores working copy of FS
//FIL   FF::fil_obj[3]; // once a file has been opened, this will store the information for that file, so you can read/write 
// the file without having to re-open it each time. 
//char * FF::dir_path; // stores last accessed directory path
//int FF::MMC_CS; // stores pin number for MMC card's CS pin
//void * FF::stream_dest; // function pointer for stream destination function
//const char FF::log_file_dir[8] = {'0',':','/','l','o','g','s','/',NULL};
//const char FF::web_page_dir[8] = {'0',':','/','h','t','m','l','/',NULL};

/*
Constructor, do not actually call, it's been done for you
*/

//FF::FF()
//{
//	dir_path = (char *)calloc(max_path_len, sizeof(dir_path)); // allocate memory for path
//}

/*
Chip Select / Deselect Functions for the MMC Card's CS pin
*/



///////////////////////////////////
// begin list of public methods
///////////////////////////////////

//! Initialization Function
/*!
  \param cs_pin is the Arduino pin connected to the MMC card's CS pin
  \return error code, see comments in FF.h for FRESULT enumeration
	  
Notes:
the value returned in the in is from the enum FRESULT in ff.h

*/
int FF::begin(byte cs_pin, byte cd_pin, byte wp_pin)
{
    int res;
	DIR dj;
	
	pinsetup(cs_pin, OUTPUT); // set CS pin to output	

	return(f_mount(0, &fatfs_obj)); 
}


//! Opens a file with a path
/*!
  \param fn is a string containing the file name and path
  \return error code, see comments in FF.h for FRESULT enumeration
	  
Notes:
path is not relative to current directory, must be complete path 
file info is saved in the FIL struct chosen by file_num.
the value returned in the in is from the enum FRESULT in ff.h

*/
int FF::open(char * fn, boolean WP, boolean Create)
{
    int res, i = 0;
	DIR dj;
	char * fpath;

	if(WP) // if we are going to write protect this will be a read only operation
	    res = f_open(&fil_obj, fn, FA_READ); // open the file for read only
	else
		res = f_open(&fil_obj, fn, FA_WRITE | FA_READ); // open the file for write and read
    

    if(res != FR_OK && Create) // if the file did not exist and we are to create it if it doesnt (and the directories leading up to it)
   	{
   	    switch(res)
   	    {
   	        case FR_NO_FILE: // then we must create the file
				res = f_open(&fil_obj, fn, FA_CREATE_NEW); //create the file
				
			    if(WP)
			    {
			        f_chmod(fn, 0x01, AM_RDO); // set read only
			        fil_obj.flag |= FA_READ; // set the read flag to allow reading (prevents us from having to do a second open with FA_READ so we dont fail out of our f_read() call
			    }
			    else
			    {
					fil_obj.flag |= FA_READ | FA_WRITE; // set the read and write flags to allow reading and writting (prevents us from having to do a second open with FA_READ | FA_WRITE so we dont fail out of f_read() and f_write()
			    }
				break;
				
			case FR_NO_PATH: // this means a (or multiple) directory the file was supposed to be in, in the path, did not exist. We'll have to create it
			    fpath = (char *)calloc(strlen(fn) + 1, sizeof(fpath)); // get enough space to make a copy of the entire string so we can chop it up and play with it

				while(1)
				{
    	            for(; i <= strlen(fn); i++) // search the string forwards to find the next directory
       		        {
       		            *(fpath + i) = *(fn + i); //copy the string so far into fpath
       		            
                        if((*(fn + i) == '/') && (i != 2)) // if we have reached 0: and the next char is a / dont stop, otherwise we need to test this current directory 
                        {
                            *(fpath + i + 1) = NULL; // end the string here
                            break;     
                        }
       		        }

					if(i >= strlen(fn)) // if we reached the end of the path, then all directories have been made
					{
					    res = f_open(&fil_obj, fn, FA_CREATE_NEW); // create the file!
					    if(WP)
					    {
					        f_chmod(fn, 0x01, AM_RDO);
					        fil_obj.flag |= FA_READ;
					    }
						else
						{
						    fil_obj.flag |= FA_READ | FA_WRITE;
						}
						break; // leave the loop we are done
					}
					
					res = f_opendir(&dj,fpath); // attempt to open the directory

					if((res == FR_NO_PATH) || (res == FR_NO_FILE)) // if the directory did not exist, create it!
					{
					    res = f_mkdir(fpath);
						if(res != FR_OK) // if we couldnt create the directory something is wrong
							break;
					}
				}
				free(fpath); // free the used space
				break;

			default:
				break;
   	    }
		
    	
    	
   	}
	
	return(res);
}

//! read from file specified by fil obj. 
/*!
  \param dest is a pointer to a buffer, make sure there is enough room in this buffer
  \param offset is the byte offset from the start of the file that you would like to start reading from
  \param NumBytes is the maximum number of bytes you want to read into the buffer
  \return num bytes read
	  
Notes:
the value returned in the in is from the enum FRESULT in ff.h

*/
int FF::read(unsigned char * dest, DWORD offset, DWORD NumBytes)
{
	int res;
	UINT bytes_read;
    res = f_lseek(&fil_obj, offset);  //update the RW pointer and sector/cluster numbers of the file object to match the offset of where we'd like to start reading from
    
    if(res != FR_OK)                            // if we failed to see the file pointer
		return(0);
	
	res = f_read(&fil_obj, (void *)dest, NumBytes, &bytes_read); // read the data!
	
	if(res != FR_OK)
		return(0);

	res = f_lseek(&fil_obj, (offset + bytes_read)); // update the R/W pointer to point just beyond where we last read

	if(res != FR_OK)
		return(0);
	
	return((int)bytes_read);
}

int FF::read(unsigned char * dest, DWORD NumBytes)
{
	int res;
	UINT bytes_read;
    
	res = f_read(&fil_obj, (void *)dest, NumBytes, &bytes_read); // read the data!
	
	if(res != FR_OK)
		return(0);

	res = f_lseek(&fil_obj, (fil_obj.fptr + bytes_read)); // update the R/W pointer to point just beyond where we last read

    if(res != FR_OK)
		return(0);
	
	return((int)bytes_read);
}

//! write into file specified by fil obj
/*!
  \param dest is a pointer to a buffer where the data to write is taken from, make sure it has as much data as you set in to_write
  \param offset is the byte offset from the start of the file you would like to start writting from
  \param NumBytes is the number of bytes you want to write into the file
  \return number of bytes written
	  
Notes:
the value returned in the in is from the enum FRESULT in ff.h

*/
int FF::write(unsigned char * dest, DWORD offset, DWORD NumBytes)
{
    int res;
	UINT bytes_written;
	
	res = f_lseek(&fil_obj, offset);  //update the RW pointer and sector/cluster numbers of the file object to match the offset of where we'd like to start writting from
	
	if(res != FR_OK)                  // if our file pointer seek did not work
		return(0);
	
	res = f_write(&fil_obj, (void *)dest, NumBytes, &bytes_written); // write the data!
	
	if(res != FR_OK)                  // if our write failed. 
		return(0);

	res = f_lseek(&fil_obj, (offset + bytes_written)); // move the RW pointer to just past where we last wrote

	if(res != FR_OK)                  // if our write failed. 
		return(0);
	
	res = f_sync(&fil_obj); // sync the file object to force an update of the directory information for this file (so that file closing is not required, and so that once this write is called
	                                  // and returns, we know the data is commited. 
    if(res != FR_OK)                  // if our write failed. 
		return(0);
									  
	return(bytes_written);
}

int FF::write(unsigned char * dest, DWORD NumBytes)
{
    int res;
	UINT bytes_written;
	
	res = f_write(&fil_obj, (void *)dest, NumBytes, &bytes_written); // write the data!
	
	if(res != FR_OK)                  // if our write failed. 
		return(0);

	res = f_lseek(&fil_obj, (fil_obj.fptr + bytes_written)); // move the RW pointer to just past where we last wrote

	if(res != FR_OK)                  // if our write failed. 
		return(0);
	
	res = f_sync(&fil_obj); // sync the file object to force an update of the directory information for this file (so that file closing is not required, and so that once this write is called
	                                  // and returns, we know the data is commited. 
    if(res != FR_OK)                  // if our write failed. 
		return(0);
									  
	return(bytes_written);
}

//! print string into fil specied by fil obj
/*!
  \param String is a pointer to a string to be written to the file
  	  
Notes:
returns number of bytes written
also does not write the null at the end of the string to the file

*/
int FF::print(unsigned char * String)
{
    int StringLength = strlen((const char*)String);
	int byteswritten;
	DWORD currentFP;

	currentFP = fil_obj.fptr;

	byteswritten = write(String, CursorLoc, StringLength);

	f_lseek(&fil_obj, currentFP); // return the file pointer to its original location
	
	return(byteswritten);
}

//! print string into fil specied by fil obj
/*!
  \param int is an intiger to be printed as ASCII to the file in fil_obj (no leading zeros)
  	  
Notes:
returns number of bytes written
also does not write the null at the end of the string to the file

*/
int FF::print(int num)
{
    char string[12]; // for an int we will only ever need 12 chars (10 for numbers 1 for negative, and 1 for null)
    char string2[12];
	char i = 0;
	char k = 0;
	char base = 10;
	DWORD currentFP;
	int byteswritten;
	
    if (num < 0) 
    {
        string2[0] = '-';
		k++;
        num = -num;
    }
	else if(num == 0)
	{
	    string2[0] = '0';
		k++;
	}

	while (num > 0) 
	{
        string[i++] = num % base;
        num /= base;
	}

	string2[i+k] = NULL; // end the string

    for (; i > 0; i--)
    {
        string2[k++] = '0' + string[i - 1]; // convert to ASCII
    }

	currentFP = fil_obj.fptr;

	byteswritten = write((unsigned char*)&string2, (DWORD)CursorLoc, (DWORD)strlen((const char*)&string));

	f_lseek(&fil_obj, currentFP);

	return(byteswritten);
    
}


int FF::print(unsigned int num)
{
    char string[12]; // for an int we will only ever need 12 chars (10 for numbers 1 for negative, and 1 for null)
    char string2[12];
	char i = 0;
	char k = 0;
	char base = 10;
	DWORD currentFP;
	int byteswritten;
	
    if(num == 0)
	{
	    string2[0] = '0';
		k++;
	}

	while (num > 0) 
	{
        string[i++] = num % base;
        num /= base;
	}

	string2[i+k] = NULL; // end the string

    for (; i > 0; i--)
    {
        string2[k++] = '0' + string[i - 1]; // convert to ASCII
    }

	currentFP = fil_obj.fptr;

	byteswritten = write((unsigned char*)&string2, (DWORD)CursorLoc, (DWORD)strlen((const char*)&string));

	f_lseek(&fil_obj, currentFP);

	return(byteswritten);
    
}

//! print string into fil specied by fil obj (string is in progmem)
/*!
  \param int is an intiger to be printed as ASCII to the file in fil_obj (no leading zeros)
  	  
Notes:
returns number of bytes written
also does not write the null at the end of the string to the file

*/

int FF::print_P(unsigned char * String)
{
    char * fpath;
	int i;
	int byteswritten;
    	
    fpath = (char *)calloc(strlen((const char*)String) + 1, sizeof(fpath)); // get enough space to make a copy of the entire string so we can chop it up and play with it

	for(i = 0; i <= strlen((const char*)String); i++)
	{
	    *(fpath + i) = (char)pgm_read_byte(String + i); // coppy the string from program memory into our temporary memory space
	}

    byteswritten = print((unsigned char*)fpath); // print the string to the file

	free(fpath); // free the space

	return(byteswritten);
}

int FF::print_P(int * num)
{
    int tempnum;

	tempnum = pgm_read_dword(num);

    return(print(tempnum));
}

int FF::print_P(unsigned int * num)
{
    unsigned int tempnum;

	tempnum = pgm_read_dword(num);

    return(print(tempnum));
}

//! print string into fil specied by fil obj and add an EOL to it
/*!
  \param int is an intiger to be printed as ASCII to the file in fil_obj (no leading zeros)
  	  
Notes:
returns number of bytes written
also does not write the null at the end of the string to the file

*/

int FF::println(unsigned char * String)
{
    char * fpath;
	int byteswritten;

	fpath = (char *)calloc(strlen((const char*)String) + 3, sizeof(fpath)); // get enough space to make a copy of the entire string so we can chop it up and play with it

	*(fpath + strlen((const char*)String) + 1) = '\r'; 
	*(fpath + strlen((const char*)String) + 2) = '\n';
	*(fpath + strlen((const char*)String) + 3) = NULL;

	byteswritten = print((unsigned char*) fpath);

	free(fpath);

	return(byteswritten);
}

int FF::println(int num)
{
    char string[12]; // for an int we will only ever need 12 chars (10 for numbers 1 for negative, and 1 for null)
    char string2[12];
	char i = 0;
	char k = 0;
	char base = 10;
	DWORD currentFP;
	int byteswritten;
	
    if (num < 0) 
    {
        string2[0] = '-';
		k++;
        num = -num;
    }
	else if(num == 0)
	{
	    string2[0] = '0';
		k++;
	}

	while (num > 0) 
	{
        string[i++] = num % base;
        num /= base;
	}

	string2[i + k + 2] = NULL; // end the string
	string2[i + k + 1] = '\n';
	string2[i + k] = '\r';

    for (; i > 0; i--)
    {
        string2[k++] = '0' + string[i - 1]; // convert to ASCII
    }

	currentFP = fil_obj.fptr;

	byteswritten = write((unsigned char*)&string2, (DWORD)CursorLoc, (DWORD)strlen((const char*)&string));

	f_lseek(&fil_obj, currentFP);

	return(byteswritten);
}

int FF::println(unsigned int num)
{
    char string[12]; // for an int we will only ever need 12 chars (10 for numbers 1 for negative, and 1 for null)
    char string2[12];
	char i = 0;
	char k = 0;
	char base = 10;
	DWORD currentFP;
	int byteswritten;
	
    if(num == 0)
	{
	    string2[0] = '0';
		k++;
	}

	while (num > 0) 
	{
        string[i++] = num % base;
        num /= base;
	}

	string2[i + k + 2] = NULL; // end the string
	string2[i + k + 1] = '\n';
	string2[i + k] = '\r';

    for (; i > 0; i--)
    {
        string2[k++] = '0' + string[i - 1]; // convert to ASCII
    }

	currentFP = fil_obj.fptr;

	byteswritten = write((unsigned char*)&string2, (DWORD)CursorLoc, (DWORD)strlen((const char*)&string));

	f_lseek(&fil_obj, currentFP);

	return(byteswritten);
}

//! read from the file in fil_obj until \r\n is encountered or we reach the limit
/*!
  \param buff is a pointer to the buffer that will hold the data we are reading
  \param limit is the max number of bytes we will read into the above buffer unless we encounter \r\n first
  	  
Notes:
returns number of bytes read including the \r\n
*/

int FF::readln(unsigned char * buff, DWORD limit)
{
    int bytesread = 0;
	int tempbytes;

	while(bytesread <= limit)
	{
	    tempbytes = read((unsigned char*)(buff + bytesread), 1);
		
		if(tempbytes == 0) // this means we had a problem
			return(0);

		bytesread += tempbytes;

		if(( *(buff + bytesread) == '\n') && ( *(buff + bytesread - 1) == '\r')) // EOL reached
		    return(bytesread);
		
	}

	return(bytesread);
}


//! set the call back function to get the current time
/*!
  \param fpointer is a function pointer to a function that takes no argument and returns an int
	  
Notes:

*/

void SetTimerFunction(unsigned int (*fpointer)(void))
{
    set_time_function_pointer(fpointer);
}

//! set the cursor location
/*!
  \param location is the byte offset from the start of the file where the cursor is
	  
Notes:

*/

int FF::set_cursor(DWORD location)       
{
    CursorLoc = location;
}

//! get the information of a file specified by Path
/*!
  \param fno is a pointer to the file info struct to be filled with the file info
  \param Path is the complete path of the file to grab the info for 
  \return error code, see comments in FF.h for FRESULT enumeration
	  
Notes:
the value returned in the in is from the enum FRESULT in ff.h
*/

int FF::get_file_info(FILINFO * fno, char * Path)
{
	return(f_stat(Path, fno));
}

//! Attach functions for streaming
/*!
  \param pre_block is a pointer to a function, refer to notes for when it is called
  \param pre_byte is a pointer to a function, refer to notes for when it is called
  \param dest is a pointer to a function, it must accept a byte as a parameter, it should return non-zero for streaming to continue, returning 0 will end the stream prematurely
  \param post_byte is a pointer to a function, refer to notes for when it is called
  \param post_block is a pointer to a function, refer to notes for when it is called
	  
Notes:

refer to the code below to understand calling order

pre_block();
do
{
	pre_byte();
	res = dest(SPI_RX());
	post_byte();
}
while (--cnt && res);
post_block();

These functions are meant for users who would like to stream directly from the MISO line to another device
For example, when streaming mp3 data to a VS1002d decoder, pre_byte can be used to wait until there is room in the decoder's buffer
and pre_block and post_block can be used to select and deselect the decoder's SDI bus

If not needed, these functions can be empty functions, but they must be provided.

This function must be called at least once before calling stream_file

*/
//void FF::setup_stream(void (* pre_block)(void), void (* pre_byte)(void), char (* dest)(char), void (* post_byte)(void), void (* post_block)(void))
//{
//	disk_attach_stream_functs(pre_byte, post_byte, pre_block, post_block); // attach functions
//	stream_dest = (void *)dest;
//}

//! Stream last file opened to a function
/*!
  \param to_read is the maximum number of bytes you want to read into the buffer
  \param read_from is a pointer to a integer which will contain the number of bytes actually read
  \return error code, see comments in FF.h for FRESULT enumeration
	  
Notes:

use read_from to determin whether you've reached the end of the file
you must setup the stream first
a file must be opened before

*/
//int FF::stream_file(int to_read, int * read_from)
//{
//	fatfs_obj.flag |= FA_STREAM; // enable streaming
//	int res = f_read(stream_dest, to_read, (WORD *)read_from); // perform read
//	return res; // return error
//}

//! Move file read pointer
/*!
  \param p is the desired pointer location
  \return error code, see comments in FF.h for FRESULT enumeration
  
*/
//int FF::lseek_file(long p)
//{
//	return f_lseek(p);
//}


//! Opens a directory as the current directory
/*!
  \param dn is a folder path string
  \return error code, see comments in FF.h for FRESULT enumeration
  
Notes:

this will rewind directory file index pointer to first file in directory

*/
//int FF::open_dir(char * dn)
//{
//	int res = f_opendir(&dir_obj, dn);
//	if (res == 0) // if successful
//	{
//		strcpy(dir_path, dn); // store path
//	}
//	return res; // return error if any
//}


//! Reopens current directory, which rewinds the file index
/*!
  \return error code, see comments in FF.h for FRESULT enumeration
  
Notes:

this will rewind directory file index pointer to first file in directory

*/
//int FF::rewind_dir()
//{
//	return f_opendir(&dir_obj, dir_path);
//}

//! Opens the parent directory of the current directory, and become the current directory
/*!
  \return error code, see comments in FF.h for FRESULT enumeration
  
Notes:
this will rewind directory file index pointer to first file in directory

*/
//int FF::up_dir()
//{
//	int res;
//	int i;
//	for (i = strlen(dir_path) - 1; i != -1 && dir_path[i] != '/'; i--); // finds last slash
//	if (i >= 1) // if not already in root
//	{
//		char * path = (char *)calloc(i + 1, sizeof(path)); // make string
//		path = (char *)memcpy((void *)path, dir_path, sizeof(path) * (i + 1)); // copy up to slash
//		path[i] = 0; // null terminate
//		res = open_dir(path); // attempt to open
//		free(path); // free string
//	}
//	else
//	{
//		res = open_dir((char *)"/"); // reopen root
//	}
//	return res;
//}

//! Saves the FILINFO of the next file in currently open directory
/*!
  \param fnfo is the pointer to the user's FILINFO struct
  \return error code, see comments in FF.h for FRESULT enumeration

Notes:

FILINFO can be a file, a directory, or nothing
if the file name is empty, it is invalid and indicates that the entire directory has been read and you need to rewind the file index, or that the directory is empty
to check if the file name is empty, check if the first char of the FILINFO's fname is null, for example:

FILINFO fnfo;
int err = FFS.read_dir(&fnfo);
if (fnfo.fname[0] == 0) print("end of directory");

if the FILINFO is a directory, check if the AM_DIR flag in the FILINFO's fattrib is set, for example:

FILINFO fnfo;
int err = FFS.read_dir(&fnfo);
if (fnfo.fattrib & AM_DIR) print("is a directory"); else print("is a file");

*/
//int FF::read_dir(FILINFO * fnfo)
//{
//	return f_readdir(&dir_obj, fnfo);
//}

//! Creates a file using a FILINFO struct, in the directory dir, strogint the information in the static FIL object
//! designated by file_num
/*!
  \param fnfo is the pointer to the user's FILINFO struct
  \param dir is the directory to create the file
  \param file_num is the index into the FIL array to hold the file information after creation in local memory
  \return error code, see comments in FF.h for FRESULT enumeration

Notes:
the value returned in the in is from the enum FRESULT in ff.h

*/
//int FF::create_file(FILINFO * fnfo, char * dir, byte file_num)
//{
//	int res; // stores error code
//	char * fpath; // stores string for file path
//	fpath = (char *)calloc(strlen(fnfo->fname) + strlen(dir) + 1, sizeof(fpath)); // create memory space for file path
//	strcpy(fpath, dir); // copy dir into fpath so the strcat doesn't destroy dir_path
//	if (fpath[strlen(fpath) - 1] != '/')
//	{
//		fpath = strcat(fpath, "/");	 // join path with slash character
//	}
//	fpath = strcat(fpath, fnfo->fname);	 // join path with file name
//	
//	res = f_open(&fil_obj[file_num], fpath, FA_CREATE_NEW); // create the file and store the file info in fil_obj[file_num]
//	
//	free(fpath); // free memory for path since it's no longer needed
//	return(res); // return error code
//}

//! Returns current directory path as a string
/*!
  \return pointer to a string containing the current directory path

*/
//char * FF::cur_dir()
//{
//	return dir_path;
//}

//////////////////////////////////////
// end list of public methods
//////////////////////////////////////

//FF FFS = FF(); // create usuable instance
