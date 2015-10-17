include theos/makefiles/common.mk

BUNDLE_NAME = CustomSpotlightActionPrefs
CustomSpotlightActionPrefs_FILES = CustomSpotlightActionPrefs.mm AddActionPrefs.mm 
CustomSpotlightActionPrefs_INSTALL_PATH = /Library/PreferenceBundles
CustomSpotlightActionPrefs_FRAMEWORKS = UIKit
CustomSpotlightActionPrefs_PRIVATE_FRAMEWORKS = Preferences AppSupport

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp  entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CustomSpotlightActionPrefs.plist$(ECHO_END)
