#!/usr/bin/env bash

set -euo pipefail

repo_owned_contracts() {
  case "$1" in
    craftalism-api)
      printf '%s\n' "transfer-flow"
      printf '%s\n' "transaction-routes"
      printf '%s\n' "error-semantics"
      printf '%s\n' "idempotency"
      printf '%s\n' "incident-recording"
      ;;
    craftalism-authorization-server)
      printf '%s\n' "auth-issuer (issuance-side)"
      ;;
    *)
      return 0
      ;;
  esac
}

repo_consumed_contracts() {
  case "$1" in
    craftalism)
      printf '%s\n' "all shared contracts as governance reference"
      ;;
    craftalism-infra)
      printf '%s\n' "security/access-control expectations relevant to infra exposure"
      ;;
    craftalism-api)
      printf '%s\n' "auth-issuer (validation-side)"
      ;;
    craftalism-authorization-server)
      printf '%s\n' "auth-issuer ecosystem compatibility requirements"
      ;;
    craftalism-dashboard)
      printf '%s\n' "transaction-routes"
      printf '%s\n' "error-semantics"
      printf '%s\n' "transfer-flow"
      ;;
    craftalism-deployment)
      printf '%s\n' "transfer-flow"
      printf '%s\n' "transaction-routes"
      printf '%s\n' "auth-issuer"
      printf '%s\n' "incident-recording"
      ;;
    craftalism-economy)
      printf '%s\n' "transfer-flow"
      printf '%s\n' "transaction-routes"
      printf '%s\n' "error-semantics"
      printf '%s\n' "idempotency"
      printf '%s\n' "incident-recording"
      printf '%s\n' "auth-issuer"
      ;;
    craftalism-market)
      printf '%s\n' "auth-issuer"
      printf '%s\n' "error-semantics"
      ;;
    *)
      return 0
      ;;
  esac
}

repo_critical_rules() {
  case "$1" in
    craftalism-api)
      printf '%s\n' "API owns canonical routes, transfer semantics, idempotency, incidents, and error taxonomy."
      ;;
    craftalism-dashboard)
      printf '%s\n' "Dashboard does not own API routes or transfer semantics."
      ;;
    craftalism-deployment)
      printf '%s\n' "Deployment owns runtime composition and is the only source of runtime truth."
      ;;
    craftalism-infra)
      printf '%s\n' "Infra owns the AWS boundary but not runtime composition."
      ;;
    craftalism-economy)
      printf '%s\n' "Economy must preserve API idempotency and auth assumptions across retries."
      ;;
    craftalism)
      printf '%s\n' "Root governance defines shared contracts, standards, system summary, and audit context."
      ;;
    craftalism-authorization-server)
      printf '%s\n' "Authorization server owns issuer issuance behavior and must not shift canonical business rules into consumers."
      ;;
    craftalism-market)
      printf '%s\n' "Market consumes auth and error behavior and must not redefine shared contract semantics."
      ;;
    *)
      return 0
      ;;
  esac
}
