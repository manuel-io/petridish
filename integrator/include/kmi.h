#include "types.h"

#ifndef KMI
#define KMI

/* ARM PrimeCell PS2
 * Keyboard/Mouse Interface (PL050)
 */

#define _KMIBASE_KEYBOAD 0x18000000
#define _KMIBASE_MOUSE 0x19000000

/* 3.2 Summary of PrimeCell KMI registers */
#define _KMIBASE _KMIBASE_KEYBOAD
#define _KMICR (_KMIBASE + 0x00)
#define _KMISTAT (_KMIBASE + 0x04)
#define _KMIDATA (_KMIBASE + 0x08)
#define _KMIIR (_KMIBASE + 0x10)

#define _KmiEn 2
#define _KMIRXINTREn 4
#define _KMITYPE 5

typedef struct __attribute__((packed)) {
  volatile u32 KMICR;
  volatile u32 KMISTAT;
  volatile u32 KMIDATA;
  volatile u32 KMIIR;
} KMIStruct;

void kmi_init(void);
#endif /* KMI */
