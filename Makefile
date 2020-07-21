TARGET := iphone:clang:13.2:13.0
ARCHS = arm64 arm64e
THEOS_DEVICE_IP = 192.168.1.248
# DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Strella
Strella_FILES = Strella.xm $(wildcard *.m) $(wildcard Extensions/*.m)
Strella_FRAMEWORKS = EventKit MediaPlayer
Strella_EXTRA_FRAMEWORKS = Cephei
Strella_PRIVATE_FRAMEWORKS = AppSupport
Strella_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += strellaprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
