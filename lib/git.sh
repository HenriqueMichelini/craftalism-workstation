#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

git_current_branch() {
  git symbolic-ref --quiet --short HEAD 2>/dev/null || echo "unborn"
}

git_head_sha() {
  git rev-parse HEAD 2>/dev/null || true
}

git_short_head_sha() {
  git rev-parse --short HEAD 2>/dev/null || true
}

git_tree_state() {
  if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
    echo "dirty"
  else
    echo "clean"
  fi
}

git_staged_files() {
  git diff --cached --name-only
}

git_has_staged_changes() {
  git diff --cached --quiet && return 1 || return 0
}

git_head_is_pushed_to_origin_main() {
  local head_sha remote_sha
  head_sha="$(git_head_sha)"
  remote_sha="$(git ls-remote --exit-code origin refs/heads/main 2>/dev/null | awk '{print $1}' || true)"
  [[ -n "${remote_sha}" ]] || return 1
  [[ "${head_sha}" == "${remote_sha}" ]]
}
