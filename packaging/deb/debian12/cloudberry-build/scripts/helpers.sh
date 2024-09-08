#!/bin/bash

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            --email)
            EMAIL="$2"
            shift # past argument
            shift # past value
            ;;
            --fullname)
            FULLNAME="$2"
            shift # past argument
            shift # past value
            ;;
            --enter-chroot)
            ENTER_CHROOT=true
            shift # past argument
            ;;
            --list-chroots)
            list_chroots
            exit 0
            ;;
            *)    # unknown option
            echo "Unknown option: $1"
            exit 1
            ;;
        esac
    done
}

install_dependencies() {
    # Implementation here
}

setup_sbuild_environment() {
    # Implementation here
}

download_and_extract_source() {
    # Implementation here
}

prepare_chroot_environment() {
    # Implementation here
}

generate_debian_files() {
    generate_control_file
    generate_rules_file
    generate_changelog
}

build_package() {
    # Implementation here
}

list_chroots() {
    echo "Available chroots:"
    schroot -l | grep -v "^union/"
}            shift # ple() {
    envsubst < "$(dirname "$0")/../templates/control.template" > "$(dirname "$0")/../generated/control"
}

generate_rules_file() {
    cp "$(dirname "$0")/../templates/rules.template" "$(dirname "$0")/../generated/rules"
    chmod +x "$(dirname "$0")/../generated/rules"
}

generate_changelog() {
    VERSION=$(get_latest_version)
    envsubst < "$(dirname "$0")/../templates/changelog.template" > "$(dirname "$0")/../generated/change            exit 1
version() {
    curl --silent "https://api.github.com/repos/cloudberrydb/cloudberrydb/releases/latest" | 
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}
