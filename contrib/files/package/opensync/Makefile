NDK_SYSROOT_LIB := $(TOOLCHAIN)/sysroot/usr/lib/$(HOST_ARCH)/$(API)/
ifeq ($(HOST_ARCH), armv7a-linux-androideabi)
NDK_SYSROOT_LIB := $(TOOLCHAIN)/sysroot/usr/lib/arm-linux-androideabi/$(API)/
endif
NDK_SYSROOT_INC := $(TOOLCHAIN)/sysroot/usr/include/

SDK_DIR := $(shell pwd)/../../../
DL_DIR := $(SDK_DIR)/dl/
PATCH_DIR := $(SDK_DIR)/contrib/

BUILD_DIR := $(shell pwd)/build_dir/
APK_ASSETS_DIR := $(BUILD_DIR)/../../../apk/app/src/main/assets

.PHONY: clean opensync apk_install

all: opensync apk_install

define download_pkg
	@[ ! -f $(DL_DIR)/$(notdir $(1)) ] && { \
		[ ! -d $(DL_DIR) ] && mkdir $(DL_DIR); \
		echo "   $(GREEN)Download $(1) $(NOCOLOR)"; \
		curl -L $(1) -o $(DL_DIR)/$(notdir $(1)); \
	} || true
endef

define tar_pkg
	if [ ! -d $(BUILD_DIR)$(1) ] || [ -z $$(ls -A $(BUILD_DIR)$(1)) ]; then \
		echo "   $(GREEN)Unpacking $(1) $(NOCOLOR)"; \
		rm -rf $(BUILD_DIR)/$(1); \
		mkdir -p $(BUILD_DIR)/$(1); \
		tar -zxvf $(DL_DIR)/$(1)* --strip-components 1 -C $(BUILD_DIR)/$(1) || \
		tar -jxvf $(DL_DIR)/$(1)* --strip-components 1 -C $(BUILD_DIR)/$(1); \
	fi
endef

define pkg_prepare
	@echo "   $(GREEN)Building $(1)...$(NOCOLOR); "
	$(call download_pkg,$(2))
	$(call tar_pkg,$(1))
endef

# Dependency Packages

OPENSSL_URL := https://ftp.openssl.org/source/old/1.1.1/openssl-1.1.1v.tar.gz
OPENSSL_PKG_NAME := openssl
define openssl
	$(call pkg_prepare,$(OPENSSL_PKG_NAME),$(OPENSSL_URL))

	@PATH=$(TOOLCHAIN)/bin:$(PATH); \
	CC=clang; \
	cd $(BUILD_DIR)/$(OPENSSL_PKG_NAME) && \
	./Configure $(ANDROID_PLAT) -D__ANDROID_API__=$(API) && \
	make -j $(JOBS)

	@echo "   $(GREEN)Installing $(OPENSSL_PKG_NAME)...$(NOCOLOR)"
	@mkdir -p rootfs/lib/include
	@cp -f $(BUILD_DIR)/$(OPENSSL_PKG_NAME)/libcrypto.so* rootfs/lib/
	@cp -f $(BUILD_DIR)/$(OPENSSL_PKG_NAME)/libcrypto.a rootfs/lib/
	@cp -f $(BUILD_DIR)/$(OPENSSL_PKG_NAME)/libssl.so* rootfs/lib/
	@cp -f $(BUILD_DIR)/$(OPENSSL_PKG_NAME)/libssl.a rootfs/lib/

	@cp -f $(BUILD_DIR)/$(OPENSSL_PKG_NAME)/libcrypto.so* $(NDK_SYSROOT_LIB)/
	@cp -f $(BUILD_DIR)/$(OPENSSL_PKG_NAME)/libcrypto.a $(NDK_SYSROOT_LIB)/
	@cp -f $(BUILD_DIR)/$(OPENSSL_PKG_NAME)/libssl.so* $(NDK_SYSROOT_LIB)/
	@cp -f $(BUILD_DIR)/$(OPENSSL_PKG_NAME)/libssl.a $(NDK_SYSROOT_LIB)/
	@cp -rf $(BUILD_DIR)/$(OPENSSL_PKG_NAME)/include/openssl $(NDK_SYSROOT_INC)/
endef

