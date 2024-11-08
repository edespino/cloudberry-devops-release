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
# Script: parse-test-results.sh
# Description: Parses CloudBerry DB test results and outputs in various formats
#
# Required Environment Variables:
#   None
#
# Optional Environment Variables:
#   GITHUB_OUTPUT - GitHub Actions output file path (for CI environment)
#   LOG_DIR - Directory for logs (defaults to build-logs/details)
#
# Usage:
#   ./parse-test-results.sh [log-file]
#
# Arguments:
#   log-file    Path to test log file (defaults to build-logs/details/make-installcheck-good.log)
#
# Examples:
#   ./parse-test-results.sh
#   ./parse-test-results.sh path/to/custom/test.log
#
# --------------------------------------------------------------------

# Exit on error
set -ex

# Default log file path
DEFAULT_LOG_PATH="build-logs/details/make-installcheck-good.log"
LOG_FILE=${1:-$DEFAULT_LOG_PATH}

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Run the perl script
perl "${SCRIPT_DIR}/parse-results.pl" "$LOG_FILE"

# Check if results file exists and source it if it does
if [ -f test_results.txt ]; then
    source test_results.txt
    echo "Results loaded into environment variables:"
    echo "STATUS=$STATUS"
    echo "TOTAL_TESTS=$TOTAL_TESTS"
    echo "FAILED_TESTS=$FAILED_TESTS"
    echo "PASSED_TESTS=$PASSED_TESTS"
    
    # Clean up
    rm test_results.txt
else
    echo "Error: No results file generated"
    exit 1
fi

# If in GitHub Actions, set outputs
if [ -n "$GITHUB_OUTPUT" ]; then
    {
        echo "status=$STATUS"
        echo "total_tests=$TOTAL_TESTS"
        echo "failed_tests=$FAILED_TESTS"
        echo "passed_tests=$PASSED_TESTS"
    } >> "$GITHUB_OUTPUT"
fi

# Exit with failure if tests failed
if [ "$STATUS" = "failed" ]; then
    echo "Tests failed: $FAILED_TESTS of $TOTAL_TESTS failed"
    exit 1
fi
