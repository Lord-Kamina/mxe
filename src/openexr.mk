# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := openexr
$(PKG)_WEBSITE  := https://www.openexr.com/
$(PKG)_DESCR    := OpenEXR
$(PKG)_IGNORE    = $(ilmbase_IGNORE)
$(PKG)_VERSION  := $(ilmbase_VERSION)
$(PKG)_CHECKSUM := $(ilmbase_CHECKSUM)
$(PKG)_SUBDIR   := openexr-$($(PKG)_VERSION)
$(PKG)_FILE     := $(ilmbase_FILE)
$(PKG)_URL      := $(ilmbase_URL)
$(PKG)_DEPS     := cc ilmbase pthreads zlib $(BUILD)~cmake
$(PKG)_PATCHES  := $(ilmbase_PATCHES)

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://www.openexr.com/downloads.html' | \
    grep 'openexr-' | \
    $(SED) -n 's,.*openexr-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

GCC_VERSION_MAJOR := $(shell echo $(gcc_VERSION) | cut -f1 -d.)
GCC_VERSION_MINOR := $(shell echo $(gcc_VERSION) | cut -f2 -d.)

$(PKG)_CXXSTD_14 := $(shell [ $(GCC_VERSION_MAJOR) -gt 6 -o \( $(GCC_VERSION_MAJOR) -eq 6 -a $(GCC_VERSION_MINOR) -ge 1 \) ] && echo true)

define $(PKG)_BUILD
    echo "patches: $(ilmbase_PATCHES)"
    $(foreach PKG_PATCH,$(ilmbase_PATCHES), \
    echo $(PKG_PATCH);\
      (cd '$(SOURCE_DIR)' && $(PATCH) -p1 -u) < $(PKG_PATCH))
    mkdir -p '$(BUILD_DIR)/native/IlmBase'
    mkdir '$(BUILD_DIR)/cross'
    cd '$(BUILD_DIR)/native/IlmBase' && cmake \
    -DOPENEXR_CXX_STANDARD=$(if $($(PKG)_CXXSTD_14),14,11) \
    -DCMAKE_INSTALL_PREFIX='$(BUILD_DIR)/native/IlmBase/install'\
    '$(SOURCE_DIR)/IlmBase'
    $(MAKE) -C '$(BUILD_DIR)/native/IlmBase' -j '$(JOBS)' install

    cd '$(BUILD_DIR)/native/' && cmake \
    -DOPENEXR_CXX_STANDARD=$(if $($(PKG)_CXXSTD_14),14,11) \
    -DIlmBase_DIR='$(BUILD_DIR)/native/IlmBase/install/lib/cmake/IlmBase'\
    '$(SOURCE_DIR)/OpenEXR'
    $(MAKE) -C '$(BUILD_DIR)/native/IlmImf' -j '$(JOBS)'
 
     cd '$(BUILD_DIR)/cross' && $(TARGET)-cmake \
    -DOPENEXR_CXX_STANDARD=$(if $($(PKG)_CXXSTD_14),14,11) \
    -DOPENEXR_INSTALL_PKG_CONFIG=ON \
    -DNATIVE_OPENEXR_BUILD_DIR='$(BUILD_DIR)/native' \
    -DBUILD_TESTING=OFF \
    "$(SOURCE_DIR)/OpenEXR"
    $(MAKE) -C '$(BUILD_DIR)/cross' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)/cross' -j 1 install

    '$(TARGET)-g++' \
        -Wall -Wextra -std=c++$(if $($(PKG)_CXXSTD_14),14,11) \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-openexr.exe' \
        `'$(TARGET)-pkg-config' OpenEXR --cflags --libs`
endef
