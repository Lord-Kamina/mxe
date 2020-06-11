# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := portaudiodev
$(PKG)_WEBSITE  := http://www.portaudio.com/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := dev
$(PKG)_CHECKSUM := 9c2638545daf0814529a67f95aa20c25b90be319ee037899199c80bcb8f7b2e6
$(PKG)_SUBDIR   := portaudio
$(PKG)_FILE     := pa_snapshot.tar.gz
$(PKG)_URL      := http://www.portaudio.com/archives/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://www.portaudio.com/download.html' | \
    $(SED) -n 's,.*pa_stable_v\([0-9][^>]*\)\.tgz.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && autoconf
    # libtool looks for a pei* format when linking shared libs
    # apparently there's no real difference b/w pei and pe
    # so we set the libtool cache variables
    # https://sourceware.org/cgi-bin/cvsweb.cgi/src/bfd/libpei.h?annotate=1.25&cvsroot=src
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-host_os=mingw \
        --with-winapi=wmme,directx,wdmks,wasapi \
        --with-dxdir=$(PREFIX)/$(TARGET) \
        ac_cv_path_AR=$(TARGET)-ar \
        CXXFLAGS="-std=c++11 -D_WIN32_WINNT=0x603" \
        CFLAGS="-D_WIN32_WINNT=0x603" \
        $(if $(BUILD_SHARED),\
            lt_cv_deplibs_check_method='file_magic file format (pe-i386|pe-x86-64)' \
            lt_cv_file_magic_cmd='$$OBJDUMP -f')
    $(MAKE) -C '$(1)' -j '$(JOBS)' $(if $(BUILD_STATIC),SHARED_FLAGS=) TESTS=
    $(MAKE) -C '$(1)' -j 1 install

		CXXFLAGS="-std=c++11 -D_WIN32_WINNT=0x603" \
        CFLAGS="-D_WIN32_WINNT=0x603" \
        '$(TARGET)-gcc' \
        -W -Wall -ansi -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-portaudio.exe' \
        `'$(TARGET)-pkg-config' portaudio-2.0 --cflags --libs`
endef
