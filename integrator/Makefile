NAME := kernel
RAMDISK := RAMDISK
TEXT := 0x10000
CROSS_COMPILE := arm-none-eabi-
AS := $(CROSS_COMPILE)as
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)ld

ASFLAGS := -c --defsym TEXT=$(TEXT)
CFLAGS  := -c -std=c99 -nostdlib -mcpu=arm926ej-s -DTEXT=$(TEXT)
LDFLAGS := -estart -Ttext $(TEXT)

QFLAGS := -machine integratorcp -kernel $(NAME) \
  -initrd $(RAMDISK) -serial stdio

.PHONY: check clean

$(NAME): _start.o main.o vga.o kmi.o uart.o req.o time.o
	$(LD) $(LDFLAGS) -o $@.elf $+
	$(CROSS_COMPILE)objcopy -O binary $@.elf $@

%.o: %.c
	$(CC) $(CFLAGS) -o $@ $<

_%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

deploy: $(NAME)
	qemu-system-arm $(QFLAGS)

check:
	sh spec/env.sh $(CROSS_COMPILE)

clean:
	rm -f *.o *.elf
	rm -f $(NAME)

