# This file is part of MXE. See LICENSE.md for licensing information.

PKG             		:= rustc-bootstrap
$(PKG)_BASE				:= $(subst -bootstrap,,$(PKG))
$(PKG)_WEBSITE  		:= https://www.rust-lang.org/
$(PKG)_VERSION 			:= 1.36.0
$(PKG)_DEPS_$(BUILD)	:= cmake

ifneq (, $(findstring darwin,$(BUILD)))
	BUILD_TRIPLET = $(firstword $(call split,-,$(BUILD)))-apple-darwin
else
	ifneq (, $(findstring ibm-linux,$(BUILD)))
		BUILD_TRIPLET = $(firstword $(call split,-,$(BUILD)))-unknown-linux-gnu
	else
		BUILD_TRIPLET = $(BUILD)
	endif
endif

TARGET_TRIPLET 			= $(firstword $(call split,-,$(TARGET)))-pc-windows-gnu
$(PKG)_FILE				:= $($(PKG)_BASE)-$($(PKG)_VERSION)-$(BUILD_TRIPLET).tar.xz
$(PKG)_URL				:= https://static.rust-lang.org/dist/$($(PKG)_FILE)

# CHECKSUMS
CHECKSUM_rustc_x86_64-unknown-netbsd			:= 2c1190ee16c515f502c3619462c8929cd8d5a99ebee99a585100246440624bee
CHECKSUM_rustc_x86_64-unknown-linux-gnu			:= fff0158da6f5af2a89936dc3e0c361077c06c2983eb310615e02f81ebbde1416
CHECKSUM_rustc_x86_64-unknown-freebsd			:= 10d896f57dd5a0dab4e44e9a94cf46e83a157cd46d904571b8eb8f0308c35fe8
CHECKSUM_rustc_x86_64-apple-darwin				:= 2465f33b66f09d4b16f0aac19179818665db5c92c97770be81bfddbef13db9d8
CHECKSUM_rustc_s390x-unknown-linux-gnu			:= ba0e2ab22e23cd5f0290d417cc509f47fe4e00f462756ad5178c3b38ee8759b3
CHECKSUM_rustc_powerpc64le-unknown-linux-gnu	:= 702818334ed9f01f60a433aa424784ec9b3785826cdaf03b0f69d03aded98df6
CHECKSUM_rustc_powerpc64-unknown-linux-gnu		:= fc89160d5f0d4bf14dc777f3280635347486b9c9687af26758a35c74ff7afced
CHECKSUM_rustc_i686-unknown-linux-gnu			:= ad86a75cc8a02a0129df480ccb28082985215f4b5558a42881777691ae1d3ff3
CHECKSUM_rustc_i686-unknown-freebsd				:= 70b25cf5912c42f8835a929c9904fc5ae5968375d0a53bc55c5b0dd20dd0e69f
CHECKSUM_rustc_i686-apple-darwin				:= 13b5384f69ea0b7f6427dbe37226e0ce8e963377125040d0afb1da364bc82d67
CHECKSUM_rustc_aarch64-unknown-linux-gnu		:= 98ce55b141a5057bee1c0126ddf20824a940104fc57d7350417776768ce533ee

$(PKG)_CHECKSUM			:= $(CHECKSUM_$($(PKG)_BASE)_$(BUILD_TRIPLET))
$(PKG)_TARGETS			:= $(BUILD)

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://static.rust-lang.org/dist/' | \
    $(SED) -n 's,.*$($(PKG)_BASE)-\([0-9][^>]*\)\.tar.*,\1,p' | \
    grep -v 'alpha\|beta\|rc\|git\|nightly' | \
    $(SORT) -Vr | \
    head -1
endef

define $(PKG)_BUILD
cd "$(SOURCE_DIR)$($(PKG)_BASE)-$($(PKG)_VERSION)-$(BUILD_TRIPLET)/$($(PKG)_BASE)"  && for currfile in `cut -d: -f2 $(SOURCE_DIR)$($(PKG)_BASE)-$($(PKG)_VERSION)-$(BUILD_TRIPLET)/$($(PKG)_BASE)/manifest.in | tr '\n' ' '`; \
	do \
		mkdir -p "$(MXE_TMP)/tmp-rust-stage0-$(BUILD_TRIPLET)/"$$(dirname $${currfile}) ; \
		mv -fv "$(SOURCE_DIR)$($(PKG)_BASE)-$($(PKG)_VERSION)-$(BUILD_TRIPLET)/$($(PKG)_BASE)/$${currfile}" "$(MXE_TMP)/tmp-rust-stage0-$(BUILD_TRIPLET)/$${currfile}" ; \
	done
endef