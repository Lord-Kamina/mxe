# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libepoxy
$(PKG)_WEBSITE  := https://github.com/anholt/libepoxy
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.5.3
$(PKG)_CHECKSUM := c2f1e2c9c12dcc57dee07cd4ca47de83cf19d0226a225b695066ce58ebb4b117
$(PKG)_GH_CONF  := anholt/libepoxy/tags,
$(PKG)_DEPS     := cc xorg-macros

define $(PKG)_BUILD
    cd '$(SOURCE_DIR)' && ACLOCAL_PATH="$(PREFIX)/$(TARGET)/share/aclocal/" ./autogen.sh
    cd '$(SOURCE_DIR)' && ./configure \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(SOURCE_DIR)' -j '$(JOBS)' $(MXE_DISABLE_CRUFT)
    $(MAKE) -C '$(SOURCE_DIR)' -j 1 install $(MXE_DISABLE_CRUFT)

    # compile test
    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' epoxy --cflags --libs`
endef
