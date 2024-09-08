#!/bin/bash
set -e

# Source helper functions
source "$(dirname "$0")/scripts/helpers.sh"

# Default values
EMAIL=${EMAIL:-}
FULLNAME=${FULLNAME:-}
ENTER_CHROOT=false

# Parse command line arguments
parse_arguments "$@"

# Install dependencies
install_dependencies

# Setup sbuild environment
setup_sbuild_environment

# Download and extract source
download_and_extract_source

# Prepare chroot environment
prepare_chroot_environment

# Generate Debian packaging files
generate_debian_files

# Build package
build_package

echo "Cloudberry package build complete. Check the parent directory for the .deb file."
