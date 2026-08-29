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
#    File:    build-gdal-docker.sh
#    Author:  Marvin Smith
#    Date:    8/16/2026
#
#    Purpose: Build the vendored GDAL Conan package inside the
#              terminus-build-centos10 Docker image.

set -euo pipefail

# shellcheck source=build-common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/build-common.sh"

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

function usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Build the vendored GDAL Conan package inside the terminus-build-centos10 Docker image.

Options:
  -r, --release      Build Release only.
  -d, --debug        Build Debug only.
  -a, --all-configs  Build both Debug and Release (default).
  -u, --upload       Upload built packages to the Conan remote.
  -e, --env-file     Env file with Conan credentials (default: \${HOME}/.terminus/docker.env).
  -i, --image IMAGE  Docker image to use (default: terminus-build-centos10:latest).
  -h, --help         Show this help message.

Environment:
  GDAL_VERSION       GDAL version to build (default: 3.13.0)

EOF
}

function main() {
    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        usage
        exit 0
    fi

    exec "${REPO_DIR}/scripts/build-docker.sh" --only gdal "$@"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
