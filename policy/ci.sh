#!/usr/bin/env bash

set -euo pipefail

repo_quality_workflow_relative_path() {
  case "$1" in
    craftalism-api) echo ".github/workflows/quality-gates.yml" ;;
    craftalism-authorization-server) echo ".github/workflows/ci.yml" ;;
    craftalism-dashboard) echo ".github/workflows/quality-gates.yml" ;;
    craftalism-deployment) echo ".github/workflows/build-staging-images.yml" ;;
    craftalism-economy) echo ".github/workflows/quality-gates.yml" ;;
    craftalism-infra) echo ".github/workflows/terraform.yml" ;;
    *)
      return 1
      ;;
  esac
}

repo_release_workflow_relative_path() {
  case "$1" in
    craftalism-api) echo ".github/workflows/build-and-push.yml" ;;
    craftalism-authorization-server) echo ".github/workflows/build-and-push.yml" ;;
    craftalism-dashboard) echo ".github/workflows/build-and-push.yml" ;;
    craftalism-economy) echo ".github/workflows/build-and-release.yml" ;;
    *)
      return 1
      ;;
  esac
}

repo_quality_job_hint() {
  case "$1" in
    craftalism-api|craftalism-authorization-server)
      echo "clean check"
      ;;
    craftalism-dashboard)
      echo "npm run build"
      ;;
    craftalism-deployment)
      echo "smoke-test-stack"
      ;;
    craftalism-economy)
      echo "clean build"
      ;;
    craftalism-infra)
      echo "./scripts/check_ingress_policy.sh"
      ;;
    *)
      return 1
      ;;
  esac
}

repo_release_job_hint() {
  case "$1" in
    craftalism-api|craftalism-authorization-server|craftalism-dashboard)
      echo "needs: quality"
      ;;
    craftalism-economy)
      echo "needs: verify-release-commit"
      ;;
    *)
      return 1
      ;;
  esac
}

ci_policy_status() {
  echo "policy gap: required status check names and branch protection enforcement are not configured yet"
}
