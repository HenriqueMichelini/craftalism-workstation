#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/git.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/verify.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/release.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/ci.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/policy/release.sh"

release_gate_branch_state() {
  [[ "$(git_current_branch)" == "main" ]] && echo "ok" || echo "blocked"
}

release_gate_tree_state() {
  [[ "$(git_tree_state)" == "clean" ]] && echo "ok" || echo "blocked"
}

release_gate_pushed_state() {
  git_head_is_pushed_to_origin_main && echo "ok" || echo "blocked"
}

release_gate_verify_state() {
  local repo_name="$1"
  [[ "$(verify_state_for_head "${repo_name}")" == "verified" ]] && echo "ok" || echo "blocked"
}

release_gate_compatibility_state() {
  local repo_name="$1"
  local path
  path="$(root_release_doc_path "$(root_compatibility_matrix_relative_path)")"

  if [[ ! -f "${path}" ]]; then
    echo "missing"
  elif compatibility_matrix_mentions_repo "${repo_name}"; then
    echo "present and lists repo"
  else
    echo "present but does not list repo explicitly"
  fi
}

release_gate_ci_standard_state() {
  local path
  path="$(root_release_doc_path "$(root_ci_standard_relative_path)")"
  [[ -f "${path}" ]] && echo "present" || echo "missing"
}

release_gate_contract_checklist_state() {
  local path
  path="$(root_release_doc_path "$(root_contract_change_checklist_relative_path)")"
  [[ -f "${path}" ]] && echo "present" || echo "missing"
}

release_gate_audit_state() {
  local latest_audit
  latest_audit="$(latest_release_audit_path || true)"
  [[ -n "${latest_audit}" ]] && latest_release_audit_verdict || echo "missing"
}

release_gate_decision() {
  local branch_state="$1"
  local tree_state="$2"
  local pushed_state="$3"
  local verify_state="$4"
  local compatibility_state="$5"
  local ci_standard_state="$6"
  local contract_checklist_state="$7"
  local ci_release_summary="$8"
  local latest_audit_state="$9"

  if [[ "${branch_state}" == "ok" \
     && "${tree_state}" == "ok" \
     && "${pushed_state}" == "ok" \
     && "${verify_state}" == "ok" \
     && "${compatibility_state}" == "present and lists repo" \
     && "${ci_standard_state}" == "present" \
     && "${contract_checklist_state}" == "present" \
     && "${ci_release_summary}" == "locally-mapped-release-gates-ok" \
     && "${latest_audit_state}" != "NO-GO" ]]; then
    echo "ready-for-next-release-gate"
  else
    echo "blocked"
  fi
}

print_release_blocking_reasons() {
  local branch_state="$1"
  local tree_state="$2"
  local pushed_state="$3"
  local verify_state="$4"
  local compatibility_state="$5"
  local latest_audit_state="$6"

  if [[ "${branch_state}" != "ok" ]]; then
    echo "- branch is not main"
  fi
  if [[ "${tree_state}" != "ok" ]]; then
    echo "- git tree is not clean"
  fi
  if [[ "${pushed_state}" != "ok" ]]; then
    echo "- HEAD is not pushed to origin/main"
  fi
  if [[ "${verify_state}" != "ok" ]]; then
    echo "- local verify proof for HEAD is missing"
  fi
  if [[ "${compatibility_state}" == "present but does not list repo explicitly" ]]; then
    echo "- compatibility matrix does not list repo explicitly"
  fi
  if [[ "${latest_audit_state}" == "NO-GO" ]]; then
    echo "- latest release audit is NO-GO"
  fi
}
