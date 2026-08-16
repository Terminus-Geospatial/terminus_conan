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
#    File:    build-docker.sh
#    Author:  Marvin Smith
#    Date:    8/15/2026
#
#    Purpose: Build the vendored OpenCV and GDAL Conan packages inside the
#              terminus-build-centos10 Docker image.

set -euo pipefail

# Global constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

readonly DEFAULT_BUILD_IMAGE="terminus-build-centos10:latest"
readonly DEFAULT_ENV_FILE="${HOME}/.terminus/docker.env"

BUILD_IMAGE="${TERMINUS_BUILD_IMAGE:-${DEFAULT_BUILD_IMAGE}}"
ENV_FILE="${DEFAULT_ENV_FILE}"

function log_info() {
    echo "[INFO] $*" >&2
}

function log_error() {
    echo "[ERROR] $*" >&2
}

function usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS] [build-local.sh options]

Build the vendored OpenCV and GDAL Conan packages inside the
${BUILD_IMAGE} Docker image.

Options:
  -e, --env-file PATH  Env file with Conan credentials (default: ${DEFAULT_ENV_FILE}).
  -i, --image IMAGE    Docker image to use (default: ${BUILD_IMAGE}).
  -h, --help           Show this help message.

All other options are passed through to build-local.sh.

EOF
}

function parse_command_line() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -e | --env-file)
                if [[ -n "${2:-}" ]]; then
                    ENV_FILE="$2"
                    shift
                else
                    log_error "${1} requires a path argument."
                    usage
                    exit 1
                fi
                ;;
            -i | --image)
                if [[ -n "${2:-}" ]]; then
                    BUILD_IMAGE="$2"
                    shift
                else
                    log_error "${1} requires an image argument."
                    usage
                    exit 1
                fi
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    BUILD_LOCAL_ARGS=("$@")
}

function validate_environment() {
    if ! command -v docker >/dev/null 2>&1; then
        log_error "docker is not installed or not in PATH."
        exit 1
    fi

    if [[ ! -f "${ENV_FILE}" ]]; then
        log_error "Environment file not found: ${ENV_FILE}"
        exit 1
    fi
}

function main() {
    parse_command_line "$@"
    validate_environment

    log_info "Running build in ${BUILD_IMAGE} for ${REPO_DIR}"

    docker run --rm \
        --env-file "${ENV_FILE}" \
        -v "${REPO_DIR}:/src" \
        -w "/src" \
        "${BUILD_IMAGE}" \
        bash -c "chmod +x /src/scripts/build-local.sh && /src/scripts/build-local.sh ${BUILD_LOCAL_ARGS[*]}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
