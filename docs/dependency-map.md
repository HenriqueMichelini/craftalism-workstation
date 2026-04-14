# Dependency Map

## Command to Policy Dependencies

- `work-status`
  Depends on `policy/repos.sh`, `policy/docs.sh`, and `policy/verify.sh`.
- `work-context`
  Depends on `policy/repos.sh`, `policy/contracts.sh`, and `policy/verify.sh`.
- `work-ownership-check`
  Depends on `policy/contracts.sh`.
- `work-docs`
  Depends on `policy/reading-order.sh`.
- `work-audit-pack`
  Depends on `policy/repos.sh`, `policy/contracts.sh`, `policy/verify.sh`, and `policy/reading-order.sh`.
- `work-checklist`
  Depends on `policy/contracts.sh` and `policy/verify.sh`.
- `work-commit`
  Depends on `policy/commit.sh`, `policy/docs.sh`, and `policy/generated-files.sh`.
- `work-verify`
  Depends on `policy/verify.sh`.
- `work-doctor`
  Depends on install environment and optional `gh`.

## Release-Oriented Dependencies

- `work-contract-change-check`
  Depends on `$HOME/IdeaProjects/craftalism/docs/standards/contract-change-checklist.md`.
- `work-tag`
  Depends on local repo/tag gates now, uses the root compatibility matrix and CI standard for context, consults mapped repo workflow files, and still depends on future branch-protection and required-check policy for real release enforcement.
- `work-release-check`
  Depends on local docs, verify state, mapped repo workflow files, the root compatibility matrix, the root CI standard, the root contract change checklist, and the latest release-readiness audit; it still depends on future branch-protection and required-check policy for stronger gating.
- `work-platform-status`
  Depends on local repo presence under `~/IdeaProjects`, mapped repo workflow files, and root release-governance documents; strong release-readiness details remain blocked on future governance mapping.
