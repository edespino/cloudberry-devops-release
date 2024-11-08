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
# Script: test-cloudberry.sh
# Description: Executes CloudBerry DB test suite with specified make target
#
# Required Environment Variables:
#   SRC_DIR - Root source directory
#
# Optional Environment Variables:
#   LOG_DIR - Directory for logs (defaults to ${SRC_DIR}/build-logs)
#
# Usage:
#   ./test-cloudberry.sh <make-target>
#
# Arguments:
#   make-target    The make target to execute (e.g., installcheck-cloudberry-1)
#
# Examples:
#   ./test-cloudberry.sh installcheck-cloudberry-1
#   ./test-cloudberry.sh installcheck-parallel
#
# --------------------------------------------------------------------
set -euo pipefail

# Source common utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/cloudberry-utils.sh"

# Check if target argument is provided
if [ $# -ne 1 ]; then
    echo "Error: Make target must be specified"
    echo "Usage: $0 <make-target>"
    echo "Example: $0 installcheck-cloudberry-1"
    exit 1
fi

MAKE_TARGET="$1"

# Define log directory and files
export LOG_DIR="${SRC_DIR}/build-logs"
TEST_LOG="${LOG_DIR}/test.log"

# Initialize environment
init_environment "CloudBerry Test Script" "${TEST_LOG}"

# Source CloudBerry environment
log_section "Environment Setup"
source_cloudberry_env
log_section_end "Environment Setup"

# Execute specified installcheck target
log_section "Install Check"
execute_cmd make ${MAKE_TARGET} PGOPTIONS='-c optimizer=off' --directory=${SRC_DIR}/../cloudberry/src/test/regress
log_section_end "Install Check"

# Log completion
log_completion "CloudBerry Test Script" "${TEST_LOG}"
exit 0
