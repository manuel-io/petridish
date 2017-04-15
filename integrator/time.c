#include "include/time.h"
#include "include/req.h"
#include "include/uart.h"

void
time_timer1_int()
{
  *((u32 *)_Timer1IntClr) = 0;
  uart_puts("TIME1: 1s\n");
}

void
time_timer2_int()
{
  *((u32 *)_Timer2IntClr) = 0;
  uart_puts("TIME2: 1m\n");
}

void
time_init()
{
  /* TIME1: 1MHz, Int: 1s, Size: 32bit, Mode: periodic
   * TIME2: 1MHz, Int: 1m, Size: 32bit, Mode: periodic 
   */

  volatile u32 *time1 = (u32 *)_Timer1Control;
  volatile u32 *load1 = (u32 *)_Timer1Load;
  *load1 = 1000000;
  req_register_int(_PIC_IRQ_TIME1, time_timer1_int);
  *time1 |= _ENABLE | _IE | _MODE | _TimerSize;

  volatile u32 *time2 = (u32 *)_Timer2Control;
  volatile u32 *load2 = (u32 *)_Timer2Load;
  *load2 = 1000000 * 60;
  req_register_int(_PIC_IRQ_TIME2, time_timer2_int);
  *time2 |= _ENABLE | _IE | _MODE | _TimerSize;
}
