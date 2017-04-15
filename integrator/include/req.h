#include "types.h"
#include "main.h"

#ifndef INTERRUPT
#define INTERRUPT

/* Integrator/CP
 * UserGuide
 */

#define _PIC_IRQ_KEYBOAD 3
#define _PIC_IRQ_TIME1 6
#define _PIC_IRQ_TIME2 7

/* 3.6.1 Primary interrupt controller */
#define _PIC_IRQ_BASE 0x14000000
#define _PIC_IRQ_STATUS _PIC_IRQ_BASE
#define _PIC_IRQ_RAWSTAT 0x14000004
#define _PIC_IRQ_ENABLESET 0x14000008
#define _PIC_IRQ_ENABLECLR 0x1400000C
#define _PIC_INT_SOFTSET 0x14000010
#define _PIC_INT_SOFTCLR 0x14000014

#define _PIC_FIQ_STATUS 0x14000020
#define _PIC_FIQ_RAWSTAT 0x14000024
#define _PIC_FIQ_ENABLESET 0x14000028
#define _PIC_FIQ_ENABLECLR 0x1400002C

/* 3.6.2 Secondary interrupt controller */
#define _SIC_INT_BASE 0xCA000000
#define _SIC_INT_STATUS _SIC_INT_BASE
#define _SIC_INT_RAWSTAT 0xCA000004
#define _SIC_INT_ENABLESET 0xCA000008
#define _SIC_INT_ENABLECLR 0xCA00000C
#define _SIC_INT_SOFTSET 0xCA000010
#define _SIC_INT_SOFTCLR 0xCA000014

typedef struct __attribute__((packed)) {
  volatile u32 PIC_IRQ_STATUS;
  volatile u32 PIC_IRQ_RAWSTAT;
  volatile u32 PIC_IRQ_ENABLESET;
  volatile u32 PIC_IRQ_ENABLECLR;
  volatile u32 PIC_INT_SOFTSET;
  volatile u32 PIC_INT_SOFTCLR;
} IRQ_CTRL;

s32 req_register_int(u32 i, void (*)(void));
void req_init(void);
#endif /* INTERRUPT */
