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
#    File:    build-common.sh
#    Author:  Marvin Smith
#    Date:    8/15/2026
#
#    Purpose: Common helpers for building vendored Conan packages in terminus_conan.

# This file is meant to be sourced, not executed directly.

set -euo pipefail

# Global constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Shared state (override in the calling script before parsing)
BUILD_TYPE="all"
UPLOAD=false
SHOW_HELP=false

function log_info() {
    echo "[INFO] $*" >&2
}

function log_error() {
    echo "[ERROR] $*" >&2
}

function host_os() {
    local uname_output
    uname_output="$(uname -s)"

    case "${uname_output}" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        CYGWIN* | MINGW* | MSYS*)
            echo "windows"
            ;;
        *)
            log_error "Unsupported host OS: ${uname_output}"
            exit 1
            ;;
    esac
}

function ensure_conan() {
    if ! command -v conan >/dev/null 2>&1; then
        local conan_venv
        conan_venv="${HOME}/conan/bin/activate"

        if [[ -f "${conan_venv}" ]]; then
            # shellcheck disable=SC1090
            source "${conan_venv}"
        else
            log_error "conan is not in PATH and no venv found at ${conan_venv}"
            exit 1
        fi
    fi

    log_info "Using conan: $(command -v conan)"
}

function conan_create() {
    local recipe_path
    recipe_path="$1"
    local version
    version="$2"
    local build_type
    build_type="$3"
    shift 3

    log_info "Creating ${recipe_path} --version ${version} -s build_type=${build_type}"

    conan create "${recipe_path}" \
        --version "${version}" \
        -s build_type="${build_type}" \
        -s compiler.cppstd=23 \
        -o "boost/*:shared=True" \
        "$@" \
        --build=missing
}

function upload_package() {
    local package_ref
    package_ref="$1"

    if ${UPLOAD}; then
        # Upload every package in the local cache, not just ${package_ref}.
        # A "conan create" build populates the cache with every dependency
        # it had to build from source (they aren't necessarily available as
        # prebuilt binaries on conancenter for our settings/options). If we
        # only uploaded the top-level package, those dependencies would need
        # to be rebuilt from scratch on every subsequent Docker build (the
        # build container's Conan cache is ephemeral).
        log_info "Uploading ${package_ref} and its dependencies to ${CONAN_REMOTE:-terminus-conan}"
        conan upload "*" -r "${CONAN_REMOTE:-terminus-conan}" -c
    fi
}

function parse_common_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r | --release)
                BUILD_TYPE="Release"
                ;;
            -d | --debug)
                BUILD_TYPE="Debug"
                ;;
            -a | --all-configs)
                BUILD_TYPE="all"
                ;;
            -u | --upload)
                UPLOAD=true
                ;;
            -h | --help)
                SHOW_HELP=true
                ;;
            *)
                break
                ;;
        esac
        shift
    done
}

function build_package_for_type() {
    local build_fn
    build_fn="$1"
    local build_type
    build_type="$2"

    ${build_fn} "${build_type}"
}
