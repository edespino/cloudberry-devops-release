#!/bin/bash
# --------------------------------------------------------------------
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed
# with this work for additional information regarding copyright
# ownership.  The ASF licenses this file to You under the Apache
# License, Version 2.0 (the "License"); you may not use this file
# except in compliance with the License.  You may obtain a copy of the
# License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#
# --------------------------------------------------------------------
#
# Script: build-cloudberry.sh
# Description: Builds CloudBerry DB from source
#
# Required Environment Variables:
#   SRC_DIR - Root source directory
#
# Optional Environment Variables:
#   LOG_DIR - Directory for logs (defaults to ${SRC_DIR}/build-logs)
#
# --------------------------------------------------------------------

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/cloudberry-utils.sh"

# Define log directory and files
export LOG_DIR="${SRC_DIR}/build-logs"
BUILD_LOG="${LOG_DIR}/build.log"

# Initialize environment
init_environment "CloudBerry Build Script" "${BUILD_LOG}"

# Set environment
log_section "Environment Setup"
export LD_LIBRARY_PATH=/usr/local/cloudberry-db/lib:LD_LIBRARY_PATH
log_section_end "Environment Setup"

# Build process
log_section "Build Process"
execute_cmd make -j$(nproc) --directory ${SRC_DIR}
execute_cmd make -j$(nproc) --directory ${SRC_DIR}/contrib
log_section_end "Build Process"

# Installation
log_section "Installation"
execute_cmd make install --directory ${SRC_DIR}
execute_cmd make install --directory ${SRC_DIR}/contrib
log_section_end "Installation"

# Log completion
log_completion "CloudBerry Build Script" "${BUILD_LOG}"
exit 0
