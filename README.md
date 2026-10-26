# AetherFFmpeg

Prebuilt FFmpeg 9.0.1 (with dav1d 1.5.4) as a static `FFmpeg.xcframework` for
AetherEngine, the playback engine in the Aether IPTV player. Each GitHub release
carries one `FFmpeg.xcframework.zip`, which Swift Package Manager downloads as a
binary target.

## What's in the binary

- FFmpeg 9.0.1 from <https://ffmpeg.org/releases/ffmpeg-9.0.1.tar.xz>
  (SHA-256 checked against `build/versions.json`).
- dav1d 1.5.4 from <https://downloads.videolan.org/pub/videolan/dav1d/1.5.4/>,
  for software AV1 decoding.
- One patch, `build/patches/0001-visionos-videotoolbox-no-opengles.patch`: on
  visionOS, VideoToolbox asks for Metal-compatible pixel buffers, because the
  OpenGL ES keys don't exist there. Other platforms are unchanged.
- Licensed LGPL only (no `--enable-gpl`, no `--enable-nonfree`). Decoders and
  demuxers only, no encoders or muxers.
- Slices: macOS (arm64 + x86_64), iOS, tvOS and visionOS devices (arm64), and
  their simulators. Minimum versions are macOS 15, iOS/tvOS 18 and visionOS 2;
  see `build/scripts/platforms.sh`.
- Headers live under `aether_ffmpeg/`. Small C shims named `aether_*` live in
  `build/support/CFFmpegShim.h`.

## Build it yourself

Requires Xcode, `meson`, `ninja` and `nasm` (`brew install meson ninja nasm`).

```bash
build/scripts/fetch-sources.sh
(source build/scripts/platforms.sh
 for p in "${ALL_PLATFORMS[@]}"; do build/scripts/build-ffmpeg.sh "$p"; done)
build/scripts/make-xcframework.sh     # writes BinaryDependencies/FFmpeg.xcframework
(cd BinaryDependencies && ditto -c -k --keepParent FFmpeg.xcframework FFmpeg.xcframework.zip)
swift package compute-checksum BinaryDependencies/FFmpeg.xcframework.zip
```

A full build of all ten slices takes about 35 minutes on an Apple-silicon Mac.

## Licenses

FFmpeg is LGPL-2.1-or-later (`licenses/FFmpeg-COPYING.LGPLv2.1`,
`licenses/FFmpeg-LICENSE.md`). dav1d is BSD-2-Clause (`licenses/dav1d-COPYING`).
This repository contains the corresponding source: the upstream tarballs it
names, plus the patch and the build scripts. The build scripts are MIT, like
AetherEngine.
