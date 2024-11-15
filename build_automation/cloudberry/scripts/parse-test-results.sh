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
# Description: Parses CloudBerry DB test results and processes the output.
#             Wraps parse_results.pl to provide additional functionality
#             and GitHub Actions integration.
#
# Required Environment Variables:
#   None
#
# Optional Environment Variables:
#   GITHUB_OUTPUT - GitHub Actions output file path (for CI environment)
#   LOG_DIR      - Directory for logs (defaults to build-logs/details)
#   SRC_DIR      - Root source directory (for locating parse_results.pl)
#
# Generated Outputs:
#   When GITHUB_OUTPUT is set, writes the following:
#   - status       (passed/failed)
#   - total_tests  (total number of tests)
#   - failed_tests (number of failed tests)
#   - passed_tests (number of passed tests)
#   - failed_test_names (comma-separated list of failed test names)
#
# Exit Codes:
#   0    Success - Tests passed or results properly parsed
#   1    Expected Failure - Tests ran but some failed
#   2    Unexpected Error - Missing files or parse errors
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
# Dependencies:
#   - parse_results.pl must be in the same directory as this script
#   - Requires Perl to be installed
#
# Notes:
#   - Will create temporary file test_results.txt which is cleaned up after execution
#   - Handles both local execution and GitHub Actions environment
#
# --------------------------------------------------------------------

set -e

# Default log file path
DEFAULT_LOG_PATH="build-logs/details/make-installcheck-good.log"
LOG_FILE=${1:-$DEFAULT_LOG_PATH}

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Test log file not found: $LOG_FILE"
    exit 2
fi

# Run the perl script
perl "${SCRIPT_DIR}/parse_results.pl" "$LOG_FILE"

# Check if results file exists and source it if it does
if [ ! -f test_results.txt ]; then
    echo "Error: No results file generated"
    exit 2
fi

source test_results.txt

echo "Results loaded into environment variables:"
echo "STATUS=$STATUS"
echo "TOTAL_TESTS=$TOTAL_TESTS"
echo "FAILED_TESTS=$FAILED_TESTS"
echo "PASSED_TESTS=$PASSED_TESTS"
if [ -n "$FAILED_TEST_NAMES" ]; then
    echo "FAILED_TEST_NAMES=$FAILED_TEST_NAMES"
fi

# If in GitHub Actions, set outputs
if [ -n "$GITHUB_OUTPUT" ]; then
    {
        echo "status=$STATUS"
        echo "total_tests=$TOTAL_TESTS"
        echo "failed_tests=$FAILED_TESTS"
        echo "passed_tests=$PASSED_TESTS"
        [ -n "$FAILED_TEST_NAMES" ] && echo "failed_test_names=$FAILED_TEST_NAMES"
    } >> "$GITHUB_OUTPUT"
fi

# Clean up
rm test_results.txt

# Handle the test status
case "$STATUS" in
    "passed")
        echo "All tests passed successfully"
        exit 0
        ;;
    "failed")
        echo "Tests failed: $FAILED_TESTS of $TOTAL_TESTS failed"
        exit 1
        ;;
    *)
        echo "Error: Unknown test status: $STATUS"
        exit 2
        ;;
esac
