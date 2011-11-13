/*
 * Timer.h
 *
 *  Created on: Nov 12, 2011
 *      Author: treaves
 */

#ifndef TIMER_H_
#define TIMER_H_

void clearTimer(byte timer);
void pauseTimer(byte timer);
void setAlarm(boolean alarmON);
void setTimer(byte timer, int minutes);
void updateBuzzer();
void updateTimers();

#endif /* TIMER_H_ */
