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
# Script: cloudberry-utils.sh
# Description: Common utility functions for CloudBerry DB build and test scripts
#
# Required Environment Variables:
#   SRC_DIR - Root source directory
#
# Optional Environment Variables:
#   LOG_DIR - Directory for logs (defaults to ${SRC_DIR}/build-logs)
#
# Functions:
#   init_environment     - Initialize logging and verify environment
#   execute_cmd         - Execute command with logging
#   run_psql_cmd       - Execute PostgreSQL command with logging
#   source_cloudberry_env - Source CloudBerry environment files
#   log_section        - Log section start
#   log_section_end    - Log section end
#   log_completion     - Log script completion
#
# Usage:
#   source ./cloudberry-utils.sh
#   init_environment "Script Name" "${LOG_FILE}"
#   execute_cmd some_command arg1 arg2
#   run_psql_cmd "SELECT version()"
#   log_section "Section Name"
#   log_section_end "Section Name"
#   log_completion "Script Name" "${LOG_FILE}"
#
# --------------------------------------------------------------------

set -euo pipefail

# Initialize logging and environment
init_environment() {
    local script_name=$1
    local log_file=$2

    echo "=== Initializing environment for ${script_name} ==="
    echo "${script_name} executed at $(date)" | tee -a "${log_file}"
    echo "Whoami: $(whoami)" | tee -a "${log_file}"
    echo "Hostname: $(hostname)" | tee -a "${log_file}"
    echo "Working directory: $(pwd)" | tee -a "${log_file}"
    echo "Source directory: ${SRC_DIR}" | tee -a "${log_file}"
    echo "Log directory: ${LOG_DIR}" | tee -a "${log_file}"

    if [ -z "${SRC_DIR:-}" ]; then
        echo "Error: SRC_DIR environment variable is not set" | tee -a "${log_file}"
        exit 1
    fi

    mkdir -p "${LOG_DIR}"
}

# Function to echo and execute command with logging
execute_cmd() {
    local cmd_str="$*"
    local timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
    echo "Executing at ${timestamp}: $cmd_str" | tee -a "${LOG_DIR}/commands.log"
    "$@" 2>&1 | tee -a "${LOG_DIR}/commands.log"
    return ${PIPESTATUS[0]}
}

# Function to run psql commands with logging
run_psql_cmd() {
    local cmd=$1
    local timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
    echo "Executing psql at ${timestamp}: $cmd" | tee -a "${LOG_DIR}/psql-commands.log"
    psql -P pager=off template1 -c "$cmd" 2>&1 | tee -a "${LOG_DIR}/psql-commands.log"
    return ${PIPESTATUS[0]}
}

# Function to source CloudBerry environment
source_cloudberry_env() {
    echo "=== Sourcing CloudBerry environment ===" | tee -a "${LOG_DIR}/environment.log"
    source /usr/local/cloudberry-db/greenplum_path.sh
    source ${SRC_DIR}/../cloudberry/gpAux/gpdemo/gpdemo-env.sh
}

# Function to log section start
log_section() {
    local section_name=$1
    local timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
    echo "=== ${section_name} started at ${timestamp} ===" | tee -a "${LOG_DIR}/sections.log"
}

# Function to log section end
log_section_end() {
    local section_name=$1
    local timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
    echo "=== ${section_name} completed at ${timestamp} ===" | tee -a "${LOG_DIR}/sections.log"
}

# Function to log script completion
log_completion() {
    local script_name=$1
    local log_file=$2
    local timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
    echo "${script_name} execution completed successfully at ${timestamp}" | tee -a "${log_file}"
}
