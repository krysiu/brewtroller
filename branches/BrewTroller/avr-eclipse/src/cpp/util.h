/*
 * util.h
 *
 *  Created on: Nov 12, 2011
 *      Author: treaves
 */

#ifndef UTIL_H_
#define UTIL_H_

void strLPad(char retString[], byte len, char pad);
void vftoa(unsigned long val, char retStr[], unsigned int divisor, boolean decimal);
void truncFloat(char retStr[], byte len);
unsigned long pow10(byte power);

#endif /* UTIL_H_ */
