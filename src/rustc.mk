# This file is part of MXE. See LICENSE.md for licensing information.

PKG						:= rustc
$(PKG)_WEBSITE  		:= https://www.rust-lang.org/
$(PKG)_VERSION  		:= 1.37.0

$(PKG)_FILE     		:= $(PKG)-$($(PKG)_VERSION)-src.tar.xz
$(PKG)_SUBDIR			:= $(PKG)-$($(PKG)_VERSION)-src
$(PKG)_URL				:= https://static.rust-lang.org/dist/$($(PKG)_FILE)
$(PKG)_DEPS_$(BUILD)	:= cc $(BUILD)~cmake $(BUILD)~llvm-tools $(BUILD)~rustc-bootstrap $(BUILD)~rust-std-bootstrap $(BUILD)~cargo-bootstrap
$(PKG)_CHECKSUM			:= 10abffac50a729cf74cef6dd03193a2f4647541bd19ee9281be9e5b12ca8cdfd
$(PKG)_TARGETS			:= $(BUILD)
LLVM_VERSION			:= $(llvm-tools_VERSION)

export RUST_BACKTRACE   :=1

ifneq (, $(findstring darwin,$(BUILD)))
	BUILD_TRIPLET = $(firstword $(call split,-,$(BUILD)))-apple-darwin
	PATCH_CARGO_CRATES := TRUE
else
	ifneq (, $(findstring ibm-linux,$(BUILD)))
		BUILD_TRIPLET = $(firstword $(call split,-,$(BUILD)))-unknown-linux-gnu
	else
		BUILD_TRIPLET = $(BUILD)
	endif
endif

TARGET_TRIPLET 			= $(firstword $(call split,-,$(TARGET)))-pc-windows-gnu

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://static.rust-lang.org/dist/' | \
    $(SED) -n 's,.*$(PKG)-src-\([0-9][^>]*\)\.tar.*,\1,p' | \
    grep -v 'alpha\|beta\|rc\|git\|nightly' | \
    $(SORT) -Vr | \
    head -1
endef

define $(PKG)_PATCH_CRATES
	(cd $(SOURCE_DIR) && $(PATCH) -p1 -u) < $(TOP_DIR)/src/rustc-2-patch-libgit2-find-iconv.diff
	rm -Rf $(TOP_DIR)/tmp-patched-cargo-deps
	mkdir -p $(TOP_DIR)/tmp-patched-cargo-deps/vendor
	cp -Rf $(SOURCE_DIR)/vendor/libgit2-sys $(TOP_DIR)/tmp-patched-cargo-deps/vendor/
	cp -Rf $(SOURCE_DIR)/vendor/libssh2-sys $(TOP_DIR)/tmp-patched-cargo-deps/vendor/
	cp -Rf $(SOURCE_DIR)/vendor/openssl-src $(TOP_DIR)/tmp-patched-cargo-deps/vendor/
	cp -Rf $(SOURCE_DIR)/vendor/openssl-sys $(TOP_DIR)/tmp-patched-cargo-deps/vendor/
	(cd $(TOP_DIR)/tmp-patched-cargo-deps && $(PATCH) -p1 -u) < $(TOP_DIR)/src/rustc-3-patch-libgit2-find-iconv.diff
(cd $(SOURCE_DIR) && $(PATCH) -p1 -u) < $(TOP_DIR)/src/rustc-4-patch-cargo-lock.diff
endef

define $(PKG)_CARGO_CONFIG_OPTS
"[build]\ncargo=\"$(PREFIX)/$(BUILD)/bin/cargo\"\nrustc=\"$(PREFIX)/$(BUILD)/bin/rustc\"\nrustdoc=\"$(PREFIX)/$(BUILD)/bin/rustdoc\"\n\n[target.i686-pc-windows-gnu]\nrustflags = [\"-C\",\"panic=abort\"]\ncc=\"i686-w64-mingw32.shared-gcc\"\ncxx=\"i686-w64-mingw32.shared-g++\"\nlinker=\"i686-w64-mingw32.shared-gcc\"\nar=\"i686-w64-mingw32.shared-ar\"\n\n[target.x86_64-pc-windows-gnu]\nrustflags = [\"-C\",\"panic=unwind\"]\ncc=\"x86_64-w64-mingw32.shared-gcc\"\ncxx=\"x86_64-w64-mingw32.shared-g++\"\nlinker=\"x86_64-w64-mingw32.shared-gcc\"\nar=\"x86_64-w64-mingw32.shared-ar\"\n"
endef


# I'm just leaving this here for now so I don't lose it in case it becomes useful in the future. I've pretty much given up on building the std library for our target, though.


