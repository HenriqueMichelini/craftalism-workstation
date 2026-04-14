# Craftalism Workstation Bootstrap v1

## Repository tree

```text
craftalism-workstation/
  bin/
    work-status
    work-context
    work-ownership-check
    work-docs
    work-audit-pack
    work-checklist
    work-commit
    work-verify
  lib/
    common.sh
    repo.sh
    git.sh
    verify.sh
    docs.sh
  policy/
    repos.sh
    commit.sh
    verify.sh
    docs.sh
    generated-files.sh
    contracts.sh
    reading-order.sh
  docs/
    workstation-spec.md
    command-reference.md
    rollout-plan.md
  install/
    work.sh
```

---

## `install/work.sh`

```bash
#!/usr/bin/env bash

WORKSTATION_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

workstation_prepend_path() {
  case ":$PATH:" in
    *":$WORKSTATION_ROOT/bin:"*) ;;
    *) export PATH="$WORKSTATION_ROOT/bin:$PATH" ;;
  esac
}

workstation_prepend_path
export CRAFTALISM_WORKSTATION_ROOT="$WORKSTATION_ROOT"
export WORKSTATION_STATE_DIR="${HOME}/.workstation/state"
```

Usage in `~/.bashrc` or `~/.zshrc`:

```bash
source "$HOME/IdeaProjects/craftalism-workstation/install/work.sh"
```

---

## `policy/repos.sh`

```bash
#!/usr/bin/env bash

repo_is_managed() {
  case "$1" in
    craftalism|\
    craftalism-infra|\
    craftalism-api|\
    craftalism-authorization-server|\
    craftalism-dashboard|\
    craftalism-deployment|\
    craftalism-economy|\
    craftalism-market)
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
    craftalism) echo "governance" ;;
    craftalism-infra) echo "infrastructure" ;;
    craftalism-api) echo "service" ;;
    craftalism-authorization-server) echo "service" ;;
    craftalism-dashboard) echo "service" ;;
    craftalism-deployment) echo "service" ;;
    craftalism-economy) echo "service" ;;
    craftalism-market) echo "service" ;;
    *) return 1 ;;
  esac
}

repo_is_deployable() {
  case "$1" in
    craftalism-api|\
    craftalism-authorization-server|\
    craftalism-dashboard|\
    craftalism-deployment|\
    craftalism-economy|\
    craftalism-market)
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
```

---

## `policy/commit.sh`

```bash
#!/usr/bin/env bash

commit_allowed_types_regex='feat|fix|refactor|perf|docs|chore|test|ci|security'

commit_message_is_valid() {
  local repo_name="$1"
  local message="$2"
  local expected_scope
  expected_scope="$(repo_scope "$repo_name")" || return 1

  [[ "$message" =~ ^(${commit_allowed_types_regex})\(${expected_scope}\):\ .+ ]] || return 1
}

commit_validation_error() {
  local repo_name="$1"
  local message="$2"
  local expected_scope
  expected_scope="$(repo_scope "$repo_name")" || {
    echo "unknown managed repo"
    return 0
  }

  if [[ -z "$message" ]]; then
    echo "commit message required"
    return 0
  fi

  if [[ ! "$message" =~ ^(${commit_allowed_types_regex})\(.+\):\ .+ ]]; then
    echo "expected format: <type>(${expected_scope}): <summary>"
    return 0
  fi

  if [[ ! "$message" =~ ^(${commit_allowed_types_regex})\(${expected_scope}\):\ .+ ]]; then
    echo "scope must be '${expected_scope}' for repo '${repo_name}'"
    return 0
  fi

  echo "invalid commit message"
}
```

---

## `policy/verify.sh`

```bash
#!/usr/bin/env bash

repo_verify_mode() {
  case "$1" in
    craftalism-api|\
    craftalism-authorization-server|\
    craftalism-economy|\
    craftalism-market|\
    craftalism-dashboard|\
    craftalism-infra)
      echo "automated"
      ;;
    craftalism|\
    craftalism-deployment)
      echo "manual"
      ;;
    *)
      return 1
      ;;
  esac
}

repo_verify_command() {
  case "$1" in
    craftalism-api|craftalism-authorization-server|craftalism-economy|craftalism-market)
      echo "./gradlew test"
      ;;
    craftalism-dashboard)
      echo "cd react && npm run test"
      ;;
    craftalism-infra)
      cat <<'EOF'
terraform fmt -check
terraform init -backend=false
terraform validate
./scripts/check_ingress_policy.sh
EOF
      ;;
    craftalism|craftalism-deployment)
      return 1
      ;;
    *)
      return 1
      ;;
  esac
}
```

---

## `policy/docs.sh`

This policy should align with AGENTS.md across repos by making the expected local control docs explicit:
- `docs/repo-contract-map.md`
- `docs/repo-requirement-pack.md`

AGENTS.md files should name these directly instead of placeholder text.

