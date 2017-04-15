NAME := vorbis2alsa
VERSION := 0.1.0
CC := gcc -c
LD := gcc
DESTDIR := /usr
CFLAGS := -Wall -std=gnu99 -I/usr/include/opus -DV2A_NAME=$(NAME) -DV2A_VERSION=$(VERSION)
LDFLAGS := -lvorbisfile -lopusfile -lmad -lasound -lpulse-simple

.PHONY: clean install uninstall

all: $(NAME)

$(NAME): main.o pulse.o alsa.o vorbis.o opus.o mad.o
	$(LD) -o $@ $+ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) $<

install:
	install -m 0755 $(NAME) $(DESTDIR)/bin/

uninstall:
	rm -f $(DESTDIR)/bin/$(NAME)

clean:
	rm -f *.o *.so
	rm -f $(NAME)
