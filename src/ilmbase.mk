# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := ilmbase
$(PKG)_WEBSITE  := https://www.openexr.com/
$(PKG)_DESCR    := IlmBase
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.4.0
$(PKG)_CHECKSUM := 4904c5ea7914a58f60a5e2fbc397be67e7a25c380d7d07c1c31a3eefff1c92f1
$(PKG)_GH_CONF  := AcademySoftwareFoundation/openexr/releases,v
$(PKG)_FILE     := openexr-v$($(PKG)_VERSION).tar.gz
$(PKG)_SUBDIR   := openexr-$($(PKG)_VERSION)
$(PKG)_DEPS     := cc $(BUILD)~cmake

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://www.openexr.com/downloads.html' | \
    grep 'ilmbase-' | \
    $(SED) -n 's,.*/ilmbase-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

GCC_VERSION_MAJOR := $(shell echo $(gcc_VERSION) | cut -f1 -d.)
GCC_VERSION_MINOR := $(shell echo $(gcc_VERSION) | cut -f2 -d.)

$(PKG)_CXXSTD_14 = $(shell if [[ $(GCC_VERSION_MAJOR) > 6 || \( $(GCC_VERSION_MAJOR) == 6 && $(GCC_VERSION_MINOR) >= 1 \) ]]; then echo true)

define $(PKG)_BUILD
    mkdir '$(BUILD_DIR)/native'
    mkdir '$(BUILD_DIR)/cross'
    cd '$(BUILD_DIR)/native' && cmake \
    -DOPENEXR_CXX_STANDARD=$(if $($(PKG)_CXXSTD_14),14,11) \
    "$(SOURCE_DIR)"/IlmBase
    $(MAKE) -C '$(BUILD_DIR)/native/Half' -j '$(JOBS)'

    cd '$(BUILD_DIR)/cross' && $(TARGET)-cmake \
    -DOPENEXR_CXX_STANDARD=$(if $($(PKG)_CXXSTD_14),14,11) \
    -DNATIVE_ILMBASE_BUILD_DIR='$(BUILD_DIR)/native' \
    -DBUILD_TESTING=OFF \
    "$(SOURCE_DIR)"/IlmBase
    $(MAKE) -C '$(BUILD_DIR)/cross' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)/cross' -j 1 install
endef
