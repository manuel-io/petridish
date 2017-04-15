#include "types.h"

#ifndef UART
#define UART

#define _UARTBASE 0x16000000
#define _UARTDR _UARTBASE
#define _UARTRSR 0x16000004
#define _UARTFR 0x16000018

#define TXFF (1 << 5)

void uart_puts(const s8 *);
void uart_putc(const s8);
#endif /* UART */
