#include "include/kmi.h"
#include "include/req.h"
#include "include/uart.h"

void
kmi_key_int_handle()
{
  u8 map[0x50];
  map[0x1e] = 'a';

  volatile u32 *status = (u32 *)_KMISTAT;
  volatile u32 *data = (u32 *)_KMIDATA;
  u8 key = *data & 0xff;
  uart_putc(map[key]);
}

void
kmi_init()
{
  volatile KMIStruct *key = (KMIStruct *)_KMIBASE_KEYBOAD;
  key->KMICR |= (1 << _KmiEn);
  key->KMICR |= (1 << _KMIRXINTREn);
  req_register_int(_PIC_IRQ_KEYBOAD, kmi_key_int_handle);
  return;
}
