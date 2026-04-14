# Rollout Plan

## Implemented Now

- Managed repo policy mapping for repo role, scope, deployability, taggability, and ownership mode.
- Shared contract ownership and consumption policy.
- Governance-aware reading order rooted at `$HOME/IdeaProjects/craftalism/docs`.
- Repo-required docs checks.
- Commit validation and staged-file blocking through centralized policy.
- Automated verification runners for repos with defined commands.
- Local verification proof storage outside managed repos.
- Operator commands for status, context, ownership checks, docs, audit packs, checklists, verification, help, version, and doctor checks.
- Short governance-aligned skills and prompts.

## Intentionally Scaffolded

- Contract change checks print the real root checklist when present.
- Tagging checks now print a structured tagged-release decision with concrete local gates, mapped workflow status, and blocking reasons.
- Release checks now print the same structured readiness posture without needing a candidate tag.
- Platform status reports local repo state plus mapped CI workflow status and root release-governance document presence without claiming release readiness.

## Remaining Governance Dependencies

- Root contract change checklist document.
- CI workflow names and required status checks for release gating.
- Compatibility policy contents and mappings.
- Any additional release policy inputs beyond local docs and local verification proof.
- Future explicit automation for `craftalism` and `craftalism-deployment` verification, if governance later defines it.
