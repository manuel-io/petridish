release = "65.0"
firefox = "firefox-${release}.tar.bz2"

install:
	test -f "${firefox}" || curl -O "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${release}/linux-x86_64/en-US/${firefox}"
	test -f SHA256SUMS \
	  || curl https://download-installer.cdn.mozilla.net/pub/firefox/releases/${release}/SHA256SUMS \
		| grep "linux-x86_64/en-US/${firefox}" \
		| cut -d\  -sf1 \
		| sed -nr "s/(.*)/\1 ${firefox}/p" > SHA256SUMS
	sha256sum -c SHA256SUMS \
	  && mkdir -p "firefox-quantum-${release}" \
		&& cp Makefile.draft "firefox-quantum-${release}/Makefile" \
	  && cd "firefox-quantum-${release}" \
	  && dh_make --createorig \
	  && DEB_BUILD_OPTIONS='nocheck nodoc noopt nostrip' debuild -i -us -uc -b

clean:
	find -name 'firefox-quantum-*' -type d -exec rm -rf {} \;
	find -name 'firefox-quantum_*.orig.tar.xz' -type f -exec rm -f {} \;
	rm -f *.build *.buildinfo *.changes *.deb
	rm -f SHA256SUMS
