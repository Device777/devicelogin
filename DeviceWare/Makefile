TARGET = iphone:clang:latest:16.5
INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS = arm64 arm64e
PACKAGE_VERSION = 1.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DeviceWare
DeviceWare_FILES = Tweak.xm
DeviceWare_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
