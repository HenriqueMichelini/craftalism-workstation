#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/policy/release.sh"

release_policy_gap_message() {
  echo "policy gap: release policy inputs are not fully configured yet"
}
