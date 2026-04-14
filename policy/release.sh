#!/usr/bin/env bash

set -euo pipefail

release_policy_missing_inputs() {
  printf '%s\n' "CI workflow mapping is not configured yet."
  printf '%s\n' "Compatibility policy content is not configured yet."
  printf '%s\n' "Release gating policy is not fully mapped yet."
}
