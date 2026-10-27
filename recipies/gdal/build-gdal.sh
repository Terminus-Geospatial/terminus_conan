#!/usr/bin/env bash
#
############################# INTELLECTUAL PROPERTY RIGHTS ############################
##                                                                                    ##
##                           Copyright (c) 2024 Terminus LLC                          ##
##                                All Rights Reserved.                                ##
##                                                                                    ##
##          Use of this source code is governed by LICENSE in the repo root.          ##
##                                                                                    ##
############################# INTELLECTUAL PROPERTY RIGHTS ############################
#
#    File:    build-gdal.sh
#    Author:  Marvin Smith
#    Date:    8/15/2026
#
#    Purpose: Build the vendored GDAL Conan package locally.

set -euo pipefail

# shellcheck source=build-common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/build-common.sh"

# Package-specific constants
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly GDAL_VERSION="${GDAL_VERSION:-3.13.0}"

# GDAL conan options populated by configure_gdal_options.
GDAL_OPTIONS=()

function usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Build the vendored GDAL Conan package locally.

Options:
  -r, --release      Build Release only.
  -d, --debug        Build Debug only.
  -a, --all-configs  Build both Debug and Release (default).
  -u, --upload       Upload built packages to the Conan remote.
  -h, --help         Show this help message.

Environment:
  GDAL_VERSION       GDAL version to build (default: ${GDAL_VERSION})
  CONAN_REMOTE       Conan remote name (default: terminus-conan)

EOF
}

function configure_gdal_options() {
    # Options common to all supported platforms.
    #
    # with_sqlite3 is intentionally left at the recipe's default (True):
    # proj is an unconditional GDAL dependency and always pulls in sqlite3,
    # but the recipe only sets the SQLite3_HAS_COLUMN_METADATA/HAS_RTREE/etc.
    # CMake cache variables GDAL's CheckDependentLibraries.cmake expects when
    # with_sqlite3=True. Disabling it here caused a
    # "missing SQLite3_HAS_COLUMN_METADATA" CMake configure error even
    # though sqlite3 was still present in the graph via proj.
    # The recipe's default_options define the heavy GDAL configuration.
    # We only override shared=True (the recipe defaults to static) and
    # skip the test-package step.
    GDAL_OPTIONS=(
        "-o" "&:shared=True"
        '--test-folder='
    )

    # Add platform-specific options here when they become necessary.
    # The host_os helper is already available from build-common.sh.
    case "$(host_os)" in
        macos)
            :
            ;;
        linux)
            :
            ;;
        windows)
            :
            ;;
    esac
}

function build_gdal() {
    local build_type
    build_type="$1"

    log_info "Building GDAL ${GDAL_VERSION} (${build_type})"

    conan_create \
        "${REPO_DIR}/recipies/gdal/post_3.5.0" \
        "${GDAL_VERSION}" \
        "${build_type}" \
        "${GDAL_OPTIONS[@]}"
}

function main() {
    parse_common_args "$@"

    if ${SHOW_HELP}; then
        usage
        exit 0
    fi

    ensure_conan
    configure_gdal_options

    if [[ "${BUILD_TYPE}" == "all" ]]; then
        build_package_for_type build_gdal "Debug"
        build_package_for_type build_gdal "Release"
    else
        build_package_for_type build_gdal "${BUILD_TYPE}"
    fi

    upload_package "gdal/${GDAL_VERSION}"

    log_info "GDAL build complete."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
