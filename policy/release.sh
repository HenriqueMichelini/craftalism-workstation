#!/usr/bin/env bash

set -euo pipefail

root_contract_change_checklist_relative_path() {
  echo "standards/contract-change-checklist.md"
}

root_compatibility_matrix_relative_path() {
  echo "compatibility-matrix.md"
}

root_ci_standard_relative_path() {
  echo "standards/ci-cd.md"
}

release_policy_missing_inputs() {
  printf '%s\n' "CI workflow mapping is incomplete for some repos."
  printf '%s\n' "Required status check names are not configured yet."
  printf '%s\n' "Tag-to-compatibility release update workflow is not configured yet."
}
