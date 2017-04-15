#include "types.h"

#ifndef MAIN
#define MAIN

/* ARM926EJ-S 
 * Technical Reference Manual
 */

/* 2.8. The program status registers */
#define _CPSR_MODE 0x1f
#define _CPSR_THUMB (1 << 5)
#define _CPSR_FIQ (1 << 6)
#define _CPSR_IRQ (1 << 7)
#define _CPSR_ABORT (1 << 8)
#define _CPSR_END (1 << 9)
#define _CPSR_GE (0xf << 16)
#define _CPSR_J (1 << 24)
#define _CPSR_Q (1 << 27)
#define _CPSR_V (1 << 28)
#define _CPSR_C (1 << 29)
#define _CPSR_Z (1 << 30)
#define _CPSR_N (1 << 31)

/* 2.8.4. The control bits */
#define _CPSR_MODE_USER 0x10
#define _CPSR_MODE_FIQ 0x11
#define _CPSR_MODE_IRQ 0x12
#define _CPSR_MODE_SUPER 0x13
#define _CPSR_MODE_ABORT 0x17
#define _CPSR_MODE_UND 0x1b
#define _CPSR_MODE_SYS 0x1f

void mode(void);
void main(void);
u32 cpsr(void);
u32 spsr(void);
s32 syscall(u32); 
void cli(void);
void sti(void);
#endif /* MAIN */