```bash
#!/usr/bin/env bash

repo_required_docs_exist() {
  local repo_name
  repo_name="$(current_repo_name)"

  case "$repo_name" in
    craftalism)
      [[ -f docs/governance-precedence.md ]] &&
      [[ -f docs/system-summary.md ]] &&
      [[ -d docs/contracts ]] &&
      [[ -d docs/standards ]] &&
      [[ -d docs/audit ]]
      ;;
    *)
      [[ -f docs/repo-contract-map.md ]] && [[ -f docs/repo-requirement-pack.md ]]
      ;;
  esac
}

repo_missing_docs() {
  local repo_name
  local missing=()

  repo_name="$(current_repo_name)"

  case "$repo_name" in
    craftalism)
      [[ -f docs/governance-precedence.md ]] || missing+=("docs/governance-precedence.md")
      [[ -f docs/system-summary.md ]] || missing+=("docs/system-summary.md")
      [[ -d docs/contracts ]] || missing+=("docs/contracts/")
      [[ -d docs/standards ]] || missing+=("docs/standards/")
      [[ -d docs/audit ]] || missing+=("docs/audit/")
      ;;
    *)
      [[ -f docs/repo-contract-map.md ]] || missing+=("docs/repo-contract-map.md")
      [[ -f docs/repo-requirement-pack.md ]] || missing+=("docs/repo-requirement-pack.md")
      ;;
  esac

  printf '%s
' "${missing[@]}"
}
```

---

## `policy/generated-files.sh`

```bash
#!/usr/bin/env bash

staged_path_is_blocked() {
  local path="$1"

  case "$path" in
    *.class|*.jar|*.war|*.nar|*.ear|*.log|*.tmp|*.backup|*.dump|*.key|*.pem|*.secret)
      return 0
      ;;
    .env|.env.local|.env.*.local|*.env)
      [[ "$path" == ".env.example" ]] && return 1
      return 0
      ;;
    .idea/*|.vscode/*|*.iml|*.ipr|*.iws|*.swp|*.swo)
      return 0
      ;;
    build/*|.gradle/*|out/*|bin/*|node_modules/*|dist/*|.terraform/*|tmp/*|temp/*)
      return 0
      ;;
    terraform.tfstate|terraform.tfstate.*|tfplan)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
```

---

## `lib/common.sh`

```bash
#!/usr/bin/env bash

set -euo pipefail

work_die() {
  echo "❌ $*" >&2
  exit 1
}

work_warn() {
  echo "⚠️  $*" >&2
}

work_info() {
  echo "ℹ️  $*"
}

work_require_repo_root() {
  git rev-parse --show-toplevel >/dev/null 2>&1 || work_die "not inside a git repository"
}
```

---

## `lib/repo.sh`

```bash
#!/usr/bin/env bash

source "${CRAFTALISM_WORKSTATION_ROOT}/policy/repos.sh"

current_repo_root() {
  git rev-parse --show-toplevel
}

current_repo_name() {
  basename "$(current_repo_root)"
}

current_repo_is_managed() {
  repo_is_managed "$(current_repo_name)"
}

require_managed_repo() {
  local repo_name
  repo_name="$(current_repo_name)"
  repo_is_managed "$repo_name" || work_die "repo '$repo_name' is not managed by workstation policy"
}
```

---

## `lib/git.sh`

```bash
#!/usr/bin/env bash

git_tree_is_clean() {
  [[ -z "$(git status --porcelain)" ]]
}

git_current_branch() {
  git branch --show-current
}

git_head_sha() {
  git rev-parse HEAD
}

git_head_is_pushed() {
  git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1 || return 1
  local upstream_sha head_sha
  upstream_sha="$(git rev-parse '@{u}')"
  head_sha="$(git rev-parse HEAD)"
  [[ "$upstream_sha" == "$head_sha" ]]
}

staged_paths() {
  git diff --cached --name-only
}
```

---

## `lib/verify.sh`

```bash
#!/usr/bin/env bash

source "${CRAFTALISM_WORKSTATION_ROOT}/policy/verify.sh"

verify_state_dir() {
  local repo_name="$1"
  echo "${WORKSTATION_STATE_DIR}/verify/${repo_name}"
}

verify_state_file() {
  local repo_name="$1"
  local sha="$2"
  echo "$(verify_state_dir "$repo_name")/${sha}.ok"
}

verify_mark_success() {
  local repo_name="$1"
  local sha="$2"
  local command="$3"

  mkdir -p "$(verify_state_dir "$repo_name")"
  cat >"$(verify_state_file "$repo_name" "$sha")" <<EOF
repo=${repo_name}
sha=${sha}
verified_at=$(date -Iseconds)
command=${command}
result=success
EOF
}

verify_has_success_for_head() {
  local repo_name="$1"
  local sha="$2"
  [[ -f "$(verify_state_file "$repo_name" "$sha")" ]]
}
```

---

## `policy/contracts.sh`

