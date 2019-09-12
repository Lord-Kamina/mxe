# This file is part of MXE. See LICENSE.md for licensing information.

PKG             		:= rust-std-bootstrap
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
CHECKSUM_rust-std_x86_64-unknown-netbsd				:= 0026bb891952b4c5b697076a53006fa3ee79aa67d267dbc57cbe6b940c0d110a
CHECKSUM_rust-std_x86_64-unknown-linux-gnu			:= ce8e12684b568a8a4f7d346a743383429849cf3f028f5712ad3d3e31590c8db3
CHECKSUM_rust-std_x86_64-unknown-freebsd			:= 5ceac44ea809ae4dd0c5ef35d4d0e83b6f082bcd5ffc244e92a041a974fc9be8
CHECKSUM_rust-std_x86_64-apple-darwin				:= 798087a4a0a3e87997abbf67f35e2f00af4fbf2f47474cb2b2899d91e88cab60
CHECKSUM_rust-std_s390x-unknown-linux-gnu			:= 9b0f0680a230424ef95abd85f1797090a069183f9fcc9af905fc0375e38c04a9
CHECKSUM_rust-std_powerpc64le-unknown-linux-gnu		:= db7a9a06b8b1b84d6fe10bc1e2e136234e31bfaa77499b9df36e2d441ef1b856
CHECKSUM_rust-std_powerpc64-unknown-linux-gnu		:= 886b723a04d52bd96c9470e72a568f86b9010d128b3c403d199bc1f50694dea3
CHECKSUM_rust-std_i686-unknown-linux-gnu			:= a78f7bdbce0a960f3334c6c639cbe96f05b9b74df26cda9a5161834098119217
CHECKSUM_rust-std_i686-unknown-freebsd				:= 164c0c9e6c971063403feebd38219c0a330a9ba6e460cc7e57001703d8a6211f
CHECKSUM_rust-std_i686-apple-darwin					:= 1f80a723c2a496cf2d577e4494325987a289c4aa112e72ea114f4f1be7ecae35
CHECKSUM_rust-std_aarch64-unknown-linux-gnu			:= 46c96cdca589e0b256e59370a6c9a1126f00cdd48b5659b638aa4dd7198b0406

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
cd "$(SOURCE_DIR)$($(PKG)_BASE)-$($(PKG)_VERSION)-$(BUILD_TRIPLET)/$($(PKG)_BASE)-$(BUILD_TRIPLET)"  && for currfile in `cut -d: -f2 $(SOURCE_DIR)$($(PKG)_BASE)-$($(PKG)_VERSION)-$(BUILD_TRIPLET)/$($(PKG)_BASE)-$(BUILD_TRIPLET)/manifest.in | tr '\n' ' '`; \
	do \
		mkdir -p "$(MXE_TMP)/tmp-rust-stage0-$(BUILD_TRIPLET)/"$$(dirname $${currfile}) ; \
		mv -fv "$(SOURCE_DIR)$($(PKG)_BASE)-$($(PKG)_VERSION)-$(BUILD_TRIPLET)/$($(PKG)_BASE)-$(BUILD_TRIPLET)/$${currfile}" "$(MXE_TMP)/tmp-rust-stage0-$(BUILD_TRIPLET)/$${currfile}" ; \
	done
endef