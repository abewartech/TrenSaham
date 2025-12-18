#!/bin/bash
set -euo pipefail

# tools/dependency-update-composer.sh
#
# Phases:
# 1) Analysis (composer outdated)
# 2) Safe update preparation (branch, backups)
# 3) Automated testing (phpunit)
# 4) Selective update (rollback on failure, keep changes on success, generate report)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BRANCH_NAME="dependency-update-composer-${TIMESTAMP}"
REPORT_FILE="dependency-update-report-composer-${TIMESTAMP}.md"

echo "=== PHASE 1: DEPENDENCY ANALYSIS (COMPOSER) ==="

if ! command -v composer >/dev/null 2>&1; then
  echo "composer is required but not found."
  exit 1
fi

composer outdated --direct --format=json > composer-outdated.json || true
echo "Composer outdated summary written to composer-outdated.json."

echo "=== PHASE 2: PREPARATION (COMPOSER) ==="

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git checkout -b "${BRANCH_NAME}"
else
  echo "Not a git repository; continuing without creating a branch."
fi

cp composer.json "composer.json.backup.${TIMESTAMP}"
cp composer.lock "composer.lock.backup.${TIMESTAMP}" 2>/dev/null || true

echo "Backups created."

echo "Running composer update for all dependencies..."
composer update

echo "=== PHASE 3: TESTING (COMPOSER) ==="

TEST_STATUS="NOT RUN"
TEST_ERROR=""

if ./vendor/bin/phpunit > phpunit.log 2>&1; then
  TEST_STATUS="✅ PASS"
else
  TEST_STATUS="❌ FAIL"
  TEST_ERROR="$(tail -20 phpunit.log || true)"
fi

echo "=== PHASE 4: FINALIZING (COMPOSER) ==="

composer show --format=json > composer-after.json || true

{
  echo "# Composer Dependency Update Report"
  echo
  echo "- Date: $(date)"
  echo "- Branch: ${BRANCH_NAME}"
  echo
  echo "## Summary"
  echo
  echo "- TESTS: ${TEST_STATUS}"
  echo
  echo "## Version Snapshots"
  echo
  echo "- Outdated (before): \`composer-outdated.json\`"
  echo "- After: \`composer-after.json\`"
  echo
  if [[ -n "${TEST_ERROR}" ]]; then
    echo "## PHPUnit Errors (tail)"
    echo
    echo '```'
    echo "${TEST_ERROR}"
    echo '```'
    echo
  fi
} > "${REPORT_FILE}"

if [[ "${TEST_STATUS}" == "✅ PASS" ]]; then
  echo "All composer tests passed. Keeping updates."

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git add composer.json composer.lock "${REPORT_FILE}" composer-outdated.json composer-after.json
    git commit -m "chore(deps): composer dependency updates (${TIMESTAMP})"
    echo "✅ COMPOSER UPDATE COMPLETE AND COMMITTED on branch ${BRANCH_NAME}"
  else
    echo "Not a git repository; composer changes are present in the working directory."
  fi
else
  echo "PHPUnit failed. Rolling back composer.json and composer.lock..."

  cp "composer.json.backup.${TIMESTAMP}" composer.json
  if [[ -f "composer.lock.backup.${TIMESTAMP}" ]]; then
    cp "composer.lock.backup.${TIMESTAMP}" composer.lock
  fi

  composer install

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git restore --staged composer.json composer.lock 2>/dev/null || true
  fi

  echo "❌ COMPOSER UPDATE ROLLED BACK. See ${REPORT_FILE} for details."
fi

echo "Composer report written to ${REPORT_FILE}"