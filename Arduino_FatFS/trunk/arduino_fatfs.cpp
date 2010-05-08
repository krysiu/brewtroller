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

}

#include "arduino_fatfs.h"

// ******************** note all paths must start with 0 for volume 0 (only volume supported) and use / slahes instead of \ for folder seperations 
// I.E. 0:/logs/log10.txt
// names must also be in 8.3 format LFN and unicode not supported, all files opened must have the complete path in the name passed in, there is no "current directory" open. 

FATFS FF::fatfs_obj; // stores working copy of FS
FIL   FF::fil_obj[3]; // once a file has been opened, this will store the information for that file, so you can read/write 
                      // the file without having to re-open it each time. 
//char * FF::dir_path; // stores last accessed directory path
//int FF::MMC_CS; // stores pin number for MMC card's CS pin
//void * FF::stream_dest; // function pointer for stream destination function
const char FF::log_file_dir[8] = {'0',':','/','l','o','g','s','/',NULL};
const char FF::web_page_dir[8] = {'0',':','/','h','t','m','l','/',NULL};

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
int FF::begin(int cs_pin)
{
    int res;
	DIR dj;
	
	pinMode(cs_pin, OUTPUT); // set CS pin to output	
	set_MMC_CS(cs_pin); // set the global for the CS pin in the mmc module

	f_mount(0, &fatfs_obj);
	res = f_opendir(&dj, &web_page_dir); // this will initialize the SD card as well as attempt to open this directory. 
	
	if( res != FR_OK) // if the open did not work, note that ALL SD cards come pre-formatted and thus if there isnt a file system already on the SD card, there isnt much we can do, it's a gonner. 
	{
		if(res == FR_NO_PATH)
			f_mkdir(&web_page_dir);
		else
			return(res);

	}

	res = f_opendir(&dj, &log_file_dir);

	if(res != FR_OK)
	{
		if(res == FR_NO_PATH)
			f_mkdir(&log_file_dir);
		else
			return(res);
	}

	return(); 
}

//! Grab a string that has the expected html directory
const char * FF::get_html_dir(void)
{
	const char * p = &web_page_dir;
	return(p);
}

//! Grab a string that has the expected log directory
const char * FF::get_logs_dir(void)
{
	const char * p = &log_file_dir;
	return(p);
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
int FF::open_file(char * fn, byte file_num)
{
	return(f_open(&fil_obj[file_num], fn, FA_OPEN_EXISTING));
}

//! read file specified by file num
/*!
  \param dest is a pointer to a buffer, make sure there is enough room in this buffer
  \param offset is the byte offset from the start of the file that you would like to start reading from
  \param to_read is the maximum number of bytes you want to read into the buffer
  \param bytes_read is a pointer to a integer which will contain the number of bytes actually read
  \return error code, see comments in FF.h for FRESULT enumeration
	  
Notes:
the value returned in the in is from the enum FRESULT in ff.h

*/
int FF::read_file(char * dest, DWORD offset, UINT to_read, UINT * bytes_read, byte file_num)
{
	int res;
    res = f_lseek(&fil_obj[file_num], offset);  //update the RW pointer and sector/cluster numbers of the file object to match the offset of where we'd like to start reading from
    if(res != FR_OK)                            // if we failed to see the file pointer
		return(res);
	return(f_read(&fil_obj[file_num], (void *)dest, to_read, bytes_read));	// read the data!
}


//! write file specified by file num
/*!
  \param dest is a pointer to a buffer where the data to write is taken from, make sure it has as much data as you set in to_write
  \param offset is the byte offset from the start of the file you would like to start writting from
  \param to_write is the number of bytes you want to write into the file
  \param bytes_written is a pointer to a integer which will contain the number of bytes actually written
  \return error code, see comments in FF.h for FRESULT enumeration
	  
Notes:
the value returned in the in is from the enum FRESULT in ff.h

*/
int FF::write_file(char * dest, DWORD offset, UINT to_write, UINT * bytes_written, byte file_num)
{
    int res;
	res = f_lseek(&fil_obj[file_num], offset);  //update the RW pointer and sector/cluster numbers of the file object to match the offset of where we'd like to start writting from
	if(res != FR_OK)                  // if our file pointer seek did not work
		return(res);
	res = f_write(&fil_obj[file_num], (void *)dest, to_write, bytes_written); // write the data!
	if(res != FR_OK)                  // if our write failed. 
		return(res);
	res = f_sync(&fil_obj[file_num]); // sync the file object to force an update of the directory information for this file (so that file closing is not required, and so that once this write is called
	                                  // and returns, we know the data is commited. 
	return(res);
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
int FF::create_file(FILINFO * fnfo, char * dir, byte file_num)
{
	int res; // stores error code
	char * fpath; // stores string for file path
	fpath = (char *)calloc(strlen(fnfo->fname) + strlen(dir) + 1, sizeof(fpath)); // create memory space for file path
	strcpy(fpath, dir); // copy dir into fpath so the strcat doesn't destroy dir_path
	if (fpath[strlen(fpath) - 1] != '/')
	{
		fpath = strcat(fpath, "/");	 // join path with slash character
	}
	fpath = strcat(fpath, fnfo->fname);	 // join path with file name
	
	res = f_open(&fil_obj[file_num], fpath, FA_CREATE_NEW); // create the file and store the file info in fil_obj[file_num]
	
	free(fpath); // free memory for path since it's no longer needed
	return(res); // return error code
}

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

FF FFS = FF(); // create usuable instance