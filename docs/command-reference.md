# Command Reference

## Setup

Source the install script:

```bash
source "$HOME/IdeaProjects/craftalism-workstation/install/work.sh"
```

## Core Commands

- `work-status`
  Prints repo identity, branch/head, tree state, docs state, verify state, deployability, and taggability.
- `work-context`
  Prints repo role, ownership mode, owned contracts, consumed contracts, critical rules, and verification mode.
- `work-ownership-check`
  Prints a concise ownership boundary statement and when work should move to another repo.
- `work-docs`
  Prints the governance-aware reading order for the current repo.
- `work-audit-pack`
  Prints a Codex-ready audit pack with governance precedence, reading order, ownership, and verification context.
- `work-checklist`
  Prints implementation, reverification, contract, and verification reminders.
- `work-commit "<type>(<scope>): <summary>"`
  Validates message format, requires control docs, stages changes, blocks unsafe artifacts, commits, and pushes `main`.
- `work-verify`
  Runs local verification for automated repos and stores proof under `~/.workstation/state/verify/<repo>/<sha>.ok`.
- `work-doctor`
  Checks install environment, optional `gh` status, state directory, and current repo detection.

## Scaffold Commands

- `work-contract-change-check`
  Prints the real root contract change checklist from `craftalism/docs/standards/contract-change-checklist.md` when present.
- `work-tag v1.2.3`
  Enforces local tag gates, reports compatibility/CI document presence, then stops on unmapped CI and release policy gaps.
- `work-release-check`
  Checks docs, local verify proof, root release documents, mapped CI workflow presence, and latest release audit status, then reports missing release policy inputs.
- `work-platform-status`
  Scans known repos under `~/IdeaProjects`, prints basic local git state plus mapped CI workflow status, and summarizes root release-governance document presence.

## Examples

```bash
work-status
work-context
work-docs
work-commit "fix(api): reject duplicate transfer retries"
work-verify
work-tag v0.1.0
```
