#!/usr/bin/make
PKG=lattuino_1
VERSION=1.0.4

all: $(PKG)-$(VERSION).tar.bz2

$(PKG)-$(VERSION).tar.bz2:
	mkdir $(VERSION)
	cp boards.txt platform.txt $(VERSION)
	cp -r cores/ variants/ $(VERSION)
	rm -rf $(VERSION)/cores/CVS $(VERSION)/cores/*/CVS
	rm -rf $(VERSION)/variants/CVS $(VERSION)/variants/*/CVS
	mkdir $(VERSION)/libraries
	cp -r libraries/SPI libraries/SoftwareSerial $(VERSION)/libraries
	rm -rf $(VERSION)/libraries/*/CVS $(VERSION)/libraries/*/*/CVS
	tar jcvf $@ $(VERSION)
	ls -la $@
	sha256sum $@
	rm -r $(VERSION)

