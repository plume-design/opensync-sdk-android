JOBS ?= $(shell grep -c ^processor /proc/cpuinfo)
CONFIG ?= android-generic

SDK_TOOL := "https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip"
NDK_VERSION ?= "ndk\;21.4.7075529"
ADK_VERSION ?= "platforms\;android-32"

BUILD_NUMBER ?= 0
BUILD_PROFILE ?= Release
IMAGE_DEPLOYMENT_PROFILE ?= local
BUILD := build-$(CONFIG)

export TEAL := $(shell tput setaf 6 2>/dev/null)
export YELLOW := $(shell tput setaf 3 2>/dev/null)
export GREEN := $(shell tput setaf 2 2>/dev/null)
export PURPLE := $(shell tput setaf 5 2>/dev/null)
export NOCOLOR := $(shell tput sgr0 2>/dev/null)

export IMAGE_DEPLOYMENT_PROFILE

export ANDROID_HOME := $(shell pwd)/$(BUILD)/android_sdk
export PATH := $(shell echo $$PATH):$(ANDROID_HOME)/cmdline-tools/latest/bin:$(ANDROID_HOME)/platform-tools
ifndef OPENSYNC_SRC
$(error OPENSYNC_SRC not set)
else
export OPENSYNC_VERSION := $(shell cd $(OPENSYNC_SRC)/core && make -f build/version.mk version_long | grep -v make | awk 'END {print}')
export OPENSYNC_BACKHAUL_SSID := $(shell cd $(OPENSYNC_SRC)/core && make SERVICE_PROVIDERS=$(SERVICE_PROVIDERS) \
	IMAGE_DEPLOYMENT_PROFILE=$(IMAGE_DEPLOYMENT_PROFILE) -f build/service-provider.mk service-provider/info | grep BACKHAUL_SSID | awk -F '=' '{print $$2}')
endif
export OPENSYNC_C_PKG := $(shell pwd)/$(BUILD)/package/opensync

prepare:
	make $(BUILD)

$(BUILD):
	@rm -rf .$(BUILD)
	@mkdir .$(BUILD)
	@make sdk-assemble
	@! test -e $(BUILD) || mv -f $(BUILD) $(BUILD).old.$(shell date +%Y-%m-%d-%H-%M-%S)
	@rsync -a $(OPENSYNC_SRC)/platform/android/apk .$(BUILD)
	@mkdir -p .$(BUILD)/package/opensync
	@ln -sf ../../../contrib/files/package/opensync/Makefile .$(BUILD)/package/opensync/Makefile
	@ln -sf apk/app/build/outputs/apk/release .$(BUILD)/images
	@mv .$(BUILD) $(BUILD)

sdk-assemble:
	@echo "   $(GREEN)Download Android SDK...$(NOCOLOR)";
	@rm -rf .$(BUILD)/.android_sdk
	@mkdir .$(BUILD)/.android_sdk
	@wget $(SDK_TOOL) -O .$(BUILD)/.android_sdk/commandlinetools.zip && \
		cd .$(BUILD)/.android_sdk; \
		unzip commandlinetools.zip && mkdir cmdline-tools/latest && mv cmdline-tools/* cmdline-tools/latest 2>/dev/null; \
		rm commandlinetools.zip; \
		yes | ./cmdline-tools/latest/bin/sdkmanager "platform-tools" "$(ADK_VERSION)"; \
		yes | ./cmdline-tools/latest/bin/sdkmanager --install "$(NDK_VERSION)"
	@mv .$(BUILD)/.android_sdk .$(BUILD)/android_sdk

opensync-apk:
	@cd $(BUILD)/apk && \
	./gradlew assemble$(BUILD_PROFILE)

clean/opensync:
	@rm -rf $(OPENSYNC_SRC)/core/work
	@rm -rf $(OPENSYNC_C_PKG)/build_dir

cleanall:
	@rm -rf build* .build*

build:
	$(info ANDROID_HOME: $(ANDROID_HOME))
	$(info OPENSYNC_SRC: $(OPENSYNC_SRC))
	$(info OPENSYNC_C_PKG: $(OPENSYNC_C_PKG))
	$(info OPENSYNC_VERSION: $(OPENSYNC_VERSION))

	@make prepare
	@make opensync-apk
