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
#   MAKE_NAME
#   MAKE_TARGET
#   MAKE_DIRECTORY
#
# Optional Environment Variables:
#   LOG_DIR - Directory for logs (defaults to build-logs)
#
# Usage:
#   ./test-cloudberry.sh
#
# --------------------------------------------------------------------
set -euo pipefail

# Source common utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/cloudberry-utils.sh"

# Define log directory and files
export LOG_DIR="build-logs"
TEST_LOG="${LOG_DIR}/test.log"

# Initialize environment
init_environment "CloudBerry Test Script" "${TEST_LOG}"

# Source CloudBerry environment
log_section "Environment Setup"
source_cloudberry_env
log_section_end "Environment Setup"

echo "MAKE_TARGET: ${MAKE_TARGET}"
echo "MAKE_DIRECTORY: ${MAKE_DIRECTORY}"
echo "PGOPTIONS: ${PGOPTIONS}"

# Execute specified target
log_section "Install Check"
execute_cmd make ${MAKE_TARGET} ${MAKE_DIRECTORY}
log_section_end "Install Check"

# Log completion
log_completion "CloudBerry Test Script" "${TEST_LOG}"
exit 0
