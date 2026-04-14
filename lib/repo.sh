#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/policy/repos.sh"

git_toplevel_or_empty() {
  git rev-parse --show-toplevel 2>/dev/null || true
}

current_repo_root() {
  local root
  root="$(git_toplevel_or_empty)"
  [[ -n "${root}" ]] || die "not inside a git repository"
  echo "${root}"
}

current_repo_name() {
  basename "$(current_repo_root)"
}

require_managed_repo() {
  local repo_name
  repo_name="$(current_repo_name)"
  repo_is_managed "${repo_name}" || die "repo '${repo_name}' is not managed by Craftalism workstation policy"
}
