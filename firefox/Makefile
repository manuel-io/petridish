install:
	test -f firefox-57.0.tar.bz2 || curl -O https://download-installer.cdn.mozilla.net/pub/firefox/releases/57.0/linux-x86_64/de/firefox-57.0.tar.bz2
	cd firefox-quantum-57.0 \
	&& dh_make --createorig \
	&& debuild -i -us -uc -b

clean:
	rm -rf firefox-quantum-57.0/debian/
	rm -f firefox-quantum_57.0.orig.tar.xz
	rm -f *.build *.buildinfo *.changes *.deb
