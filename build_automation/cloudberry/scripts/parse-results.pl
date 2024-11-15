#!/usr/bin/env perl
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
# Script: parse_results.pl
# Description: Parses CloudBerry DB test output and extracts test
#              summary statistics.  Processes test results to
#              determine pass/fail status and test counts.
#
# Usage:
#   ./parse_results.pl <log-file>
#
# Arguments:
#   log-file    Path to test log file to parse
#
# Output Files:
#   Creates test_results.txt with the following variables:
#   - STATUS        (passed/failed)
#   - TOTAL_TESTS   (total number of tests)
#   - FAILED_TESTS  (number of failed tests)
#   - PASSED_TESTS  (number of passed tests)
#
# Exit Codes:
#   0    Success - All tests passed
#   1    Expected Failure - Tests ran but some failed
#   2    Parse Error - Could not find/read file or parse results
#
# Pattern Matching:
#   Looks for lines containing either:
#   - "All X tests passed."
#   - "Y of X tests failed."
#
# Examples:
#   ./parse_results.pl build-logs/details/make-installcheck-good.log
#   ./parse_results.pl path/to/custom/test.log
#
# Notes:
#   - Requires read access to input file
#   - Requires write access to current directory for test_results.txt
#   - Will print last 10 lines of log file if no test summary found
#
# --------------------------------------------------------------------

use strict;
use warnings;

# Exit codes
use constant {
    SUCCESS => 0,
    TEST_FAILURE => 1,
    PARSE_ERROR => 2
};

# Get log file path from command line argument
my $file = $ARGV[0] or die "Usage: $0 LOG_FILE\n";
print "Parsing test results from: $file\n";

# Check if file exists and is readable
unless (-e $file) {
    print "Error: File does not exist: $file\n";
    exit PARSE_ERROR;
}
unless (-r $file) {
    print "Error: File is not readable: $file\n";
    exit PARSE_ERROR;
}

# Open and parse the log file
open(my $fh, '<', $file) or do {
    print "Cannot open log file: $! (looking in $file)\n";
    exit PARSE_ERROR;
};

my ($status, $total_tests, $failed_tests, $passed_tests);

while (<$fh>) {
    if (/All (\d+) tests passed\./) {
        $status = 'passed';
        $total_tests = $1;
        $failed_tests = 0;
        $passed_tests = $1;
        last;
    }
    elsif (/(\d+) of (\d+) tests failed\./) {
        $status = 'failed';
        $failed_tests = $1;
        $total_tests = $2;
        $passed_tests = $2 - $1;
        last;
    }
}
close($fh);

unless (defined $status) {
    print "Error: Could not find test summary in $file\n";
    print "Last few lines of file:\n";
    # Print last few lines for debugging
    open(my $fh, '<', $file) or exit PARSE_ERROR;
    my @lines = <$fh>;
    close($fh);
    print join("", @lines[-10..-1]) if @lines > 0;
    exit PARSE_ERROR;
}

# Write results to file
open(my $out, '>', 'test_results.txt') or do {
    print "Cannot write results: $!\n";
    exit PARSE_ERROR;
};

print $out "STATUS=$status\n";
print $out "TOTAL_TESTS=$total_tests\n";
print $out "FAILED_TESTS=$failed_tests\n";
print $out "PASSED_TESTS=$passed_tests\n";
close($out);

# Also print to stdout for logging
print "Test Results:\n";
print "Status: $status\n";
print "Total Tests: $total_tests\n";
print "Failed Tests: $failed_tests\n";
print "Passed Tests: $passed_tests\n";

# Exit with appropriate code
if ($status eq 'passed') {
    exit SUCCESS;
} elsif ($status eq 'failed') {
    exit TEST_FAILURE;
} else {
    exit PARSE_ERROR;
}
