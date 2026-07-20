---
title: TDD implement endpoint
use_when: Adding or changing a FastAPI endpoint with test-first discipline
related_skills:
  - tdd-workflow
  - python-fastapi
  - python-style
  - testing-mariadb
---

# Prompt: TDD implement endpoint

Copy everything below the line into chat.

---

Implement FastAPI endpoint **`<METHOD> <PATH>`** for **`<BEHAVIOR>`**.

Process:
1. Write a failing pytest (API level) that defines success criteria
2. Show the red failure
3. Implement minimum code (schema → service → router → DI)
4. Refactor; keep tests green
5. Run black and ruff on touched files

Constraints:
- Pydantic v2; thin routers; SQLAlchemy only if persistence is required
- Integration persistence tests use MariaDB in Docker
- Newest stable FastAPI stack; venv or Dev Container only
- If authenticated: JWKS JWT validation via provider-agnostic OIDC settings (KumpeCloud Auth default)