# define $(PKG)_BUILD
# 	$(if $(PATCH_CARGO_CRATES), $(call $(PKG)_PATCH_CRATES))
# 	$(if $(BUILD_SHARED), $(call $(PKG)_PATCH_STATIC))
# 	rm $(MXE_TMP)/build 
# 	rm -rf $(MXE_TMP)/.cargo
# 	mkdir -p $(SOURCE_DIR)/.cargo
# 	mkdir -p $(BUILD_DIR)/bootstrap.build
# 	ln -sfn $(BUILD_DIR)/bootstrap.build $(MXE_TMP)/build
# 	printf $($(PKG)_CARGO_CONFIG_OPTS) >>  $(SOURCE_DIR)/.cargo/config
# 	cd $(BUILD_DIR); \
# 	$(SOURCE_DIR)/configure \
# 	--prefix=$(PREFIX)/libexec/rust-std/ \
# 	--sysconfdir=$(PREFIX)/$(TARGET)/etc \
# 	--enable-vendor \
# 	--default-linker=$(BUILD_CC) \
# 	--disable-codegen-tests \
# 	--disable-docs \
# 	--release-channel=stable \
# 	--llvm-root=$(PREFIX)/libexec/llvm-$(LLVM_VERSION) \
# 	--build=$(BUILD_TRIPLET) \
# 	--target=$(TARGET_TRIPLET) \
# 	--set=target.$(TARGET_TRIPLET).cc=$(TARGET)-gcc \
# 	--set=target.$(TARGET_TRIPLET).cxx=$(TARGET)-g++ \
# 	--set=target.$(TARGET_TRIPLET).linker=$(TARGET)-gcc \
# 	--set=target.$(TARGET_TRIPLET).crt-static=$(if $(BUILD_STATIC),true,false) \
# 	$(if $(BUILD_STATIC),--enable-cargo-native-static,) \
# 	--set=build.python=$(PYTHON2) \
# 	--local-rust-root=$(PREFIX)/$(BUILD) \
# 	--enable-local-rebuild
# 	CD $(BUILD_DIR); \
# 	$(PYTHON2) $(SOURCE_DIR)/src/bootstrap/bootstrap.py build -vv --config $(BUILD_DIR)/config.toml  -j$(JOBS) src/libstd --stage 2 --keep-stage 2
# 	CD $(BUILD_DIR); \
# 	$(PYTHON2) $(SOURCE_DIR)/src/bootstrap/bootstrap.py install -vv --config $(BUILD_DIR)/config.toml  -j1
# 	cp -Rvf $(BUILD_DIR)/bootstrap.build /opt/bootstrap.build.w32
# endef

define $(PKG)_BUILD_$(BUILD)
	$(if $(PATCH_CARGO_CRATES), $(call $(PKG)_PATCH_CRATES))
	mkdir -p $(BUILD_DIR)/bootstrap.build
	ln -sfn $(BUILD_DIR)/bootstrap.build $(MXE_TMP)/build
	mkdir -p $(PREFIX)/.cargo
	printf $($(PKG)_CARGO_CONFIG_OPTS) > $(PREFIX)/.cargo/config
	cd $(BUILD_DIR); \
	$(SOURCE_DIR)/configure \
	--prefix=$(PREFIX)/$(BUILD) \
	--sysconfdir=$(PREFIX)/$(BUILD)/etc \
	--enable-vendor \
	--default-linker=$(BUILD_CC) \
	--disable-codegen-tests \
	--disable-docs \
	--release-channel=stable \
	--llvm-root=$(PREFIX)/libexec/llvm-$(LLVM_VERSION) \
	--build=$(BUILD_TRIPLET) \
	$(if $(BUILD_STATIC),--enable-cargo-native-static,) \
	--set=build.python=$(PYTHON2) \
	--local-rust-root=$(MXE_TMP)/tmp-rust-stage0-$(BUILD_TRIPLET)
	CD $(BUILD_DIR); \
	$(PYTHON2) $(SOURCE_DIR)/src/bootstrap/bootstrap.py build -vv --config $(BUILD_DIR)/config.toml  -j$(JOBS) src/libstd src/rustc src/tools/cargo --stage 2
	CD $(BUILD_DIR); \
	$(PYTHON2) $(SOURCE_DIR)/src/bootstrap/bootstrap.py install -vv --config $(BUILD_DIR)/config.toml  -j1
	cp -Rvf $(BUILD_DIR)/bootstrap.build/$(BUILD)/stage2/bin/ $(PREFIX)/$(BUILD)/bin/
	cp -Rvf $(BUILD_DIR)/bootstrap.build/$(BUILD)/stage2/lib/ $(PREFIX)/$(BUILD)/lib/
	cp -Rvf $(BUILD_DIR)/bootstrap.build/$(BUILD)/stage2-tools-bin/ $(PREFIX)/$(BUILD)/bin/
	rm -Rvf $(MXE_TMP)/tmp-patched-cargo-deps $(MXE_TMP)/tmp-rust-stage0-$(BUILD_TRIPLET)
endef