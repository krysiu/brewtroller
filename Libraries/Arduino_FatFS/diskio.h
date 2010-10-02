/*-----------------------------------------------------------------------
/  Low level disk interface modlue include file  R0.05   (C)ChaN, 2007
/-----------------------------------------------------------------------*/

#ifndef _DISKIO

#define _READONLY	0	/* 1: Read-only mode */
#define _USE_IOCTL	1

#include "integer.h"

#define PA 0
#define PB 1
#define PC 2
#define PD 3

//Following defintions copied from CodeRage's FastPin Library (pin.h)
//Define the Digital pin arrangements and masks for each port on the Arduino or Sanguino
#if defined(__AVR_ATmega644P__) || defined(__AVR_ATmega644__) || defined(__AVR_ATmega1284P__) || defined(__AVR_ATmega1284__)
//If on the Sanguino platform
//maximum number of digital IO pins available
#define _P_MAX		31

#define _PA_FIRST   24
#define _PA_LAST	31
#define _PA_MASK(n) (0x80 >> ((n) & 0x07))
#define _PA(n)		((n) > (_PA_FIRST-1)) && ((n) < (_PA_FIRST + 8))

#define _PB_FIRST   0
#define _PB_LAST	7
#define _PB_MASK(n) (0x01 << ((n) & 0x07))
#define _PB(n)		((n) > (_PB_FIRST-1)) && ((n) < (_PB_FIRST + 8))

#define _PC_FIRST   16
#define _PC_LAST	23
#define _PC_MASK(n) (0x01 << ((n) & 0x07))
#define _PC(n)		((n) > (_PC_FIRST-1)) && ((n) < (_PC_FIRST + 8))

#define _PD_FIRST   8
#define _PD_LAST	15
#define _PD_MASK(n) (0x01 << ((n) & 0x07))
#define _PD(n)		((n) > (_PD_FIRST-1)) && ((n) < (_PD_FIRST + 8))


#else
//else if the Arduino platform
#define _P_MAX		15

#define _PA_FIRST   0
#define _PA_LAST	0
#define _PA_MASK(n) 0
#define _PA(n)		0

#define _PB_FIRST   8
#define _PB_LAST	15
#define _PB_MASK(n) (0x01 << ((n) & 0x07))
#define _PB(n)		(((n) > (_PB_FIRST-1)) && ((n) < (_PB_FIRST+8))

#define _PC_FIRST   0
#define _PC_LAST	0
#define _PC_MASK(n) 0
#define _PC(n)		0

#define _PD_FIRST   0
#define _PD_LAST	7
#define _PD_MASK(n) (0x01 << ((n) & 0x07))
#define _PD(n)		(((n) > (_PD_FIRST-1)) && ((n) < (_PD_LAST+8))
#endif


/* Status of Disk Functions */
typedef BYTE2	DSTATUS;

/* Results of Disk Functions */
typedef enum {
	RES_OK = 0,		/* 0: Successful */
	RES_ERROR,		/* 1: R/W Error */
	RES_WRPRT,		/* 2: Write Protected */
	RES_NOTRDY,		/* 3: Not Ready */
	RES_PARERR		/* 4: Invalid Parameter */
} DRESULT;


/*---------------------------------------*/
/* Prototypes for disk control functions */

DSTATUS disk_initialize (BYTE2);
DSTATUS disk_status (BYTE2);
DRESULT disk_read (BYTE2, BYTE2*, DWORD, BYTE2);
#if	_READONLY == 0
DRESULT disk_write (BYTE2, const BYTE2*, DWORD, BYTE2);
#endif
DRESULT disk_ioctl (BYTE2, BYTE2, void*);
void	disk_timerproc (void);
void    pinsetup(BYTE2, BYTE2);





/* Disk Status Bits (DSTATUS) */

#define STA_NOINIT		0x01	/* Drive not initialized */
#define STA_NODISK		0x02	/* No medium in the drive */
#define STA_PROTECT		0x04	/* Write protected */



/* Command code for disk_ioctrl() */

/* Generic command */
#define CTRL_SYNC			0	/* Mandatory for write functions */
#define GET_SECTOR_COUNT	1	/* Mandatory for only f_mkfs() */
#define GET_SECTOR_SIZE		2
#define GET_BLOCK_SIZE		3	/* Mandatory for only f_mkfs() */
#define CTRL_POWER			4
#define CTRL_LOCK			5
#define CTRL_EJECT			6
/* MMC/SDC command */
#define MMC_GET_TYPE		10
#define MMC_GET_CSD			11
#define MMC_GET_CID			12
#define MMC_GET_OCR			13
#define MMC_GET_SDSTAT		14
/* ATA/CF command */
#define ATA_GET_REV			20
#define ATA_GET_MODEL		21
#define ATA_GET_SN			22



/* Card type flags (CardType) */
#define CT_MMC				0x01	/* MMC ver 3 */
#define CT_SD1				0x02	/* SD ver 1 */
#define CT_SD2				0x04	/* SD ver 2 */
#define CT_SDC				(CT_SD1|CT_SD2)	/* SD */
#define CT_BLOCK			0x08	/* Block addressing */


#define _DISKIO
#endif
