#include "include/time.h"
#include "include/vga.h"
#include "include/kmi.h"
#include "include/req.h"
#include "include/uart.h"
#include "include/main.h"

void
mode()
{
  switch(cpsr() & _CPSR_MODE) {
    case _CPSR_MODE_USER:
      uart_puts("Mode: User, ");
      break;
    case _CPSR_MODE_FIQ:
      uart_puts("Mode: FIQ, ");
      break;
    case _CPSR_MODE_IRQ:
      uart_puts("Mode: IRQ, ");
      break;
    case _CPSR_MODE_SUPER:
      uart_puts("Mode: Super, ");
      break;
    case _CPSR_MODE_ABORT:
      uart_puts("Mode: Abort, ");
      break;
    case _CPSR_MODE_UND:
      uart_puts("Mode: Undef, ");
      break;
    case _CPSR_MODE_SYS:
      uart_puts("Mode: Sys, ");
      break;
    default:
      uart_puts("Mode: Unknown\n");
  }
 
  uart_puts("IRQ: ");
  if(cpsr() & _CPSR_IRQ) uart_puts("disable, ");
  else uart_puts("enable, ");

  uart_putc('\n');
}

void
main()
{
  char *hello = "Hello ";
  char *world = (char *)0x4000000;
  mode();
  req_init();
  time_init();
  vga_init();
  kmi_init();
  uart_puts(hello);
  uart_puts(world);
  sti();
  syscall(65);
  mode();
  return;
}
