DESTDIR=$(CURDIR)/debian/firefox-quantum

install:
	mkdir -p $(DESTDIR)/opt/
	mkdir -p $(DESTDIR)/usr/share/applications/
	tar -C $(DESTDIR)/opt -xvf ../firefox-57.0.tar.bz2
	install -m 0644 ../firefox-quantum.desktop $(DESTDIR)/usr/share/applications/
