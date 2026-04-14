#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/repo.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/github.sh"

doctor_current_repo_status() {
  local root repo
  root="$(git_toplevel_or_empty)"
  if [[ -z "${root}" ]]; then
    echo "not-in-git-repo"
    return 0
  fi

  repo="$(basename "${root}")"
  if repo_is_managed "${repo}"; then
    echo "managed:${repo}"
  else
    echo "unmanaged:${repo}"
  fi
}
