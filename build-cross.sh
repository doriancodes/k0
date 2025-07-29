#!/bin/bash
set -e

# === Config ===
ROOT_DIR=$(pwd)/cross-compilation
SRC_DIR=$ROOT_DIR/src
BUILD_BINUTILS=$ROOT_DIR/build-binutils
BUILD_GCC=$ROOT_DIR/build-gcc
PREFIX=$ROOT_DIR/cross-compiler
TARGET=i686-elf
PATH="$PREFIX/bin:$PATH"

# === Dependencies Check (Fedora example) ===
echo "⚠️  Make sure you have: gmp-devel mpfr-devel libmpc-devel zlib-devel isl-devel"

# === Create directories ===
mkdir -p "$SRC_DIR" "$BUILD_BINUTILS" "$BUILD_GCC"

# === Download sources ===
cd "$SRC_DIR"

[ ! -f binutils.tar.xz ] && wget -O binutils.tar.xz https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.xz
[ ! -f gcc.tar.xz ] && wget -O gcc.tar.xz https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz

[ ! -d binutils-2.42 ] && tar -xf binutils.tar.xz
[ ! -d gcc-13.2.0 ] && tar -xf gcc.tar.xz

# === Build binutils ===
cd "$BUILD_BINUTILS"
"$SRC_DIR/binutils-2.42/configure" \
  --target=$TARGET \
  --prefix=$PREFIX \
  --with-sysroot \
  --disable-nls \
  --disable-werror
make -j$(nproc)
make install

# === Build gcc ===
cd "$BUILD_GCC"
"$SRC_DIR/gcc-13.2.0/configure" \
  --target=$TARGET \
  --prefix=$PREFIX \
  --disable-nls \
  --enable-languages=c \
  --without-headers
make all-gcc -j$(nproc)
make all-target-libgcc -j$(nproc)
make install-gcc
make install-target-libgcc

echo "✅ Cross-compiler built at: $PREFIX/bin"