```bash
#!/usr/bin/env bash

repo_owned_contracts() {
  case "$1" in
    craftalism-api)
      printf '%s
' "transfer-flow" "transaction-routes" "error-semantics" "idempotency" "incident-recording"
      ;;
    craftalism-authorization-server)
      printf '%s
' "auth-issuer (issuance-side)"
      ;;
    *)
      return 0
      ;;
  esac
}

repo_consumed_contracts() {
  case "$1" in
    craftalism)
      printf '%s
' "all shared contracts (governance reference)"
      ;;
    craftalism-infra)
      printf '%s
' "security-access-control"
      ;;
    craftalism-api)
      printf '%s
' "auth-issuer (validation-side)"
      ;;
    craftalism-authorization-server)
      printf '%s
' "auth-issuer ecosystem compatibility requirements"
      ;;
    craftalism-dashboard)
      printf '%s
' "transaction-routes" "error-semantics" "transfer-flow"
      ;;
    craftalism-deployment)
      printf '%s
' "transfer-flow" "transaction-routes" "auth-issuer" "incident-recording"
      ;;
    craftalism-economy)
      printf '%s
' "transfer-flow" "transaction-routes" "error-semantics" "idempotency" "incident-recording" "auth-issuer"
      ;;
    craftalism-market)
      printf '%s
' "auth-issuer" "error-semantics"
      ;;
    *)
      return 0
      ;;
  esac
}

repo_critical_rules() {
  case "$1" in
    craftalism)
      printf '%s
' \
        "owns ecosystem governance and must not redefine repo-local runtime behavior" \
        "contracts and standards outrank audit findings and repo-local docs"
      ;;
    craftalism-infra)
      printf '%s
' \
        "owns AWS boundary only, not runtime composition" \
        "must not replace deployment as source of runtime truth"
      ;;
    craftalism-api)
      printf '%s
' \
        "owns canonical economy routes, transfer semantics, idempotency, incidents, and error taxonomy" \
        "must validate issuer alignment on protected operations"
      ;;
    craftalism-authorization-server)
      printf '%s
' \
        "owns token issuance, discovery metadata, and JWKS behavior" \
        "must not redefine API-side issuer validation semantics"
      ;;
    craftalism-dashboard)
      printf '%s
' \
        "does not own API routes or transfer semantics" \
        "must mirror canonical route and error contracts exactly"
      ;;
    craftalism-deployment)
      printf '%s
' \
        "owns runtime composition and environment alignment" \
        "is the only source of runtime truth for image/version wiring"
      ;;
    craftalism-economy)
      printf '%s
' \
        "does not own canonical transfer behavior" \
        "must preserve API idempotency and auth assumptions across retries"
      ;;
    craftalism-market)
      printf '%s
' \
        "must not redefine shared auth or API semantics outside owned market behavior" \
        "consumer-side docs and tests must align with shared standards"
      ;;
    *)
      return 0
      ;;
  esac
}
```

---

## `policy/reading-order.sh`

```bash
#!/usr/bin/env bash

repo_relevant_contracts() {
  case "$1" in
    craftalism)
      printf '%s
' "auth-issuer.md" "error-semantics.md" "idempotency.md" "incident-recording.md" "transaction-routes.md" "transfer-flow.md"
      ;;
    craftalism-infra)
      printf '%s
' "security-access-control.md"
      ;;
    craftalism-api)
      printf '%s
' "auth-issuer.md" "error-semantics.md" "idempotency.md" "incident-recording.md" "transaction-routes.md" "transfer-flow.md"
      ;;
    craftalism-authorization-server)
      printf '%s
' "auth-issuer.md"
      ;;
    craftalism-dashboard)
      printf '%s
' "transaction-routes.md" "error-semantics.md" "transfer-flow.md"
      ;;
    craftalism-deployment)
      printf '%s
' "auth-issuer.md" "incident-recording.md" "transaction-routes.md" "transfer-flow.md"
      ;;
    craftalism-economy)
      printf '%s
' "auth-issuer.md" "error-semantics.md" "idempotency.md" "incident-recording.md" "transaction-routes.md" "transfer-flow.md"
      ;;
    craftalism-market)
      printf '%s
' "auth-issuer.md" "error-semantics.md"
      ;;
    *)
      return 0
      ;;
  esac
}

repo_relevant_standards() {
  case "$1" in
    craftalism|craftalism-api|craftalism-authorization-server|craftalism-dashboard|craftalism-deployment|craftalism-economy|craftalism-market)
      printf '%s
' "ci-cd.md" "documentation.md" "security-access-control.md" "testing.md"
      ;;
    craftalism-infra)
      printf '%s
' "ci-cd.md" "documentation.md" "security-access-control.md"
      ;;
    *)
      return 0
      ;;
  esac
}
```

---

## `lib/docs.sh`

```bash
#!/usr/bin/env bash

source "${CRAFTALISM_WORKSTATION_ROOT}/policy/reading-order.sh"

root_doc_base() {
  echo "$HOME/IdeaProjects/craftalism/docs"
}

print_reading_order() {
  local repo_name="$1"
  local base
  base="$(root_doc_base)"

  echo "1. ${base}/governance-precedence.md"
  echo "2. ${base}/system-summary.md"
  echo "3. relevant contracts:"
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    echo "   - ${base}/contracts/${file}"
  done < <(repo_relevant_contracts "$repo_name")

  echo "4. relevant standards:"
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    echo "   - ${base}/standards/${file}"
  done < <(repo_relevant_standards "$repo_name")

  echo "5. ${base}/audit/"

  case "$repo_name" in
    craftalism)
      echo "6. ${base}/governance-precedence.md (root-owned required doc)"
      echo "7. ${base}/system-summary.md (root-owned required doc)"
      ;;
    *)
      echo "6. $(current_repo_root)/docs/repo-contract-map.md"
      echo "7. $(current_repo_root)/docs/repo-requirement-pack.md"
      ;;
  esac
}
```

