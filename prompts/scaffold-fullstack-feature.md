---
title: Scaffold fullstack feature
use_when: Starting a new end-to-end feature across Angular and FastAPI
related_skills:
  - tdd-workflow
  - python-fastapi
  - angular-frontend
  - sqlalchemy-db
  - oidc-oauth-auth
---

# Prompt: Scaffold fullstack feature

Copy everything below the line into chat.

---

Scaffold fullstack feature **`<FEATURE_NAME>`**.

Standards (non-negotiable):
- Strict TDD: failing tests first (pytest + Angular specs), red → green → refactor
- DRY and SOLID
- Python: PEP8 + black + ruff; type hints
- Newest stable Angular, FastAPI, SQLAlchemy 2.x
- Dev Container or venv only (no system Python)

Stack:
- Frontend: Angular standalone + signals, lazy route
- Backend: FastAPI router + service + Pydantic v2 schemas
- DB: SQLAlchemy 2.x dialect-agnostic model + Alembic if persistence is needed
- Integration tests: MariaDB in Docker (Compose profile `test`)
- Auth: if required, KumpeCloud Auth OIDC default behind provider-agnostic config

Deliver:
1. Failing tests (API + UI as applicable)
2. Minimal implementation
3. Compose/env notes if new services are needed
4. Short summary of files touched
