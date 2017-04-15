#include "types.h"
#include "main.h"

#ifndef VGA
#define VGA

/* PrimeCell
 * Color LCD Controller 
 * Technical Reference Manual
 */

#define _LCDBASE 0xC0000000
#define _LCDTiming0 _LCDBASE
#define _LCDTiming1 0xC0000004
#define _LCDTiming2 0xC0000008
#define _LCDTiming3 0xC000000C
#define _LCDUPBASE 0xC0000010
#define _LCDLPBASE 0xC0000014
#define _LCDINTRENABLE 0xC0000018
#define _LCDControl 0xC000001C
#define _LCDStatus 0xC0000020
#define _LCDInterrupt 0xC0000024
#define _LCDUPCURR 0xC0000028
#define _LCDLPCURR 0xC000002C
#define _LCDPalette 0xC0000200

#define _STD_LCDControl 0x1829

/* 3.2.7 Control Register, LCDControl */

#define _LcdEn (1 << 0)
#define _LcdBpp (3 << 1)

#define _LcdBpp1 (0 << 1)
#define _LcdBpp2 (1 << 1)
#define _LcdBpp4 (2 << 1)
#define _LcdBpp8 (3 << 1)
#define _LcdBpp16 (4 << 1)
#define _LcdBpp24 (5 << 1)

#define _BGR (1 << 8)

typedef struct __attribute__((packed)) {
  volatile u32 LCDTiming0;
  volatile u32 LCDTiming1;
  volatile u32 LCDTiming2;
  volatile u32 LCDTiming3;
  volatile u32 LCDUPBASE;
  volatile u32 LCDLPBASE;
  volatile u32 LCDINTRENABLE;
  volatile u32 LCDControl;
} ColorLCD;

void vga_init(void);
#endif /* VGA */
