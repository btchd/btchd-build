IMAGENAME=btchd.org/btchd-build
IMAGEVERSION?=0.0.1-bionic

BASEDIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

all: build

images: image_x86_64-w64-mingw32 image_i686-w64-mingw32 image_x86_64-apple-darwin14 image_x86_64-linux-gnu image_i686-linux-gnu image_arm-linux-gnueabihf image_aarch64-linux-gnu image_riscv64-linux-gnu

build: build_x86_64-w64-mingw32 build_i686-w64-mingw32 build_x86_64-apple-darwin14 build_x86_64-linux-gnu build_i686-linux-gnu build_arm-linux-gnueabihf build_aarch64-linux-gnu build_riscv64-linux-gnu

image_x86_64-w64-mingw32:
	cd $(BASEDIR)/images && docker build -f Dockerfile.x86_64-w64-mingw32 -t $(IMAGENAME):$(IMAGEVERSION)-x86_64-w64-mingw32 .

build_x86_64-w64-mingw32: image_x86_64-w64-mingw32
	HOSTS=x86_64-w64-mingw32 $(BASEDIR)/build.sh

image_i686-w64-mingw32:
	cd $(BASEDIR)/images && docker build -f Dockerfile.i686-w64-mingw32 -t $(IMAGENAME):$(IMAGEVERSION)-i686-w64-mingw32 .

build_i686-w64-mingw32: image_i686-w64-mingw32
	HOSTS=i686-w64-mingw32 $(BASEDIR)/build.sh

image_x86_64-apple-darwin14:
	cd $(BASEDIR)/images && docker build -f Dockerfile.x86_64-apple-darwin14 -t $(IMAGENAME):$(IMAGEVERSION)-x86_64-apple-darwin14 .

build_x86_64-apple-darwin14: image_x86_64-apple-darwin14
	HOSTS=x86_64-apple-darwin14 $(BASEDIR)/build.sh

image_x86_64-linux-gnu:
	cd $(BASEDIR)/images && docker build -f Dockerfile.x86_64-linux-gnu -t $(IMAGENAME):$(IMAGEVERSION)-x86_64-linux-gnu .

build_x86_64-linux-gnu: image_x86_64-linux-gnu
	HOSTS=x86_64-linux-gnu $(BASEDIR)/build.sh

image_i686-linux-gnu:
	cd $(BASEDIR)/images && docker build -f Dockerfile.i686-linux-gnu -t $(IMAGENAME):$(IMAGEVERSION)-i686-linux-gnu .

build_i686-linux-gnu: image_i686-linux-gnu
	HOSTS=i686-linux-gnu $(BASEDIR)/build.sh

image_arm-linux-gnueabihf:
	cd $(BASEDIR)/images && docker build -f Dockerfile.arm-linux-gnueabihf -t $(IMAGENAME):$(IMAGEVERSION)-arm-linux-gnueabihf .

build_arm-linux-gnueabihf: image_arm-linux-gnueabihf
	HOSTS=arm-linux-gnueabihf $(BASEDIR)/build.sh

image_aarch64-linux-gnu:
	cd $(BASEDIR)/images && docker build -f Dockerfile.aarch64-linux-gnu -t $(IMAGENAME):$(IMAGEVERSION)-aarch64-linux-gnu .

build_aarch64-linux-gnu: image_aarch64-linux-gnu
	HOSTS=aarch64-linux-gnu $(BASEDIR)/build.sh

image_riscv64-linux-gnu:
	cd $(BASEDIR)/images && docker build -f Dockerfile.riscv64-linux-gnu -t $(IMAGENAME):$(IMAGEVERSION)-riscv64-linux-gnu .

build_riscv64-linux-gnu: image_riscv64-linux-gnu
	HOSTS=aarch64-linux-gnu $(BASEDIR)/build.sh

clean-none:
	docker images | grep "<none>" | awk '{ print $3 }' | xargs docker rmi

.PHONEY: build images clean-none
