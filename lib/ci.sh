#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/policy/ci.sh"

repo_quality_workflow_file() {
  local repo_root="$1"
  local repo_name="$2"
  local relative

  relative="$(repo_quality_workflow_relative_path "${repo_name}" || true)"
  [[ -n "${relative}" ]] || return 1
  echo "${repo_root}/${relative}"
}

repo_release_workflow_file() {
  local repo_root="$1"
  local repo_name="$2"
  local relative

  relative="$(repo_release_workflow_relative_path "${repo_name}" || true)"
  [[ -n "${relative}" ]] || return 1
  echo "${repo_root}/${relative}"
}

workflow_has_pull_request_trigger() {
  local file="$1"
  grep -Eq '^[[:space:]]*pull_request:' "${file}"
}

workflow_has_push_trigger() {
  local file="$1"
  grep -Eq '^[[:space:]]*push:' "${file}"
}

workflow_has_tag_trigger() {
  local file="$1"
  grep -Eq '^[[:space:]]*-[[:space:]]*"v\*\.\*\.\*"' "${file}"
}

workflow_has_quality_job_hint() {
  local file="$1"
  local pattern="$2"
  [[ -n "${pattern}" ]] || return 0
  grep -Fq "${pattern}" "${file}"
}

repo_quality_workflow_status() {
  local repo_root="$1"
  local repo_name="$2"
  local file
  local pattern
  local issues=()

  file="$(repo_quality_workflow_file "${repo_root}" "${repo_name}" || true)"
  [[ -n "${file}" && -f "${file}" ]] || {
    echo "missing"
    return 0
  }

  workflow_has_pull_request_trigger "${file}" || issues+=("missing pull_request trigger")
  workflow_has_push_trigger "${file}" || issues+=("missing push trigger")
  pattern="$(repo_quality_job_hint "${repo_name}" || true)"
  workflow_has_quality_job_hint "${file}" "${pattern}" || issues+=("missing expected quality command")

  if [[ ${#issues[@]} -eq 0 ]]; then
    echo "present"
  else
    printf 'present but %s' "$(printf '%s; ' "${issues[@]}" | sed 's/; $//')"
  fi
}

repo_release_workflow_status() {
  local repo_root="$1"
  local repo_name="$2"
  local file
  local pattern
  local issues=()

  file="$(repo_release_workflow_file "${repo_root}" "${repo_name}" || true)"
  [[ -n "${file}" ]] || {
    echo "policy gap: no release workflow mapping configured"
    return 0
  }
  [[ -f "${file}" ]] || {
    echo "missing"
    return 0
  }

  workflow_has_tag_trigger "${file}" || issues+=("missing tag trigger")
  pattern="$(repo_release_job_hint "${repo_name}" || true)"
  workflow_has_quality_job_hint "${file}" "${pattern}" || issues+=("missing expected release gate")

  if [[ ${#issues[@]} -eq 0 ]]; then
    echo "present"
  else
    printf 'present but %s' "$(printf '%s; ' "${issues[@]}" | sed 's/; $//')"
  fi
}
