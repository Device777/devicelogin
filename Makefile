ARCHS = arm64
TARGET = iphone:clang:latest:latest
PACKAGE_VERSION = 1.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DeviceWare

DeviceWare_FILES = Tweak.xm
DeviceWare_FRAMEWORKS = UIKit WebKit

include $(THEOS_MAKE_PATH)/tweak.mk
