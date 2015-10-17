THEOS_DEVICE_IP=192.168.199.176
export ARCHS = armv7 armv7s arm64
include theos/makefiles/common.mk

TWEAK_NAME = CustomSpotlightAction 
CustomSpotlightAction_FILES = Tweak.xm CSAPreferencesHandler.m CSANotificationHandler.mm
CustomSpotlightAction_FRAMEWORKS = UIKit
CustomSpotlightAction_PRIVATE_FRAMEWORKS = AppSupport
SUBPROJECTS = customspotlightactionprefs

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
