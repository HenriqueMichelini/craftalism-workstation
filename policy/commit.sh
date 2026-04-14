#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/policy/repos.sh"

commit_allowed_types_regex='feat|fix|refactor|perf|docs|test|ci|chore|security'

commit_message_is_valid() {
  local repo_name="$1"
  local message="$2"
  local scope

  scope="$(repo_scope "${repo_name}")" || return 1
  [[ "${message}" =~ ^(${commit_allowed_types_regex})\(${scope}\):\ .+ ]] || return 1
}

commit_validation_error() {
  local repo_name="$1"
  local message="$2"
  local scope

  scope="$(repo_scope "${repo_name}")" || {
    echo "unknown repo scope"
    return 0
  }

  if [[ -z "${message}" ]]; then
    echo "commit message required"
    return 0
  fi

  if [[ ! "${message}" =~ ^(${commit_allowed_types_regex})\(.+\):\ .+ ]]; then
    echo "expected format: <type>(${scope}): <summary>"
    return 0
  fi

  if [[ ! "${message}" =~ ^(${commit_allowed_types_regex})\(${scope}\):\ .+ ]]; then
    echo "scope must be '${scope}' for repo '${repo_name}'"
    return 0
  fi

  echo "invalid commit message"
}
