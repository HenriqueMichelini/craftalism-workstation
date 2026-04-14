#!/usr/bin/env bash

set -euo pipefail

repo_verify_mode() {
  case "$1" in
    craftalism-api|craftalism-authorization-server|craftalism-economy|craftalism-market|craftalism-dashboard|craftalism-infra)
      echo "automated"
      ;;
    craftalism|craftalism-deployment)
      echo "manual-policy-gap"
      ;;
    *)
      return 1
      ;;
  esac
}

repo_verify_commands() {
  case "$1" in
    craftalism-api|craftalism-authorization-server|craftalism-economy)
      printf '%s\n' "cd java && ./gradlew test"
      ;;
    craftalism-market)
      printf '%s\n' "./gradlew test"
      ;;
    craftalism-dashboard)
      printf '%s\n' "cd react && npm run test"
      ;;
    craftalism-infra)
      printf '%s\n' "terraform fmt -check"
      printf '%s\n' "terraform init -backend=false"
      printf '%s\n' "terraform validate"
      printf '%s\n' "./scripts/check_ingress_policy.sh"
      ;;
    craftalism|craftalism-deployment)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
