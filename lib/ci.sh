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

workflow_has_forbidden_release_pattern() {
  local file="$1"
  local pattern="$2"
  [[ -n "${pattern}" ]] || return 1
  grep -Fq -- "${pattern}" "${file}"
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
  pattern="$(repo_release_forbidden_pattern "${repo_name}" || true)"
  workflow_has_forbidden_release_pattern "${file}" "${pattern}" && issues+=("contains forbidden release pattern: ${pattern}")

  if [[ ${#issues[@]} -eq 0 ]]; then
    echo "present"
  else
    printf 'present but %s' "$(printf '%s; ' "${issues[@]}" | sed 's/; $//')"
  fi
}

repo_ci_release_summary() {
  local repo_root="$1"
  local repo_name="$2"
  local quality_status
  local release_status

  quality_status="$(repo_quality_workflow_status "${repo_root}" "${repo_name}")"
  release_status="$(repo_release_workflow_status "${repo_root}" "${repo_name}")"

  if [[ "${quality_status}" == "present" && "${release_status}" == "present" ]]; then
    echo "locally-mapped-release-gates-ok"
  elif [[ "${quality_status}" == "missing" || "${release_status}" == "missing" ]]; then
    echo "blocked-by-missing-workflows"
  elif [[ "${release_status}" == policy\ gap:* ]]; then
    echo "blocked-by-policy-gap"
  else
    echo "blocked-by-workflow-issues"
  fi
}
