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
#    File:    build-xorg-docker.sh
#    Author:  Marvin Smith
#    Date:    8/18/2026
#
#    Purpose: Export the vendored xorg/system Conan recipe inside the
#              terminus-build-centos10 Docker image.
#

set -euo pipefail

# shellcheck source=build-common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/build-common.sh"

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

function usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Export the vendored xorg/system Conan recipe inside the terminus-build-centos10 Docker image.

Options:
  -u, --upload       Upload the recipe to the Conan remote.
  -e, --env-file     Env file with Conan credentials (default: \${HOME}/.terminus/docker.env).
  -i, --image IMAGE  Docker image to use (default: terminus-build-centos10:latest).
  -h, --help         Show this help message.

Environment:
  XORG_VERSION       xorg version to export (default: system)

EOF
}

function main() {
    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        usage
        exit 0
    fi

    exec "${REPO_DIR}/scripts/build-docker.sh" --only xorg "$@"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
