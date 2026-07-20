---
name: python-style
description: Enforces PEP8, black formatting, ruff lint, and typing for Python. Use when writing or formatting Python, editing pyproject.toml, fixing lint, or when the user mentions black, ruff, PEP8, or type hints.
---

# Python Style (PEP8 + black)

## Required tooling

- **Formatter**: black (newest stable)
- **Linter**: ruff (PEP8-aligned; prefer over flake8 when adding tooling)
- **Types**: type hints on public functions, methods, and Pydantic/SQLAlchemy-facing APIs; run mypy or pyright when the project already uses them

Never commit unformatted Python. After edits, run black (and ruff) in the project venv or Dev Container.

## pyproject.toml baseline

```toml
[tool.black]
line-length = 88
target-version = ["py312"]

[tool.ruff]
line-length = 88
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM"]
```

Adjust `target-version` to the project's newest supported CPython.

## Conventions

- 4-space indent; snake_case functions/modules; PascalCase classes.
- Imports sorted (ruff `I`); no unused imports.
- Prefer explicit `Optional`/`X | None` per project Python version.
- Docstrings for non-obvious public APIs; keep them concise.
- No `# noqa` unless justified in a comment.

## Workflow

1. Implement under TDD (`tdd-workflow`).
2. Run `black` on touched paths.
3. Run `ruff check` (and `--fix` when safe).
4. Fix type errors before calling the task done.

## Prompt-like workflow

```
Format and lint all Python you touch with black and ruff (PEP8).
Add type hints on public APIs. Do not use system Python—use the project venv or Dev Container.
```

## Related

- Skills: `tdd-workflow`, `python-fastapi`, `devcontainer-venv`, `dependency-versions`
