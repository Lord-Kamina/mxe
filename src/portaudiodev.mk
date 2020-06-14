# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := portaudiodev
$(PKG)_WEBSITE  := http://www.portaudio.com/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := dev
$(PKG)_CHECKSUM := 1697784bcb75a0c6e64d355ff091160e10c7460e86de93e8b5c98908d38ed602
$(PKG)_SUBDIR   := portaudio
$(PKG)_FILE     := pa_snapshot.tgz
$(PKG)_URL      := http://www.portaudio.com/archives/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://www.portaudio.com/download.html' | \
    $(SED) -n 's,.*pa_stable_v\([0-9][^>]*\)\.tgz.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
	cd '$(BUILD_DIR)' && $(TARGET)-cmake \
	-DCMAKE_CXX_FLAGS="-std=c++11 -D_WIN32_WINNT=0x603" \
    -DCMAKE_C_FLAGS="-D_WIN32_WINNT=0x603" \
    -DPA_BUILD_$(if $(BUILD_SHARED),SHARED,STATIC)=ON \
    -DBUILD_$(if $(BUILD_SHARED),SHARED,STATIC)=ON \
    -DBUILD_$(if $(BUILD_SHARED),SHARED,STATIC)_LIBS=ON \
    -DPA_BUILD_$(if $(BUILD_STATIC),SHARED,STATIC)=OFF \
    -DBUILD_$(if $(BUILD_STATIC),SHARED,STATIC)=OFF \
    -DBUILD_$(if $(BUILD_STATIC),SHARED,STATIC)_LIBS=OFF \
    -DPA_USE_DS=ON \
    -DPA_USE_WASAPI=ON \
    -DPA_USE_WDMKS=ON \
    -DPA_USE_WDMKS_DEVICE_INFO=ON \
    -DPA_USE_WMME=ON \
    -DPA_UNICODE_BUILD=ON \
    -DPA_BUILD_TESTS=OFF \
    -DPA_BUILD_EXAMPLES=OFF \
    '$(SOURCE_DIR)'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' $(if $(BUILD_STATIC),SHARED_FLAGS=) TESTS=
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    CXXFLAGS="-std=c++11 -D_WIN32_WINNT=0x603" \
    CFLAGS="-D_WIN32_WINNT=0x603" \
    '$(TARGET)-gcc' \
    -W -Wall -ansi -pedantic \
    '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-portaudio.exe' \
    `'$(TARGET)-pkg-config' portaudio-2.0 --cflags --libs`
endef
