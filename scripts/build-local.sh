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
#    File:    build-local.sh
#    Author:  Marvin Smith
#    Date:    8/15/2026
#
#    Purpose: Convenience wrapper to build both OpenCV and GDAL locally.
#              Also supports building only one of them via --only.

set -euo pipefail

# shellcheck source=build-common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/build-common.sh"

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ONLY=""

function usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Build the vendored OpenCV and GDAL Conan packages locally.

Options:
  -r, --release      Build Release only.
  -d, --debug        Build Debug only.
  -a, --all-configs  Build both Debug and Release (default).
  -u, --upload       Upload built packages to the Conan remote.
  --only PACKAGE     Build only 'opencv' or 'gdal'.
  -h, --help         Show this help message.

Environment:
  OPENCV_VERSION     OpenCV version to build (default: 4.14.0)
  GDAL_VERSION       GDAL version to build (default: 3.13.0)
  CONAN_REMOTE       Conan remote name (default: terminus-conan)

EOF
}

function parse_command_line() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --only)
                if [[ -n "${2:-}" ]]; then
                    ONLY="$2"
                    shift
                else
                    log_error "${1} requires an argument."
                    usage
                    exit 1
                fi
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    parse_common_args "$@"
}

function main() {
    parse_command_line "$@"

    if ${SHOW_HELP}; then
        usage
        exit 0
    fi

    ensure_conan

    local build_local_args
    build_local_args=()
    [[ "${BUILD_TYPE}" != "Release" ]] && build_local_args+=("-${BUILD_TYPE:0:1}")
    ${UPLOAD} && build_local_args+=("-u")

    if [[ -z "${ONLY}" || "${ONLY}" == "opencv" ]]; then
        log_info "Building OpenCV..."
        "${REPO_DIR}/recipies/opencv/build-opencv.sh" "${build_local_args[@]}"
    fi

    if [[ -z "${ONLY}" || "${ONLY}" == "gdal" ]]; then
        log_info "Building GDAL..."
        "${REPO_DIR}/recipies/gdal/build-gdal.sh" "${build_local_args[@]}"
    fi

    log_info "All local builds complete."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