OVSDB_URL := https://www.openvswitch.org/releases/openvswitch-2.11.1.tar.gz
OVSDB_PKG_NAME := openvswitch
define ovsdb
	$(call pkg_prepare,$(OVSDB_PKG_NAME),$(OVSDB_URL))

	cd $(BUILD_DIR)/$(OVSDB_PKG_NAME) && \
	patch -p1 < $(PATCH_DIR)/patches/package/openvswitch/0001-OIC-101-ovsdb-0001-fix-pthread_setaffinity_np.patch && \
	patch -p1 < $(PATCH_DIR)/patches/package/openvswitch/0002-ESW-17109-OVSDB-bootstrap.patch && \
	./boot.sh && \
	./configure --host $(HOST_ARCH) \
		--with-rundir=/data/data/com.opensync.app/cache \
		--with-dbdir=/data/data/com.opensync.app/cache \
		--enable-ssl; \
	make

	@echo "   $(GREEN)Installing $(OVSDB_PKG_NAME)...$(NOCOLOR)"
	@mkdir -p rootfs/bin
	@cp -f $(BUILD_DIR)/$(OVSDB_PKG_NAME)/ovsdb/ovsdb-server rootfs/bin/
	@cp -f $(BUILD_DIR)/$(OVSDB_PKG_NAME)/ovsdb/ovsdb-client rootfs/bin/
endef

JANSSON_URL := https://sources.buildroot.net/jansson/jansson-2.14.tar.bz2
JANSSON_PKG_NAME := jansson
define jansson
	$(call pkg_prepare,$(JANSSON_PKG_NAME),$(JANSSON_URL))

	cd $(BUILD_DIR)/$(JANSSON_PKG_NAME) && \
	autoreconf -fi && \
	./configure --host $(HOST_ARCH) \
		--enable-shared CFLAGS=-fPIC && \
	make

	@echo "   $(GREEN)Installing $(JANSSON_PKG_NAME)...$(NOCOLOR)"
	@mkdir -p rootfs/lib
	@cp -f $(BUILD_DIR)/$(JANSSON_PKG_NAME)/src/.libs/libjansson.a rootfs/lib/

	@cp -f $(BUILD_DIR)/$(JANSSON_PKG_NAME)/src/.libs/libjansson.a $(NDK_SYSROOT_LIB)/
	@cp -f $(BUILD_DIR)/$(JANSSON_PKG_NAME)/src/jansson.h $(NDK_SYSROOT_INC)/
	@cp -f $(BUILD_DIR)/$(JANSSON_PKG_NAME)/src/jansson_config.h $(NDK_SYSROOT_INC)/
endef

LIBEV_URL := http://dist.schmorp.de/libev/Attic/libev-4.24.tar.gz
LIBEV_PKG_NAME := libev
define libev
	$(call pkg_prepare,$(LIBEV_PKG_NAME),$(LIBEV_URL))
	cd $(BUILD_DIR)/$(LIBEV_PKG_NAME) && \
	./configure --host $(HOST_ARCH) && \
	make

	@echo "   $(GREEN)Installing $(LIBEV_PKG_NAME)...$(NOCOLOR)"
	@cp -f $(BUILD_DIR)/$(LIBEV_PKG_NAME)/.libs/libev.a rootfs/lib/

	@cp -f $(BUILD_DIR)/$(LIBEV_PKG_NAME)/.libs/libev.a $(NDK_SYSROOT_LIB)/
	@cp -f $(BUILD_DIR)/$(LIBEV_PKG_NAME)/ev.h $(NDK_SYSROOT_INC)/
endef

PROTOBUF_C_URL := https://sources.buildroot.net/protobuf-c/protobuf-c-1.3.3.tar.gz
PROTOBUF_C_PKG_NAME := protobuf-c
define protobuf-c
	$(call pkg_prepare,$(PROTOBUF_C_PKG_NAME),$(PROTOBUF_C_URL))
	cd $(BUILD_DIR)/$(PROTOBUF_C_PKG_NAME) && \
	./autogen.sh && \
	./configure --host $(HOST_ARCH) --prefix=$(shell pwd)/$(PROTOBUF_C_PKG_NAME) \
        --enable-shared \
        --enable-static \
        --disable-protoc && \
	make

	@echo "   $(GREEN)Installing $(PROTOBUF_C_PKG_NAME)...$(NOCOLOR)"
	@cp -f $(BUILD_DIR)/$(PROTOBUF_C_PKG_NAME)/protobuf-c/.libs/libprotobuf-c.a rootfs/lib/

	@cp -f $(BUILD_DIR)/$(PROTOBUF_C_PKG_NAME)/protobuf-c/.libs/libprotobuf-c.a $(NDK_SYSROOT_LIB)/
	@mkdir -p $(NDK_SYSROOT_INC)/protobuf-c
	@cp -f $(BUILD_DIR)/$(PROTOBUF_C_PKG_NAME)/protobuf-c/protobuf-c.h $(NDK_SYSROOT_INC)/protobuf-c/