---

## `bin/work-status`

```bash
#!/usr/bin/env bash

source "${CRAFTALISM_WORKSTATION_ROOT}/lib/common.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/lib/repo.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/lib/git.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/lib/verify.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/policy/docs.sh"

work_require_repo_root
require_managed_repo

repo_name="$(current_repo_name)"
repo_role_value="$(repo_role "$repo_name")"
scope="$(repo_scope "$repo_name")"
branch="$(git_current_branch)"
sha="$(git_head_sha)"

if git_tree_is_clean; then
  tree_state="clean"
else
  tree_state="dirty"
fi

if repo_required_docs_exist; then
  docs_state="present"
else
  docs_state="missing"
fi

if verify_has_success_for_head "$repo_name" "$sha"; then
  verify_state="verified"
else
  verify_state="not-verified"
fi

if repo_is_deployable "$repo_name"; then
  deployable_state="yes"
else
  deployable_state="no"
fi

if repo_is_taggable "$repo_name"; then
  taggable_state="yes"
else
  taggable_state="no"
fi

cat <<EOF
repo: ${repo_name}
role: ${repo_role_value}
scope: ${scope}
branch: ${branch}
head: ${sha}
tree: ${tree_state}
docs: ${docs_state}
verify: ${verify_state}
deployable: ${deployable_state}
taggable: ${taggable_state}
EOF

if ! repo_required_docs_exist; then
  work_warn "missing required docs:"
  repo_missing_docs | sed 's/^/  - /'
fi
```

---

## `bin/work-context`

```bash
#!/usr/bin/env bash

source "${CRAFTALISM_WORKSTATION_ROOT}/lib/common.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/lib/repo.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/policy/contracts.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/policy/verify.sh"

work_require_repo_root
require_managed_repo

repo_name="$(current_repo_name)"
role="$(repo_role "$repo_name")"
scope="$(repo_scope "$repo_name")"
verify_mode="$(repo_verify_mode "$repo_name")"

cat <<EOF
repo: ${repo_name}
role: ${role}
scope: ${scope}
verify-mode: ${verify_mode}
EOF

echo

echo "owns:"
owned="$(repo_owned_contracts "$repo_name")"
if [[ -n "$owned" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "  - $line"
  done <<< "$owned"
else
  echo "  - none"
fi

echo

echo "consumes:"
consumed="$(repo_consumed_contracts "$repo_name")"
if [[ -n "$consumed" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "  - $line"
  done <<< "$consumed"
else
  echo "  - none"
fi

echo

echo "critical-rules:"
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  echo "  - $line"
done < <(repo_critical_rules "$repo_name")

echo
if [[ "$verify_mode" == "automated" ]]; then
  echo "verify-command:"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "  $line"
  done < <(repo_verify_command "$repo_name")
else
  echo "verify-command: manual"
fi
```

---

## `bin/work-ownership-check`

```bash
#!/usr/bin/env bash

source "${CRAFTALISM_WORKSTATION_ROOT}/lib/common.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/lib/repo.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/policy/contracts.sh"

work_require_repo_root
require_managed_repo

repo_name="$(current_repo_name)"
role="$(repo_role "$repo_name")"

cat <<EOF
You are in: ${repo_name}
role: ${role}
EOF

echo
owned="$(repo_owned_contracts "$repo_name")"
if [[ -n "$owned" ]]; then
  echo "This repo owns:"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "  - $line"
  done <<< "$owned"
else
  echo "This repo owns no shared contracts."
fi

echo
consumed="$(repo_consumed_contracts "$repo_name")"
if [[ -n "$consumed" ]]; then
  echo "This repo must conform to:"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "  - $line"
  done <<< "$consumed"
fi

echo
case "$repo_name" in
  craftalism-dashboard|craftalism-economy|craftalism-market)
    cat <<'EOF'
If your change modifies routes, transfer semantics, issuer behavior, or canonical API error rules:
➡️ STOP: the change likely belongs in an owning repo or in root governance first.
EOF
    ;;
  craftalism-deployment)
    cat <<'EOF'
If your change modifies runtime wiring, issuer alignment, or deployment assumptions:
➡️ keep it here.
If it changes canonical service behavior or shared contracts:
➡️ STOP and change the owning repo or root governance first.
EOF
    ;;
  craftalism)
    cat <<'EOF'
If your change modifies ecosystem-wide policy, contracts, or standards:
➡️ keep it here first.
If it modifies repo-local implementation behavior:
➡️ STOP and change the owning repo.
EOF
    ;;
  *)
    echo "Use governance precedence before implementation work."
    ;;
esac
```

---

## `bin/work-docs`

```bash
#!/usr/bin/env bash

source "${CRAFTALISM_WORKSTATION_ROOT}/lib/common.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/lib/repo.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/lib/docs.sh"

work_require_repo_root
require_managed_repo

repo_name="$(current_repo_name)"
print_reading_order "$repo_name"
```

---

## `bin/work-audit-pack`

