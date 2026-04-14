#!/usr/bin/env bash

set -euo pipefail

workstation_root() {
  if [[ -n "${CRAFTALISM_WORKSTATION_ROOT:-}" ]]; then
    echo "${CRAFTALISM_WORKSTATION_ROOT}"
    return 0
  fi

  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

default_state_dir() {
  echo "${WORKSTATION_STATE_DIR:-${HOME}/.workstation/state}"
}

root_governance_dir() {
  echo "${HOME}/IdeaProjects/craftalism/docs"
}

print_kv() {
  local key="$1"
  local value="$2"
  printf '%-18s %s\n' "${key}:" "${value}"
}

join_by() {
  local delimiter="$1"
  shift || true
  local first=1
  local item

  for item in "$@"; do
    if [[ ${first} -eq 1 ]]; then
      printf '%s' "${item}"
      first=0
    else
      printf '%s%s' "${delimiter}" "${item}"
    fi
  done
}

die() {
  echo "error: $*" >&2
  exit 1
}

warn() {
  echo "warn: $*" >&2
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}
