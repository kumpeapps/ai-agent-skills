# Agent Contract

This repository (or a consumer that imports it) enforces the following standards on every task. Do not bypass them unless the user explicitly overrides a rule for that turn.

## Non-negotiable standards

1. **TDD** — Write a failing test first. Do not write production code without a failing test that justifies it. Follow red → green → refactor.
2. **DRY** — Do not duplicate logic, types, or configuration. Extract shared behavior only when duplication is real (not speculative).
3. **SOLID** — Prefer small, single-purpose modules; depend on abstractions; keep interfaces focused; favor composition and open extension points.
4. **PEP8 + black** — Python must pass black formatting and ruff/PEP8 lint. Use type hints on public functions and models.
5. **Newest stable versions** — Prefer the newest stable release of frameworks, plugins, and base images. Pin versions in lockfiles.
6. **Isolated environments** — Prefer a Dev Container. Otherwise use a Python venv. Never install or run against system Python for project work.

## Default stack

| Layer | Choice |
|-------|--------|
| Frontend | Angular (newest stable), standalone components, signals |
| Backend | FastAPI (newest stable), Pydantic v2 |
| Data access | SQLAlchemy 2.x, dialect-agnostic models; Alembic for migrations |
| Containers | Docker Compose with **separate** containers (frontend, backend, db, optional auth) |
| Integration tests | MariaDB in a Docker container (Compose `test` profile) |
| Auth | **KumpeCloud Auth** (Logto fork) OIDC by default; design behind a provider-agnostic OIDC/OAuth abstraction |

## Auth expectations

- Default IdP: KumpeCloud Auth (`ghcr.io/kumpecloud/kumpecloud-auth`), Logto-compatible APIs and environment variables.
- Applications must configure issuer, client id/secret, scopes, and redirect URIs via a shared config interface so any OIDC or OAuth 2.x provider can be swapped.
- FastAPI: validate JWTs via JWKS; protect routes with dependencies.
- Angular: authorization code + PKCE; attach Bearer tokens via interceptors.

## Skills and prompts

Project skills are wired by `install.sh` into the paths each IDE/agent expects (Cursor `.cursor/skills`, Claude `.claude/skills`, Copilot `.github/skills`, etc.). Reusable prompt templates live under `prompts/` in the skills package—reference them with `@` or paste into chat.

When implementing features, prefer the matching skill workflow (especially `tdd-workflow`, stack skills, and `oidc-oauth-auth`).

## Definition of done

- Failing test existed before implementation; tests pass after.
- Code is formatted (black for Python) and lint-clean.
- No unjustified duplication; SOLID boundaries respected.
- Docker services remain separate containers; test DB is MariaDB in Docker when integration tests are involved.
- Auth remains provider-swappable with KumpeCloud Auth as the documented default.
