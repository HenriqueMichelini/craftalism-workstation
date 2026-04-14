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
  Depends on a future root checklist document at `$HOME/IdeaProjects/craftalism/docs/contract-change-checklist.md`.
- `work-tag`
  Depends on local repo/tag gates now, and on future `policy/ci.sh` plus `policy/release.sh` completion for real release enforcement.
- `work-release-check`
  Depends on local docs and verify state now, and on future release-policy completion for stronger gating.
- `work-platform-status`
  Depends on local repo presence under `~/IdeaProjects`; release-readiness details remain blocked on future governance mapping.
