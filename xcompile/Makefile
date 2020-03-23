# This Makefile script compiles the xerces-c, log4cplus and lmdb
# libraries required for cross-compiling GEM software on the CTP7.
#
# Two variables must be set in order for the script to work
#
# * SYSROOT_DIR must point to the CTP7 sysroot/Peta stage
# * INSTALL_DIR must point to the directory in which you want the
#   libraries to be installed. It can be the same directory as
#   SYSROOT_DIR

ifndef SYSROOT_DIR
    $(error "Error: SYSROOT_DIR must be defined!")
endif

ifndef INSTALL_DIR
    $(error "Error: INSTALL_DIR must be defined!")
endif

default: xerces-c log4cplus lmdb

xerces-c:
	cd xerces-c-3.1.4 \
	    && ./configure \
	    --disable-threads --prefix=/usr \
	    --host=arm-linux --with-sysroot=$(SYSROOT_DIR) \
	    CC=arm-linux-gnueabihf-gcc \
	    CXX=arm-linux-gnueabihf-g++ \
	    CFLAGS='-fomit-frame-pointer -pipe -fno-common -fno-builtin -Wall -march=armv7-a -mfpu=neon -mfloat-abi=hard -mthumb-interwork -mtune=cortex-a9 -DEMBED -Dlinux -D__linux__ -Dunix -fPIC --sysroot=$(SYSROOT_DIR)' \
	    CXXFLAGS='-fomit-frame-pointer -pipe -fno-common -fno-builtin -Wall -march=armv7-a -mfpu=neon -mfloat-abi=hard -mthumb-interwork -mtune=cortex-a9 -DEMBED -Dlinux -D__linux__ -Dunix -fPIC --sysroot=$(SYSROOT_DIR)' \
	    && $(MAKE) \
	    && $(MAKE) install DESTDIR=$(INSTALL_DIR)

log4cplus:
	cd log4cplus-1.1.2/ \
	    && ./configure \
	    --disable-threads --prefix=/usr \
	    --host=arm-linux --with-sysroot=$(SYSROOT_DIR) \
	    CC=arm-linux-gnueabihf-gcc \
	    CXX=arm-linux-gnueabihf-g++ \
	    CFLAGS='-fomit-frame-pointer -pipe -fno-common -fno-builtin -Wall -march=armv7-a -mfpu=neon -mfloat-abi=hard -mthumb-interwork -mtune=cortex-a9 -DEMBED -Dlinux -D__linux__ -Dunix -fPIC --sysroot=$(SYSROOT_DIR)' \
	    CXXFLAGS='-fomit-frame-pointer -pipe -fno-common -fno-builtin -Wall -march=armv7-a -mfpu=neon -mfloat-abi=hard -mthumb-interwork -mtune=cortex-a9 -DEMBED -Dlinux -D__linux__ -Dunix -fPIC --sysroot=$(SYSROOT_DIR)' \
	    && $(MAKE) \
	    && $(MAKE) install DESTDIR=$(INSTALL_DIR)

lmdb:
	cd lmdb-LMDB_0.9.19/libraries/liblmdb/ \
	    && $(MAKE) install DESTDIR=$(INSTALL_DIR) \
	    prefix=/usr \
	    CC=arm-linux-gnueabihf-gcc \
	    XCFLAGS='-fomit-frame-pointer -pipe -fno-common -fno-builtin -Wall -march=armv7-a -mfpu=neon -mfloat-abi=hard -mthumb-interwork -mtune=cortex-a9 -DEMBED -Dlinux -D__linux__ -Dunix -fPIC --sysroot=$(SYSROOT_DIR)' \
	    AR=arm-linux-gnueabihf-ar
