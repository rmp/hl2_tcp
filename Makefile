#
# hl2_tcp makefile
#

OS    := $(shell uname -s)
ARCH  := $(shell dpkg --print-architecture)
MAJOR ?= $(shell date +%Y)
MINOR ?= $(shell date +%m)
SUB   ?= $(shell date +%d)
PATCH ?= 0

ifeq ($(OS), Darwin)
	CC  = clang
	LL  = -lm -lpthread
else
ifeq ($(OS), Linux)
	CC  = cc
	LL = -lm -lpthread
	STD = -std=c99
else
	$(error OS not detected)
endif
endif

FLAGS = -Os
# FLAGS = -g

FILES_2  =  hl2_tcp.c hl2_tx.c

all:	hl2_tcp 

hl2_tcp:	$(FILES_2)
	$(CC) $(FILES_2) $(LL) -lpthread -Os -o hl2_tcp

clean:
	rm -f hl2_tcp 

#

deb: deb_$(OS)
deb_Linux: all
	rm -rf tmp
	mkdir --p tmp/usr/bin
	cp -p hl2_tcp tmp/usr/bin
	cp -pR DEBIAN tmp/
	sed -i "s/MAJOR/$(MAJOR)/g"       tmp/DEBIAN/control
	sed -i "s/MINOR/$(MINOR)/g"       tmp/DEBIAN/control
	sed -i "s/PATCH/$(PATCH)/g"       tmp/DEBIAN/control
	sed -i "s/SUB/$(SUB)/g"           tmp/DEBIAN/control
	sed -i "s/CODENAME/$(CODENAME)/g" tmp/DEBIAN/control
	sed -i "s/ARCH/$(ARCH)/g"         tmp/DEBIAN/control

	dpkg-deb -b tmp hl2tcp-$(MAJOR).$(MINOR).$(SUB)-$(PATCH)~$$(lsb_release -cs)_$(ARCH).deb

deb_Darwin: docker
	docker run --platform linux/amd64 -it --rm -v $$(pwd):$$(pwd) -w $$(pwd) hl2_tcp:amd64 make deb
	docker run --platform linux/arm64 -it --rm -v $$(pwd):$$(pwd) -w $$(pwd) hl2_tcp:arm64 make deb

docker:
	docker build --platform linux/amd64 -t hl2_tcp:amd64 .
	docker build --platform linux/arm64 -t hl2_tcp:arm64 .

.PHONY: docker
