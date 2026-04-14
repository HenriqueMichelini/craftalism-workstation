#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

repo_reading_order() {
  local repo_name="$1"
  local repo_root="$2"
  local root_docs

  root_docs="$(root_governance_dir)"
  printf '%s\n' "${root_docs}/governance-precedence.md"
  printf '%s\n' "${root_docs}/system-summary.md"
  printf '%s\n' "${root_docs}/contracts/"
  printf '%s\n' "${root_docs}/standards/"
  printf '%s\n' "${root_docs}/audit/"

  if [[ "${repo_name}" == "craftalism" ]]; then
    printf '%s\n' "${root_docs}/"
  else
    printf '%s\n' "${repo_root}/docs/repo-contract-map.md"
    printf '%s\n' "${repo_root}/docs/repo-requirement-pack.md"
  fi
}
