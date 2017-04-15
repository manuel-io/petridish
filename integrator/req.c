#include "include/req.h"
#include "include/uart.h"

static void (*libs[32])(void);
static volatile IRQ_CTRL *p;

void
c_swi_handler(u32 type)
{ 
  mode();
  return;
}

void
c_int_handler()
{
  u32 s = p->PIC_IRQ_STATUS;
  while(s) {

    if(s & (1 << _PIC_IRQ_KEYBOAD)) { 
      libs[_PIC_IRQ_KEYBOAD]();
      s &= ~(1 << _PIC_IRQ_KEYBOAD);
    }

    if(s & (1 << _PIC_IRQ_TIME1)) { 
      libs[_PIC_IRQ_TIME1]();
      s &= ~(1 << _PIC_IRQ_TIME1);
    }

    if(s & (1 << _PIC_IRQ_TIME2)) { 
      libs[_PIC_IRQ_TIME2]();
      s &= ~(1 << _PIC_IRQ_TIME2);
    }
  }
  return;
}

s32
req_register_int(u32 i, void (*function)(void))
{
  if(i > 32) return -1;
  libs[i] = function;
  return 0;
}

void
req_init()
{
  p = (IRQ_CTRL *)_PIC_IRQ_BASE;
  p->PIC_IRQ_ENABLECLR = 0xffffffff;
  p->PIC_IRQ_ENABLESET = 0xffffffff;
  return;
}
