# terminus_conan

Conan packages helpful for building core Terminus dependencies.

## Recipes

- `recipies/opencv` — OpenCV recipe vendored from [conan-center-index](https://github.com/conan-io/conan-center-index).
- `recipies/gdal` — GDAL recipe vendored from [conan-center-index](https://github.com/conan-io/conan-center-index).

## Notes

The following recipes may also need to be vendored/pinned to avoid version
conflicts with the main Terminus packages (e.g. `libtiff`, `libgeotiff`,
`libpng`, `libjpeg`, `libwebp`, `zlib`, `eigen`, `libcurl`, `openssl`, `proj`,
`geos`, `sqlite3`):

- `libtiff`
- `libgeotiff`
- `libpng`
- `libjpeg`
- `libwebp`
- `zlib`
- `eigen`
- `libcurl`
- `openssl`
- `proj`
- `geos`
- `sqlite3`

This list is a starting point; update it as dependency conflicts are discovered
or resolved.
