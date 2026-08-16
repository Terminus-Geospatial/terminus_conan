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
#    File:    build-opencv.sh
#    Author:  Marvin Smith
#    Date:    8/15/2026
#
#    Purpose: Build the vendored OpenCV Conan package locally.

set -euo pipefail

# shellcheck source=build-common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/build-common.sh"

# Package-specific constants
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly OPENCV_VERSION="${OPENCV_VERSION:-4.14.0}"

# OpenCV conan options populated by configure_opencv_options.
OPENCV_OPTIONS=()

function usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Build the vendored OpenCV Conan package locally.

Options:
  -r, --release      Build Release only.
  -d, --debug        Build Debug only.
  -a, --all-configs  Build both Debug and Release (default).
  -u, --upload       Upload built packages to the Conan remote.
  -h, --help         Show this help message.

Environment:
  OPENCV_VERSION     OpenCV version to build (default: ${OPENCV_VERSION})
  CONAN_REMOTE       Conan remote name (default: terminus-conan)

EOF
}

function configure_opencv_options() {
    local os
    os="$(host_os)"

    # Options common to all supported platforms.
    OPENCV_OPTIONS=(
        "-o" "&:shared=True"
        "-o" "&:text=True"
        "-o" "&:photo=False"
        "-o" "&:stitching=False"
        "-o" "&:gapi=False"
        "-o" "&:with_openexr=False"
        "-o" "&:with_webp=False"
        "-o" "&:with_jpeg2000=False"
        "-o" "&:with_ffmpeg=True"
        "-o" "&:with_tesseract=True"
        "-o" "&:with_quirc=True"
        '--test-folder='
    )

    # Platform-specific GUI/highgui backend choices.
    # Note: the OpenCV conanfile deletes with_gtk and with_wayland on all
    # platforms except Linux, so we must only set them on Linux.
    case "${os}" in
        macos)
            # macOS highgui builds against the Cocoa framework by default.
            # Qt is also supported but pulling the Qt Conan package adds a very
            # large build, so it is disabled by default on macOS. Flip this to
            # True if you need Qt support on macOS.
            OPENCV_OPTIONS+=("-o" "&:with_qt=False")
            ;;
        linux)
            # Qt5 on conan-center pins libpng/1.6.42, which conflicts with the
            # libpng/[>=1.6 <2] range resolved to 1.6.58 elsewhere in the graph.
            # Build a headless highgui for now and revisit Qt6 later.
            # TODO: Switch to Qt6 once a stable conan-center Qt6 recipe is available.
            # ffmpeg's with_vaapi/with_vdpau defaults require libva-devel and
            # libvdpau-devel, which the CentOS Stream 10 build image installs
            # via CRB. with_xcb/with_xlib (X11 screen-grab support, not needed
            # headless) and pulseaudio's with_x11 (pulled in via
            # ffmpeg's with_pulse) are disabled because they pull
            # xorg/system, which requests libXScrnSaver-devel -- a package no
            # longer available on EL10.
            OPENCV_OPTIONS+=(
                "-o" "&:with_qt=False"
                "-o" "&:with_gtk=False"
                "-o" "&:with_wayland=False"
                "-o" "ffmpeg/*:with_xcb=False"
                "-o" "ffmpeg/*:with_xlib=False"
                "-o" "pulseaudio/*:with_x11=False"
            )
            ;;
        windows)
            # Windows highgui can use Qt or the native Win32 API.
            OPENCV_OPTIONS+=("-o" "&:with_qt=True")
            ;;
    esac
}

function build_opencv() {
    local build_type
    build_type="$1"

    log_info "Building OpenCV ${OPENCV_VERSION} (${build_type})"

    conan_create \
        "${REPO_DIR}/recipies/opencv/4.x" \
        "${OPENCV_VERSION}" \
        "${build_type}" \
        "${OPENCV_OPTIONS[@]}"
}

function main() {
    parse_common_args "$@"

    if ${SHOW_HELP}; then
        usage
        exit 0
    fi

    ensure_conan
    configure_opencv_options

    if [[ "${BUILD_TYPE}" == "all" ]]; then
        build_package_for_type build_opencv "Debug"
        build_package_for_type build_opencv "Release"
    else
        build_package_for_type build_opencv "${BUILD_TYPE}"
    fi

    upload_package "opencv/${OPENCV_VERSION}"

    log_info "OpenCV build complete."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
