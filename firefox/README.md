    curl -O https://download-installer.cdn.mozilla.net/pub/firefox/releases/57.0/linux-x86_64/de/firefox-57.0.tar.bz2
    cd firefox-quantum-57.0
    dh_make --createorig
    debuild -i -us -uc -b
