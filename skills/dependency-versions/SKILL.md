---
name: dependency-versions
description: Prefers newest stable versions of frameworks, plugins, and base images with lockfile pinning. Use when scaffolding projects, adding dependencies, upgrading packages, choosing Docker base images, or when the user mentions versions, upgrades, or latest releases.
---

# Dependency Versions

## Policy

1. Prefer the **newest stable** release of libraries, CLIs, and base images (not pre-releases unless the user asks).
2. Before scaffolding or adding a dependency, check current stable (PyPI, npm, Docker Hub/GHCR, Angular releases).
3. **Pin** versions in lockfiles (`uv.lock`, `poetry.lock`, `package-lock.json` / `pnpm-lock.yaml`, Compose image tags or digests).
4. Avoid unbounded ranges like `*` in application lockfiles; use compatible ranges only where the project's package manager expects them, then lock.

## Stack defaults (always resolve "newest stable" at time of work)

| Area | Package / image family |
|------|-------------------------|
| Backend | `fastapi`, `uvicorn`, `pydantic`, `sqlalchemy`, `alembic`, `httpx`, `pytest` |
| Frontend | `@angular/*` (CLI + current stable) |
| Auth | KumpeCloud Auth image `ghcr.io/kumpecloud/kumpecloud-auth` (newest stable tag) |
| Test DB | Official `mariadb` image, current stable |

## Upgrade workflow

1. Read current pins/lockfile.
2. Look up newest stable.
3. Upgrade in a branch; run the full test suite (TDD suite must stay green).
4. Note breaking changes; adapt code behind abstractions (especially auth and DB dialects).

## Prompt-like workflow

```
Add/upgrade <PACKAGE> to the newest stable release.
Update the lockfile, run tests, and fix breakages.
Prefer Dev Container or venv; do not use system package managers for project libs.
```

## Related

- Prompt: [../../prompts/bump-dependencies.md](../../prompts/bump-dependencies.md)
- Skills: `devcontainer-venv`, `docker-multi-container`, `python-fastapi`, `angular-frontend`
