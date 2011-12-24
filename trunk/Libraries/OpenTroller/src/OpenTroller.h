#ifndef OPENTROLLER_H
#define OPENTROLLER_H

#import <wiring.h>

/**
  * An enum used to describe the state of a pin.
  * Uses #defines from wiring.h
  */
typedef enum {
    State_LOW = LOW, /*!< The state is LOW */
    State_HIGH = HIGH /*!< The state is HIGH */
} State;


#endif // OPENTROLLER_H
