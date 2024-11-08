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
# Script: configure-cloudberry.sh
# Description: Configures CloudBerry DB build environment and runs ./configure
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
CONFIGURE_LOG="${LOG_DIR}/configure.log"

# Initialize environment
init_environment "CloudBerry Configure Script" "${CONFIGURE_LOG}"

# Initial setup
log_section "Initial Setup"
execute_cmd sudo rm -rf /usr/local/cloudberry-db
execute_cmd sudo chmod a+w /usr/local
execute_cmd mkdir -p /usr/local/cloudberry-db/lib
execute_cmd sudo cp /usr/local/xerces-c/lib/libxerces-c.so \
        /usr/local/xerces-c/lib/libxerces-c-3.3.so \
        /usr/local/cloudberry-db/lib
execute_cmd sudo chown -R gpadmin.gpadmin /usr/local/cloudberry-db

log_section_end "Initial Setup"

# Set environment
log_section "Environment Setup"
export LD_LIBRARY_PATH=/usr/local/cloudberry-db/lib:LD_LIBRARY_PATH
log_section_end "Environment Setup"

# Configure build
log_section "Configure"
execute_cmd ./configure --prefix=/usr/local/cloudberry-db \
            --disable-external-fts \
            --enable-gpcloud \
            --enable-ic-proxy \
            --enable-mapreduce \
            --enable-orafce \
            --enable-orca \
            --enable-pxf \
            --enable-tap-tests \
            --with-gssapi \
            --with-ldap \
            --with-libxml \
            --with-lz4 \
            --with-openssl \
            --with-pam \
            --with-perl \
            --with-pgport=5432 \
            --with-python \
            --with-pythonsrc-ext \
            --with-ssl=openssl \
            --with-openssl \
            --with-uuid=e2fs \
            --with-includes=/usr/local/xerces-c/include \
            --with-libraries=/usr/local/cloudberry-db/lib
log_section_end "Configure"

# Capture version information
log_section "Version Information"
execute_cmd ag "GP_VERSION | GP_VERSION_NUM | PG_VERSION | PG_VERSION_NUM | PG_VERSION_STR" src/include/pg_config.h
log_section_end "Version Information"

# Log completion
log_completion "CloudBerry Configure Script" "${CONFIGURE_LOG}"
exit 0
