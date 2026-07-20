---
name: code-review
description: Reviews code against TDD, DRY, SOLID, PEP8/black, stack defaults, Docker separation, and OIDC auth abstraction. Use when reviewing PRs, diffs, or when the user asks for a code review or quality check.
---

# Code Review

## Severity

- **Critical** — Must fix before merge (security, broken TDD, data loss, secrets).
- **Suggestion** — Should improve (SOLID/DRY, clarity, missing edge tests).
- **Nice to have** — Optional polish.

## Checklist

### Process and tests

- [ ] Evidence of failing test before implementation (or clear waiver)
- [ ] Tests cover happy path and meaningful edge cases
- [ ] Integration tests use MariaDB in Docker when DB is involved

### Design

- [ ] DRY: no unjustified duplication
- [ ] SOLID: clear boundaries; DI for infra; auth behind adapter
- [ ] Frontend/backend responsibilities not mixed

### Python

- [ ] black-formatted; ruff/PEP8 clean
- [ ] Type hints on public APIs
- [ ] FastAPI routers thin; services testable

### Angular

- [ ] Standalone/signals patterns match project norms
- [ ] No client secrets in the SPA
- [ ] Tests updated for behavior changes

### Ops and auth

- [ ] Separate containers for frontend/backend/db (and auth if present)
- [ ] Newest stable deps where this change introduces packages
- [ ] OIDC config is provider-agnostic; KumpeCloud Auth remains a valid default
- [ ] No secrets committed

## Output format

```markdown
## Review summary
[1–2 sentence verdict]

## Findings
- **Critical**: ...
- **Suggestion**: ...
- **Nice to have**: ...

## Standards gaps
- TDD / DRY / SOLID / PEP8-black / Docker / Auth: [pass or gaps]
```

## Prompt-like workflow

```
Review this diff against ai-agent-skills standards:
TDD, DRY, SOLID, PEP8/black, Angular+FastAPI+SQLAlchemy, Docker multi-container,
MariaDB for integration tests, KumpeCloud Auth-first OIDC with provider swap ability.
Use Critical / Suggestion / Nice to have.
```

## Related

- Prompt: [../../prompts/code-review.md](../../prompts/code-review.md)
- Skills: `tdd-workflow`, `solid-dry`, `python-style`, `oidc-oauth-auth`
