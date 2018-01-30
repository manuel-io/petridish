release = 0.6

install:
	mkdir -p "xtensa-lx106-${release}" \
		&& cp Makefile.draft "xtensa-lx106-${release}/Makefile" \
	  && cd "xtensa-lx106-${release}" \
	  && dh_make --createorig \
	  && DEB_BUILD_OPTIONS='nostrip' debuild -i -us -uc -b

clean:
	rm -rf "xtensa-lx106-${release}"
	rm -rf "xtensa-lx106_${release}.orig.tar.xz"
	rm -f *.build *.buildinfo *.changes *.deb
	rm -f SHA256SUMS
