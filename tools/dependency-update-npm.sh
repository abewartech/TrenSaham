#!/bin/bash
set -euo pipefail

# tools/dependency-update-npm.sh
#
# Phases:
# 1) Analysis (record current versions)
# 2) Safe update preparation (branch, backups, ncu update)
# 3) Automated testing (build + phpunit tests via npm scripts)
# 4) Selective update (rollback on failure, keep changes on success, generate report)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BRANCH_NAME="dependency-update-npm-${TIMESTAMP}"
REPORT_FILE="dependency-update-report-npm-${TIMESTAMP}.md"

echo "=== PHASE 1: DEPENDENCY ANALYSIS ==="

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required but not found. Please install Node.js/npm."
  exit 1
fi

# Capture current dependency snapshot
npx npm-check-updates --format json > current_versions.json
echo "Current dependencies scanned into current_versions.json."

echo "=== PHASE 2: PREPARATION ==="

# Create dedicated branch if we are in a git repo
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git checkout -b "${BRANCH_NAME}"
else
  echo "Not a git repository; continuing without creating a branch."
fi

# Backup package.json / lockfile
cp package.json "package.json.backup.${TIMESTAMP}"
cp package-lock.json "package-lock.json.backup.${TIMESTAMP}" 2>/dev/null || true

echo "Backups created."

# Update ALL dependencies to latest using npm-check-updates
npx npm-check-updates -u
echo "package.json updated to latest dependency ranges."

echo "Installing updated dependencies (npm install)..."
npm install --silent

echo "=== PHASE 3: TESTING ==="

BUILD_STATUS="NOT RUN"
TEST_STATUS="NOT RUN"
BUILD_ERROR=""
TEST_ERROR=""

# Build test (uses `npm run build` which we mapped to `npm run production`)
if npm run build > build.log 2>&1; then
  BUILD_STATUS="✅ PASS"
else
  BUILD_STATUS="❌ FAIL"
  BUILD_ERROR="$(tail -20 build.log || true)"
fi

# Unit / integration tests (mapped to phpunit via npm script)
if npm test > test.log 2>&1; then
  TEST_STATUS="✅ PASS"
else
  TEST_STATUS="❌ FAIL"
  TEST_ERROR="$(tail -20 test.log || true)"
fi

echo "=== PHASE 4: FINALIZING ==="

# Capture updated dependency snapshot
npx npm-check-updates --format json > updated_versions.json

# Generate markdown report
{
  echo "# NPM Dependency Update Report"
  echo
  echo "- Date: $(date)"
  echo "- Branch: ${BRANCH_NAME}"
  echo
  echo "## Summary"
  echo
  echo "- BUILD: ${BUILD_STATUS}"
  echo "- TESTS: ${TEST_STATUS}"
  echo
  echo "## Version Snapshots"
  echo
  echo "- Before: \`current_versions.json\`"
  echo "- After:  \`updated_versions.json\`"
  echo
  if [[ -n "${BUILD_ERROR}" ]]; then
    echo "## Build Errors (tail)"
    echo
    echo '```'
    echo "${BUILD_ERROR}"
    echo '```'
    echo
  fi
  if [[ -n "${TEST_ERROR}" ]]; then
    echo "## Test Errors (tail)"
    echo
    echo '```'
    echo "${TEST_ERROR}"
    echo '```'
    echo
  fi
} > "${REPORT_FILE}"

# Decide whether to keep or roll back changes
if [[ "${BUILD_STATUS}" == "✅ PASS" && "${TEST_STATUS}" == "✅ PASS" ]]; then
  echo "All tests passed. Keeping updates."

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git add package.json package-lock.json "${REPORT_FILE}" current_versions.json updated_versions.json
    git commit -m "chore(deps): npm dependency updates (${TIMESTAMP})"
    echo "✅ UPDATE COMPLETE AND COMMITTED on branch ${BRANCH_NAME}"
  else
    echo "Not a git repository; changes are present in the working directory."
  fi
else
  echo "Tests and/or build failed. Rolling back package.json and package-lock.json..."

  # Restore from backups
  cp "package.json.backup.${TIMESTAMP}" package.json
  if [[ -f "package-lock.json.backup.${TIMESTAMP}" ]]; then
    cp "package-lock.json.backup.${TIMESTAMP}" package-lock.json
  fi

  npm install --silent

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git restore --staged package.json package-lock.json 2>/dev/null || true
  fi

  echo "❌ UPDATE ROLLED BACK. See ${REPORT_FILE} for details."
fi

echo "Report written to ${REPORT_FILE}"