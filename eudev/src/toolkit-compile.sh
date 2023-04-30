#!/usr/bin/env bash

git clone -c http.sslVerify=false --single-branch https://github.com/kmod-project/kmod.git /tmp/kmod
cd /tmp/kmod
git checkout v30
patch -p1 < /source/input/kmod.patch
./autogen.sh
./configure CFLAGS='-O2' --prefix=/usr --sysconfdir=/etc --libdir=/usr/lib --enable-tools --disable-manpages --disable-python --without-zstd --without-xz --without-zlib --without-openssl
make all
make install
make DESTDIR=/source/output install
git clone -c http.sslVerify=false --single-branch https://github.com/eudev-project/eudev.git /tmp/eudev
cd /tmp/eudev
git checkout v3.2.11
./autogen.sh
./configure --prefix=/usr --sysconfdir=/etc --disable-manpages --disable-selinux --disable-mtd_probe --enable-kmod
make -i all
make -i DESTDIR=/source/output install
rm -Rf /source/output/usr/share /source/output/usr/include /source/output/usr/lib/pkgconfig /source/output/usr/lib/libudev.*
rm /source/output/usr/lib/udev/rules.d/80-net-name-slot.rules
ln -sf /usr/bin/kmod /source/output/usr/sbin/depmod
chown 1000.1000 -R /source/output