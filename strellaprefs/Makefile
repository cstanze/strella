TARGET := iphone:clang:13.2:13.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = StrellaPrefs
StrellaPrefs_FILES = $(wildcard *.m)
StrellaPrefs_FRAMEWORKS = UIKit EventKit
StrellaPref_EXTRA_FRAMEWORKS = Cephei
StrellaPrefs_PRIVATE_FRAMEWORKS = Preferences
StrellaPrefs_INSTALL_PATH = /Library/PreferenceBundles
StrellaPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
