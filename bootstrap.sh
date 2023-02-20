#!/bin/bash -eu

ANSIBLE_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

usage() {
    cat << EOF
usage: $(basename "$0") [<options>]

-h <host>       Use config for <host>. Defaults to hostname.
-s <skip>       Ansible tags to skip (tag1,tag2,tag3).
EOF
}

main() {
    local config
    local playbook
    local skip

    config=$(uname -n)
    skip=""
    while getopts "hc:s:" arg; do
        case $arg in
        c)
            config="${OPTARG}"
            ;;
        s)
            skip="${OPTARG}"
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 0
            ;;
        esac
    done

    if ! ansible-playbook --version > /dev/null 2>&1; then
        echo "error: ansible missing" >&2
        exit 1
    fi

    playbook="${ANSIBLE_DIR}/${config}.yml"

    args=()

    if [ -n "${skip}" ]; then
        args+=(--skip-tags ${skip})
    fi

    args+=(-K "${playbook}")

    if [ -e "${playbook}" ]; then
        echo "Bootstrapping system ${config} using ${playbook}..."
        ansible-playbook "${args[@]}"
    else
        echo "error: no such config ${config}"
    fi
}

main "$@"