endef

MOSQUITTO_URL := https://mosquitto.org/files/source/mosquitto-1.6.15.tar.gz
MOSQUITTO_PKG_NAME := mosquitto
define mosquitto
	$(call pkg_prepare,$(MOSQUITTO_PKG_NAME),$(MOSQUITTO_URL))

	cd $(BUILD_DIR)/$(MOSQUITTO_PKG_NAME) && \
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=$(ANDROID_NDK_HOME)/build/cmake/android.toolchain.cmake \
        -DANDROID_ABI=$(ANDROID_ABI)  \
        -DANDROID_PLATFORM=android-$(API)  \
        -DWITH_THREADING=OFF  \
        -DWITH_TLS=ON \
        -DWITH_BUNDLED_DEPS=yes \
        -DDOCUMENTATION=OFF; \
	make

	@echo "   $(GREEN)Installing $(MOSQUITTO_PKG_NAME)...$(NOCOLOR)"
	@cp -f $(BUILD_DIR)/$(MOSQUITTO_PKG_NAME)/lib/libmosquitto.so rootfs/lib/libmosquitto.so

	@cp -f $(BUILD_DIR)/$(MOSQUITTO_PKG_NAME)/lib/libmosquitto.so $(NDK_SYSROOT_LIB)/libmosquitto.so
	@cp -f $(BUILD_DIR)/$(MOSQUITTO_PKG_NAME)/lib/mosquitto.h $(NDK_SYSROOT_INC)/
endef

LIBMNL_URL := https://www.netfilter.org/pub/libmnl/libmnl-1.0.3.tar.bz2
LIBMNL_PKG_NAME := libmnl
define libmnl
	$(call pkg_prepare,$(LIBMNL_PKG_NAME),$(LIBMNL_URL))

	cd $(BUILD_DIR)/$(LIBMNL_PKG_NAME); \
	autoreconf -fvi && \
	./configure --host $(HOST_ARCH) --enable-static; \
	make

	@echo "   $(GREEN)Installing $(LIBMNL_PKG_NAME)...$(NOCOLOR)"
	@cp -f $(BUILD_DIR)/$(LIBMNL_PKG_NAME)/src/.libs/libmnl.a rootfs/lib/

	@cp -f $(BUILD_DIR)/$(LIBMNL_PKG_NAME)/src/.libs/libmnl.a $(NDK_SYSROOT_LIB)/
	mkdir -p $(NDK_SYSROOT_INC)/libmnl
	@cp -f $(BUILD_DIR)/$(LIBMNL_PKG_NAME)/include/libmnl/libmnl.h $(NDK_SYSROOT_INC)/libmnl
endef

LIBPCAP_URL := https://www.tcpdump.org/release/libpcap-1.10.1.tar.gz
LIBPCAP_PKG_NAME := libpcap
define libpcap
	$(call pkg_prepare,$(LIBPCAP_PKG_NAME),$(LIBPCAP_URL))

	cd $(BUILD_DIR)/$(LIBPCAP_PKG_NAME); \
	autoreconf -fvi && \
	./configure --host $(HOST_ARCH) \
		--disable-ipv6 --disable-usb \
		--disable-bluetooth --disable-canusb \
		--disable-can --disable-dbus --without-libnl; \
	make

	@echo "   $(GREEN)Installing $(LIBPCAP_PKG_NAME)...$(NOCOLOR)"
	@cp -f $(BUILD_DIR)/$(LIBPCAP_PKG_NAME)/libpcap.a rootfs/lib/

	@cp -f $(BUILD_DIR)/$(LIBPCAP_PKG_NAME)/libpcap.a $(NDK_SYSROOT_LIB)/
	@cp -f $(BUILD_DIR)/$(LIBPCAP_PKG_NAME)/pcap.h $(NDK_SYSROOT_INC)/
	@cp -rf $(BUILD_DIR)/$(LIBPCAP_PKG_NAME)/pcap $(NDK_SYSROOT_INC)/.
endef

