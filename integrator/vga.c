#include "include/vga.h"

void
vga_init()
{
  volatile ColorLCD *pc = (ColorLCD *)_LCDBASE;
  pc->LCDTiming0 = 0x3f1f3f9c;
  pc->LCDTiming1 = 0x080b61df;
  pc->LCDUPBASE = 0x200000;
  pc->LCDControl = _STD_LCDControl | _LcdBpp24 | _BGR;

  u32 i = 0;
  volatile u32 *fb = (u32 *)0x200000;

  for (; i < (640 * 480); i++) {
    fb[i] = 0x99cc33;
  }
}
