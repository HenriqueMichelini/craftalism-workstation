#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

gh_status() {
  if has_command gh; then
    echo "available"
  else
    echo "missing"
  fi
}
