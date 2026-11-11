#!/bin/bash
# Build libass and the libraries it needs — FreeType, FriBidi, HarfBuzz — as
# static libraries for one Apple platform slice. Called by build-ffmpeg.sh;
# the libraries are merged into libffmpeg.a next to FFmpeg's own, and libass's
# headers ship in the artifact under aether_ffmpeg/ass/.
#
# Usage: build-libass.sh <platform-id>   (see platforms.sh for ids)
#
# Output: build/src/<name>-<version>-<platform>/prefix/{include,lib} for
# freetype, fribidi, harfbuzz and libass.
#
# Licences (see THIRD-PARTY-NOTICES.md): libass ISC, FreeType under the
# FreeType License (its BSD-style option, not GPLv2), HarfBuzz MIT ("Old
# MIT"), FriBidi LGPL-2.1+ — none GPL, so the artifact stays LGPL.
#
# Fonts come from the system through libass's Core Text provider; no
# fontconfig. Every optional feature that would pull in another library
# (PNG, zlib, brotli, ICU, GLib, Cairo, Graphite) is off.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/platforms.sh"

PLATFORM="${1:?usage: build-libass.sh <platform-id>}"
platform_env "$PLATFORM"

for tool in meson ninja; do
    command -v "$tool" >/dev/null || { echo "$tool is required (brew install meson ninja)" >&2; exit 1; }
done

version() { python3 -c "import json;print(json.load(open('$BUILD_DIR/versions.json'))['$1']['version'])"; }

case "$FF_ARCH" in
    arm64)  CPU_FAMILY=aarch64 ;;
    x86_64) CPU_FAMILY=x86_64 ;;
esac
# Same reasoning as build-dav1d.sh: `system` stays darwin for every slice.
case "$SDK" in
    macosx)                     SUBSYSTEM=macos ;;
    iphoneos|iphonesimulator)   SUBSYSTEM=ios ;;
    appletvos|appletvsimulator) SUBSYSTEM=tvos ;;
    xros|xrsimulator)           SUBSYSTEM=visionos ;;
esac

CC="$(xcrun --sdk "$SDK" -f clang)"
CXX="$(xcrun --sdk "$SDK" -f clang++)"
AR="$(xcrun --sdk "$SDK" -f ar)"
STRIP="$(xcrun --sdk "$SDK" -f strip)"

# Prefixes of the libraries built so far for this slice; each later one finds
# the earlier ones through pkg-config, and only those (never Homebrew's).
PKG_DIRS=()

build_one() { # build_one <versions.json key> <tarball basename prefix> <meson options...>
    local key="$1" stem="$2"; shift 2
    local ver; ver="$(version "$key")"
    local src="$BUILD_DIR/src/${key}-${ver}-${PLATFORM}"
    # Not "install": several tarballs ship an INSTALL file, and macOS volumes
    # are case-insensitive.
    local prefix="$src/prefix"
    local tarball
    tarball="$(ls "$BUILD_DIR/${stem}-${ver}".tar.* 2>/dev/null | head -1)"
    [ -n "$tarball" ] || { echo "missing $BUILD_DIR/${stem}-${ver}.tar.* (run fetch-sources.sh)" >&2; exit 1; }

    echo "==> ${key} ${ver} for ${PLATFORM}"
    rm -rf "$src" && mkdir -p "$src"
    tar -xf "$tarball" -C "$src" --strip-components=1

    local cross="$src/cross.ini"
    cat > "$cross" <<EOF
[binaries]
c = '$CC'
cpp = '$CXX'
objc = '$CC'
ar = '$AR'
strip = '$STRIP'
nasm = '$(command -v nasm || echo nasm)'
pkg-config = '$(command -v pkg-config || echo pkg-config)'

[built-in options]
c_args = ['-target', '$TARGET', '-isysroot', '$SYSROOT', '-fno-stack-check']
cpp_args = ['-target', '$TARGET', '-isysroot', '$SYSROOT', '-fno-stack-check']
objc_args = ['-target', '$TARGET', '-isysroot', '$SYSROOT']
c_link_args = ['-target', '$TARGET', '-isysroot', '$SYSROOT']
cpp_link_args = ['-target', '$TARGET', '-isysroot', '$SYSROOT']

[host_machine]
system = 'darwin'
subsystem = '$SUBSYSTEM'
cpu_family = '$CPU_FAMILY'
cpu = '$FF_ARCH'
endian = 'little'
EOF

    local libdir_path
    libdir_path="$(IFS=:; echo "${PKG_DIRS[*]:-}")"
    PKG_CONFIG_LIBDIR="$libdir_path" PKG_CONFIG_PATH="" \
    meson setup "$src/build" "$src" \
        --cross-file "$cross" \
        --prefix "$prefix" \
        --libdir lib \
        --buildtype release \
        --default-library static \
        --wrap-mode nodownload \
        "$@" \
        > "$BUILD_DIR/configure-${key}-$PLATFORM.log" 2>&1 || {
            echo "meson setup failed — tail of log:"; tail -40 "$BUILD_DIR/configure-${key}-$PLATFORM.log"; exit 1; }

    ninja -C "$src/build" install > "$BUILD_DIR/make-${key}-$PLATFORM.log" 2>&1 || {
        echo "ninja failed — tail of log:"; tail -40 "$BUILD_DIR/make-${key}-$PLATFORM.log"; exit 1; }

    PKG_DIRS+=("$prefix/lib/pkgconfig")
}

build_one freetype freetype \
    -Dbrotli=disabled -Dbzip2=disabled -Dharfbuzz=disabled -Dpng=disabled \
    -Dzlib=disabled -Dtests=disabled -Dmmap=enabled -Dhvf=disabled

build_one fribidi fribidi \
    -Ddocs=false -Dbin=false -Dtests=false -Ddeprecated=false

build_one harfbuzz harfbuzz \
    -Dfreetype=enabled -Dglib=disabled -Dgobject=disabled -Dcairo=disabled \
    -Dchafa=disabled -Dpng=disabled -Dzlib=disabled -Dicu=disabled \
    -Dgraphite=disabled -Dgraphite2=disabled -Dfontations=disabled \
    -Dgdi=disabled -Ddirectwrite=disabled -Dcoretext=disabled -Dharfrust=disabled \
    -Dkbts=disabled -Dwasm=disabled -Draster=disabled -Dvector=disabled \
    -Dgpu=disabled -Dgpu_demo=disabled -Dsubset=disabled -Dtests=disabled \
    -Dintrospection=disabled -Ddocs=disabled -Ddoc_tests=false \
    -Dutilities=disabled -Dbenchmark=disabled

# Assembly: NEON on arm64; x86_64 needs nasm, which the dav1d build already
# requires for those slices.
build_one libass libass \
    -Dfontconfig=disabled -Ddirectwrite=disabled -Dcoretext=enabled \
    -Dlibunibreak=disabled -Dasm=enabled -Drequire-system-font-provider=true \
    -Dtest=disabled -Dcompare=disabled -Dprofile=disabled -Dfuzz=disabled \
    -Dcheckasm=disabled

echo "==> libass stack installed for ${PLATFORM}"
