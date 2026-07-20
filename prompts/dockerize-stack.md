---
title: Dockerize stack
use_when: Containerizing frontend, backend, database, and optional auth
related_skills:
  - docker-multi-container
  - testing-mariadb
  - devcontainer-venv
  - oidc-oauth-auth
  - dependency-versions
---

# Prompt: Dockerize stack

Copy everything below the line into chat.

---

Dockerize this project with **separate containers** for frontend, backend, and database.

Also include:
- Compose profiles `dev` and `test`
- `mariadb-test` on the `test` profile for integration tests
- Optional `auth` service using `ghcr.io/kumpecloud/kumpecloud-auth` (newest stable tag)
- Healthchecks, networks, env-based config (no secrets in images)
- Multi-stage Dockerfiles; non-root where practical
- Prefer Dev Container that attaches to this Compose stack

Use newest stable base images and pin tags after checking current stables.