```bash
#!/usr/bin/env bash

source "${CRAFTALISM_WORKSTATION_ROOT}/lib/common.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/lib/repo.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/lib/docs.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/policy/contracts.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/policy/verify.sh"

work_require_repo_root
require_managed_repo

repo_name="$(current_repo_name)"
role="$(repo_role "$repo_name")"
scope="$(repo_scope "$repo_name")"
verify_mode="$(repo_verify_mode "$repo_name")"

cat <<EOF
repo: ${repo_name}
role: ${role}
scope: ${scope}

governance-precedence:
  1. shared contracts
  2. shared standards
  3. system summary
  4. repo-contract-map
  5. repo-requirement-pack
  6. point-in-time audit artifacts

reading-order:
EOF
print_reading_order "$repo_name" | sed 's/^/  /'

echo

echo "ownership:"
owned="$(repo_owned_contracts "$repo_name")"
if [[ -n "$owned" ]]; then
  echo "  owns:"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "    - $line"
  done <<< "$owned"
else
  echo "  owns: none"
fi

echo "  consumes:"
consumed="$(repo_consumed_contracts "$repo_name")"
if [[ -n "$consumed" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "    - $line"
  done <<< "$consumed"
else
  echo "    - none"
fi

echo

echo "critical-rules:"
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  echo "  - $line"
done < <(repo_critical_rules "$repo_name")

echo

echo "verification:"
if [[ "$verify_mode" == "automated" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "  - $line"
  done < <(repo_verify_command "$repo_name")
else
  echo "  - manual"
fi

echo
cat <<EOF
codex-prompt:
  Read the project docs and relevant standards first.
  Identify whether this codebase owns or consumes the behavior.
  Resolve conflicts using governance precedence.
  Do not redefine shared contracts locally.
  Make the smallest correct change.
  Update tests/docs if required.
  Run relevant verification.
  Summarize any follow-up that belongs in another repo or root governance.
EOF
```

---

## `docs/command-reference.md`

```md
# Command Reference

## work-status
Shows repository policy state for the current repo.

## work-context
Shows repo role, owned/consumed contracts, critical rules, and verification mode.

## work-ownership-check
Reminds the operator what this repo owns and what must be changed elsewhere.

## work-docs
Prints the governance-aware reading order for the current repo.

## work-audit-pack
Prints a Codex-ready audit pack for the current repo.

## work-checklist
Prints a repo-aware implementation and reverify checklist.

## work-commit "type(scope): summary"
Validates the commit message, stages changes, blocks unsafe files, commits, and pushes `main`.

## work-verify
Runs the repo verification policy and records success for the current HEAD.
```

---

## `docs/rollout-plan.md`

```md
# Rollout Plan

## Phase 1
- implement work-status
- implement work-commit
- implement work-verify
- verify repo detection and scope validation
- verify generated file blocking
- verify state storage under ~/.workstation/state
- align commit validation with Codex commit-standard skill

## Phase 1.5
- add work-context
- add work-ownership-check
- add work-docs
- add work-audit-pack
- align reading order with governance precedence
- align shell commands with ownership rules and contracts
- make AGENTS local-doc expectations explicit

## Phase 2
- add work-checklist
- add contract-affecting change warnings in work-commit
- add richer repo-aware policy output
- make docs policy fully repo-aware
- add a cross-repo contract-change checklist standard
- add workstation/release-readiness skills

## Phase 3
- add work-tag
- add work-release-check
- add work-platform-status
- integrate gh CLI for CI checks
- add deployment digest validation
- map exact CI workflow/status check names per repo
- define ecosystem smoke-check policy

## Phase 4
- add gitignore/generated-files root standard
- add compatibility matrix and release-history support
- add AGENTS drift detection or generation
````

---

## `docs/workstation-spec.md`

Use the audited spec we finalized as the baseline content for this file.

Add these explicit alignment notes:
- workstation commit validation MUST match the Codex `commit-standard` skill exactly
- governance precedence MUST be enforced consistently by `work-docs`, `work-audit-pack`, `work-checklist`, and future release commands
- repo-local control docs are explicitly `docs/repo-contract-map.md` and `docs/repo-requirement-pack.md`
- release-related commands should rely on shared standards, not ad-hoc shell assumptions
- future policy warnings should distinguish shared contracts from shared standards cleanly

---

## `bin/work-commit`

```bash
#!/usr/bin/env bash

source "${CRAFTALISM_WORKSTATION_ROOT}/lib/common.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/lib/repo.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/lib/git.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/policy/commit.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/policy/docs.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/policy/generated-files.sh"

work_require_repo_root
require_managed_repo

repo_name="$(current_repo_name)"
message="${1:-}"

commit_message_is_valid "$repo_name" "$message" || work_die "$(commit_validation_error "$repo_name" "$message")"
repo_required_docs_exist || work_die "required docs missing"

git add .

blocked=()
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  if staged_path_is_blocked "$path"; then
    blocked+=("$path")
  fi
done < <(staged_paths)

