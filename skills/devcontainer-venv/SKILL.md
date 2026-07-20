---
name: devcontainer-venv
description: Prefers Dev Containers for development and Python venv as the minimum isolation. Use when setting up environments, .devcontainer, venv, or when dependencies must be installed.
---

# Dev Container and venv

## Policy

1. **Prefer Dev Container** (`.devcontainer/`) that composes or connects to the project's Docker services.
2. **Minimum**: Python **venv** (or `uv` project env) for backend work on the host.
3. **Never** install project dependencies with system Python or global `pip`/`npm` for app code.

## Dev Container sketch

```json
{
  "name": "app-dev",
  "dockerComposeFile": ["../docker-compose.yml"],
  "service": "backend",
  "workspaceFolder": "/workspace",
  "features": {},
  "customizations": {
    "vscode": {
      "extensions": ["ms-python.python", "ms-python.black-formatter", "angular.ng-template"]
    }
  },
  "postCreateCommand": "uv sync || pip install -e '.[dev]'"
}
```

Align Compose so frontend/backend/db/auth match `docker-multi-container`.

## Host venv fallback

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -U pip
pip install -e ".[dev]"
# or: uv sync
black . && ruff check .
```

Frontend: use the project Node version (`.nvmrc` / Volta / Dev Container Node feature)—newest stable LTS unless the repo pins otherwise.

## Agent behavior

- Before running Python tools, activate/use the project env or Dev Container.
- If no env exists, create a venv (or recommend opening in Dev Container) before installing.

## Prompt-like workflow

```
Set up development using a Dev Container if possible; otherwise a Python venv.
Do not use system Python. Install newest stable tooling (black, ruff, pytest) into the project env.
```

## Related

- Skills: `docker-multi-container`, `python-style`, `dependency-versions`, `python-fastapi`
