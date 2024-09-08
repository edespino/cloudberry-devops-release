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
    if ! command -v sbuild >/dev/null 2>&1 || ! command -v schroot >/dev/null 2>&1 || ! command -v debootstrap >/dev/null 2>&1 || ! command -v dch >/dev/null 2>&1; then
        echo "Installing necessary packages..."
        sudo apt-get update
        sudo apt-get install -y sbuild schroot debootstrap devscripts
    fi
}

setup_sbuild_environment() {
    if ! getent group sbuild > /dev/null; then
        echo "Creating sbuild group..."
        sudo groupadd sbuild
    fi

    if ! groups | grep -q '\bsbuild\b'; then
        echo "Adding current user to sbuild group..."
        sudo usermod -a -G sbuild $USER
        echo "User added to sbuild group. Please log out and log back in for changes to take effect."
        echo "Alternatively, run 'newgrp sbuild' to activate the new group membership in this session."
        echo "Then run this script again."
        exit 0
    fi

    if [ ! -f ~/.sbuildrc ]; then
        echo "Setting up minimal sbuild configuration..."
        cat << 'EOF' > ~/.sbuildrc
# Minimal sbuildrc file
$distribution = 'bookworm';
$build_arch_all = 1;

# Don't remove this, Perl needs it:
1;
EOF
    fi

    if ! sudo sbuild-adduser $USER &>/dev/null; then
        echo "Current user is already an sbuild user."
    else
        echo "Added current user as sbuild user."
    fi

    sudo mkdir -p /etc/sbuild/chroot
}

download_and_extract_source() {
    VERSION=$(get_latest_version)
    echo "Latest Cloudberry version: $VERSION"

    TARBALL_FILENAME="cloudberry-db_${VERSION}.orig.tar.gz"

    if [ -f "$TARBALL_FILENAME" ]; then
        echo "Tarball $TARBALL_FILENAME already exists. Skipping download."
    else
        TARBALL_URL="https://github.com/cloudberrydb/cloudberrydb/archive/refs/tags/${VERSION}.tar.gz"
        echo "Downloading $TARBALL_FILENAME..."
        wget -O "$TARBALL_FILENAME" "$TARBALL_URL"
    fi

    echo "Extracting $TARBALL_FILENAME..."
    tar xzf "$TARBALL_FILENAME"
    SOURCE_DIR="cloudberrydb-${VERSION#v}"  # Remove 'v' prefix if present
    cd "$SOURCE_DIR"
}

prepare_chroot_environment() {
    if [ ! -d /srv/chroot/bookworm-amd64-sbuild ]; then
        echo "Setting up sbuild environment..."
        sudo sbuild-createchroot --include=eatmydata,ccache,gnupg bookworm /srv/chroot/bookworm-amd64-sbuild http://deb.debian.org/debian
    fi

    CHROOT_BUILD_DIR="/srv/chroot/bookworm-amd64-sbuild/build/cloudberry-db"
    sudo mkdir -p "$CHROOT_BUILD_DIR"

    echo "Copying source files to chroot environment..."
    sudo rsync -a --exclude='.git' \
                  --exclude='debian' \
                  --exclude='*.o' \
                  --exclude='*.so' \
                  --exclude='*.a' \
                  "./" "$CHROOT_BUILD_DIR/"

    if [ -d "debian" ]; then
        echo "Copying debian directory to chroot environment..."
        sudo mkdir -p "$CHROOT_BUILD_DIR/debian"
        sudo cp -r debian/* "$CHROOT_BUILD_DIR/debian/"
    fi
}

generate_debian_files() {
    mkdir -p debian/source
    echo "1.0" > debian/source/format

    generate_control_file
    generate_rules_file
    generate_changelog
}

build_package() {
    if [ "$ENTER_CHROOT" = true ]; then
        enter_chroot
        echo "You've exited the chroot. Do you want to continue with the build process? (y/n)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
            echo "Continuing with the build process..."
        else
            echo "Build process cancelled."
            exit 0
        fi
    fi

    CFLAGS="-Wno-suggest-attribute=format -Wno-missing-prototypes -Wno-cast-function-type" sbuild -d bookworm --no-run-lintian -j$(nproc) .
}

list_chroots() {
    echo "Available chroots:"
    schroot -l | grep -v "^union/"
}

generate_control_file() {
    envsubst < "$(dirname "$0")/../templates/control.template" > debian/control
}

generate_rules_file() {
    cp "$(dirname "$0")/../templates/rules.template" debian/rules
    chmod +x debian/rules
}

generate_changelog() {
    VERSION=$(get_latest_version)
    export VERSION
    envsubst < "$(dirname "$0")/../templates/changelog.template" > debian/changelog
}

get_latest_version() {
    curl --silent "https://api.github.com/repos/cloudberrydb/cloudberrydb/releases/latest" | 
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

enter_chroot() {
    local chroot_name="bookworm-amd64-sbuild"
    local user_name=$(whoami)
    local build_dir="/build/cloudberry-db"
    
    echo "Entering sbuild chroot environment..."
    echo "You can exit the chroot by typing 'exit' or pressing Ctrl+D"
    echo "The source code is located in $build_dir"
    echo "Run 'cd $build_dir' after entering the chroot to access the source."
    
    sudo schroot -c "$chroot_name" -u "$user_name" -d "$build_dir"
    
    echo "Exited chroot environment."
}
