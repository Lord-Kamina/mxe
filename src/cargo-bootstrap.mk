# This file is part of MXE. See LICENSE.md for licensing information.

PKG             		:= cargo-bootstrap
$(PKG)_BASE				:= $(subst -bootstrap,,$(PKG))
$(PKG)_WEBSITE  		:= https://www.rust-lang.org/
$(PKG)_VERSION 			:= 0.37.0
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
CHECKSUM_cargo_x86_64-unknown-netbsd				:= 0db9ba8e0488f5a0251054fcc9c854d52272c920182bb1966584176282fbb11f
CHECKSUM_cargo_x86_64-unknown-linux-gnu				:= d20fa121951339d5492cf8862f8a7af59efc99d18f3c27b95ab6d4658b6a7d67
CHECKSUM_cargo_x86_64-unknown-freebsd				:= c7b5400fff47e1f4b850f87f1b204d2b134b5750564dad03c25c8e897e4039a7
CHECKSUM_cargo_x86_64-apple-darwin					:= fadc3c67d0f52bc2df2e68ac6ece175951550b0ffe825b37a9473352f3622f25
CHECKSUM_cargo_s390x-unknown-linux-gnu				:= b9be0d96b80a3d5253486881dac40fa08c7df955b0e154ad818c945189ee2ec2
CHECKSUM_cargo_powerpc64le-unknown-linux-gnu		:= 4cda7686160f6981e936229703e8e2e756c74f390245f2ad9e356bbbed28a2c9
CHECKSUM_cargo_powerpc64-unknown-linux-gnu			:= e687733b4a6d9812ced9967d76546c5b953247a57dde42e823f640b3804ceafb
CHECKSUM_cargo_i686-unknown-linux-gnu				:= 6835a73e2ce17e11eda5393133dd7c78bc41bae5a09784e5327648f14340fd48
CHECKSUM_cargo_i686-unknown-freebsd					:= 82b755518b5404526854cca732e2b9e7325e819362f73b2bb1d3de97370ec874
CHECKSUM_cargo_i686-apple-darwin					:= d4d3ac68f972dada26a0b63ab796338e9b0c28c4f00a866d937e18f7cf83c277
CHECKSUM_cargo_aarch64-unknown-linux-gnu			:= 1cb4f14b8cf39d4c4b9ca532fc5fa09d8a592b832ff85f7efa55f068f589178f

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