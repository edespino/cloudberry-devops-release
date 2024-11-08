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
# summary statistics
#
# Usage:
#   ./parse_results.pl <log-file>
#
# Arguments:
#   log-file    Path to test log file to parse
#
# Output:
#   Creates test_results.txt with the following variables:
#   - STATUS        (passed/failed)
#   - TOTAL_TESTS   (total number of tests)
#   - FAILED_TESTS  (number of failed tests)
#   - PASSED_TESTS  (number of passed tests)
#
# Examples:
#   ./parse_results.pl build-logs/details/make-installcheck-good.log
#
# --------------------------------------------------------------------
use strict;
use warnings;

# Get log file path from command line argument
my $file = $ARGV[0] or die "Usage: $0 LOG_FILE\n";
print "Parsing test results from: $file\n";

# Open and parse the log file
open(my $fh, '<', $file) or die "Cannot open log file: $! (looking in $file)\n";

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
    die "Could not find test summary in $file\n";
}

# Write results to file
open(my $out, '>', 'test_results.txt') or die "Cannot write results: $!\n";
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
