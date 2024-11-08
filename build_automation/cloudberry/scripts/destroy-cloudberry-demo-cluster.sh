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
# Script: destroy-cloudberry-demo-cluster.sh
# Description: Destroys demo CloudBerry DB cluster
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

# Define log directory
export LOG_DIR="${SRC_DIR}/build-logs"
CLUSTER_LOG="${LOG_DIR}/destroy-cluster.log"

# Initialize environment
init_environment "Destroy CloudBerry Demo Cluster Script" "${CLUSTER_LOG}"

# Source CloudBerry environment
log_section "Environment Setup"
source_cloudberry_env
log_section_end "Environment Setup"

# Destroy demo cluster
log_section "Destroy Demo Cluster"
execute_cmd make destroy-demo-cluster --directory ${SRC_DIR}/../cloudberry
log_section_end "Destroy Demo Cluster"

# Log completion
log_completion "Destroy CloudBerry Demo Cluster Script" "${CLUSTER_LOG}"
exit 0
