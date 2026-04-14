#!/usr/bin/env bash

set -euo pipefail

repo_required_docs() {
  case "$1" in
    craftalism)
      printf '%s\n' "docs/governance-precedence.md"
      printf '%s\n' "docs/system-summary.md"
      printf '%s\n' "docs/contracts"
      printf '%s\n' "docs/standards"
      printf '%s\n' "docs/audit"
      ;;
    craftalism-api|craftalism-authorization-server|craftalism-dashboard|craftalism-deployment|craftalism-economy|craftalism-infra|craftalism-market)
      printf '%s\n' "docs/repo-contract-map.md"
      printf '%s\n' "docs/repo-requirement-pack.md"
      ;;
    *)
      return 1
      ;;
  esac
}
