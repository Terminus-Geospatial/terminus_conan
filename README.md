# terminus_conan

Conan packages helpful for building core Terminus dependencies.

## Recipes

- `recipies/opencv` — OpenCV recipe vendored from [conan-center-index](https://github.com/conan-io/conan-center-index).
- `recipies/gdal` — GDAL recipe vendored from [conan-center-index](https://github.com/conan-io/conan-center-index).

## Dependency Versions

Resolved dependency graphs for `opencv/4.14.0` (Linux/CentOS Stream 10 build,
see `recipies/opencv/build-opencv.sh`) and `gdal/3.13.0` (see
`recipies/gdal/build-gdal.sh`), captured from actual `conan create` runs.
Packages required by both recipes must resolve to the same version to avoid a
Conan graph conflict (see the OpenCV `libpng`/Qt5 conflict discovered earlier
in this project as an example of what this looks like when it goes wrong). A
`-` means the package isn't in that recipe's graph. Versions here reflect what
conancenter's version ranges currently resolve to and will drift over time as
conancenter publishes new revisions -- re-run the builds and refresh this
table if a conflict is suspected.

| Package | OpenCV | GDAL |
| :--- | :--- | :--- |
| abseil | 20260107.1 | - |
| autoconf (build) | 2.71 | 2.71 |
| automake (build) | 1.16.5 | 1.16.5 |
| brotli | 1.1.0 | - |
| bzip2 | 1.0.8 | - |
| cmake (build) | 4.4.2 | 4.4.2 / 3.31.12* |
| cpuinfo | cci.20251210 | - |
| dav1d | 1.5.4 | - |
| eigen | 3.4.0 | - |
| ffmpeg | 7.1.5 | - |
| flac | 1.4.2 | - |
| freetype | 2.13.2 | - |
| giflib | 5.2.1 | - |
| gnu-config (build) | cci.20210814 | cci.20210814 |
| json-c | - | 0.17 |
| leptonica | 1.87.0 | - |
| libalsa | 1.2.10 | - |
| libaom-av1 | 3.13.3 | - |
| libarchive | 3.7.9 | - |
| libcap | 2.78 | - |
| libcurl | 8.21.0 | 8.21.0 |
| libdrm | 2.4.119 | - |
| libfdk_aac | 2.0.3 | - |
| libgeotiff | - | 1.7.1 |
| libiconv | 1.17 | - |
| libjpeg | 9f | 9f |
| libmp3lame | 3.100 | - |
| libpng | 1.6.58 | 1.6.58 |
| libsndfile | 1.2.2 | - |
| libsvtav1 | 2.1.0 | - |
| libtiff | 4.7.2 | 4.7.2 |
| libtool (build) | 2.4.7 | 2.4.7 |
| libvpx | 1.16.0 | - |
| libwebp | 1.6.0 | - |
| libx264 | cci.20250910 | - |
| libx265 | 3.6 | - |
| m4 (build) | 1.4.19 | 1.4.19 |
| meson (build) | 1.10.2 | 1.10.2 |
| mpg123 | 1.33.0 | - |
| ninja (build) | 1.13.2 | 1.13.2 |
| nlohmann_json | - | 3.11.3 |
| ogg | 1.3.5 | - |
| opencl-clhpp-headers | - | 2023.12.14 |
| opencl-headers | - | 2023.12.14 |
| opencl-icd-loader | - | 2023.12.14 |
| openh264 | 2.6.0 | - |
| openjpeg | 2.5.4 | - |
| openssl | 3.6.3 | 3.6.3 |
| opus | 1.6.1 | - |
| pkgconf (build) | 2.0.3 / 2.1.0 / 2.5.1* | 2.5.1 |
| proj | - | 9.3.1 |
| protobuf | 7.35.0 | - |
| pulseaudio | 14.2 | - |
| quirc | 1.2 | - |
| sqlite3 | - | 3.53.4 |
| tesseract | 5.5.2 | - |
| vaapi | system | - |
| vorbis | 1.3.7 | - |
| xz_utils | 5.8.3 | 5.8.3 |
| zlib | 1.3.2 | 1.3.2 |

\* Some dependencies pull in more than one version of a build-only tool
(e.g. an older `cmake`/`pkgconf` required by a specific sub-dependency).
Build requirements can coexist at multiple versions since they aren't linked
into the final binary, so this is not a conflict.

## Notes

The following packages are worth watching closely for version conflicts with
the main Terminus packages, since they're either shared between OpenCV/GDAL
or commonly pinned elsewhere in the Terminus stack: `libtiff`, `libgeotiff`,
`libpng`, `libjpeg`, `libwebp`, `zlib`, `eigen`, `libcurl`, `openssl`, `proj`,
`geos`, `sqlite3`.

As of the versions captured above, `libwebp`, `eigen`, `libgeotiff`, `proj`,
and `sqlite3` are each only pulled in by one of OpenCV or GDAL (not both), and
`geos` isn't in either graph (`with_geos=False` in `build-gdal.sh`), so there
is currently no cross-recipe conflict for those. Update this note if that
changes.
