#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/policy/docs.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/policy/reading-order.sh"

repo_required_docs_missing() {
  local repo_root="$1"
  local repo_name="$2"
  local missing=()
  local relative

  while IFS= read -r relative; do
    [[ -n "${relative}" ]] || continue
    if [[ ! -e "${repo_root}/${relative}" ]]; then
      missing+=("${relative}")
    fi
  done < <(repo_required_docs "${repo_name}")

  printf '%s\n' "${missing[@]:-}"
}

repo_docs_state() {
  local repo_root="$1"
  local repo_name="$2"
  local missing
  missing="$(repo_required_docs_missing "${repo_root}" "${repo_name}")"

  if [[ -z "${missing}" ]]; then
    echo "ok"
  else
    echo "missing-required-docs"
  fi
}

print_repo_reading_order() {
  local repo_name="$1"
  local repo_root="$2"
  local line
  local index=1

  while IFS= read -r line; do
    [[ -n "${line}" ]] || continue
    printf '%d. %s\n' "${index}" "${line}"
    index=$((index + 1))
  done < <(repo_reading_order "${repo_name}" "${repo_root}")
}
