#include "include/uart.h"

void
uart_putc(const s8 hw)
{
  volatile s8 *data = (s8 *)_UARTDR;
  volatile u32 *status = (u32 *)_UARTFR;

  while (*status & TXFF);
  *data = hw;
  return;
}

void
uart_puts(const s8 *hw)
{
  volatile s8 *data = (s8 *)_UARTDR;
  volatile u32 *status = (u32 *)_UARTFR;

  while (*hw != '\0') {
    while (*status & TXFF);
    *data = *(hw++);
  }
  return;
}
