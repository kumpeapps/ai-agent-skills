---
name: python-fastapi
description: Builds and extends FastAPI backends with Pydantic v2, DI, routers, and TDD. Use when creating APIs, FastAPI apps, endpoints, dependencies, or Python backend services.
---

# Python FastAPI

## Defaults

- Newest stable FastAPI, Uvicorn, Pydantic v2, SQLAlchemy 2.x.
- Run in Dev Container or project venv only.
- Strict TDD (`tdd-workflow`); format with black (`python-style`).

## Suggested layout

```
backend/
  app/
    main.py
    api/routers/
    core/          # config, security
    db/            # session, engine
    models/        # SQLAlchemy
    schemas/       # Pydantic
    services/
  tests/
  alembic/
  pyproject.toml
  Dockerfile
```

## Patterns

- **Routers**: HTTP only; validate with Pydantic; call services.
- **Services**: business rules; accept repository/session via DI.
- **Config**: `pydantic-settings`; never hard-code secrets.
- **Errors**: map domain errors to consistent HTTP exceptions.
- **Lifespan**: create engine/pool on startup; dispose on shutdown.
- **Auth**: JWT via JWKS in `core/security`; `Depends(require_user)` — see `oidc-oauth-auth`.

## Minimal app sketch

```python
from fastapi import FastAPI
from app.api.routers import items
from app.core.config import settings

app = FastAPI(title=settings.app_name)
app.include_router(items.router, prefix="/api")
```

## TDD for an endpoint

1. Write API test expecting status + body.
2. Confirm red.
3. Add schema, service, router, wire DI.
4. Green → refactor; run black/ruff.

## Prompt-like workflow

```
Add FastAPI endpoint <METHOD> <PATH> for <BEHAVIOR>.
TDD first (pytest). Use Pydantic v2 schemas, service layer, SQLAlchemy if persistence is needed.
black + ruff clean. Newest stable deps. Provider-agnostic OIDC if auth is required.
```

## Related

- Prompts: [../../prompts/tdd-implement-endpoint.md](../../prompts/tdd-implement-endpoint.md), [../../prompts/scaffold-fullstack-feature.md](../../prompts/scaffold-fullstack-feature.md)
- Skills: `tdd-workflow`, `python-style`, `sqlalchemy-db`, `oidc-oauth-auth`, `testing-mariadb`
