#!/usr/bin/env bash

set -euo pipefail

blocked_stage_pattern() {
  cat <<'EOF'
(^|/)build(/|$)
(^|/)\.gradle(/|$)
(^|/)out(/|$)
(^|/)bin(/|$)
(^|/)dist(/|$)
(^|/)node_modules(/|$)
(^|/)\.terraform(/|$)
\.class$
\.jar$
\.war$
\.nar$
\.ear$
\.log$
(^|/)tmp(/|$)
(^|/)temp(/|$)
\.tmp$
\.backup$
\.dump$
(^|/)terraform\.tfstate$
(^|/)terraform\.tfstate\..*$
(^|/)tfplan$
(^|/)\.env$
(^|/)\.env\.local$
(^|/)\.env\.[^/]+\.local$
[^/]+\.env$
\.key$
\.pem$
\.secret$
(^|/)\.idea(/|$)
(^|/)\.vscode(/|$)
\.iml$
\.ipr$
\.iws$
\.swp$
\.swo$
EOF
}

is_allowed_generated_exception() {
  case "$1" in
    .env.example|*/.env.example)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
