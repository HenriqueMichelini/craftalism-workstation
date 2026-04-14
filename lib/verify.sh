#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/git.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/policy/verify.sh"

verify_state_file() {
  local repo_name="$1"
  local sha="$2"
  echo "$(default_state_dir)/verify/${repo_name}/${sha}.ok"
}

verify_state_for_head() {
  local repo_name="$1"
  local sha
  sha="$(git_head_sha)"

  if [[ -z "${sha}" ]]; then
    echo "not-verified"
    return 0
  fi

  if [[ -f "$(verify_state_file "${repo_name}" "${sha}")" ]]; then
    echo "verified"
  else
    echo "not-verified"
  fi
}

write_verify_success() {
  local repo_name="$1"
  local command_text="$2"
  local sha
  local file

  sha="$(git_head_sha)"
  [[ -n "${sha}" ]] || die "cannot store verification proof before the first commit exists"
  file="$(verify_state_file "${repo_name}" "${sha}")"
  mkdir -p "$(dirname "${file}")"

  cat > "${file}" <<EOF
repo=${repo_name}
sha=${sha}
verified_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
command=${command_text}
result=success
EOF
}

run_verify_command() {
  local repo_root="$1"
  local command_text="$2"

  (
    cd "${repo_root}"
    bash -lc "${command_text}"
  )
}
