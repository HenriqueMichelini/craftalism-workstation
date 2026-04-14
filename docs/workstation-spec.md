# Craftalism Workstation Spec

## Purpose

`craftalism-workstation` provides governance-aware local operator commands for the Craftalism platform. It centralizes policy lookup, repo ownership context, local verification handling, and release-readiness scaffolding without inventing missing platform governance.

## Command Set

Implemented now:

- `work-status`
- `work-context`
- `work-ownership-check`
- `work-docs`
- `work-audit-pack`
- `work-checklist`
- `work-commit`
- `work-verify`
- `work-help`
- `work-version`
- `work-doctor`

Scaffolded with explicit policy-gap behavior:

- `work-contract-change-check`
- `work-tag`
- `work-release-check`
- `work-platform-status`

## Policy Model

The workstation separates policy from command logic.

- `policy/repos.sh` maps managed repositories, scopes, deployability, and taggability.
- `policy/contracts.sh` holds owned and consumed contract policy plus concise repo boundary rules.
- `policy/commit.sh` enforces the shared commit standard.
- `policy/verify.sh` maps automated verification commands and manual-policy-gap repos.
- `policy/docs.sh` defines required repo-local governance control docs.
- `policy/generated-files.sh` defines blocked staged-file patterns and safe exceptions.
- `policy/reading-order.sh` defines the required governance reading order.
- `policy/release.sh`, `policy/ci.sh`, and `policy/compatibility.sh` are intentionally honest scaffolds for incomplete release governance.
- `policy/ci.sh` now maps known repo workflow files so release-oriented commands can report concrete local CI coverage without inventing branch-protection or required-check policy.

## Governance Alignment

The workstation uses the required precedence order:

1. shared contracts
2. shared standards
3. system summary
4. repo-local `docs/repo-contract-map.md`
5. repo-local `docs/repo-requirement-pack.md`
6. point-in-time audit artifacts

Commands that expose context surface whether the current repository owns or consumes behavior before presenting contract information. Consumer repos are not allowed to redefine shared contracts locally.

The reading order starts at the root governance docs under `$HOME/IdeaProjects/craftalism/docs/...` and then moves into repo-local control docs for non-root repos.

## Known Policy Gaps

- CI workflow mappings and required status-check names are not configured.
- Some workflow files are now mapped, but branch protection and required-check enforcement still cannot be derived locally.
- The compatibility matrix exists, but the workstation does not infer release approval from its contents beyond basic presence and repo listing checks.
- Release policy inputs beyond local docs and local verify proof are not yet defined.
- `craftalism` and `craftalism-deployment` intentionally report manual verification gaps instead of pretending automation exists.
