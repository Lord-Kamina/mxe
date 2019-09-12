# This file is part of MXE. See LICENSE.md for licensing information.

PKG						:= rust-std
$(PKG)_WEBSITE  		:= https://www.rust-lang.org/
$(PKG)_VERSION  		:= 1.37.0

$(PKG)_DEPS				:= cc $(BUILD)~rustc get-target-triplet

ifneq (, $(findstring darwin,$(BUILD)))
	BUILD_TRIPLET = $(firstword $(call split,-,$(BUILD)))-apple-darwin
else
	ifneq (, $(findstring ibm-linux,$(BUILD)))
		BUILD_TRIPLET = $(firstword $(call split,-,$(BUILD)))-unknown-linux-gnu
	else
		BUILD_TRIPLET = $(BUILD)
	endif
endif

define DEP_TARGET
$(shell [[ -f $(MXE_TMP)/get-target-triplet.txt ]] && cat $(MXE_TMP)/get-target-triplet.txt || echo ERROR)
endef

TARGET_TRIPLET 			= $(firstword $(call split,-,$(DEP_TARGET)))-pc-windows-gnu

CHECKSUM_rust-std_x86_64-pc-windows-gnu	:= ff7665735afb052e43da20ed206e135da4977b9bffbaf394c4571259950ca6a4
CHECKSUM_rust-std_i686-pc-windows-gnu		:= 0667452dcca5c08dc6c4a3d5f38852b9a883489793d035dea6fcccd2b9a219f9

$(PKG)_FILE     		:= $(PKG)-$($(PKG)_VERSION)-$(TARGET_TRIPLET).tar.xz
$(PKG)_URL				:= https://static.rust-lang.org/dist/$($(PKG)_FILE)
$(PKG)_CHECKSUM			:= $(CHECKSUM_$(PKG)_$(TARGET_TRIPLET))

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://static.rust-lang.org/dist/' | \
    $(SED) -n 's,.*$(PKG)-\([0-9][^>]*\)\.tar.*,\1,p' | \
    grep -v 'alpha\|beta\|rc\|git\|nightly' | \
    $(SORT) -Vr | \
    head -1
endef

define $(PKG)_BUILD
	$(shell [[ -f $(PREFIX)/$(TARGET)/lib/rustlib/uninstall.sh ]] && $(PREFIX)/$(TARGET)/lib/rustlib/uninstall.sh)
	cd $(SOURCE_DIR)/$(PKG)-$($(PKG)_VERSION)-$(TARGET_TRIPLET) && ./install.sh --prefix=$(PREFIX)/$(TARGET) --verbose
	rm -fv $(PREFIX)/$(TARGET)/installed/get-target-triplet
endef
