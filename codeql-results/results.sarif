#!/bin/bash

set -e

# Parameters
sarif_file=$1
severity_threshold=$2
score_threshold=$3

# Extract the number of issues by severity using jq
critical_count=$(jq '[.runs[].results[] | select(.properties.problem.severity == "critical")] | length' "$sarif_file")
high_count=$(jq '[.runs[].results[] | select(.properties.problem.severity == "high")] | length' "$sarif_file")
medium_count=$(jq '[.runs[].results[] | select(.properties.problem.severity == "medium")] | length' "$sarif_file")
low_count=$(jq '[.runs[].results[] | select(.properties.problem.severity == "low")] | length' "$sarif_file")

# Output the counts
echo "Number of critical issues: $critical_count"
echo "Number of high issues: $high_count"
echo "Number of medium issues: $medium_count"
echo "Number of low issues: $low_count"

# Compare against thresholds
if [ "$severity_threshold" == "critical" ] && [ "$critical_count" -gt "$score_threshold" ]; then
  echo "Critical count ($critical_count) exceeds threshold ($score_threshold). Failing the job."
  exit 1
elif [ "$severity_threshold" == "high" ] && [ "$high_count" -gt "$score_threshold" ]; then
  echo "High count ($high_count) exceeds threshold ($score_threshold). Failing the job."
  exit 1
elif [ "$severity_threshold" == "medium" ] && [ "$medium_count" -gt "$score_threshold" ]; then
  echo "Medium count ($medium_count) exceeds threshold ($score_threshold). Failing the job."
  exit 1
elif [ "$severity_threshold" == "low" ] && [ "$low_count" -gt "$score_threshold" ]; then
  echo "Low count ($low_count) exceeds threshold ($score_threshold). Failing the job."
  exit 1
else
  echo "All counts are within the thresholds."
fi