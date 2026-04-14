#!/usr/bin/env bash

set -euo pipefail

repo_is_managed() {
  case "$1" in
    craftalism|craftalism-api|craftalism-authorization-server|craftalism-dashboard|craftalism-deployment|craftalism-economy|craftalism-infra|craftalism-market)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

repo_scope() {
  case "$1" in
    craftalism) echo "craftalism" ;;
    craftalism-infra) echo "infra" ;;
    craftalism-api) echo "api" ;;
    craftalism-authorization-server) echo "authorization-server" ;;
    craftalism-dashboard) echo "dashboard" ;;
    craftalism-deployment) echo "deployment" ;;
    craftalism-economy) echo "economy" ;;
    craftalism-market) echo "market" ;;
    *) return 1 ;;
  esac
}

repo_role() {
  case "$1" in
    craftalism) echo "governance, shared contracts, shared standards, audits" ;;
    craftalism-api) echo "authoritative backend behavior for economy operations" ;;
    craftalism-authorization-server) echo "token issuance, OAuth2/OIDC behavior, issuer metadata, discovery, JWKS" ;;
    craftalism-dashboard) echo "frontend read and display client" ;;
    craftalism-deployment) echo "runtime composition, service wiring, environment alignment, operational orchestration" ;;
    craftalism-economy) echo "Minecraft plugin client" ;;
    craftalism-infra) echo "Terraform infrastructure and AWS boundary" ;;
    craftalism-market) echo "Minecraft market plugin" ;;
    *) return 1 ;;
  esac
}

repo_primary_mode() {
  case "$1" in
    craftalism|craftalism-api|craftalism-authorization-server|craftalism-infra|craftalism-deployment)
      echo "owns"
      ;;
    craftalism-dashboard|craftalism-economy|craftalism-market)
      echo "consumes"
      ;;
    *)
      return 1
      ;;
  esac
}

repo_is_deployable() {
  case "$1" in
    craftalism-api|craftalism-authorization-server|craftalism-dashboard|craftalism-deployment|craftalism-economy|craftalism-market)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

repo_is_taggable() {
  repo_is_deployable "$1"
}
