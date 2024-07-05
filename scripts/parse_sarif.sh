#!/bin/bash

# Create the directory for results
mkdir -p codeql-results

# Path to the SARIF file for the current language
language=$(echo "${1}" | tr '[:upper:]' '[:lower:]')
results_path="codeql-results/results-${1}.sarif/${language}.sarif"

# Debugging: Print the SARIF file content
echo "Debug: Printing SARIF file content for ${language}"
cat $results_path

# Parse the SARIF file to extract vulnerabilities and count based on severity levels
critical=$(jq '[.runs[].results[] | select(.properties["security-severity"] >= 9)] | length' $results_path)
high=$(jq '[.runs[].results[] | select(.properties["security-severity"] >= 7 and .properties["security-severity"] < 9)] | length' $results_path)
medium=$(jq '[.runs[].results[] | select(.properties["security-severity"] >= 4 and .properties["security-severity"] < 7)] | length' $results_path)
low=$(jq '[.runs[].results[] | select(.properties["security-severity"] >= 0.1 and .properties["security-severity"] < 4)] | length' $results_path)

# Parse non-security alerts
error=$(jq '[.runs[].results[] | select(.level == "error")] | length' $results_path)
warning=$(jq '[.runs[].results[] | select(.level == "warning")] | length' $results_path)
note=$(jq '[.runs[].results[] | select(.level == "note")] | length' $results_path)

# Debugging: Print parsed counts
echo "Debug: Vulnerability counts for ${language}"
echo "Critical: $critical"
echo "High: $high"
echo "Medium: $medium"
echo "Low: $low"
echo "Error: $error"
echo "Warning: $warning"
echo "Note: $note"

# Using $GITHUB_OUTPUT to set outputs
echo "critical=$critical" >> $GITHUB_OUTPUT
echo "high=$high" >> $GITHUB_OUTPUT
echo "medium=$medium" >> $GITHUB_OUTPUT
echo "low=$low" >> $GITHUB_OUTPUT
echo "error=$error" >> $GITHUB_OUTPUT
echo "warning=$warning" >> $GITHUB_OUTPUT
echo "note=$note" >> $GITHUB_OUTPUT

# Extract detailed vulnerabilities and generate Markdown table
vulnerabilities=$(jq -r '[.runs[].results[] | select(.properties["security-severity"] >= 0.1) | {severity: .properties["security-severity"], message: .message.text, level: .level}]' $results_path)

# Generate Markdown summary
{
  echo "## CodeQL Vulnerability Report"
  echo "| Severity | Level | Message |"
  echo "| --- | --- | --- |"
  echo "$vulnerabilities" | jq -r '.[] | "| \(.severity) | \(.level) | \(.message) |"'

  echo "## Vulnerability Counts"
  echo "| Severity | Count |"
  echo "| --- | --- |"
  echo "| Critical | $critical |"
  echo "| High | $high |"
  echo "| Medium | $medium |"
  echo "| Low | $low |"
  echo "| Error | $error |"
  echo "| Warning | $warning |"
  echo "| Note | $note |"
} >> $GITHUB_STEP_SUMMARY
