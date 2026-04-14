#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/policy/release.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/policy/repos.sh"

release_policy_gap_message() {
  echo "policy gap: release policy inputs are not fully configured yet"
}

root_release_doc_path() {
  local doc_name="$1"
  echo "$(root_governance_dir)/${doc_name}"
}

latest_release_audit_path() {
  local audit_dir
  audit_dir="$(root_release_doc_path "audit")"

  find "${audit_dir}" -maxdepth 1 -type f -name '*release-readiness*.md' 2>/dev/null | sort | tail -n 1
}

repo_compatibility_component_name() {
  case "$1" in
    craftalism-api) echo "API" ;;
    craftalism-authorization-server) echo "Auth Server" ;;
    craftalism-dashboard) echo "Dashboard" ;;
    craftalism-deployment) echo "Deployment" ;;
    craftalism-economy) echo "Economy" ;;
    craftalism-market) echo "Market" ;;
    *)
      return 1
      ;;
  esac
}

compatibility_matrix_mentions_repo() {
  local repo_name="$1"
  local matrix
  local component_name

  matrix="$(root_release_doc_path "compatibility-matrix.md")"
  [[ -f "${matrix}" ]] || return 1

  component_name="$(repo_compatibility_component_name "${repo_name}")" || return 1
  grep -Fq "| ${component_name} |" "${matrix}"
}

latest_release_audit_verdict() {
  local audit_file
  audit_file="$(latest_release_audit_path)"
  [[ -n "${audit_file}" && -f "${audit_file}" ]] || return 1

  if grep -Fq "**NO-GO for final release today**" "${audit_file}"; then
    echo "NO-GO"
  elif grep -Fq "**GO" "${audit_file}"; then
    echo "GO"
  else
    echo "unknown"
  fi
}
