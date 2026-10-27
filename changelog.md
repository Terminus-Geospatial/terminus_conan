# Changelog

All notable changes to `terminus_conan` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.0]

### Changed

- `recipies/gdal/build-gdal.sh` now defers to the recipe's `default_options` for the heavy feature set instead of disabling Arrow, curl, expat, GEOS, libdeflate, libarchive, qhull, and other drivers one by one. The script only overrides `shared=True` and skips the test package, producing a feature-rich GDAL by default.
- `recipies/opencv/build-opencv.sh` re-enables `photo`, `stitching`, and `gapi`, matching the recipe's mandatory-option resolution so the packaged component metadata (`opencv_photo`, `opencv_stitching`, `opencv_gapi`) always has libraries behind it.
- `scripts/build-common.sh`'s `conan_create()` now passes `tools.cmake.cmaketoolchain:extra_variables={"CMAKE_POLICY_VERSION_MINIMUM":"3.5"}` so older vendored recipes configure cleanly under newer CMake.

### Fixed

- `.gitignore` now excludes `.DS_Store` and `.vscode/`.

## [0.0.3]

### Changed

- Pinned vendored OpenCV's ffmpeg dependency to `ffmpeg/7.1.5`.
- Switched ffmpeg hardware acceleration from the X11 path to DRM/GBM (`with_vaapi=True`, `with_libdrm=True`; `with_xcb`/`with_xlib`/`with_vdpau=False`). This removes the `xorg/system` dependency and the EL10 `libXScrnSaver-devel` issue.
- Replaced X11/XCB devel packages in `Dockerfile.build` with `libva-devel` and `libdrm-devel`.
- Updated Docker runtime/README notes and `terminus_conan/README.md` dependency table for the no-X11 ffmpeg configuration.

## [0.0.2]

### Added

- Added `recipies/xorg/all/conanfile.py`, a vendored/patched copy of conan-center-index's `xorg/system` recipe that drops `libXScrnSaver-devel` from the `dnf`/`yum` install lists, since that package no longer exists on EL10. `build-opencv.sh` exports this recipe before building so it takes precedence over conancenter's copy.
- Added `recipies/gdal/build-gdal-docker.sh`, mirroring `recipies/opencv/build-opencv-docker.sh`, to build GDAL inside the `terminus-build-centos10` Docker image.
- Added a `## Dependency Versions` table to `README.md` listing every resolved package version from the OpenCV and GDAL dependency graphs side by side, to make cross-recipe version conflicts easy to spot.

### Changed

- `scripts/build-common.sh`'s `upload_package()` now uploads every package in the local Conan cache (`conan upload "*"`) instead of only the top-level recipe. Previously, only `opencv/x.y.z` or `gdal/x.y.z` itself was pushed to `terminus-conan`, so every dependency built from source (ffmpeg, tesseract, proj, sqlite3, etc.) had to be rebuilt from scratch on every subsequent Docker build, since the build container's Conan cache is ephemeral.
- `recipies/opencv/build-opencv.sh`: on Linux, `with_qt` is disabled (Qt5 on conan-center pins `libpng/1.6.42`, conflicting with the `libpng/[>=1.6 <2]` range resolved elsewhere in the graph); `with_xcb`/`with_xlib` are enabled for `ffmpeg` so its VAAPI/VDPAU hardware-accel code (which links against X11 regardless of those options) is declared correctly in the Conan package metadata.
- `recipies/gdal/build-gdal.sh`: removed the `with_sqlite3=False` override. GDAL's `proj` dependency always requires `sqlite3`, but the recipe only sets the `SQLite3_HAS_COLUMN_METADATA`/`SQLite3_HAS_RTREE`/etc. CMake cache variables when `with_sqlite3=True`, so disabling it caused a `missing SQLite3_HAS_COLUMN_METADATA` CMake configure error.

### Fixed

- Fixed the OpenCV Docker build failing on the `xorg/system` recipe's `libXScrnSaver-devel` dependency (see the vendored `xorg` recipe above).
- Fixed `ninja`'s Conan build failing with `cannot find -lstdc++` in the CentOS Stream 10 build image (`libstdc++-static` wasn't installed; `libstdc++-devel`/`gcc-c++` only provide the shared library).

## [0.0.1] - 2026-08-15

### Added

- Initial recipe structure: `recipies/opencv` (2.x/3.x/4.x, vendored from conan-center-index) and `recipies/gdal` (`post_3.5.0`, vendored from conan-center-index).
- `scripts/build-common.sh`, `scripts/build-local.sh`, and `scripts/build-docker.sh` shared build helpers.
- `recipies/opencv/build-opencv.sh` and `recipies/opencv/build-opencv-docker.sh` to build OpenCV locally or inside the Terminus build Docker image.
- `recipies/gdal/build-gdal.sh` to build GDAL locally.
- `README.md` documenting the vendored recipes and packages to watch for cross-recipe version conflicts.
