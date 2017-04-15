#include "types.h"
#ifndef TIME
#define TIME

#define _Timer0Load 0x13000000
#define _Timer0Value
#define _Timer0Control
#define _Timer0IntClr
#define _Timer0RIS
#define _Timer0MIS 0x13000014
#define _Timer0BGLoad 0x13000018

#define _Timer1Load 0x13000100
#define _Timer1Value 0x13000104
#define _Timer1Control 0x13000108
#define _Timer1IntClr 0x1300010C
#define _Timer1RIS 0x13000110
#define _Timer1MIS 0x13000114
#define _Timer1BGLoad 0x13000118

#define _Timer2Load 0x13000200
#define _Timer2Value 0x13000204
#define _Timer2Control 0x13000208
#define _Timer2IntClr 0x1300020C
#define _Timer2RIS 0x13000210
#define _Timer2MIS 0x13000214
#define _Timer2BGLoad 0x13000218

#define _OneShot (1<<0)
#define _TimerSize (1<<1)
#define _PRESCALE (1<<2) | (1<<3)
#define _R (1<<4)
#define _IE (1<<5)
#define _MODE (1<<6)
#define _ENABLE (1<<7)

void time_init(void);
#endif /* TIME */