if (( ${#blocked[@]} > 0 )); then
  printf '❌ blocked staged paths:
' >&2
  printf '  - %s
' "${blocked[@]}" >&2
  exit 1
fi

git diff --cached --quiet && work_die "nothing to commit"

git commit -m "$message"
git push origin main
```

---

## `bin/work-checklist`

```bash
#!/usr/bin/env bash

source "${CRAFTALISM_WORKSTATION_ROOT}/lib/common.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/lib/repo.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/policy/contracts.sh"
source "${CRAFTALISM_WORKSTATION_ROOT}/policy/verify.sh"

work_require_repo_root
require_managed_repo

repo_name="$(current_repo_name)"
role="$(repo_role "$repo_name")"
verify_mode="$(repo_verify_mode "$repo_name")"

cat <<EOF
repo: ${repo_name}
role: ${role}

implementation-checklist:
  - confirm ownership before editing
  - read governance precedence and system summary first
  - read relevant contracts and standards for this repo
  - make the smallest correct change
  - update repo-local docs if required
  - avoid redefining shared behavior in a consumer repo
EOF

owned="$(repo_owned_contracts "$repo_name")"
if [[ -n "$owned" ]]; then
  echo "  - verify owned contract behavior remains authoritative"
fi

consumed="$(repo_consumed_contracts "$repo_name")"
if [[ -n "$consumed" ]]; then
  echo "  - verify consumed contracts are mirrored, not redefined"
fi

cat <<EOF

reverify-checklist:
  - inspect the diff for scope creep
  - rerun repo verification
  - confirm required docs still exist
  - confirm README and local control docs do not contradict root governance
  - identify any follow-up required in another repo or in root governance
EOF

if [[ "$verify_mode" == "automated" ]]; then
  echo "  - automated verify is required before tagging"
else
  echo "  - manual verify path exists today; formal automation is still a policy gap"
fi
```

---

## Bootstrapping checklist

1. Create the `craftalism-workstation` repo.
2. Add the file tree above.
3. `chmod +x bin/* install/work.sh`
4. Add `source ~/IdeaProjects/craftalism-workstation/install/work.sh` to shell config.
5. Open a new shell.
6. Run `work-status` inside one managed repo.
7. Run `work-context` and `work-ownership-check` in one consumer repo.
8. Run `work-docs` to confirm reading order output.
9. Run `work-verify` in `craftalism-api`.
10. Run `work-commit "docs(api): test workstation commit"` in a safe test change.

---

## Recommended next audit pass

After the bootstrap exists, audit these together so the workstation and platform governance line up:

1. root docs in `craftalism`
2. repo-local docs in each repo
3. AGENTS / Codex prompts in use
4. skills content and overlap
5. gitignore consistency across repos
6. verification commands and CI workflow naming
7. release unit compatibility matrix expectations
8. market ownership/governance mapping

That audit should answer:
- which root contracts apply to each repo
- which standards should become workstation policy
- where prompts/agents duplicate docs
- which checks belong local vs CI
- which docs should be generated vs maintained manually
- how release readiness should be proven across all deployable repos

---

## Additional governance items still to add in root docs

### Cross-repo contract-change checklist
A root governance document should define the mandatory same-cycle checks when a change affects:
- routes
- auth behavior
- error semantics
- idempotency
- incident behavior
- deployment/runtime assumptions

It should be consumed by:
- AGENTS.md
- Codex prompt templates
- `work-checklist`
- `work-release-check`

### Gitignore / generated-files standard
A root standard should define:
- shared ignore categories
- generated artifact blocking expectations
- safe examples/exceptions such as `.env.example`
- repo-specific overlays for Java, Node, and Terraform

### Compatibility matrix / ecosystem release history
A root governance page should define:
- which repo versions/tags are intended to run together
- what constitutes an ecosystem release unit
- how compatibility drift is communicated

### AGENTS alignment task
All AGENTS files should explicitly name repo-local docs as:
- `docs/repo-contract-map.md`
- `docs/repo-requirement-pack.md`

and should remove placeholder text like `repo-local docs (, )`.

### Commit standard alignment task
The workstation should validate the same repo scopes and types defined by the Codex `commit-standard` skill:
- scopes: `api`, `economy`, `authorization-server`, `dashboard`, `deployment`, `infra`, `craftalism`, `market`
- types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `ci`, `chore`, `security`
```



---

# Final Version Specification

## 1. Final Objective

The final Craftalism workstation is a governance-aware engineering workstation for the full platform.

It must:
- enforce repository-local discipline
- reflect shared contracts and shared standards
- guide Codex and human operators through the same ownership model
- provide local confidence before CI
- provide release-readiness checks grounded in platform governance
- avoid redefining missing governance artifacts in shell logic

The final version is not only a workstation repo.
It is the combination of:
- `craftalism-workstation`
- completed root governance docs in `craftalism`
- aligned AGENTS/docs/CI expectations across managed repos

---

## 2. Final Command Set

### Operator / daily commands
- `work-status`
- `work-context`
- `work-ownership-check`
- `work-docs`
- `work-checklist`
- `work-commit "type(scope): summary"`
- `work-verify`

### Audit / Codex commands
- `work-audit-pack`
- `work-contract-change-check`

### Release / platform commands
- `work-tag vX.Y.Z`
- `work-release-check`
- `work-platform-status`

### Optional support commands
- `work-help`
- `work-version`
- `work-doctor`

---

## 3. Final Command Behavior

### `work-status`
Shows:
- repo name
- role
- canonical scope
- branch
- head SHA
- clean/dirty tree
- required docs present/missing
- verify status for HEAD
- deployable/taggable status
- warnings

### `work-context`
Shows:
- whether the repo owns or consumes the behavior
- owned contracts
- consumed contracts
- critical rules
- verification mode
- release relevance

### `work-ownership-check`
Shows the ownership boundary before edits begin.
It should explicitly warn when the current repo must not redefine shared behavior owned elsewhere.

### `work-docs`
Prints the governance-aware reading order using the exact precedence model:
1. governance precedence
2. system summary
3. relevant contracts
4. relevant standards
5. relevant audit artifacts
6. repo-local control docs

### `work-checklist`
Prints implementation + reverify checklist for the current repo.
It must include:
- ownership confirmation
- required reading
- owned vs consumed contract reminder
- verify expectation
- docs consistency reminder
- follow-up boundary reminder

### `work-commit`
Must:
- validate commit message against Codex commit standard
- stage changes
- block unsafe generated/sensitive files
- fail if required docs are missing
- warn for possible contract-affecting changes when heuristics detect them
- commit and push `main`

### `work-verify`
Must:
- run repo-specific verification commands where defined
- record verification proof for current HEAD
- clearly report manual-policy gaps where local automation does not yet exist

### `work-audit-pack`
Must generate a Codex-ready audit pack containing:
- repo summary
- ownership model
- governance precedence summary
- reading order
- owned/consumed contracts
- critical rules
- verify expectations
- Codex prompt block

### `work-contract-change-check`
Must print the required same-cycle checks when a change may affect:
- routes
- auth behavior
- error semantics
- idempotency
- incident behavior
- deployment/runtime assumptions

This command should be backed by a root governance checklist, not ad-hoc shell text.

### `work-tag`
Must:
- validate tag format `vX.Y.Z`
- fail unless current repo is taggable
- fail unless branch is `main`
- fail unless tree is clean
- fail unless HEAD is pushed
- fail unless local verify proof exists for HEAD
- fail unless latest CI for HEAD is green
- fail if required docs are missing
- fail if release-specific policy violations exist

### `work-release-check`
Must support:
- current-repo release readiness
- all-deployables release readiness

It must validate:
- docs presence
- verification proof
- exact CI success on current pushed SHA
- release-related policy gaps
- deployment digest/reference integrity
- placeholder digest rejection
- compatibility matrix presence when checking full platform release

### `work-platform-status`
Must summarize all deployable repos together.
Suggested fields:
- repo
- branch
- clean/dirty
- local HEAD
- pushed alignment
- verify status
- CI state
- docs state
- release readiness
- notes/warnings

### `work-help`
Must provide concise help for commands and expected usage.

### `work-version`
Must print workstation version and maybe policy version.

### `work-doctor`
Must validate workstation installation and dependencies, including:
- shell installation state
- executable permissions
- `git`
- `gh` for release commands
- repo policy files available
- state directory writable

---

## 4. Final Policy Model

The final workstation must draw authority from policy, not from hardcoded hidden assumptions.

### Policy domains
- repository identity and role
- commit standard
- verification commands and modes
- docs requirements
- contract ownership and consumption
- reading order / governance precedence
- generated-file blocking
- release readiness requirements
- CI workflow/status mapping
- compatibility matrix requirements

### Policy principle
If a rule depends on platform governance, prefer a root-governed artifact or explicit workstation policy file over embedding business logic directly in a command.

---

## 5. Final Repository Scope Mapping

Canonical scopes must match the Codex commit skill exactly:
- `craftalism`
- `infra`
- `api`
- `authorization-server`
- `dashboard`
- `deployment`
- `economy`
- `market`

Allowed commit types must match the Codex skill set:
- `feat`
- `fix`
- `refactor`
- `perf`
- `docs`
- `test`
- `ci`
- `chore`
- `security`

---

## 6. Final Verification Policy

### Automated verify
- `craftalism-api` → `./gradlew test`
- `craftalism-authorization-server` → `./gradlew test`
- `craftalism-economy` → `./gradlew test`
- `craftalism-market` → `./gradlew test`
- `craftalism-dashboard` → `cd react && npm run test`
- `craftalism-infra` →
  - `terraform fmt -check`
  - `terraform init -backend=false`
  - `terraform validate`
  - `./scripts/check_ingress_policy.sh`

### Manual-policy gap
- `craftalism`
- `craftalism-deployment`

The final version should still report these honestly as manual-policy gaps unless automation is added.

### Verification state
Verification proof must live outside managed repos, for example:
- `~/.workstation/state/verify/<repo>/<sha>.ok`

---

## 7. Final Root Governance Dependencies

The final workstation depends on the following root governance artifacts existing in `craftalism`.

### Already present / already modeled
- governance precedence
- system summary
- shared contracts
- shared standards
- audits

### Must be added for final-version completeness
- cross-repo contract-change checklist
- gitignore / generated-files standard
- compatibility matrix
- ecosystem release-history or milestone summary

These are not optional for a polished final system because release and consistency commands depend on them.

---

## 8. Required Root Governance Docs To Add

### `docs/standards/commit-format.md` or equivalent
Should formally document the commit format now enforced by skills and workstation.

### `docs/standards/gitignore-generated-files.md` or equivalent
Should define:
- shared ignore categories
- generated artifact blocking
- secrets blocking
- allowed example-file exceptions
- repo-local overlays

### `docs/contracts-or-checklists/cross-repo-contract-change-checklist.md` or equivalent
Should define mandatory same-cycle checks when shared behavior changes.

### `docs/compatibility-matrix.md`
Should define which versions/tags are intended to run together.

### `docs/release-history.md` or equivalent
Should summarize ecosystem releases/milestones at platform level.

---

## 9. Final AGENTS Alignment Requirements

All AGENTS files across repos should:
- explicitly name `docs/repo-contract-map.md`
- explicitly name `docs/repo-requirement-pack.md`
- remove placeholder `repo-local docs (, )`
- keep repo purpose/ownership specific
- keep the workflow and boundary rules consistent

A future validation script should detect AGENTS drift.

---

## 10. Final Repo Alignment Checklist

### All repos
- AGENTS cleaned up
- repo-local control docs present
- README/contract references aligned with root contracts and standards
- verify command confirmed
- CI quality workflow name identified

### Root `craftalism`
- missing governance docs added
- compatibility/release-history layer added
- market governance mapping clarified if still ambiguous

### `craftalism-deployment`
- release/digest policy clarified enough for workstation checks
- placeholder-digest rejection rules made explicit in docs
- verify automation improved when ready

### `craftalism-infra`
- CI workflow name and validation command names confirmed
- infra/deployment ownership boundary stated clearly in docs

### `craftalism-dashboard`
- verify command and CI workflow names aligned
- trust-boundary documentation stays explicit

### `craftalism-market`
- owned vs consumed contract mapping clarified in root docs and/or local docs

---

## 11. Final Release Readiness Model

The final release-readiness model should be based on standards, not intuition.

### Current-repo readiness requires
- clean tree
- correct branch
- pushed HEAD
- local verify proof
- CI green on exact HEAD
- required docs present
- no blocked policy issues

### Full-platform readiness requires
- all deployable repos satisfy current-repo readiness
- compatibility matrix exists and is current
- deployment references are aligned
- placeholder digests are absent
- ecosystem smoke/integration policy is satisfied

---

## 12. Final CI Integration Requirements

Release-related commands may require `gh`.

The final policy must map, per repo:
- quality workflow name
- expected required status checks
- whether release check should verify one workflow or multiple checks
- which workflow counts as ecosystem smoke/integration validation

Until this mapping exists, release commands should fail honestly with a policy gap message rather than guessing.

---

## 13. Final File Tree

```text
craftalism-workstation/
  bin/
    work-status
    work-context
    work-ownership-check
    work-docs
    work-audit-pack
    work-checklist
    work-contract-change-check
    work-commit
    work-verify
    work-tag
    work-release-check
    work-platform-status
    work-help
    work-version
    work-doctor
  lib/
    common.sh
    repo.sh
    git.sh
    verify.sh
    docs.sh
    release.sh
    github.sh
    doctor.sh
  policy/
    repos.sh
    commit.sh
    verify.sh
    docs.sh
    generated-files.sh
    contracts.sh
    reading-order.sh
    release.sh
    ci.sh
    compatibility.sh
  templates/
    audit-prompt.md
    implementation-checklist.md
    contract-change-checklist.md
    gitignore/
      common.gitignore
      java-gradle.gitignore
      node.gitignore
      terraform.gitignore
  skills/
    audit/
    implement/
    reverify/
    triage/
    commit-standard/
    release-readiness/
    workstation-usage/
  prompts/
    audit/
    reverify/
    implementation/
  docs/
    workstation-spec.md
    command-reference.md
    rollout-plan.md
    dependency-map.md
  install/
    work.sh
```

---

## 14. Final Codex Implementation Boundary

When handing the final version to Codex, the task should be framed like this:

### Codex should implement
- workstation repository structure
- command scripts
- policy files
- install flow
- help/version/doctor support
- current policy-backed commands
- honest TODO / policy-gap behavior where governance artifacts are missing

### Codex should not invent
- missing root governance documents beyond requested scaffolds
- guessed CI workflow names
- guessed compatibility matrix contents
- guessed market ownership rules if not documented
- guessed release gates that are not yet formalized

### Codex should scaffold when needed
- release-related policy files
- compatibility policy hooks
- contract-change-check command body that points to the future root checklist if not yet present

---

## 15. Recommended Final Execution Order

### Step 1
Finish root governance dependencies:
- cross-repo contract-change checklist
- gitignore/generated-files standard
- compatibility matrix
- release-history page

### Step 2
Clean AGENTS and repo-local control-doc references across repos.

### Step 3
Implement the full workstation repo through Codex.

### Step 4
Confirm per-repo CI workflow/status-check mapping.

### Step 5
Enable release commands with strict `gh`-based checks.

### Step 6
Run a platform-wide re-audit to verify that workstation, governance docs, AGENTS, skills, and repo-local docs all align.

---

## 16. Final Readiness Verdict

The final version is definable now.

It is ready to be designed and handed to Codex in two possible ways:
- **pragmatic path**: implement workstation now, leave explicit policy gaps for the missing governance docs
- **fully finished path**: first add the missing root governance docs, then implement the workstation against that completed governance layer

The best-quality final version follows the fully finished path.

