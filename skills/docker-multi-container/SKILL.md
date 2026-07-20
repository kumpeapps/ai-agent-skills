---
name: docker-multi-container
description: Structures Docker Compose with separate frontend, backend, database, and optional auth containers. Use when dockerizing apps, writing Dockerfiles, Compose files, or designing local/dev stacks.
---

# Docker Multi-Container

## Rules

- **Separate containers** for frontend, backend, and database. Optional `auth` service.
- Do not ship a single container that runs both Angular and FastAPI process supervisors for production-like setups.
- Prefer newest stable base images; pin tags (and digests in prod when possible).
- Use Compose **profiles**: `dev`, `test` (see `testing-mariadb`).
- Healthchecks + dedicated networks; secrets via env/secret mounts—never bake secrets into images.

## Suggested Compose services

| Service | Role |
|---------|------|
| `frontend` | Angular (nginx or dev server) |
| `backend` | FastAPI / Uvicorn |
| `db` | App database (prod dialect as chosen) |
| `mariadb-test` | Test profile only |
| `auth` | `ghcr.io/kumpecloud/kumpecloud-auth` (optional, recommended for full-stack auth) |

## Sketch

```yaml
services:
  frontend:
    build: ./frontend
    profiles: ["dev"]
    ports: ["4200:80"]
    depends_on: [backend]
  backend:
    build: ./backend
    profiles: ["dev"]
    env_file: [.env]
    depends_on: [db]
  db:
    image: postgres:latest  # or chosen dialect; prefer current stable tag
    profiles: ["dev"]
    volumes: ["db_data:/var/lib/postgresql/data"]
  auth:
    image: ghcr.io/kumpecloud/kumpecloud-auth:latest
    profiles: ["dev"]
```

Replace `latest` with the newest stable pin after checking GHCR/Docker Hub (`dependency-versions`).

## Dockerfiles

- Multi-stage builds; non-root user; minimal final image.
- Backend: install into venv inside the image or use official Python slim + `uv`/`pip`.
- Frontend: build static assets in Node stage; serve with nginx.

## Prompt-like workflow

```
Dockerize this stack with separate frontend, backend, and db containers.
Add optional KumpeCloud Auth service. Use Compose profiles dev and test.
Healthchecks, env-based config, newest stable base images. No secrets in images.
```

## Related

- Prompt: [../../prompts/dockerize-stack.md](../../prompts/dockerize-stack.md)
- Skills: `testing-mariadb`, `devcontainer-venv`, `oidc-oauth-auth`, `dependency-versions`
