#ifndef OT_STACK_H
	#define OT_STACK_H
	#include "OT_Encoder.h"
	#include "OT_HWProfile.h"
	#include "OT_Outputs.h"
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