#ifndef OT_STATUS_H
	#define OT_STATUS_H

	#include "OT_Stack.h"
	#include "OT_HWProfile.h"


	namespace OpenTroller {
		class statusLED
		{
			private:
			uint8_t _status;
			uint32_t _hbStart;
			uint16_t _interval;
			uint8_t _blinks;
			pin _hbPin;
			
			public:
			void init();
			void update();
			void setStatus(uint8_t);
			uint8_t getStatus();
		};
		extern OpenTroller::statusLED StatusLED;
	}
	
#endif