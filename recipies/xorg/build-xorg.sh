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
#    File:    build-xorg.sh
#    Author:  Marvin Smith
#    Date:    8/18/2026
#
#    Purpose: Export the vendored xorg/system Conan recipe to the local cache.
#
#              xorg/system is a "system" recipe: it does not compile anything.
#              It declares X11 system dependencies and exposes them through
#              Conan so that packages like ffmpeg and OpenCV can link against
#              X11 libraries on Linux.  The vendored copy removes the obsolete
#              libXScrnSaver-devel package that the upstream conan-center recipe
#              still requests, making it usable on CentOS Stream 10 / EL10.
#
#              This script simply exports (and optionally uploads) the recipe.
#
#    Usage:    ./build-xorg.sh [-u]
#

set -euo pipefail

# shellcheck source=build-common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/build-common.sh"

# Package-specific constants
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly XORG_VERSION="${XORG_VERSION:-system}"

function usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Export the vendored xorg/system Conan recipe to the local cache.

Options:
  -r, --release      Ignored (system recipe has no build type).
  -d, --debug        Ignored (system recipe has no build type).
  -a, --all-configs  Ignored (system recipe has no build type).
  -u, --upload       Upload the recipe to the Conan remote.
  -h, --help         Show this help message.

Environment:
  XORG_VERSION       xorg version to export (default: ${XORG_VERSION})
  CONAN_REMOTE       Conan remote name (default: terminus-conan)

EOF
}

function build_xorg() {
    log_info "Exporting vendored xorg/${XORG_VERSION} recipe"
    conan export "${REPO_DIR}/recipies/xorg/all" --name=xorg --version="${XORG_VERSION}"
}

function main() {
    parse_common_args "$@"

    if ${SHOW_HELP}; then
        usage
        exit 0
    fi

    ensure_conan
    build_xorg

    upload_package "xorg/${XORG_VERSION}"

    log_info "xorg/${XORG_VERSION} export complete."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