CURL_URL := https://curl.se/download/curl-7.88.1.tar.gz
CURL_PKG_NAME := curl
define curl
	$(call pkg_prepare,$(CURL_PKG_NAME),$(CURL_URL))

	cd $(BUILD_DIR)/$(CURL_PKG_NAME); \
	autoreconf -fvi && \
	./configure --host $(HOST_ARCH) --with-ssl --disable-ftp -disable-shared \
		--disable-gopher --disable-file --disable-imap \
		--disable-ldap --disable-ldaps --disable-pop3  \
		--disable-proxy --disable-rtsp --disable-smtp  \
		--disable-telnet --disable-tftp --without-gnutls \
		--without-libidn --without-librtmp --disable-dict; \
	make

	@echo "   $(GREEN)Installing $(CURL_PKG_NAME)...$(NOCOLOR)"
	@cp -f $(BUILD_DIR)/$(CURL_PKG_NAME)/./lib/.libs/libcurl.a rootfs/lib/

	@cp -f $(BUILD_DIR)/$(CURL_PKG_NAME)/./lib/.libs/libcurl.a $(NDK_SYSROOT_LIB)/
	@cp -rf $(BUILD_DIR)/$(CURL_PKG_NAME)/include/curl $(NDK_SYSROOT_INC)/.
endef

ZEROMQ_URL := https://sources.buildroot.net/zeromq/zeromq-4.3.4.tar.gz
ZEROMQ_PKG_NAME := zeromq
define libzmq
	$(call pkg_prepare,$(ZEROMQ_PKG_NAME),$(ZEROMQ_URL))

	cd $(BUILD_DIR)/$(ZEROMQ_PKG_NAME)/builds/android; \
	[ $(ANDROID_PLAT) = android-arm ] && arch=arm || arch=arm64; \
	./build.sh $$arch

	@echo "   $(GREEN)Installing $(ZEROMQ_PKG_NAME)...$(NOCOLOR)"
	@cp -f $(BUILD_DIR)/$(ZEROMQ_PKG_NAME)/builds/android/prefix/*/lib/libzmq.so rootfs/lib/
	@cp -f $(BUILD_DIR)/$(ZEROMQ_PKG_NAME)/builds/android/prefix/*/lib/libzmq.a rootfs/lib/

	@cp -f $(BUILD_DIR)/$(ZEROMQ_PKG_NAME)/builds/android/prefix/*/lib/libzmq.so $(NDK_SYSROOT_LIB)/
	@cp -f $(BUILD_DIR)/$(ZEROMQ_PKG_NAME)/builds/android/prefix/*/lib/libzmq.a $(NDK_SYSROOT_LIB)/
	@cp -f $(BUILD_DIR)/$(ZEROMQ_PKG_NAME)/builds/android/prefix/arm/include/* $(NDK_SYSROOT_INC)/
endef

# Workaround that NDK doesn't have -lrt -lpthread, OpenSync referenced too
# many lrt and lpthread, this WR is the simplest way.
define wr_rt_pthread
	cd $(NDK_SYSROOT_LIB)/; \
	$(AR) cru librt.a; \
	$(AR) cru libpthread.a
endef

.opensync_dep:
	$(call openssl)
	$(call ovsdb)
	$(call jansson)
	$(call libev)
	$(call protobuf-c)
	$(call mosquitto)
	$(call libmnl)
	$(call libpcap)
	$(call curl)
	$(call libzmq)
	$(call wr_rt_pthread)
	touch .opensync_dep

opensync: .opensync_dep
	@echo "   $(GREEN)Building OpenSync core...$(NOCOLOR)"

	# ESW-18323: Remove patch applying logic to pass CI
	# cd $(OPENSYNC_SRC)/core; \
	# mkdir -p patches; \
	# cp -vaf $(PATCH_DIR)/package/patches/opensync/* patches/.; \
	# ! quilt series | grep . || quilt push -a; \

	cd $(OPENSYNC_SRC)/core; \
	make TARGET=$(TARGET) ANDROID_NDK_ROOT=$(ANDROID_NDK_ROOT) rootfs

	@echo "   $(GREEN)Installing OpenSync...$(NOCOLOR)"
	@cp -rf $(OPENSYNC_SRC)/core/work/$(TARGET)/rootfs/etc  $(shell pwd)/rootfs/
	@cp -rf $(OPENSYNC_SRC)/core/work/$(TARGET)/rootfs/usr/opensync  $(shell pwd)/rootfs/

apk_install:
	@echo "   $(GREEN)Installing Rootfs...$(NOCOLOR)"
	@cp $(NDK_SYSROOT_LIB)/../libc++_shared.so rootfs/lib/
	@rm -rf $(APK_ASSETS_DIR)/opensync.zip
	@[  ! -d $(APK_ASSETS_DIR) ] && mkdir -p $(APK_ASSETS_DIR) || true
	@cd rootfs && zip -q -r opensync.zip * && mv opensync.zip $(APK_ASSETS_DIR)

clean:
	@@echo "   $(GREEN)Cleaning...$(NOCOLOR)"
	rm -rf build_dir .opensync_dep
