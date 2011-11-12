#ifndef OT_HWPROFILE_H
	#define OT_HWPROFILE_H
	#include "OT_Encoder.h"
	#include "OT_HWProfile.h"
	#include "OT_OutputBank.h"
	#include "OT_LCD.h"
	#include "OT_Status.h"
	
	namespace OpenTroller {
		class stack
		{
			public:
			void init();
			void update();
			
		};
		extern OpenTroller::stack Stack;
	}
#endif