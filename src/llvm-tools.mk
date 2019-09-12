# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := llvm-tools
$(PKG)_WEBSITE  := https://llvm.org/
$(PKG)_VERSION  := 8.0.0
$(PKG)_CHECKSUM := 8872be1b12c61450cacc82b3d153eab02be2546ef34fa3580ed14137bb26224c
$(PKG)_GH_CONF  := llvm/llvm-project/tags, llvmorg-
$(PKG)_SUBDIR   := llvm-$($(PKG)_VERSION).src
$(PKG)_FILE     := llvm-$($(PKG)_VERSION).src.tar.xz
$(PKG)_URL      := https://releases.llvm.org/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_TARGETS  := $(BUILD)
$(PKG)_DEPS_$(BUILD) := cc cmake

define $(PKG)_BUILD_$(BUILD)
    cd "$(BUILD_DIR)" && cmake "$(SOURCE_DIR)" \
    	-DCMAKE_INSTALL_PREFIX="$(PREFIX)/libexec/llvm-$($(PKG)_VERSION)" \
        -DLLVM_TARGETS_TO_BUILD=X86 \
        -DLLVM_TARGET_ARCH=X86 \
        -DLLVM_BUILD_DOCS=OFF \
        -DLLVM_BUILD_EXAMPLES=OFF \
    	-DLLVM_BUILD_RUNTIME=ON \
    	-DBUILD_SHARED_LIBS=OFF \
        -DLLVM_BUILD_TESTS=OFF \
        -DLLVM_BUILD_TOOLS=ON \
        -DLLVM_ENABLE_BINDINGS=OFF \
        -DLLVM_ENABLE_DOXYGEN=OFF \
        -DLLVM_ENABLE_OCAMLDOC=OFF \
        -DLLVM_ENABLE_SPHINX=OFF \
        -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_INCLUDE_GO_TESTS=OFF \
        -DLLVM_INCLUDE_RUNTIMES=ON \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_TOOLS=ON \
        -DLLVM_INCLUDE_UTILS=OFF \
        -DLLVM_STATIC_LINK_CXX_STDLIB=ON
    $(MAKE) -C "$(BUILD_DIR)" -j "$(JOBS)" VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef